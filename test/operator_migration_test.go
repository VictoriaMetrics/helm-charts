//go:build operatorcompat

package test

import (
	"bytes"
	"context"
	"crypto/md5"
	"encoding/json"
	"fmt"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"slices"
	"sort"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/util/wait"
	"k8s.io/client-go/kubernetes"
	"sigs.k8s.io/yaml"
)

const compatName = "compat"

type migrationCase struct {
	chart         string
	values        map[string]any
	manifest      string
	kinds         []string
	workloadKinds []string
	ignore        []string
	data          *dataCheck
	healthPath    string
	prepare       func(t *testing.T, kubeconfig, namespace string)
}

func (tc *migrationCase) expandManifest(chartDir string) (string, error) {
	var chart struct {
		AppVersion string `json:"appVersion"`
	}
	var values map[string]any
	for name, v := range map[string]any{"Chart.yaml": &chart, "values.yaml": &values} {
		data, err := os.ReadFile(filepath.Join(chartDir, name))
		if err != nil {
			return "", err
		}
		if err := yaml.Unmarshal(data, v); err != nil {
			return "", err
		}
	}
	return os.Expand(tc.manifest, func(key string) string {
		if v, ok := tc.values[key]; ok {
			return fmt.Sprint(v)
		}
		var v any = values
		for _, k := range strings.Split(key, ".") {
			m, _ := v.(map[string]any)
			v = m[k]
		}
		if s, ok := v.(string); ok && s != "" {
			return s
		}
		return chart.AppVersion
	}), nil
}

func (tc *migrationCase) health() string {
	if tc.healthPath == "" {
		return "/-/healthy"
	}
	return tc.healthPath
}

type dataCheck struct {
	write func(id string, ts time.Time) (target, body string)
	read  func(id string) string
}

type dataPoint struct {
	id     string
	result string
}

func metricsData(insert, sel string) *dataCheck {
	return &dataCheck{
		write: func(id string, ts time.Time) (string, string) {
			return insert + "/api/v1/import/prometheus", fmt.Sprintf("migration_test{id=%q} 1 %d\n", id, ts.UnixMilli())
		},
		read: func(id string) string {
			return sel + "/api/v1/export?match%5B%5D=" + url.QueryEscape(fmt.Sprintf("migration_test{id=%q}", id))
		},
	}
}

func tracesData(insert, sel string) *dataCheck {
	traceID := func(id string) string { return fmt.Sprintf("%x", md5.Sum([]byte(id))) }
	return &dataCheck{
		write: func(id string, ts time.Time) (string, string) {
			span := map[string]any{
				"traceId":           traceID(id),
				"spanId":            traceID(id)[:16],
				"name":              id,
				"kind":              1,
				"startTimeUnixNano": strconv.FormatInt(ts.UnixNano(), 10),
				"endTimeUnixNano":   strconv.FormatInt(ts.Add(time.Millisecond).UnixNano(), 10),
			}
			body, _ := json.Marshal(map[string]any{"resourceSpans": []any{map[string]any{
				"resource":   map[string]any{"attributes": []any{map[string]any{"key": "service.name", "value": map[string]any{"stringValue": "migration"}}}},
				"scopeSpans": []any{map[string]any{"spans": []any{span}}},
			}}})
			return insert + "/insert/opentelemetry/v1/traces", string(body)
		},
		read: func(id string) string {
			return sel + "/select/logsql/query?disable_latency_offset=true&query=" + url.QueryEscape(fmt.Sprintf("trace_id:=%q | fields _time, trace_id, span_id, name", traceID(id)))
		},
	}
}

func logsData(insert, sel string) *dataCheck {
	return &dataCheck{
		write: func(id string, ts time.Time) (string, string) {
			return insert + "/insert/jsonline?_stream_fields=id", fmt.Sprintf(`{"_time":%q,"_msg":"migration","id":%q}`+"\n", ts.UTC().Format(time.RFC3339Nano), id)
		},
		read: func(id string) string {
			return sel + "/select/logsql/query?query=" + url.QueryEscape(fmt.Sprintf("id:=%q | fields _time, _msg, id", id))
		},
	}
}

var migrationCases = []migrationCase{
	{
		chart:  "victoria-metrics-single",
		values: map[string]any{"server.mode": "deployment"},
		manifest: `
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMSingle
spec:
  image: {tag: "${server.image.tag}"}
  storage: {resources: {requests: {storage: 16Gi}}}
`,
		kinds: []string{"vmsingle"},
		data:  metricsData("vmsingle-compat", "vmsingle-compat"),
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
  image: {tag: "${server.image.tag}"}
  storage: {resources: {requests: {storage: 10Gi}}}
`,
		kinds: []string{"vlsingle"},
		data:  logsData("vlsingle-compat", "vlsingle-compat"),
	},
	{
		chart:  "victoria-traces-single",
		values: map[string]any{"server.mode": "deployment", "serviceAccount.create": true},
		manifest: `
apiVersion: operator.victoriametrics.com/v1
kind: VTSingle
spec:
  image: {tag: "${server.image.tag}"}
  storage: {resources: {requests: {storage: 10Gi}}}
`,
		kinds: []string{"vtsingle"},
		data:  tracesData("vtsingle-compat", "vtsingle-compat"),
	},
	{
		chart:  "victoria-metrics-agent",
		values: map[string]any{"remoteWrite": []any{map[string]any{"url": "http://x:8428/api/v1/write"}}, "service.enabled": true},
		manifest: `
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMAgent
spec:
  image: {tag: "${image.tag}"}
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
		values: map[string]any{"remoteWrite": []any{map[string]any{"url": "http://x:9428"}}, "service.enabled": true, "podManagementPolicy": "Parallel"},
		manifest: `
apiVersion: operator.victoriametrics.com/v1
kind: VLAgent
spec:
  image: {tag: "${image.tag}"}
  rollingUpdateStrategy: RollingUpdate
  remoteWrite: [{url: "http://x:9428/internal/insert"}]
`,
		kinds: []string{"vlagent"},
	},
	{
		chart:  "victoria-traces-agent",
		values: map[string]any{"remoteWrite": []any{map[string]any{"url": "http://x:10428"}}, "podManagementPolicy": "Parallel"},
		manifest: `
apiVersion: operator.victoriametrics.com/v1
kind: VTAgent
spec:
  image: {tag: "${image.tag}"}
  rollingUpdateStrategy: RollingUpdate
  remoteWrite: [{url: "http://x:10428/insert/native"}]
`,
		kinds: []string{"vtagent"},
	},
	{
		chart: "victoria-metrics-alert",
		values: map[string]any{
			"server.datasource.url":            "http://x:8428",
			"alertmanager.enabled":             true,
			"alertmanager.replicaCount":        1,
			"alertmanager.mode":                "statefulSet",
			"server.notifier.alertmanager.url": "",
		},
		manifest: `
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMAlert
spec:
  image: {tag: "${server.image.tag}"}
  datasource: {url: "http://x:8428"}
  notifier: {url: "http://x:9093"}
---
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMAlertmanager
spec:
  image: {tag: "${alertmanager.image.tag}"}
  rollingUpdateStrategy: RollingUpdate
  replicaCount: 1
`,
		kinds: []string{"vmalert", "vmalertmanager"},
		ignore: []string{
			"Deployment/vmalert-compat volume=config",
			"Deployment/vmalert-compat volume=tls-assets",
			"StatefulSet/vmalertmanager-compat container=config-reloader",
			"StatefulSet/vmalertmanager-compat container[config-reloader]",
			"StatefulSet/vmalertmanager-compat volume=tls-assets",
			"StatefulSet/vmalertmanager-compat container[alertmanager].port=mesh-",
			"Service/vmalertmanager-compat port=tcp-mesh",
			"Service/vmalertmanager-compat port=udp-mesh",
		},
	},
	{
		chart:  "victoria-metrics-auth",
		values: map[string]any{"config.unauthorized_user.url_prefix": "http://x:8428"},
		manifest: `
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMAuth
spec:
  image: {tag: "${image.tag}"}
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
		values: map[string]any{
			"serviceAccount.create":  true,
			"vmselect.mode":          "statefulSet",
			"vmstorage.replicaCount": 1,
			"vmselect.replicaCount":  1,
			"vminsert.replicaCount":  1,
		},
		manifest: `
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMCluster
spec:
  clusterVersion: "${vmstorage.image.tag}-cluster"
  retentionPeriod: "1"
  vmstorage:
    replicaCount: 1
    rollingUpdateStrategy: RollingUpdate
    resources: {requests: {cpu: 10m, memory: 32Mi}}
    storage: {volumeClaimTemplate: {spec: {resources: {requests: {storage: 8Gi}}}}}
  vmselect:
    replicaCount: 1
    rollingUpdateStrategy: RollingUpdate
    resources: {requests: {cpu: 10m, memory: 32Mi}}
  vminsert:
    replicaCount: 1
    resources: {requests: {cpu: 10m, memory: 32Mi}}
`,
		kinds:         []string{"vmcluster", "vmstorage", "vmselect", "vminsert"},
		workloadKinds: []string{"vmstorage", "vmselect", "vminsert"},
		data:          metricsData("vminsert-compat/insert/0/prometheus", "vmselect-compat/select/0/prometheus"),
	},
	{
		chart: "victoria-logs-cluster",
		values: map[string]any{
			"serviceAccount.create":  true,
			"vlstorage.replicaCount": 1,
			"vlselect.replicaCount":  1,
			"vlinsert.replicaCount":  1,
		},
		manifest: `
apiVersion: operator.victoriametrics.com/v1
kind: VLCluster
spec:
  clusterVersion: "${vlstorage.image.tag}"
  vlstorage:
    replicaCount: 1
    rollingUpdateStrategy: RollingUpdate
    resources: {requests: {cpu: 10m, memory: 32Mi}}
    storage: {volumeClaimTemplate: {spec: {resources: {requests: {storage: 10Gi}}}}}
  vlselect:
    replicaCount: 1
    resources: {requests: {cpu: 10m, memory: 32Mi}}
  vlinsert:
    replicaCount: 1
    resources: {requests: {cpu: 10m, memory: 32Mi}}
`,
		kinds:         []string{"vlcluster", "vlstorage", "vlselect", "vlinsert"},
		workloadKinds: []string{"vlstorage", "vlselect", "vlinsert"},
		data:          logsData("vlinsert-compat", "vlselect-compat"),
	},
	{
		chart: "victoria-traces-cluster",
		values: map[string]any{
			"serviceAccount.create":  true,
			"vtstorage.replicaCount": 1,
			"vtselect.replicaCount":  1,
			"vtinsert.replicaCount":  1,
		},
		manifest: `
apiVersion: operator.victoriametrics.com/v1
kind: VTCluster
spec:
  clusterVersion: "${vtstorage.image.tag}"
  storage:
    replicaCount: 1
    rollingUpdateStrategy: RollingUpdate
    resources: {requests: {cpu: 10m, memory: 32Mi}}
    storage: {volumeClaimTemplate: {spec: {resources: {requests: {storage: 10Gi}}}}}
  select:
    replicaCount: 1
    resources: {requests: {cpu: 10m, memory: 32Mi}}
  insert:
    replicaCount: 1
    resources: {requests: {cpu: 10m, memory: 32Mi}}
`,
		kinds:         []string{"vtcluster", "vtstorage", "vtselect", "vtinsert"},
		workloadKinds: []string{"vtstorage", "vtselect", "vtinsert"},
		data:          tracesData("vtinsert-compat", "vtselect-compat"),
	},
	{
		chart: "victoria-metrics-anomaly",
		values: map[string]any{
			"license.secret.name":                  "license",
			"license.secret.key":                   "key",
			"persistentVolume.enabled":             true,
			"statefulSet.spec.podManagementPolicy": "Parallel",
			"service.enabled":                      true,
			"config.reader.datasource_url":         "http://vmsingle-datasource:8428",
			"config.reader.sampling_period":        "1m",
			"config.reader.queries.test.expr":      "sum(up)",
			"config.writer.datasource_url":         "http://vmsingle-datasource:8428",
			"config.models.test.class":             "zscore",
			"config.schedulers.test.class":         "scheduler.periodic.PeriodicScheduler",
			"config.schedulers.test.infer_every":   "1m",
			"config.schedulers.test.fit_every":     "2m",
			"config.schedulers.test.fit_window":    "3h",
		},
		manifest: `
apiVersion: operator.victoriametrics.com/v1
kind: VMAnomaly
spec:
  image: {tag: "${image.tag}"}
  license: {keyRef: {name: license, key: key}}
  configRawYaml: |
    reader:
      queries:
        test: {expr: "sum(up)"}
    models:
      test: {class: zscore}
    schedulers:
      test: {class: scheduler.periodic.PeriodicScheduler, infer_every: 1m, fit_every: 2m, fit_window: 3h}
  reader: {datasourceURL: "http://vmsingle-datasource:8428", samplingPeriod: 1m}
  writer: {datasourceURL: "http://vmsingle-datasource:8428"}
  storage:
    volumeClaimTemplate:
      spec:
        accessModes: [ReadWriteOnce]
        resources: {requests: {storage: 1Gi}}
`,
		kinds:      []string{"vmanomaly"},
		healthPath: "/health",
		ignore: []string{
			"ServiceAccount/vmanomaly-compat",
			"StatefulSet/vmanomaly-compat serviceAccountName=",
			"StatefulSet/vmanomaly-compat container[vmanomaly].port=monitoring-http",
			"StatefulSet/vmanomaly-compat volume=license",
			"StatefulSet/vmanomaly-compat volume=tls-assets",
		},
		prepare: func(t *testing.T, kubeconfig, namespace string) {
			_, err := kubectl(kubeconfig, `
apiVersion: v1
kind: Secret
metadata: {name: license}
stringData: {key: dummy}
---
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMSingle
metadata: {name: datasource}
spec: {}
`, "apply", "-n", namespace, "-f", "-")
			require.NoError(t, err)
		},
	},
	{
		chart: "victoria-metrics-estimator",
		values: map[string]any{
			"serviceAccount.create": true,
			"storage.replicaCount":  2,
			"select.enabled":        true,
			"config.data":           map[string]any{"streams": []any{map[string]any{"interval": "5m"}}},
		},
		manifest: `
apiVersion: operator.victoriametrics.com/v1
kind: VMEstimator
spec:
  streams: [{interval: 5m}]
  storage:
    replicaCount: 2
  select:
    replicaCount: 2
`,
		kinds:         []string{"vmestimator", "vmestimator-storage", "vmestimator-select"},
		workloadKinds: []string{"vmestimator-storage", "vmestimator-select"},
		ignore: []string{
			"StatefulSet/vmestimator-storage-compat container=config-reloader",
			"StatefulSet/vmestimator-storage-compat container[config-reloader]",
		},
	},
}

var manifestKindRe = regexp.MustCompile(`(?m)^kind: (\w+)$`)

func TestOperatorMigration(t *testing.T) {
	workdir, err := os.Getwd()
	require.NoError(t, err)
	chartsDir := filepath.Join(filepath.Dir(workdir), "charts")
	kc := getKubeconfig()
	client, err := newKubeClient(kc)
	require.NoError(t, err)

	for _, tc := range migrationCases {
		t.Run(tc.chart, func(t *testing.T) {
			t.Parallel()
			ctx := context.Background()
			namespace := fmt.Sprintf("migrate-%s", uniqueID())
			_, err := kubectl(kc, "", "create", "namespace", namespace)
			require.NoError(t, err)
			defer client.CoreV1().Namespaces().Delete(ctx, namespace, metav1.DeleteOptions{})                    //nolint:errcheck
			defer helmRun(kc, "uninstall", compatName, "--namespace", namespace, "--wait", "--ignore-not-found") //nolint:errcheck

			var crKinds []string
			for _, m := range manifestKindRe.FindAllStringSubmatch(tc.manifest, -1) {
				crKinds = append(crKinds, m[1])
			}
			workloadKinds := tc.workloadKinds
			if workloadKinds == nil {
				workloadKinds = tc.kinds
			}
			byChart := func(o *unstructured.Unstructured) bool {
				return len(o.GetOwnerReferences()) == 0 && o.GetAnnotations()["meta.helm.sh/release-name"] == compatName
			}
			byOperator := func(o *unstructured.Unstructured) bool {
				return slices.ContainsFunc(o.GetOwnerReferences(), func(r metav1.OwnerReference) bool {
					return slices.Contains(crKinds, r.Kind) && r.Name == compatName
				})
			}
			waitForStatus := func(status string) {
				t.Helper()
				for _, k := range crKinds {
					err := wait.PollUntilContextTimeout(ctx, pollingInterval, pollingTimeout, true, func(ctx context.Context) (bool, error) {
						out, err := kubectl(kc, "", "get", strings.ToLower(k), compatName, "-n", namespace, "-o", "jsonpath={.status.updateStatus}")
						return err == nil && string(out) == status, nil
					})
					require.NoError(t, err, "%s did not become %s", k, status)
				}
			}
			if tc.prepare != nil {
				tc.prepare(t, kc, namespace)
			}
			var points []dataPoint
			checkData := func(phase string) {
				t.Helper()
				if tc.data == nil {
					return
				}
				requireData(t, ctx, client, namespace, tc.data, points)
				points = append(points, writeData(t, ctx, client, namespace, tc.data, namespace+"-"+phase))
			}
			chartDir := filepath.Join(chartsDir, tc.chart)
			chartArgs := migrationHelmArgs(chartDir, namespace, tc.values)
			manifest, err := tc.expandManifest(chartDir)
			require.NoError(t, err)
			forgetRelease := func() {
				t.Helper()
				_, err := kubectl(kc, "", "delete", "secrets", "-n", namespace, "-l", fmt.Sprintf("owner=helm,name=%s", compatName))
				require.NoError(t, err)
			}

			out, err := helmRun(kc, chartArgs...)
			require.NoError(t, err, "helm install failed: %s", out)
			chartObjs := waitForRollout(t, ctx, kc, namespace, tc.kinds, workloadKinds, byChart)
			chartPVCs, err := releaseObjects(kc, namespace, "persistentvolumeclaims")
			require.NoError(t, err)
			requireAvailable(t, ctx, client, namespace, tc.health(), chartObjs)
			checkData("chart")

			forgetRelease()
			_, err = kubectl(kc, compatManifest(manifest), "apply", "-n", namespace, "-f", "-")
			require.NoError(t, err)
			waitForStatus("operational")
			operatorObjs := waitForRollout(t, ctx, kc, namespace, tc.kinds, workloadKinds, byOperator)
			requireSameContract(t, operatorObjs, chartObjs, tc.ignore, "chart %s differs from the operator", tc.chart)
			requireKept(t, chartPVCs, mustReleaseObjects(t, kc, namespace, "persistentvolumeclaims"))
			requireKept(t, chartObjs, operatorObjs)
			requireAvailable(t, ctx, client, namespace, tc.health(), operatorObjs)
			checkData("operator")

			for _, k := range crKinds {
				_, err = kubectl(kc, "", "patch", strings.ToLower(k), compatName, "-n", namespace, "--type=merge", "-p", `{"spec":{"paused":true}}`)
				require.NoError(t, err)
			}
			waitForStatus("paused")
			forgetRelease()
			for _, k := range crKinds {
				_, err = kubectl(kc, "", "delete", strings.ToLower(k), compatName, "-n", namespace, "--cascade=orphan")
				require.NoError(t, err)
			}
			handOverToHelm(t, kc, namespace)

			out, err = helmRun(kc, append(chartArgs, "--take-ownership", "--force-conflicts")...)
			require.NoError(t, err, "helm install --take-ownership --force-conflicts failed: %s", out)
			migratedObjs := waitForRollout(t, ctx, kc, namespace, tc.kinds, workloadKinds, byChart)
			requireSameContract(t, chartObjs, migratedObjs, nil, "chart %s changed after migrating back from the operator", tc.chart)
			requireKept(t, chartPVCs, mustReleaseObjects(t, kc, namespace, "persistentvolumeclaims"))
			requireKept(t, operatorObjs, migratedObjs)
			requireAvailable(t, ctx, client, namespace, tc.health(), migratedObjs)
			checkData("migrated")
		})
	}
}

func handOverToHelm(t *testing.T, kubeconfig, namespace string) {
	t.Helper()
	out, err := kubectl(kubeconfig, "", "get", "deployments,statefulsets,daemonsets,services,serviceaccounts,secrets,configmaps,poddisruptionbudgets",
		"-n", namespace, "-o", "json", "--show-managed-fields", "-l", fmt.Sprintf("app.kubernetes.io/instance=%s", compatName))
	require.NoError(t, err)
	var list unstructured.UnstructuredList
	require.NoError(t, json.Unmarshal(out, &list))
	for _, o := range list.Items {
		fields := map[string]any{}
		managed := []metav1.ManagedFieldsEntry{{Manager: "helm", Operation: metav1.ManagedFieldsOperationApply, APIVersion: o.GetAPIVersion(), FieldsType: "FieldsV1"}}
		for _, e := range o.GetManagedFields() {
			if e.Subresource != "" {
				managed = append(managed, e)
				continue
			}
			var f map[string]any
			require.NoError(t, json.Unmarshal(e.FieldsV1.Raw, &f))
			mergeFields(fields, f)
		}
		raw, err := json.Marshal(fields)
		require.NoError(t, err)
		managed[0].FieldsV1 = &metav1.FieldsV1{Raw: raw}
		patch, err := json.Marshal([]map[string]any{{"op": "replace", "path": "/metadata/managedFields", "value": managed}})
		require.NoError(t, err)
		_, err = kubectl(kubeconfig, "", "patch", strings.ToLower(o.GetKind()), o.GetName(), "-n", namespace, "--type=json", "-p", string(patch))
		require.NoError(t, err)
	}
}

func mergeFields(dst, src map[string]any) {
	for k, v := range src {
		sv, ok := v.(map[string]any)
		dv, dok := dst[k].(map[string]any)
		if ok && dok {
			mergeFields(dv, sv)
		} else {
			dst[k] = v
		}
	}
}

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

func compatObjects(kubeconfig, namespace string, kinds []string) ([]*unstructured.Unstructured, error) {
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
		if o.GetKind() == "PersistentVolumeClaim" && slices.ContainsFunc(claimPrefixes, func(p string) bool { return strings.HasPrefix(o.GetName(), p) }) {
			continue
		}
		objs = append(objs, o)
	}
	return objs, nil
}

func isWorkload(o *unstructured.Unstructured) bool {
	return slices.Contains([]string{"Deployment", "StatefulSet", "DaemonSet"}, o.GetKind())
}

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

func withoutOwnership(labels map[string]string) map[string]string {
	out := make(map[string]string, len(labels))
	for k, v := range labels {
		if k != "managed-by" && k != "app.kubernetes.io/managed-by" {
			out[k] = v
		}
	}
	return out
}

func waitForRollout(t *testing.T, ctx context.Context, kubeconfig, namespace string, kinds, workloadKinds []string, owned func(*unstructured.Unstructured) bool) []*unstructured.Unstructured {
	t.Helper()
	var objs []*unstructured.Unstructured
	err := wait.PollUntilContextTimeout(ctx, pollingInterval, pollingTimeout, true, func(ctx context.Context) (bool, error) {
		var err error
		objs, err = compatObjects(kubeconfig, namespace, kinds)
		if err != nil {
			return false, nil
		}
		for _, k := range workloadKinds {
			if !slices.ContainsFunc(objs, func(o *unstructured.Unstructured) bool {
				return isWorkload(o) && o.GetLabels()["app.kubernetes.io/name"] == k && owned(o)
			}) {
				return false, nil
			}
		}
		if slices.ContainsFunc(objs, func(o *unstructured.Unstructured) bool { return isWorkload(o) && !rolledOut(o) }) {
			return false, nil
		}
		out, err := kubectl(kubeconfig, "", "get", "pods", "-n", namespace, "-o", "json", "-l", "app.kubernetes.io/instance="+compatName)
		if err != nil {
			return false, nil
		}
		var pods unstructured.UnstructuredList
		if err := json.Unmarshal(out, &pods); err != nil {
			return false, nil
		}
		return !slices.ContainsFunc(pods.Items, func(p unstructured.Unstructured) bool { return p.GetDeletionTimestamp() != nil }), nil
	})
	require.NoError(t, err, "workloads for %v did not roll out", workloadKinds)
	return objs
}

func rolledOut(o *unstructured.Unstructured) bool {
	generation, _, _ := unstructured.NestedInt64(o.Object, "status", "observedGeneration")
	if generation < o.GetGeneration() {
		return false
	}
	if o.GetKind() == "DaemonSet" {
		desired, _, _ := unstructured.NestedInt64(o.Object, "status", "desiredNumberScheduled")
		updated, _, _ := unstructured.NestedInt64(o.Object, "status", "updatedNumberScheduled")
		ready, _, _ := unstructured.NestedInt64(o.Object, "status", "numberReady")
		return desired == updated && desired == ready
	}
	desired, found, _ := unstructured.NestedInt64(o.Object, "spec", "replicas")
	if !found {
		desired = 1
	}
	replicas, _, _ := unstructured.NestedInt64(o.Object, "status", "replicas")
	updated, _, _ := unstructured.NestedInt64(o.Object, "status", "updatedReplicas")
	ready, _, _ := unstructured.NestedInt64(o.Object, "status", "readyReplicas")
	if o.GetKind() == "StatefulSet" {
		current, _, _ := unstructured.NestedString(o.Object, "status", "currentRevision")
		update, _, _ := unstructured.NestedString(o.Object, "status", "updateRevision")
		if current != update {
			return false
		}
	}
	return replicas == desired && updated == desired && ready == desired
}

func requireSameContract(t *testing.T, expectedObjs, actualObjs []*unstructured.Unstructured, ignore []string, msg string, args ...any) {
	t.Helper()
	expected := filterIgnored(contract(expectedObjs), ignore)
	actual := filterIgnored(contract(actualObjs), ignore)
	var problems []string
	for _, line := range expected {
		if !slices.Contains(actual, line) {
			problems = append(problems, "missing:    "+line)
		}
	}
	for _, line := range actual {
		if !slices.Contains(expected, line) && contractObjectIn(line, expected) {
			problems = append(problems, "unexpected: "+line)
		}
	}
	require.Empty(t, problems, "%s:\n%s", fmt.Sprintf(msg, args...), strings.Join(problems, "\n"))
}

func requireKept(t *testing.T, expected, actual []*unstructured.Unstructured) {
	t.Helper()
	uids := make(map[string]string, len(actual))
	for _, o := range actual {
		uids[o.GetKind()+"/"+o.GetName()] = string(o.GetUID())
	}
	for _, o := range expected {
		if isWorkload(o) {
			continue
		}
		key := o.GetKind() + "/" + o.GetName()
		require.Equal(t, string(o.GetUID()), uids[key], "%s was recreated or removed", key)
	}
}

func migrationHelmArgs(chartDir, namespace string, values map[string]any) []string {
	args := []string{"install", compatName, chartDir, "--namespace", namespace, "--set", "useLegacyNaming=false"}
	for k, v := range values {
		b, _ := json.Marshal(v)
		args = append(args, "--set-json", k+"="+string(b))
	}
	return args
}

func helmRun(kubeconfig string, args ...string) ([]byte, error) {
	cmd := exec.Command("helm", append([]string{"--kubeconfig", kubeconfig}, args...)...)
	return cmd.CombinedOutput()
}

func mustReleaseObjects(t *testing.T, kubeconfig, namespace, resources string) []*unstructured.Unstructured {
	t.Helper()
	objs, err := releaseObjects(kubeconfig, namespace, resources)
	require.NoError(t, err)
	return objs
}

func releaseObjects(kubeconfig, namespace, resources string) ([]*unstructured.Unstructured, error) {
	out, err := kubectl(kubeconfig, "", "get", resources,
		"-n", namespace, "-o", "json",
		"-l", fmt.Sprintf("app.kubernetes.io/instance=%s", compatName))
	if err != nil {
		return nil, err
	}
	var list unstructured.UnstructuredList
	if err := json.Unmarshal(out, &list); err != nil {
		return nil, err
	}
	objs := make([]*unstructured.Unstructured, len(list.Items))
	for i := range list.Items {
		objs[i] = &list.Items[i]
	}
	return objs, nil
}

func serviceRequest(ctx context.Context, client *kubernetes.Clientset, namespace, target, body string) ([]byte, error) {
	svc, rest, _ := strings.Cut(target, "/")
	p, query, _ := strings.Cut(rest, "?")
	req := client.CoreV1().RESTClient().Get()
	if body != "" {
		req = client.CoreV1().RESTClient().Post().SetHeader("Content-Type", "application/json").Body([]byte(body))
	}
	req = req.AbsPath("/api/v1/namespaces", namespace, "services", svc+":http", "proxy", p)
	values, err := url.ParseQuery(query)
	if err != nil {
		return nil, err
	}
	for k, vs := range values {
		for _, v := range vs {
			req = req.Param(k, v)
		}
	}
	return req.DoRaw(ctx)
}

func pollService(ctx context.Context, client *kubernetes.Clientset, namespace, target, body string, done func([]byte) bool) ([]byte, error) {
	var out []byte
	var lastErr error
	err := wait.PollUntilContextTimeout(ctx, pollingInterval, pollingTimeout, true, func(ctx context.Context) (bool, error) {
		out, lastErr = serviceRequest(ctx, client, namespace, target, body)
		return lastErr == nil && done(out), nil
	})
	if lastErr != nil {
		return out, lastErr
	}
	return out, err
}

func requireAvailable(t *testing.T, ctx context.Context, client *kubernetes.Clientset, namespace, healthPath string, objs []*unstructured.Unstructured) {
	t.Helper()
	for _, o := range objs {
		if o.GetKind() != "Service" {
			continue
		}
		ports, _, _ := unstructured.NestedSlice(o.Object, "spec", "ports")
		if !slices.ContainsFunc(ports, func(p any) bool { return p.(map[string]any)["name"] == "http" }) {
			continue
		}
		_, err := pollService(ctx, client, namespace, o.GetName()+healthPath, "", func([]byte) bool { return true })
		require.NoError(t, err, "Service %s is not available", o.GetName())
	}
}

func writeData(t *testing.T, ctx context.Context, client *kubernetes.Clientset, namespace string, d *dataCheck, id string) dataPoint {
	t.Helper()
	target, body := d.write(id, time.Now())
	_, err := pollService(ctx, client, namespace, target, body, func([]byte) bool { return true })
	if err != nil {
		logDiagnostics(t, ctx, client, namespace)
	}
	require.NoError(t, err, "cannot write %s", id)
	out, err := pollService(ctx, client, namespace, d.read(id), "", func(out []byte) bool { return bytes.Contains(out, []byte(id)) })
	if err != nil {
		logDiagnostics(t, ctx, client, namespace)
	}
	require.NoError(t, err, "cannot read %s after writing it: %s", id, out)
	return dataPoint{id: id, result: string(out)}
}

func requireData(t *testing.T, ctx context.Context, client *kubernetes.Clientset, namespace string, d *dataCheck, points []dataPoint) {
	t.Helper()
	for _, p := range points {
		out, err := pollService(ctx, client, namespace, d.read(p.id), "", func(out []byte) bool { return string(out) == p.result })
		if err != nil {
			logDiagnostics(t, ctx, client, namespace)
		}
		require.NoError(t, err, "%s differs from what was read before migration:\nbefore: %s\nafter:  %s", p.id, p.result, out)
	}
}

func logDiagnostics(t *testing.T, ctx context.Context, client *kubernetes.Clientset, namespace string) {
	t.Helper()
	pods, err := client.CoreV1().Pods(namespace).List(ctx, metav1.ListOptions{})
	if err != nil {
		t.Logf("cannot list pods: %s", err)
		return
	}
	tail := int64(50)
	for _, p := range pods.Items {
		t.Logf("pod %s: phase=%s terminating=%t node=%s", p.Name, p.Status.Phase, p.DeletionTimestamp != nil, p.Spec.NodeName)
		for _, c := range p.Spec.Containers {
			logs, err := client.CoreV1().Pods(namespace).GetLogs(p.Name, &corev1.PodLogOptions{Container: c.Name, TailLines: &tail}).DoRaw(ctx)
			if err != nil {
				t.Logf("cannot get logs of %s/%s: %s", p.Name, c.Name, err)
				continue
			}
			t.Logf("logs of %s/%s:\n%s", p.Name, c.Name, logs)
		}
	}
}
