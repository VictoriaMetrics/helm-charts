package main

import (
	"bytes"
	"encoding/json/v2"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/VictoriaMetrics/metricsql"
	"github.com/google/go-jsonnet"
	"gopkg.in/yaml.v2"
)

var chartsDir = flag.String("charts.dir", "../../charts", "path to charts dir")

type remoteImporter struct {
	cache map[string]jsonnet.Contents
}

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
{{- $clusterLabel := ($Values.global).clusterLabel | default "cluster" }}
{{- range (((($Values.grafana).sidecar).datasources).victoriametrics | default list) }}
  {{- if and .isDefault .type }}{{ $defaultDatasource = .type }}{{- end }}
{{- end }}
`,
	"rules": `
{{- $Values := (.helm).Values | default .Values }}
{{- $runbookUrl := ($Values.defaultRules).runbookUrl | default "https://runbooks.prometheus-operator.dev/runbooks" }}
{{- $clusterLabel := ($Values.global).clusterLabel | default "cluster" }}
{{- $additionalGroupByLabels := append $Values.defaultRules.additionalGroupByLabels $clusterLabel }}
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
	if c, ok := i.cache[src]; ok {
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
		contentBytes, err := io.ReadAll(resp.Body)
		if err != nil {
			return jsonnet.Contents{}, "", fmt.Errorf("failed to read remote import content: %w", err)
		}
		c := jsonnet.MakeContents(string(contentBytes))
		i.cache[src] = c
		return c, src, nil
	} else {
		contentBytes, err := os.ReadFile(src)
		if err != nil {
			return jsonnet.MakeContents(""), "", fmt.Errorf("failed to read local import: %w", err)
		}
		c := jsonnet.MakeContents(string(contentBytes))
		i.cache[src] = c
		return c, src, nil
	}
}

type source struct {
	url     string
	kind    string
	snippet string
	charts  []string
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
		url: "etcd.dashboard.libsonnet",
		snippet: `
local common = import "https://raw.githubusercontent.com/etcd-io/etcd/main/contrib/mixin/mixin.libsonnet";
common.grafanaDashboards
`,
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
		url: "etcd.rules.libsonnet",
		snippet: `
local common = import "https://raw.githubusercontent.com/etcd-io/etcd/main/contrib/mixin/mixin.libsonnet";
{ [group.name]: group for group in common.prometheusAlerts.groups }
`,
		kind: "rules",
		charts: []string{
			"victoria-metrics-k8s-stack",
		},
	},
}

// rules
type ruleCRD struct {
	Spec ruleSpec `yaml:"spec"`
}

type ruleSpec struct {
	Groups []ruleGroup `yaml:"groups"`
}

type ruleGroup struct {
	Name  string         `yaml:"name"`
	Rules []rule         `yaml:"rules"`
	XXX   map[string]any `yaml:",inline"`
}

type rule struct {
	Rule        string            `yaml:"rule,omitempty"`
	Alert       string            `yaml:"alert,omitempty"`
	Expr        string            `yaml:"expr"`
	Annotations map[string]string `yaml:"annotations,omitempty"`
	XXX         map[string]any    `yaml:",inline"`
}

func (r *rule) Name() string {
	if len(r.Rule) > 0 {
		return r.Rule
	}
	return r.Alert
}

// dashboards
type dashboardCRD struct {
	Items []dashboardItem `yaml:"items" json:"items"`
}

type dashboardItem struct {
	Data map[string]string `yaml:"data" json:"data"`
}

type dashboard struct {
	Targets     []dashboardTarget    `yaml:"targets,omitempty" json:"targets,omitempty"`
	Title       string               `yaml:"title" json:"title"`
	Templating  dashboardTemplating  `yaml:"templating" json:"templating"`
	Editable    bool                 `yaml:"editable" json:"editable"`
	Timezone    string               `yaml:"timezone" json:"timezone"`
	Tags        []string             `yaml:"tags" json:"tags"`
	Annotations dashboardAnnotations `yaml:"annotations,omitempty" json:"annotations,omitempty"`
	Panels      []dashboardPanel     `yaml:"panels" json:"panels"`
	XXX         map[string]any       `yaml:",inline" json:",unknown"`
}

type dashboardPanel struct {
	Title      string            `yaml:"title,omitempty" json:"title,omitempty"`
	Targets    []dashboardTarget `yaml:"targets,omitempty" json:"targets,omitempty"`
	Panels     []dashboardPanel  `yaml:"panels,omitempty" json:"panels,omitempty"`
	Datasource *stringOrMap      `yaml:"datasource,omitempty" json:"datasource,omitempty"`
	XXX        map[string]any    `yaml:",inline" json:",unknown"`
}

type dashboardTarget struct {
	Datasource *stringOrMap   `yaml:"datasource,omitempty" json:"datasource,omitempty"`
	Expr       string         `yaml:"expr,omitempty" json:"expr,omitempty"`
	XXX        map[string]any `yaml:",inline" json:",unknown"`
}

type dashboardAnnotations struct {
	List []dashboardAnnotation `yaml:"list,omitempty" json:"list,omitempty"`
}

type dashboardAnnotation struct {
	Name       string         `yaml:"name,omitempty" json:"name,omitempty"`
	Expr       string         `yaml:"expr,omitempty" json:"expr,omitempty"`
	Datasource *stringOrMap   `yaml:"datasource,omitempty" json:"datasource,omitempty"`
	XXX        map[string]any `yaml:",inline" json:",unknown"`
}

type dashboardTemplating struct {
	List []dashboardVariable `yaml:"list" json:"list"`
}

type stringOrMap struct {
	String string
	Map    map[string]any
}

func (r stringOrMap) MarshalYAML() (any, error) {
	if len(r.String) > 0 {
		return r.String, nil
	}

	if len(r.Map) > 0 {
		return r.Map, nil
	}

	return nil, nil
}

func (r stringOrMap) MarshalJSON() ([]byte, error) {
	if len(r.String) > 0 {
		return json.Marshal(r.String)
	}

	if len(r.Map) > 0 {
		return json.Marshal(r.Map)
	}

	return []byte("null"), nil
}

func (r *stringOrMap) UnmarshalJSON(raw []byte) error {
	if len(raw) == 0 {
		return nil
	}

	var o any
	if err := json.Unmarshal(raw, &o); err != nil {
		r.String = ""
		r.Map = nil
		return err
	} else {
		switch v := o.(type) {
		case string:
			r.String = v
		case map[string]any:
			r.Map = v
		default:
			return fmt.Errorf("unexpected type %T", v)
		}
		return nil
	}
}

type intOrStr struct {
	IntVal int
	StrVal string
	IsInt  bool
}

func (v intOrStr) MarshalYAML() (any, error) {
	if v.IsInt {
		return v.IntVal, nil
	}
	return v.StrVal, nil
}

func (v intOrStr) MarshalJSON() ([]byte, error) {
	if v.IsInt {
		return json.Marshal(v.IntVal)
	}
	return json.Marshal(v.StrVal)
}

func (r *intOrStr) UnmarshalJSON(raw []byte) error {
	if len(raw) == 0 {
		return nil
	}
	var o any
	if err := json.Unmarshal(raw, &o); err != nil {
		r.StrVal = ""
		r.IntVal = 0
		r.IsInt = false
		return err
	} else {
		switch v := o.(type) {
		case string:
			r.StrVal = v
		case float64:
			r.IntVal = int(v)
		default:
			return fmt.Errorf("unexpected type %T", v)
		}
		return nil
	}
}

type dashboardVariable struct {
	Name       string         `yaml:"name" json:"name"`
	Label      string         `yaml:"label,omitempty" json:"label,omitempty"`
	Multi      bool           `yaml:"multi,omitempty" json:"multi,omitempty"`
	IncludeAll bool           `yaml:"includeAll,omitempty" json:"includeAll,omitempty"`
	Datasource *stringOrMap   `yaml:"datasource,omitempty" json:"datasource,omitempty"`
	Type       string         `yaml:"type" json:"type"`
	Query      *stringOrMap   `yaml:"query,omitempty" json:"query,omitempty"`
	Hide       intOrStr       `yaml:"hide,omitempty" json:"hide,omitempty"`
	XXX        map[string]any `yaml:",inline" json:",unknown"`
}

var re = regexp.MustCompile("[ /-]+")

func main() {
	yaml.FutureLineWrap()
	// Required to correctly unmarshal panels and dataqueries
	vm := jsonnet.MakeVM()
	vm.Importer(&remoteImporter{
		cache: make(map[string]jsonnet.Contents),
	})

	var raw []byte

	for _, src := range sources {
		log.Printf("generating %s from %q", src.kind, src.url)
		if len(src.snippet) == 0 {
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
				raw, err = io.ReadAll(resp.Body)
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
		} else {
			raw = []byte(src.snippet)
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
	groups := make(map[string]*ruleGroup)
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
		ds, err := vm.EvaluateAnonymousSnippetMulti("snippet", string(raw))
		if err != nil {
			return nil, fmt.Errorf("failed to evaluate jsonnet: %w", err)
		}
		for n, d := range ds {
			k := filepath.Base(n)
			n = strings.TrimSuffix(k, ext)
			var g ruleGroup
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
					r.Annotations[ak] = strings.ReplaceAll(av, "https://runbooks.prometheus-operator.dev/runbooks", "<< $runbookUrl >>")
				case strings.HasPrefix(av, "http://localhost:3000"):
					r.Annotations[ak] = strings.ReplaceAll(av, "http://localhost:3000", "<< $grafanaAddr >>")
				}
			}
			expr, args := patchExpr(r.Expr, g.Name, r.Name(), "rules")
			if len(args) > 0 {
				r.Expr = fmt.Sprintf("<< printf %q %s >>", expr, args)
			}
			if r.XXX == nil {
				r.XXX = make(map[string]any)
			}
			if c, ok := alertsMap[r.Name()]; ok {
				r.XXX["condition"] = fmt.Sprintf("<< %s >>", c)
			} else {
				r.XXX["condition"] = true
			}
		}
		if g.XXX == nil {
			g.XXX = make(map[string]any)
		}
		if c, ok := rulesMap[n]; ok && len(c) > 0 {
			g.XXX["condition"] = fmt.Sprintf("<< %q >>", c)
		} else {
			g.XXX["condition"] = true
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
		ds, err := vm.EvaluateAnonymousSnippetMulti("snippet", string(raw))
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
		var d dashboard
		if err := json.Unmarshal(v, &d); err != nil {
			return nil, fmt.Errorf("failed to unmarshal file: %w", err)
		}
		if len(d.Title) > 0 {
			n = re.ReplaceAllString(strings.ToLower(d.Title), "-")
		}
		if _, ok := dashboardsMap[n]; !ok {
			continue
		}
		patchDashboard(&d, n)
		data, err := yaml.Marshal(&d)
		if err != nil {
			return nil, fmt.Errorf("failed to marshal dashboard: %w", err)
		}
		resources[n] = escape(data)
	}
	return resources, nil
}

type replacement struct {
	from []byte
	to   []byte
}

var replacements = []replacement{
	{
		from: []byte("{{"),
		to:   []byte("{{`{{"),
	},
	{
		from: []byte("}}"),
		to:   []byte("}}`}}"),
	},
	{
		from: []byte("{{`{{"),
		to:   []byte("{{`{{`}}"),
	},
	{
		from: []byte("}}`}}"),
		to:   []byte("{{`}}`}}"),
	},
	{
		from: []byte("<<"),
		to:   []byte("{{"),
	},
	{
		from: []byte(">>"),
		to:   []byte("}}"),
	},
}

func escape(v []byte) []byte {
	for _, r := range replacements {
		v = bytes.ReplaceAll(v, r.from, r.to)
	}
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

func patchDashboard(d *dashboard, name string) {
	d.Editable = false
	timezone := "utc"
	if d.Timezone != "" {
		timezone = d.Timezone
	}
	d.Timezone = fmt.Sprintf("<< default %q ($Values.defaultDashboards).defaultTimezone >>", timezone)
	d.Tags = append(d.Tags, "vm-k8s-stack")

	if d.XXX == nil {
		d.XXX = make(map[string]any)
	}
	if c, ok := dashboardsMap[name]; ok && len(c) > 0 {
		d.XXX["condition"] = fmt.Sprintf("<< %q >>", c)
	} else {
		d.XXX["condition"] = true
	}
	dsName := "prometheus"
	for i := range d.Annotations.List {
		a := &d.Annotations.List[i]
		patchDatasource(a.Datasource, dsName)
		expr, args := patchExpr(a.Expr, name, a.Name, "dashboards")
		if len(args) > 0 {
			expr = fmt.Sprintf("<< printf %q %s >>", expr, args)
		}
		a.Expr = expr
	}
	for i := range d.Targets {
		t := &d.Targets[i]
		patchDatasource(t.Datasource, dsName)
		expr, args := patchExpr(t.Expr, name, name, "dashboards")
		if len(args) > 0 {
			expr = fmt.Sprintf("<< printf %q %s >>", expr, args)
		}
		t.Expr = expr
	}
	for i := range d.Panels {
		p := &d.Panels[i]
		patchPanel(p, dsName, name)
	}
	hasCluster := false
	for i := range d.Templating.List {
		t := &d.Templating.List[i]
		patchDatasource(t.Datasource, dsName)
		switch t.Type {
		case "query":
			if t.Query != nil {
				if len(t.Query.String) > 0 {
					expr, args := patchExpr(t.Query.String, name, t.Name, "dashboards")
					if t.Name == "cluster" {
						expr = fmt.Sprintf(`<< ternary (printf %q %s) ".*" $multicluster >>`, expr, args)
					} else if len(args) > 0 {
						expr = fmt.Sprintf(`<< printf %q %s >>`, expr, args)
					}
					t.Query.String = expr
				} else if len(t.Query.Map) > 0 {
					if q, ok := t.Query.Map["query"]; ok {
						expr, args := patchExpr(q.(string), name, t.Name, "dashboards")
						if t.Name == "cluster" {
							expr = fmt.Sprintf(`<< ternary (printf %q %s) ".*" $multicluster >>`, expr, args)
						} else if len(args) > 0 {
							expr = fmt.Sprintf(`<< printf %q %s >>`, expr, args)
						}
						t.Query.Map["query"] = expr
					}
				}
			}
		case "datasource":
			if t.Query != nil {
				if len(t.Query.String) > 0 && t.Query.String == dsName {
					t.Query.String = "<< $defaultDatasource >>"
				} else if len(t.Query.Map) > 0 {
					if q, ok := t.Query.Map["query"]; ok && q == dsName {
						t.Query.Map["query"] = "<< $defaultDatasource >>"
					}
				}
			}
		}
		if t.Name == "cluster" {
			hasCluster = true
			t.Name = "cluster"
			t.Type = `<< ternary "query" "constant" $multicluster >>`
			t.Hide = intOrStr{
				StrVal: `<< ternary 0 2 $multicluster >>`,
			}
		}
	}
	if !hasCluster {
		metric, ok := dashboardClusterMetric[name]
		if !ok {
			log.Printf("no cluster variable found for dashboard %q, also no metrics provided as a source for this label", name)
			return
		}
		ds := &stringOrMap{
			Map: map[string]any{
				"type": dsName,
			},
		}
		patchDatasource(ds, dsName)
		v := dashboardVariable{
			Type:  `<< ternary "query" "constant" $multicluster >>`,
			Name:  "cluster",
			Label: "cluster",
			Hide: intOrStr{
				StrVal: "<< ternary 0 2 $multicluster >>",
			},
			Query: &stringOrMap{
				String: fmt.Sprintf(`<< ternary (printf "label_values(%s, %%s)" $clusterLabel) ".*" $multicluster >>`, metric),
			},
			Datasource: ds,
			Multi:      true,
			IncludeAll: true,
		}
		d.Templating.List = append(d.Templating.List, v)
	}
}

func patchDatasource(d *stringOrMap, dsName string) {
	if d == nil {
		return
	}
	if len(d.Map) > 0 && d.Map["type"] == dsName {
		d.Map["type"] = "<< $defaultDatasource >>"
	}
}

func patchExpr(expr, groupName, name, kind string) (string, string) {
	if len(expr) == 0 {
		return expr, ""
	}
	e, err := metricsql.ParseWithVars(expr, true)
	if err != nil {
		log.Printf("failed to parse expression %q: %s", expr, err)
		return expr, ""
	}
	patchFn := patchFns[groupName]
	args := []string{}
	metricsql.VisitAll(e, func(ex metricsql.Expr) {
		switch t := ex.(type) {
		case *metricsql.AggrFuncExpr:
			if name == "cluster" {
				return
			}
			if t.Modifier.Op == "by" || t.Modifier.Op == "on" {
				var found bool
				for i := range t.Modifier.Args {
					if t.Modifier.Args[i] == "cluster" {
						found = true
						if kind == "rules" {
							t.Modifier.Args[i] = "VAR__string"
							args = append(args, "$groupLabels")
						} else {
							t.Modifier.Args[i] = "VAR__string"
							args = append(args, "$clusterLabel")
						}
					}
				}
				if !found {
					switch kind {
					case "dashboards":
						t.Modifier.Args = append(t.Modifier.Args, "VAR__string")
						args = append(args, "$clusterLabel")
					case "rules":
						t.Modifier.Args = append(t.Modifier.Args, "VAR__string")
						args = append(args, "$groupLabels")
					}
				}
			}
			if t.Modifier.Op == "" {
				t.Modifier.Op = "by"
				switch kind {
				case "dashboards":
					t.Modifier.Args = append(t.Modifier.Args, "VAR__string")
					args = append(args, "$clusterLabel")
				case "rules":
					t.Modifier.Args = append(t.Modifier.Args, "VAR__string")
					args = append(args, "$groupLabels")
				}
			}
		case *metricsql.MetricExpr:
			for i := range t.LabelFilterss {
				var found bool
				filters := t.LabelFilterss[i][:0]
				for _, f := range t.LabelFilterss[i] {
					if kind == "dashboards" {
						if f.Label == "cluster" || f.Value == "$cluster" {
							f.Label = "VAR__string"
							f.Value = "$cluster"
							f.IsRegexp = true
							found = true
							args = append(args, "$clusterLabel")
						} else if f.Label == "__name__" && f.Value == "cluster" {
							f.Value = "VAR__string"
							found = true
							args = append(args, "$clusterLabel")
						}
					}
					if f.Label == "job" && f.Value == "alertmanager-main" {
						f.Value = "VAR__string"
						args = append(args, `(include "vm-k8s-stack.alertmanager.name" .)`)
					}
					if f.Label == "job" && f.Value == "node-exporter" {
						f.Value = "VAR__string"
						args = append(args, `(include "vm-k8s-stack.nodeExporter.name" .)`)
					}
					filters = append(filters, f)
					if patchFn != nil {
						filters = patchFn(filters, &f)
					}
				}
				if !found && len(filters) > 1 && kind == "dashboards" && name != "cluster" {
					filters = append(filters, metricsql.LabelFilter{
						Label:    "VAR__string",
						Value:    "$cluster",
						IsRegexp: true,
					})
					args = append(args, "$clusterLabel")
				}
				t.LabelFilterss[i] = filters
			}
		}
	})
	return strings.ReplaceAll(string(e.AppendString(nil)), "VAR__string", "%s"), strings.Join(args, " ")
}

var patchFns = map[string]func([]metricsql.LabelFilter, *metricsql.LabelFilter) []metricsql.LabelFilter{
	"kubernetes-apps": func(fs []metricsql.LabelFilter, f *metricsql.LabelFilter) []metricsql.LabelFilter {
		if f.Label == "job" && f.Value == "kube-state-metrics" {
			fs = append(fs, metricsql.LabelFilter{
				Label:    "namespace",
				Value:    "<< .targetNamespace >>",
				IsRegexp: true,
			})
		}
		return fs
	},
	"kubernetes-storage": func(fs []metricsql.LabelFilter, f *metricsql.LabelFilter) []metricsql.LabelFilter {
		if f.Label == "job" && f.Value == "kubelet" {
			fs = append(fs, metricsql.LabelFilter{
				Label:    "namespace",
				Value:    "<< .targetNamespace >>",
				IsRegexp: true,
			})
		}
		return fs
	},
	"alertmanager": func(fs []metricsql.LabelFilter, f *metricsql.LabelFilter) []metricsql.LabelFilter {
		if f.Label == "namespace" && f.Value == "monitoring" {
			f.Value = `<< include "vm.namespace" . >>`
		}
		return fs
	},
}

func patchPanel(p *dashboardPanel, dsName, name string) {
	patchDatasource(p.Datasource, dsName)
	for i := range p.Targets {
		t := &p.Targets[i]
		patchDatasource(t.Datasource, dsName)
		expr, args := patchExpr(t.Expr, name, p.Title, "dashboards")
		if len(args) > 0 {
			expr = fmt.Sprintf("<< printf %q %s >>", expr, args)
		}
		t.Expr = expr
	}
	for i := range p.Panels {
		pp := &p.Panels[i]
		patchPanel(pp, dsName, name)
	}
}
