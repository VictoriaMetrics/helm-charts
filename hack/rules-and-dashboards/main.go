package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	vmalert "github.com/VictoriaMetrics/VictoriaMetrics/app/vmalert/config"
	"github.com/VictoriaMetrics/metricsql"
	"github.com/google/go-jsonnet"
	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/cog/plugins"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
	"github.com/grafana/grafana-foundation-sdk/go/datasource"
	"github.com/grafana/grafana-foundation-sdk/go/prometheus"
	"gopkg.in/yaml.v2"
)

var chartsDir = flag.String("charts.dir", "../../charts", "path to charts dir")

type remoteImporter struct{}

var jsonnetContent = make(map[string]jsonnet.Contents)

func targetDir(charts, chart, targetType string) string {
	return filepath.Join(
		charts,
		chart,
		"files",
		targetType,
		"generated",
	)
}

var headers = map[string]string{
	"dashboards": `
{{- $Values := (.helm).Values | default .Values }}
{{- $multicluster := ((($Values.grafana).sidecar).dashboards).multicluster | default false }}
{{- $defaultDatasource := "prometheus" -}}
{{- range (((($Values.grafana).sidecar).datasources).victoriametrics | default list) }}
  {{- if and .isDefault .type }}{{ $defaultDatasource = .type }}{{- end }}
{{- end }}
`,
	"rules": `
{{- $Values := (.helm).Values | default .Values }}
{{- $runbookUrl := ($Values.defaultRules).runbookUrl | default "https://runbooks.prometheus-operator.dev/runbooks" }}
{{- $additionalGroupByLabels := append $Values.defaultRules.additionalGroupByLabels "cluster" }}
{{- $groupLabels := join "," (uniq $additionalGroupByLabels) }}
{{- $grafanaAddr := include "vm-k8s-stack.grafana.addr" . }}
`,
}

// Rules map
var rulesMap = map[string]string{
	"alertmanager.rules":                   "($Values.alertmanager).enabled",
	"etcd":                                 "($Values.kubeEtcd).enabled",
	"kube-apiserver-availability.rules":    "($Values.kubeApiServer).enabled",
	"kube-apiserver-burnrate.rules":        "($Values.kubeApiServer).enabled",
	"kube-apiserver-histogram.rules":       "($Values.kubeApiServer).enabled",
	"kube-apiserver-slos":                  "($Values.kubeApiServer).enabled",
	"kube-apiserver.rules":                 "($Values.kubeApiServer).enabled",
	"kube-scheduler.rules":                 "($Values.kubeScheduler).enabled",
	"kubelet.rules":                        "($Values.kubelet).enabled",
	"kubernetes-system-controller-manager": "($Values.kubeControllerManager).enabled",
	"kubernetes-system-scheduler":          "($Values.kubeScheduler).enabled",
}

// Alerts map
var alertsMap = map[string]string{
	"KubeAPIDown":               "($Values.kubeApiServer).enabled",
	"KubeControllerManagerDown": "($Values.kubeControllerManager).enabled",
	"KubeSchedulerDown":         "($Values.kubeScheduler).enabled",
	"KubeStateMetricsDown":      `(index $Values "kube-state-metrics" "enabled")`,
	"KubeletDown":               "($Values.kubelet).enabled",
	"PrometheusOperatorDown":    "($Values.prometheusOperator).enabled",
	"NodeExporterDown":          "($Values.nodeExporter).enabled",
	"CoreDNSDown":               "($Values.kubeDns).enabled",
	"AlertmanagerDown":          "($Values.alertmanager).enabled",
	"KubeProxyDown":             "($Values.kubeProxy).enabled",
}

// Dashboards map
var dashboardsMap = map[string]string{
	"vector-k8s-monitoring":         "",
	"victorialogs-single-node":      "($Values.vlogs).enabled",
	"alertmanager-overview":         "($Values.alertmanager).enabled",
	"kubernetes-system-api-server":  "($Values.kubeApiServer).enabled",
	"kubernetes-controller-manager": "($Values.kubeControllerManager).enabled",
	"etcd":                          "($Values.kubeEtcd).enabled",
	"grafana-overview":              "($Values.grafana).enabled",
	"kubernetes-kubelet":            "($Values.kubelet).enabled",
	"kubernetes-system-coredns":     "($Values.coreDns).enabled",
	"kubernetes-views-global":       "($Values.kubelet).enabled",
	"kubernetes-views-namespaces":   "($Values.kubelet).enabled",
	"kubernetes-views-nodes":        "($Values.kubelet).enabled",
	"kubernetes-views-pods":         "($Values.kubelet).enabled",
	"node-cluster-rsrc-use":         `(index $Values "prometheus-node-exporter" "enabled")`,
	"node-exporter-full":            "false",
	"node-rsrc-use":                 `(index $Values "prometheus-node-exporter" "enabled")`,
	"kubernetes-proxy":              "$Values.kubeProxy.enabled",
	"kubernetes-scheduler":          "$Values.kubeScheduler.enabled",
	"victoriametrics-backupmanager": "or (not (empty (((($Values).vmsingle).spec).vmBackup).destination)) (not (empty ((((($Values).vmcluster).spec).storage).vmBackup).destination))",
	"victoriametrics-cluster":       "($Values.vmcluster).enabled",
	"victoriametrics-operator":      `(index $Values "victoria-metrics-operator" "enabled")`,
	"victoriametrics-single-node":   "($Values.vmsingle).enabled",
	"victoriametrics-vmalert":       "($Values.vmalert).enabled",
	"victoriametrics-vmagent":       "($Values.vmagent).enabled",
}

var dashboardClusterMetric = map[string]string{
	"victoriametrics-backupmanager": "vm_app_version",
	"victoriametrics-cluster":       "vm_app_version",
	"victoriametrics-operator":      "vm_app_version",
	"victoriametrics-single-node":   "vm_app_version",
	"victoriametrics-vmalert":       "vm_app_version",
	"victoriametrics-vmagent":       "vm_app_version",
	"victorialogs-single-node":      "vm_app_version",
	"grafana-overview":              "grafana_build_info",
	"alertmanager-overview":         "alertmanager_alerts",
	"node-exporter-full":            "node_uname_info",
}

func (i *remoteImporter) Import(importedFrom, path string) (jsonnet.Contents, string, error) {
	iu, err := url.Parse(importedFrom)
	if err != nil {
		return jsonnet.Contents{}, "", fmt.Errorf("failed to parse import from: %w", err)
	}
	if strings.HasPrefix(path, "github.com") {
		path = "https://" + path
	}
	pu, err := url.Parse(path)
	if err != nil {
		return jsonnet.Contents{}, "", fmt.Errorf("failed to parse path: %w", err)
	}
	u := pu
	if !u.IsAbs() {
		u = iu.ResolveReference(pu)
	}
	src := u.String()
	if u.Host == "github.com" {
		parts := strings.SplitN(u.Path, "/", 4)
		repoOrg, repoName, repoPath := parts[1], parts[2], parts[3]
		repoSlug := fmt.Sprintf("%s/%s", repoOrg, repoName)
		apiUrl := fmt.Sprintf("https://api.github.com/repos/%s", repoSlug)
		resp, err := http.Get(apiUrl)
		if err != nil {
			return jsonnet.Contents{}, "", fmt.Errorf("failed to get repo status: %w", err)
		}
		defer resp.Body.Close()
		if resp.StatusCode != http.StatusOK {
			return jsonnet.Contents{}, "", fmt.Errorf("failed to get repo status, HTTP status: %d != 200", resp.StatusCode)
		}
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			return jsonnet.Contents{}, "", fmt.Errorf("error reading response body: %w", err)
		}
		var repoStatus struct {
			DefaultBranch string `json:"default_branch"`
		}
		if err = json.Unmarshal(body, &repoStatus); err != nil {
			return jsonnet.Contents{}, "", fmt.Errorf(" error unmarshalling repo status: %w", err)
		}
		src = fmt.Sprintf("https://raw.githubusercontent.com/%s/%s/%s", repoSlug, repoStatus.DefaultBranch, repoPath)
	}
	if c, ok := jsonnetContent[src]; ok {
		return c, src, nil
	}
	if strings.HasPrefix(src, "http://") || strings.HasPrefix(src, "https://") {
		resp, err := http.Get(src)
		if err != nil {
			return jsonnet.Contents{}, "", fmt.Errorf("failed to fetch remote import: %w", err)
		}
		defer resp.Body.Close()
		if resp.StatusCode != http.StatusOK {
			return jsonnet.Contents{}, "", fmt.Errorf("remote import of %q returned non-OK status: %d", src, resp.StatusCode)
		}
		contentBytes, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			return jsonnet.Contents{}, "", fmt.Errorf("failed to read remote import content: %w", err)
		}
		c := jsonnet.MakeContents(string(contentBytes))
		jsonnetContent[src] = c
		return c, src, nil
	} else {
		contentBytes, err := os.ReadFile(src)
		if err != nil {
			return jsonnet.MakeContents(""), "", fmt.Errorf("failed to read local import: %w", err)
		}
		c := jsonnet.MakeContents(string(contentBytes))
		jsonnetContent[src] = c
		return c, src, nil
	}

}

type source struct {
	url    string
	kind   string
	charts []string
}

var sources = []source{
	{
		url:  "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/victoriametrics.json",
		kind: "dashboards",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/vmagent.json",
		kind: "dashboards",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/victoriametrics-cluster.json",
		kind: "dashboards",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/vmalert.json",
		kind: "dashboards",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/operator.json",
		kind: "dashboards",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaLogs/master/dashboards/victorialogs.json",
		kind: "dashboards",
		charts: []string{
			"victoria-logs-single",
		},
	},
	{
		url:  "./dashboards/vector.json",
		kind: "dashboards",
		charts: []string{
			"victoria-logs-single",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-system-coredns.json",
		kind: "dashboards",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-global.json",
		kind: "dashboards",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-namespaces.json",
		kind: "dashboards",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-pods.json",
		kind: "dashboards",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-system-api-server.json",
		kind: "dashboards",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/dotdc/grafana-dashboards-kubernetes/master/dashboards/k8s-views-nodes.json",
		kind: "dashboards",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/dashboards/backupmanager.json",
		kind: "dashboards",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/grafana-dashboardDefinitions.yaml",
		kind: "dashboards",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/etcd-io/etcd/main/contrib/mixin/mixin.libsonnet",
		kind: "dashboards",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/rfmoz/grafana-dashboards/refs/heads/master/prometheus/node-exporter-full.json",
		kind: "dashboards",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/alertmanager-prometheusRule.yaml",
		kind: "rules",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/kubernetesControlPlane-prometheusRule.yaml",
		kind: "rules",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/kubePrometheus-prometheusRule.yaml",
		kind: "rules",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/kubeStateMetrics-prometheusRule.yaml",
		kind: "rules",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/nodeExporter-prometheusRule.yaml",
		kind: "rules",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/rules/alerts-cluster.yml",
		kind: "rules",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/rules/alerts-health.yml",
		kind: "rules",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/rules/alerts-vmagent.yml",
		kind: "rules",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/deployment/docker/rules/alerts.yml",
		kind: "rules",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/VictoriaMetrics/operator/master/config/alerting/vmoperator-rules.yaml",
		kind: "rules",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
	{
		url:  "https://raw.githubusercontent.com/etcd-io/etcd/main/contrib/mixin/mixin.libsonnet",
		kind: "rules",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
}

type ruleCRDSpec struct {
	Groups []vmalert.Group `yaml:"groups"`
}

type ruleCRD struct {
	Spec ruleCRDSpec `yaml:"spec"`
}

type unsafeTemplating struct {
	List []map[string]any `yaml:"list" json:"list"`
	XXX  map[string]any   `yaml:",inline" json:",inline"`
}

type unsafeDashboard struct {
	Templating unsafeTemplating `yaml:"templating" json:"templating"`
	XXX        map[string]any   `yaml:",inline" json:",inline"`
}

type dashboardCRDItem struct {
	Data map[string]string `yaml:"data"`
}

type dashboardCRD struct {
	Items []dashboardCRDItem `yaml:"items"`
}

var re = regexp.MustCompile("[ /-]+")

func main() {
	// Required to correctly unmarshal panels and dataqueries
	plugins.RegisterDefaultPlugins()
	vm := jsonnet.MakeVM()
	vm.Importer(&remoteImporter{})

	var raw []byte

	for _, src := range sources {
		log.Printf("generating %s from %q", src.kind, src.url)
		if strings.HasPrefix(src.url, "http://") || strings.HasPrefix(src.url, "https://") {
			resp, err := http.Get(src.url)
			if err != nil {
				log.Printf("skipping the file: %s", err)
				continue
			}
			defer resp.Body.Close()
			if resp.StatusCode != http.StatusOK {
				log.Printf("skipping the file, response code {response.status_code} not equals 200")
				continue
			}
			raw, err = ioutil.ReadAll(resp.Body)
			if err != nil {
				log.Printf("error reading response body: %s", err)
				continue
			}
		} else {
			content, err := os.ReadFile(src.url)
			if err != nil {
				log.Printf("error reading file: %s", err)
				continue
			}
			raw = content
		}

		resources, err := collectResources(vm, raw, &src)
		if err != nil {
			log.Printf("failed to collect resources: %s", err)
			continue
		}

		for n, data := range resources {
			if err := toFile(n, data, &src); err != nil {
				log.Printf("failed to create %s: %s", src.kind, err)
			}
		}
	}
}

func collectResources(vm *jsonnet.VM, raw []byte, src *source) (map[string][]byte, error) {
	switch src.kind {
	case "dashboards":
		return collectDashboards(vm, raw, src)
	case "rules":
		return collectRules(vm, raw, src)
	default:
		return nil, fmt.Errorf("unsupported source kind %q", src.kind)
	}
}

func collectRules(vm *jsonnet.VM, raw []byte, src *source) (map[string][]byte, error) {
	groups := make(map[string]*vmalert.Group)
	ext := filepath.Ext(src.url)
	switch ext {
	case ".yml", ".yaml":
		var rr ruleCRD
		if err := yaml.Unmarshal(raw, &rr); err != nil {
			return nil, fmt.Errorf("failed to unmarshal yaml %s CRD: %w", src.kind, err)
		}
		if len(rr.Spec.Groups) == 0 {
			if err := yaml.Unmarshal(raw, &rr.Spec); err != nil {
				return nil, fmt.Errorf("failed to unmarshal yaml %s CRD: %w", src.kind, err)
			}
		}
		for _, g := range rr.Spec.Groups {
			groups[g.Name] = &g
		}
	case ".libsonnet":
		ds, err := vm.EvaluateSnippetMulti(src.url, `{ [group.name]: group for group in (`+string(raw)+`).prometheusAlerts.groups }`)
		if err != nil {
			return nil, fmt.Errorf("failed to evaluate jsonnet: %w", err)
		}
		for n, d := range ds {
			k := filepath.Base(n)
			n = strings.TrimSuffix(k, ext)
			var g vmalert.Group
			err := json.Unmarshal([]byte(d), &g)
			if err != nil {
				return nil, fmt.Errorf("failed to unmarshal rule: %w", err)
			}
			groups[n] = &g
		}
	default:
		return nil, fmt.Errorf("%s file extension %q is not supported", src.kind, ext)
	}
	resources := make(map[string][]byte)
	for n, g := range groups {
		for i := range g.Rules {
			r := &g.Rules[i]
			for ak, av := range r.Annotations {
				switch {
				case strings.HasPrefix(av, "https://runbooks.prometheus-operator.dev/runbooks"):
					r.Annotations[ak] = strings.ReplaceAll(av, "https://runbooks.prometheus-operator.dev/runbooks", "[[ $runbookUrl ]]")
				case strings.HasPrefix(av, "http://localhost:3000"):
					r.Annotations[ak] = strings.ReplaceAll(av, "http://localhost:3000", "[[ $grafanaAddr ]]")
				}
			}
			r.Expr = patchExpr(r.Expr, g.Name, "rules")
			condition := "[[ true ]]"
			if c, ok := alertsMap[r.Name()]; ok {
				condition = fmt.Sprintf("[[ %s ]]", c)
			}
			r.XXX = map[string]any{
				"condition": condition,
			}
		}
		condition := "[[ true ]]"
		if c, ok := rulesMap[n]; ok && len(c) > 0 {
			condition = fmt.Sprintf("[[ %s ]]", c)
		}
		g.XXX = map[string]any{
			"condition": condition,
		}
		data, err := yaml.Marshal(g)
		if err != nil {
			return nil, fmt.Errorf("failed to marshal rule: %w", err)
		}
		resources[n] = escape(data)
	}
	return resources, nil
}

func collectDashboards(vm *jsonnet.VM, raw []byte, src *source) (map[string][]byte, error) {
	rawResources := make(map[string][]byte)
	ext := filepath.Ext(src.url)
	switch ext {
	case ".yml", ".yaml":
		var rd dashboardCRD
		if err := yaml.Unmarshal(raw, &rd); err != nil {
			return nil, fmt.Errorf("failed to unmarshal yaml %s CRD: %w", src.kind, err)
		}
		for _, d := range rd.Items {
			for k, v := range d.Data {
				name := strings.TrimSuffix(k, filepath.Ext(k))
				rawResources[name] = []byte(v)
			}
		}
	case ".json":
		k := filepath.Base(src.url)
		name := strings.TrimSuffix(k, ext)
		rawResources[name] = raw
	case ".libsonnet":
		ds, err := vm.EvaluateSnippetMulti(src.url, `(`+string(raw)+`).grafanaDashboards`)
		if err != nil {
			return nil, fmt.Errorf("failed to evaluate jsonnet: %w", err)
		}
		for n, d := range ds {
			k := filepath.Base(n)
			n = strings.TrimSuffix(k, ext)
			rawResources[n] = []byte(d)
		}
	default:
		return nil, fmt.Errorf("%s file extension %q is not supported", src.kind, ext)

	}
	resources := make(map[string][]byte)
	for n, v := range rawResources {
		decoder := json.NewDecoder(bytes.NewReader(v))
		for decoder.More() {
			var d dashboard.Dashboard
			if err := decoder.Decode(&d); err != nil {
				return nil, fmt.Errorf("failed to unmarshal file: %w", err)
			}
			if d.Title != nil {
				n = re.ReplaceAllString(strings.ToLower(*d.Title), "-")
			}
			if _, ok := dashboardsMap[n]; !ok {
				continue
			}
			patchDashboard(&d, n)
			data, err := json.Marshal(&d)
			if err != nil {
				return nil, fmt.Errorf("failed to marshal dashboard: %w", err)
			}
			var ud unsafeDashboard
			err = yaml.Unmarshal(data, &ud)
			if err != nil {
				return nil, fmt.Errorf("failed to unmarshal raw dashboard: %w", err)
			}
			condition := "[[ true ]]"
			if c, ok := dashboardsMap[n]; ok && len(c) > 0 {
				condition = fmt.Sprintf("[[ %s ]]", c)
			}
			for i := range ud.Templating.List {
				v := ud.Templating.List[i]
				if hide, ok := v["hide"].(int); ok && hide == -1 {
					v["hide"] = `[[ ternary 0 2 $multicluster ]]`
				}
			}
			ud.XXX["condition"] = condition
			data, err = yaml.Marshal(&ud)
			if err != nil {
				return nil, fmt.Errorf("failed to marshal dashboard: %w", err)
			}
			resources[n] = escape(data)
		}
	}
	return resources, nil
}



func escape(v []byte) []byte {
	v = bytes.ReplaceAll(v, []byte("{{"), []byte("{{`{{"))
	v = bytes.ReplaceAll(v, []byte("}}"), []byte("}}`}}"))
	v = bytes.ReplaceAll(v, []byte("{{`{{"), []byte("{{`{{`}}"))
	v = bytes.ReplaceAll(v, []byte("}}`}}"), []byte("{{`}}`}}"))
	v = bytes.ReplaceAll(v, []byte("'[["), []byte("{{"))
	v = bytes.ReplaceAll(v, []byte("]]'"), []byte("}}"))
	v = bytes.ReplaceAll(v, []byte("[["), []byte("{{"))
        v = bytes.ReplaceAll(v, []byte("]]"), []byte("}}"))
	return v
}

func toFile(name string, data []byte, src *source) error {
	for _, chart := range src.charts {
		dest := targetDir(*chartsDir, chart, src.kind)
		name = name + ".yaml"
		filename := filepath.Join(dest, name)
		if err := os.MkdirAll(dest, os.ModePerm); err != nil {
			return fmt.Errorf("failed to create dashboards dir: %w", err)
		}
		f, err := os.OpenFile(filename, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
		if err != nil {
			return fmt.Errorf("failed to open file: %w", err)
		}
		if _, err = f.WriteString(headers[src.kind]); err != nil {
			return fmt.Errorf("failed to write header to file: %w", err)
		}
		if _, err = f.Write(data); err != nil {
			return fmt.Errorf("failed to write dashboard to file: %w", err)
		}
	}
	return nil
}

func patchDashboard(d *dashboard.Dashboard, name string) {
	d.Editable = cog.ToPtr(false)
	timezone := "utc"
	if d.Timezone != nil {
		timezone = *d.Timezone
	}
	d.Timezone = cog.ToPtr(fmt.Sprintf("[[ default %q ($Values.defaultDashboards).defaultTimezone ]]", timezone))
	d.Tags = append(d.Tags, "vm-k8s-stack")
	dsName := "prometheus"
	for i := range d.Annotations.List {
		if d.Annotations.List[i].Expr != nil {
			d.Annotations.List[i].Expr = cog.ToPtr(patchExpr(*d.Annotations.List[i].Expr, name, "dashboards"))
		}
	}
	for _, p := range d.Panels {
		if p.Panel != nil {
			patchPanel(p.Panel, dsName, name)
		} else if p.RowPanel != nil {
			for _, rp := range p.RowPanel.Panels {
				patchPanel(&rp, dsName, name)
			}
		}
	}
	hasCluster := false
	for i := range d.Templating.List {
		t := &d.Templating.List[i]
		switch t.Type {
		case dashboard.VariableTypeQuery:
			patchDatasource(t.Datasource, dsName)
			if t.Query != nil {
				if t.Query.String != nil {
					expr := patchExpr(*t.Query.String, name, "dashboards")
					if t.Name == "cluster" {
						expr = fmt.Sprintf(`[[ ternary %q ".*" $multicluster ]]`, expr)
					}
					t.Query.String = cog.ToPtr(expr)
				} else if len(t.Query.Map) > 0 {
					if q, ok := t.Query.Map["query"]; ok {
						expr := patchExpr(q.(string), name, "dashboards")
						if t.Name == "cluster" {
							expr = fmt.Sprintf(`[[ ternary %q ".*" $multicluster ]]`, expr)
						}
						t.Query.Map["query"] = expr
					}
				}
			}
		case dashboard.VariableTypeDatasource:
			if t.Query != nil {
				if t.Query.String != nil && *t.Query.String == dsName {
					t.Query.String = cog.ToPtr("[[ $defaultDatasource ]]")
				} else if len(t.Query.Map) > 0 {
					if q, ok := t.Query.Map["query"]; ok && q == dsName {
						t.Query.Map["query"] = "[[ $defaultDatasource ]]"
					}
				}
			}
		}
		if t.Name == "cluster" {
			hasCluster = true
			t.Type = `[[ ternary "query" "constant" $multicluster ]]`
			t.Hide = cog.ToPtr(dashboard.VariableHide(-1))
		}
	}
	if !hasCluster {
		metric, ok := dashboardClusterMetric[name]
		if !ok {
			log.Printf("no cluster variable found for dashboard %q, also no metrics provided as a source for this label", name)
			return
		}
		ds := &dashboard.DataSourceRef{
			Type: cog.ToPtr(dsName),
		}
		patchDatasource(ds, dsName)
		d.Templating.List = append(d.Templating.List, dashboard.VariableModel{
			Type:  dashboard.VariableTypeQuery,
			Name:  "cluster",
			Label: cog.ToPtr("Cluster"),
			Hide:  cog.ToPtr(dashboard.VariableHide(-1)),
			Query: &dashboard.StringOrMap{
				String: cog.ToPtr(fmt.Sprintf("label_values(%s, cluster)", metric)),
			},
			Datasource: ds,
			Multi:      cog.ToPtr(true),
			IncludeAll: cog.ToPtr(true),
		})
	}
}

func patchDatasource(d *dashboard.DataSourceRef, dsName string) {
	if d == nil {
		return
	}
	if d.Type != nil && *d.Type == dsName {
		d.Type = cog.ToPtr("[[ $defaultDatasource ]]")
		d.Uid = cog.ToPtr("$datasource")
	}
}

func patchExpr(expr, name, kind string) string {
	if len(expr) == 0 {
		return expr
	}
	e, err := metricsql.ParseWithVars(expr, true)
	if err != nil {
		log.Printf("failed to parse expression %q: %s", expr, err)
		return expr
	}
	patchFn := patchFns[name]
	metricsql.VisitAll(e, func(ex metricsql.Expr) {
		switch t := ex.(type) {
		case *metricsql.AggrFuncExpr:
			if t.Modifier.Op == "by" || t.Modifier.Op == "on" {
				var found bool
				for i := range t.Modifier.Args {
					if t.Modifier.Args[i] == "cluster" {
						found = true
						if kind == "rules" {
							t.Modifier.Args[i] = `[[ $groupLabels ]]`
						}
					}
				}
				if !found {
					switch kind {
					case "dashboards":
						t.Modifier.Args = append(t.Modifier.Args, "cluster")
					case "rules":
						t.Modifier.Args = append(t.Modifier.Args, `[[ $groupLabels ]]`)
					}
				}
			}
			if t.Modifier.Op == "" {
				t.Modifier.Op = "by"
				switch kind {
				case "dashboards":
					t.Modifier.Args = append(t.Modifier.Args, "cluster")
				case "rules":
					t.Modifier.Args = append(t.Modifier.Args, `[[ $groupLabels ]]`)
				}
			}
		case *metricsql.MetricExpr:
			for i := range t.LabelFilterss {
				var found bool
				filters := t.LabelFilterss[i][:0]
				for _, f := range t.LabelFilterss[i] {
					if kind == "dashboards" && (f.Label == "cluster" || f.Value == "$cluster") {
						f.Label = "cluster"
						f.Value = "$cluster"
						f.IsRegexp = true
						found = true
					}
					if f.Label == "job" && f.Value == "alertmanager-main" {
						f.Value = `[[ include "vm-k8s-stack.alertmanager.name" . ]]`
					}
					if f.Label == "job" && f.Value == "node-exporter" {
						f.Value = `[[ include "vm-k8s-stack.nodeExporter.name" . ]]`
					}
					filters = append(filters, f)
					if patchFn != nil {
						filters = patchFn(filters, &f)
					}
				}
				if !found && len(filters) > 1 && kind == "dashboards" {
					filters = append(filters, metricsql.LabelFilter{
						Label:    "cluster",
						Value:    "$cluster",
						IsRegexp: true,
					})
				}
				t.LabelFilterss[i] = filters
			}
		}
	})
	return string(e.AppendString(nil))
}

var patchFns = map[string]func([]metricsql.LabelFilter, *metricsql.LabelFilter) []metricsql.LabelFilter{
	"kubernetes-apps": func(fs []metricsql.LabelFilter, f *metricsql.LabelFilter) []metricsql.LabelFilter {
		if f.Label == "job" && f.Value == "kube-state-metrics" {
			fs = append(fs, metricsql.LabelFilter{
				Label:    "namespace",
				Value:    "[[ .targetNamespace ]]",
				IsRegexp: true,
			})
		}
		return fs
	},
	"kubernetes-storage": func(fs []metricsql.LabelFilter, f *metricsql.LabelFilter) []metricsql.LabelFilter {
		if f.Label == "job" && f.Value == "kubelet" {
			fs = append(fs, metricsql.LabelFilter{
				Label:    "namespace",
				Value:    "[[ .targetNamespace ]]",
				IsRegexp: true,
			})
		}
		return fs
	},
	"alertmanager": func(fs []metricsql.LabelFilter, f *metricsql.LabelFilter) []metricsql.LabelFilter {
		if f.Label == "namespace" && f.Value == "monitoring" {
			f.Value = `[[ include "vm.namespace" . ]]`
		}
		return fs
	},
}

func patchPanel(p *dashboard.Panel, dsName, name string) {
	patchDatasource(p.Datasource, dsName)
	for _, t := range p.Targets {
		switch q := t.(type) {
		case *prometheus.Dataquery:
			patchDatasource(q.Datasource, dsName)
			q.Expr = patchExpr(q.Expr, name, "dashboards")
		case *datasource.Dataquery:
			patchDatasource(q.Datasource, dsName)
		default:
			log.Printf("do not support %q target %T", q.DataqueryType(), q)
			continue
		}
	}
}
