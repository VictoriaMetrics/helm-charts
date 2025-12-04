package test

import (
	"context"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/require"
	appsv1 "k8s.io/api/apps/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/wait"
)

func TestVictoriaMetricsK8sStackBasic(t *testing.T) {
	cp := chartInstall(t, "victoria-metrics-k8s-stack", nil)
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	// Verify victoria-metrics-operator components
	releaseName := cp.releaseName
	o := cp.opts
	namespaceName := o.KubectlOptions.Namespace
	operatorName := fmt.Sprintf("%s-victoria-metrics-operator", releaseName)
	k8s.WaitUntilDeploymentAvailable(t, o.KubectlOptions, operatorName, retries, pollingInterval)

	// Verify kube-state-metrics components
	kubeStateMetricsName := fmt.Sprintf("%s-kube-state-metrics", releaseName)
	k8s.WaitUntilDeploymentAvailable(t, o.KubectlOptions, kubeStateMetricsName, retries, pollingInterval)
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, kubeStateMetricsName, retries, pollingInterval)

	// Verify prometheus-node-exporter components (DaemonSet)
	promNodeExporterName := fmt.Sprintf("%s-prometheus-node-exporter", releaseName)
	var daemonset *appsv1.DaemonSet
	err := wait.PollUntilContextTimeout(context.Background(), pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		daemonset, err = cp.client.AppsV1().DaemonSets(namespaceName).Get(ctx, promNodeExporterName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		return daemonset.Status.CurrentNumberScheduled == daemonset.Status.DesiredNumberScheduled &&
			daemonset.Status.NumberReady == daemonset.Status.DesiredNumberScheduled, nil
	})
	require.NoError(t, err)
	require.NotNil(t, daemonset)
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, promNodeExporterName, retries, pollingInterval)

	// Verify Grafana components (if enabled by default)
	grafanaName := fmt.Sprintf("%s-grafana", releaseName)
	// Check if grafana deployment exists before waiting, as it might be optional (e.g., if it's set to replicaCount: 0 or disabled)
	k8s.WaitUntilDeploymentAvailable(t, o.KubectlOptions, grafanaName, retries, pollingInterval)
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, grafanaName, retries, pollingInterval)
	k8s.WaitUntilSecretAvailable(t, o.KubectlOptions, grafanaName, retries, pollingInterval)
	k8s.WaitUntilConfigMapAvailable(t, o.KubectlOptions, grafanaName, retries, pollingInterval)
	k8s.WaitUntilConfigMapAvailable(t, o.KubectlOptions, fmt.Sprintf("%s-grafana-config-dashboards", releaseName), retries, pollingInterval)
}
