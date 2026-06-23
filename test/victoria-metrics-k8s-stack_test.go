package test

import (
	"context"
	"fmt"
	"testing"

	"github.com/stretchr/testify/require"
	appsv1 "k8s.io/api/apps/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/wait"
)

func TestVictoriaMetricsK8sStackBasic(t *testing.T) {
	cp := chartInstall(t, "victoria-metrics-k8s-stack", nil)
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	operatorName := fmt.Sprintf("%s-victoria-metrics-operator", cp.releaseName)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, operatorName)

	kubeStateMetricsName := fmt.Sprintf("%s-kube-state-metrics", cp.releaseName)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, kubeStateMetricsName)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, kubeStateMetricsName)

	promNodeExporterName := fmt.Sprintf("%s-prometheus-node-exporter", cp.releaseName)
	var daemonset *appsv1.DaemonSet
	err := wait.PollUntilContextTimeout(ctx, pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		daemonset, err = cp.client.AppsV1().DaemonSets(cp.namespace).Get(ctx, promNodeExporterName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		return daemonset.Status.CurrentNumberScheduled == daemonset.Status.DesiredNumberScheduled &&
			daemonset.Status.NumberReady == daemonset.Status.DesiredNumberScheduled, nil
	})
	require.NoError(t, err)
	require.NotNil(t, daemonset)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, promNodeExporterName)

	grafanaName := fmt.Sprintf("%s-grafana", cp.releaseName)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, grafanaName)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, grafanaName)
	waitUntilSecretAvailable(t, ctx, cp.client, cp.namespace, grafanaName)
	waitUntilConfigMapAvailable(t, ctx, cp.client, cp.namespace, grafanaName)
	waitUntilConfigMapAvailable(t, ctx, cp.client, cp.namespace, fmt.Sprintf("%s-grafana-config-dashboards", cp.releaseName))
}
