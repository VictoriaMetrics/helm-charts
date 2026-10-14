//go:build operatorcompat

package test

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"sort"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/util/wait"
	utilyaml "k8s.io/apimachinery/pkg/util/yaml"
)

const compatName = "compat"

// compatKinds are the object kinds whose naming has to match between a chart and the operator.
var compatKinds = []string{"Deployment", "StatefulSet", "DaemonSet", "Service", "ServiceAccount", "PersistentVolumeClaim"}

type compatCase struct {
	// chart is a chart directory name under charts/
	chart string
	// values are passed to helm template with --set-json
	values map[string]any
	// manifest is the operator custom resource equivalent to values, named compatName
	manifest string
	// kinds are values of the app.kubernetes.io/name label on objects created by the operator for manifest
	kinds []string
	// workloadKinds are the kinds the operator creates a workload for; defaults to kinds
	workloadKinds []string
	// ignore lists contract entries that intentionally differ, as "<kind>/<name> <field>"
	ignore []string
}

var compatCases = []compatCase{
	{
		chart:  "victoria-metrics-single",
		values: map[string]any{"server.mode": "deployment"},
		manifest: `
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMSingle
spec:
  storage: {resources: {requests: {storage: 16Gi}}}
`,
		kinds: []string{"vmsingle"},
		// the operator listens on 8429 and keeps 8428 as a Service alias; changing the port would restart the storage pod
		ignore: []string{
			"Deployment/vmsingle-compat container[vmsingle].port=",
			"Service/vmsingle-compat port=",
		},
	},
	{
		chart:  "victoria-logs-single",
		values: map[string]any{"server.mode": "deployment", "serviceAccount.create": true},
		manifest: `
apiVersion: operator.victoriametrics.com/v1
kind: VLSingle
spec:
  storage: {resources: {requests: {storage: 10Gi}}}
`,
		kinds: []string{"vlsingle"},
	},
	{
		chart:  "victoria-traces-single",
		values: map[string]any{"server.mode": "deployment", "serviceAccount.create": true},
		manifest: `
apiVersion: operator.victoriametrics.com/v1
kind: VTSingle
spec:
  storage: {resources: {requests: {storage: 10Gi}}}
`,
		kinds: []string{"vtsingle"},
	},
	{
		chart:  "victoria-metrics-agent",
		values: map[string]any{"remoteWrite": []any{map[string]any{"url": "http://x:8428/api/v1/write"}}, "service.enabled": true},
		manifest: `
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMAgent
spec:
  remoteWrite: [{url: "http://x:8428/api/v1/write"}]
`,
		kinds: []string{"vmagent"},
		ignore: []string{
			"Deployment/vmagent-compat container=config-reloader",
			"Deployment/vmagent-compat container[config-reloader]",
			"Deployment/vmagent-compat volume=config",
			"Deployment/vmagent-compat volume=tls-assets",
		},
	},
	{
		chart:  "victoria-logs-agent",
		values: map[string]any{"remoteWrite": []any{map[string]any{"url": "http://x:9428"}}, "service.enabled": true},
		manifest: `
apiVersion: operator.victoriametrics.com/v1
kind: VLAgent
spec:
  remoteWrite: [{url: "http://x:9428/internal/insert"}]
`,
		kinds: []string{"vlagent"},
	},
	{
		chart:  "victoria-traces-agent",
		values: map[string]any{"remoteWrite": []any{map[string]any{"url": "http://x:10428"}}},
		manifest: `
apiVersion: operator.victoriametrics.com/v1
kind: VTAgent
spec:
  remoteWrite: [{url: "http://x:10428/insert/native"}]
`,
		kinds: []string{"vtagent"},
	},
	{
		chart: "victoria-metrics-alert",
		values: map[string]any{
			"server.datasource.url":            "http://x:8428",
			"alertmanager.enabled":             true,
			"alertmanager.replicaCount":        2,
			"alertmanager.mode":                "statefulSet",
			"server.notifier.alertmanager.url": "",
		},
		manifest: `
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMAlert
spec:
  datasource: {url: "http://x:8428"}
  notifier: {url: "http://x:9093"}
---
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMAlertmanager
spec:
  replicaCount: 2
`,
		kinds: []string{"vmalert", "vmalertmanager"},
		ignore: []string{
			"Deployment/vmalert-compat volume=config",
			"Deployment/vmalert-compat volume=tls-assets",
			"StatefulSet/vmalertmanager-compat container=config-reloader",
			"StatefulSet/vmalertmanager-compat container[config-reloader]",
			"StatefulSet/vmalertmanager-compat volume=tls-assets",
		},
	},
	{
		chart:  "victoria-metrics-auth",
		values: map[string]any{"config.unauthorized_user.url_prefix": "http://x:8428"},
		manifest: `
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMAuth
spec:
  unauthorizedUserAccessSpec:
    url_prefix: ["http://x:8428"]
`,
		kinds: []string{"vmauth"},
		ignore: []string{
			"Deployment/vmauth-compat container=config-reloader",
			"Deployment/vmauth-compat container[config-reloader]",
		},
	}, {
		chart: "victoria-metrics-cluster",
		// the chart runs vmselect as a Deployment by default, the operator always as a StatefulSet
		values: map[string]any{"serviceAccount.create": true, "vmselect.mode": "statefulSet"},
		manifest: `
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMCluster
spec:
  retentionPeriod: "1"
  vmstorage:
    replicaCount: 2
    resources: {requests: {cpu: 10m, memory: 32Mi}}
    storage: {volumeClaimTemplate: {spec: {resources: {requests: {storage: 8Gi}}}}}
  vmselect:
    replicaCount: 2
    resources: {requests: {cpu: 10m, memory: 32Mi}}
  vminsert:
    replicaCount: 2
    resources: {requests: {cpu: 10m, memory: 32Mi}}
`,
		kinds:         []string{"vmcluster", "vmstorage", "vmselect", "vminsert"},
		workloadKinds: []string{"vmstorage", "vmselect", "vminsert"},
	},
	{
		chart:  "victoria-logs-cluster",
		values: map[string]any{"serviceAccount.create": true},
		manifest: `
apiVersion: operator.victoriametrics.com/v1
kind: VLCluster
spec:
  vlstorage:
    replicaCount: 2
    resources: {requests: {cpu: 10m, memory: 32Mi}}
    storage: {volumeClaimTemplate: {spec: {resources: {requests: {storage: 10Gi}}}}}
  vlselect:
    replicaCount: 2
    resources: {requests: {cpu: 10m, memory: 32Mi}}
  vlinsert:
    replicaCount: 2
    resources: {requests: {cpu: 10m, memory: 32Mi}}
`,
		kinds:         []string{"vlcluster", "vlstorage", "vlselect", "vlinsert"},
		workloadKinds: []string{"vlstorage", "vlselect", "vlinsert"},
	},
	{
		chart:  "victoria-traces-cluster",
		values: map[string]any{"serviceAccount.create": true},
		manifest: `
apiVersion: operator.victoriametrics.com/v1
kind: VTCluster
spec:
  storage:
    replicaCount: 2
    resources: {requests: {cpu: 10m, memory: 32Mi}}
    storage: {volumeClaimTemplate: {spec: {resources: {requests: {storage: 10Gi}}}}}
  select:
    replicaCount: 2
    resources: {requests: {cpu: 10m, memory: 32Mi}}
  insert:
    replicaCount: 2
    resources: {requests: {cpu: 10m, memory: 32Mi}}
`,
		kinds:         []string{"vtcluster", "vtstorage", "vtselect", "vtinsert"},
		workloadKinds: []string{"vtstorage", "vtselect", "vtinsert"},
	},
}

// TestOperatorCompat checks that charts rendered with `useLegacyNaming: false` name their
// workloads, services, service accounts, volumes, containers and ports the same way the
// VictoriaMetrics operator does for an equivalent custom resource.
//
// The operator has to be running in the cluster before the test starts.
func TestOperatorCompat(t *testing.T) {
	workdir, err := os.Getwd()
	require.NoError(t, err)
	chartsDir := filepath.Join(filepath.Dir(workdir), "charts")
	kc := getKubeconfig()
	client, err := newKubeClient(kc)
	require.NoError(t, err)

	for _, tc := range compatCases {
		t.Run(tc.chart, func(t *testing.T) {
			t.Parallel()
			ctx := context.Background()
			namespace := fmt.Sprintf("compat-%s", uniqueID())
			_, err := kubectl(kc, "", "create", "namespace", namespace)
			require.NoError(t, err)
			defer client.CoreV1().Namespaces().Delete(ctx, namespace, metav1.DeleteOptions{}) //nolint:errcheck

			_, err = kubectl(kc, compatManifest(tc.manifest), "apply", "-n", namespace, "-f", "-")
			require.NoError(t, err)

			var operatorObjs []*unstructured.Unstructured
			err = wait.PollUntilContextTimeout(ctx, pollingInterval, pollingTimeout, true, func(ctx context.Context) (bool, error) {
				operatorObjs, err = operatorObjects(kc, namespace, tc.kinds)
				if err != nil {
					return false, nil
				}
				workloadKinds := tc.workloadKinds
				if workloadKinds == nil {
					workloadKinds = tc.kinds
				}
				for _, k := range workloadKinds {
					if !slices.ContainsFunc(operatorObjs, func(o *unstructured.Unstructured) bool {
						return isWorkload(o) && o.GetLabels()["app.kubernetes.io/name"] == k
					}) {
						return false, nil
					}
				}
				return true, nil
			})
			require.NoError(t, err, "operator didn't create workloads for %v", tc.kinds)

			chartObjs, err := chartObjects(filepath.Join(chartsDir, tc.chart), namespace, tc.values)
			require.NoError(t, err)

			expected := filterIgnored(contract(operatorObjs), tc.ignore)
			actual := filterIgnored(contract(chartObjs), tc.ignore)
			var problems []string
			for _, line := range expected {
				if !slices.Contains(actual, line) {
					problems = append(problems, "operator only: "+line)
				}
			}
			for _, line := range actual {
				if !slices.Contains(expected, line) && contractObjectIn(line, expected) {
					problems = append(problems, "chart only:    "+line)
				}
			}
			require.Empty(t, problems, "chart %s differs from the operator:\n%s", tc.chart, strings.Join(problems, "\n"))
		})
	}
}

// compatManifest names every document of manifest after compatName.
func compatManifest(manifest string) string {
	var docs []string
	for _, doc := range strings.Split(manifest, "\n---\n") {
		docs = append(docs, strings.TrimSpace(doc)+"\nmetadata:\n  name: "+compatName+"\n")
	}
	return strings.Join(docs, "---\n")
}

func kubectl(kubeconfig, stdin string, args ...string) ([]byte, error) {
	cmd := exec.Command("kubectl", append([]string{"--kubeconfig", kubeconfig}, args...)...)
	if stdin != "" {
		cmd.Stdin = strings.NewReader(stdin)
	}
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	out, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("kubectl %s: %w: %s", strings.Join(args, " "), err, stderr.String())
	}
	return out, nil
}

// operatorObjects returns objects the operator created for the compatName custom resources of the given kinds.
func operatorObjects(kubeconfig, namespace string, kinds []string) ([]*unstructured.Unstructured, error) {
	out, err := kubectl(kubeconfig, "", "get", "deployments,statefulsets,daemonsets,services,serviceaccounts,persistentvolumeclaims",
		"-n", namespace, "-o", "json",
		"-l", fmt.Sprintf("app.kubernetes.io/instance=%s,app.kubernetes.io/name in (%s)", compatName, strings.Join(kinds, ",")))
	if err != nil {
		return nil, err
	}
	var list unstructured.UnstructuredList
	if err := json.Unmarshal(out, &list); err != nil {
		return nil, err
	}
	var claimPrefixes []string
	for _, o := range list.Items {
		if o.GetKind() != "StatefulSet" {
			continue
		}
		vcts, _, _ := unstructured.NestedSlice(o.Object, "spec", "volumeClaimTemplates")
		for _, v := range vcts {
			name, _, _ := unstructured.NestedString(v.(map[string]any), "metadata", "name")
			claimPrefixes = append(claimPrefixes, name+"-"+o.GetName()+"-")
		}
	}
	var objs []*unstructured.Unstructured
	for i := range list.Items {
		o := &list.Items[i]
		// claims created by the StatefulSet controller from volumeClaimTemplates aren't rendered by charts
		if o.GetKind() == "PersistentVolumeClaim" && slices.ContainsFunc(claimPrefixes, func(p string) bool { return strings.HasPrefix(o.GetName(), p) }) {
			continue
		}
		objs = append(objs, o)
	}
	return objs, nil
}

// chartObjects renders a chart with operator naming and returns the rendered objects.
func chartObjects(chartDir, namespace string, values map[string]any) ([]*unstructured.Unstructured, error) {
	args := []string{"template", compatName, chartDir, "--namespace", namespace, "--set", "useLegacyNaming=false"}
	for k, v := range values {
		b, err := json.Marshal(v)
		if err != nil {
			return nil, err
		}
		args = append(args, "--set-json", k+"="+string(b))
	}
	cmd := exec.Command("helm", args...)
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	out, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("helm %s: %w: %s", strings.Join(args, " "), err, stderr.String())
	}
	var objs []*unstructured.Unstructured
	dec := utilyaml.NewYAMLOrJSONDecoder(bytes.NewReader(out), 4096)
	for {
		var obj map[string]any
		if err := dec.Decode(&obj); err != nil {
			if errors.Is(err, io.EOF) {
				break
			}
			return nil, err
		}
		if obj == nil {
			continue
		}
		u := &unstructured.Unstructured{Object: obj}
		if slices.Contains(compatKinds, u.GetKind()) {
			objs = append(objs, u)
		}
	}
	return objs, nil
}

func isWorkload(o *unstructured.Unstructured) bool {
	return slices.Contains([]string{"Deployment", "StatefulSet", "DaemonSet"}, o.GetKind())
}

// contract flattens naming-relevant fields of objects into sorted "<kind>/<name> <field>=<value>" lines.
func contract(objs []*unstructured.Unstructured) []string {
	var lines []string
	add := func(o *unstructured.Unstructured, field string, value any) {
		lines = append(lines, fmt.Sprintf("%s/%s %s=%v", o.GetKind(), o.GetName(), field, value))
	}
	for _, o := range objs {
		switch o.GetKind() {
		case "Deployment", "StatefulSet", "DaemonSet":
			sel, _, _ := unstructured.NestedStringMap(o.Object, "spec", "selector", "matchLabels")
			sel = withoutOwnership(sel)
			add(o, "selector", keyValues(sel))
			podLabels, _, _ := unstructured.NestedStringMap(o.Object, "spec", "template", "metadata", "labels")
			for k, v := range sel {
				if podLabels[k] != v {
					add(o, "podLabelMissing", k)
				}
			}
			sa, _, _ := unstructured.NestedString(o.Object, "spec", "template", "spec", "serviceAccountName")
			add(o, "serviceAccountName", sa)
			containers, _, _ := unstructured.NestedSlice(o.Object, "spec", "template", "spec", "containers")
			for _, c := range containers {
				cm := c.(map[string]any)
				name := cm["name"]
				add(o, "container", name)
				ports, _, _ := unstructured.NestedSlice(cm, "ports")
				for _, p := range ports {
					pm := p.(map[string]any)
					add(o, fmt.Sprintf("container[%s].port", name), fmt.Sprintf("%v:%v", pm["name"], pm["containerPort"]))
				}
			}
			volumes, _, _ := unstructured.NestedSlice(o.Object, "spec", "template", "spec", "volumes")
			for _, v := range volumes {
				add(o, "volume", v.(map[string]any)["name"])
			}
			if o.GetKind() == "StatefulSet" {
				svc, _, _ := unstructured.NestedString(o.Object, "spec", "serviceName")
				add(o, "serviceName", svc)
				vcts, _, _ := unstructured.NestedSlice(o.Object, "spec", "volumeClaimTemplates")
				for _, v := range vcts {
					name, _, _ := unstructured.NestedString(v.(map[string]any), "metadata", "name")
					add(o, "volumeClaimTemplate", name)
				}
			}
		case "Service":
			sel, _, _ := unstructured.NestedStringMap(o.Object, "spec", "selector")
			add(o, "selector", keyValues(withoutOwnership(sel)))
			clusterIP, _, _ := unstructured.NestedString(o.Object, "spec", "clusterIP")
			add(o, "headless", clusterIP == "None")
			ports, _, _ := unstructured.NestedSlice(o.Object, "spec", "ports")
			for _, p := range ports {
				pm := p.(map[string]any)
				add(o, "port", fmt.Sprintf("%v:%v", pm["name"], pm["port"]))
			}
		default:
			add(o, "exists", true)
		}
	}
	sort.Strings(lines)
	return lines
}

// contractObjectIn reports whether the object of a contract line appears in lines,
// so that objects rendered only by the chart (e.g. optional ones) don't fail the check.
func contractObjectIn(line string, lines []string) bool {
	obj, _, _ := strings.Cut(line, " ")
	return slices.ContainsFunc(lines, func(l string) bool { return strings.HasPrefix(l, obj+" ") })
}

func filterIgnored(lines, ignore []string) []string {
	var out []string
	for _, l := range lines {
		if !slices.ContainsFunc(ignore, func(i string) bool { return strings.HasPrefix(l, i) }) {
			out = append(out, l)
		}
	}
	return out
}

func keyValues(m map[string]string) string {
	var kv []string
	for k, v := range m {
		kv = append(kv, k+"="+v)
	}
	sort.Strings(kv)
	return strings.Join(kv, ",")
}

// withoutOwnership drops labels that identify the managing tool,
// which intentionally differ between Helm and the operator.
func withoutOwnership(labels map[string]string) map[string]string {
	out := make(map[string]string, len(labels))
	for k, v := range labels {
		if k != "managed-by" && k != "app.kubernetes.io/managed-by" {
			out[k] = v
		}
	}
	return out
}
