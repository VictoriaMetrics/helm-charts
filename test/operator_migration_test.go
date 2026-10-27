//go:build operatorcompat

package test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"slices"
	"sort"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/util/wait"
)

const compatName = "compat"

type migrationCase struct {
	// chart is a chart directory name under charts/
	chart string
	// values are passed to helm install with --set-json
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

var migrationCases = []migrationCase{
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
		values: map[string]any{"remoteWrite": []any{map[string]any{"url": "http://x:9428"}}, "service.enabled": true, "podManagementPolicy": "Parallel"},
		manifest: `
apiVersion: operator.victoriametrics.com/v1
kind: VLAgent
spec:
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
  rollingUpdateStrategy: RollingUpdate
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
    rollingUpdateStrategy: RollingUpdate
    resources: {requests: {cpu: 10m, memory: 32Mi}}
    storage: {volumeClaimTemplate: {spec: {resources: {requests: {storage: 8Gi}}}}}
  vmselect:
    replicaCount: 2
    rollingUpdateStrategy: RollingUpdate
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
    rollingUpdateStrategy: RollingUpdate
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
    rollingUpdateStrategy: RollingUpdate
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

var manifestKindRe = regexp.MustCompile(`(?m)^kind: (\w+)$`)

// TestOperatorMigration checks that a release installed with `useLegacyNaming: false` can be replaced
// by an equivalent operator custom resource and back. Pods may be restarted, and the operator may recreate
// StatefulSets with changed claim templates, but Services, ServiceAccounts and PersistentVolumeClaims have
// to be kept, and workloads, services, service accounts, volumes, containers and ports have to be named
// the same way by the chart and the operator.
//
// Chart -> operator:
//  1. Helm release secrets are deleted, so that Helm forgets the release without deleting its objects;
//  2. the custom resource is applied, the operator adopts objects with the same names, updating them
//     in place or, e.g. for StatefulSets with changed claim templates, recreating them without their pods.
//
// Operator -> chart:
//  1. the custom resource is paused, so that an in-flight reconcile doesn't put back owner references
//     the orphaning delete removes, which would make the garbage collector delete the objects;
//  2. `kubectl delete <cr> --cascade=orphan` removes the custom resource without deleting its children;
//  3. fields managed by the operator are handed over to Helm's field manager, otherwise server-side apply
//     would keep fields the chart doesn't render, e.g. an httpGet probe next to the chart's tcpSocket one;
//  4. `helm install --take-ownership --force-conflicts` adopts the objects in place, removing such fields.
//
// The operator has to be running in the cluster before the test starts.
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
			chartDir := filepath.Join(chartsDir, tc.chart)
			chartArgs := migrationHelmArgs("install", chartDir, namespace, tc.values)

			out, err := helmRun(kc, chartArgs...)
			require.NoError(t, err, "helm install failed: %s", out)
			chartObjs := waitForRollout(t, ctx, kc, namespace, tc.kinds, workloadKinds, byChart)
			chartPVCs, err := releaseObjects(kc, namespace, "persistentvolumeclaims")
			require.NoError(t, err)

			_, err = kubectl(kc, "", "delete", "secrets", "-n", namespace, "-l", fmt.Sprintf("owner=helm,name=%s", compatName))
			require.NoError(t, err)
			_, err = kubectl(kc, compatManifest(tc.manifest), "apply", "-n", namespace, "-f", "-")
			require.NoError(t, err)
			waitForStatus("operational")
			operatorObjs := waitForRollout(t, ctx, kc, namespace, tc.kinds, workloadKinds, byOperator)
			requireSameContract(t, operatorObjs, chartObjs, tc.ignore, "chart %s differs from the operator", tc.chart)
			requireKept(t, chartPVCs, mustReleaseObjects(t, kc, namespace, "persistentvolumeclaims"))
			requireKept(t, chartObjs, operatorObjs)

			for _, k := range crKinds {
				_, err = kubectl(kc, "", "patch", strings.ToLower(k), compatName, "-n", namespace, "--type=merge", "-p", `{"spec":{"paused":true}}`)
				require.NoError(t, err)
			}
			waitForStatus("paused")
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
		})
	}
}

// handOverToHelm makes Helm's field manager the only owner of all non-subresource fields of compatName objects,
// so that `helm install --take-ownership` removes fields the chart doesn't render.
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

// mergeFields adds the field set src to dst.
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

// compatObjects returns compatName objects of the given kinds, whether created by the chart or by the operator.
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
		// claims created by the StatefulSet controller from volumeClaimTemplates aren't rendered by charts
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

// waitForRollout waits until every workload kind has a workload matching owned and all compatName
// workloads finished rolling out, then returns compatName objects of the given kinds.
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
		return !slices.ContainsFunc(objs, func(o *unstructured.Unstructured) bool { return isWorkload(o) && !rolledOut(o) }), nil
	})
	require.NoError(t, err, "workloads for %v did not roll out", workloadKinds)
	return objs
}

// rolledOut reports whether all replicas of a workload are updated and ready.
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

// requireSameContract checks that actual objects are named the same way as expected ones,
// ignoring objects present only in actual.
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

// requireKept checks that every expected object except workloads, which may be recreated,
// is still present in actual with the same UID.
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

// migrationHelmArgs builds a helm install or upgrade run of the compatName release with operator naming.
func migrationHelmArgs(verb, chartDir, namespace string, values map[string]any) []string {
	args := []string{verb, compatName, chartDir, "--namespace", namespace, "--set", "useLegacyNaming=false"}
	return append(args, migrationValues(values)...)
}

func migrationValues(values map[string]any) []string {
	var args []string
	for k, v := range values {
		b, _ := json.Marshal(v)
		args = append(args, "--set-json", k+"="+string(b))
	}
	return args
}

// helmRun runs an arbitrary helm command against the test cluster, returning combined output.
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

// releaseObjects returns compatName objects of the given resources, regardless of which controller created them.
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
