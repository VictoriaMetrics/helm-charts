package test

import (
	"context"
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/stretchr/testify/require"
	appsv1 "k8s.io/api/apps/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/wait"
)

func TestVictoriaMetricsK8sStackBasic(t *testing.T) {
	const helmChartPath = "../charts/victoria-metrics-k8s-stack"

	namespaceName := fmt.Sprintf("vmstack-%s", strings.ToLower(random.UniqueId()))
	k8sOpts := k8s.NewKubectlOptions("", "", namespaceName)

	helmOpts := &helm.Options{
		BuildDependencies: true,
		KubectlOptions:    k8sOpts,
		ExtraArgs: map[string][]string{
			"upgrade": {"--create-namespace", "--wait"},
		},
	}

	releaseName := fmt.Sprintf("vm-%s", strings.ToLower(random.UniqueId()))
	defer helmCleanup(context.Background(), t, k8sOpts, helmOpts, releaseName)
	helm.Upgrade(t, helmOpts, helmChartPath, releaseName)

	k8sClient, err := k8s.GetKubernetesClientFromOptionsE(t, k8sOpts)
	require.NoError(t, err)

	// Verify victoria-metrics-operator components
	operatorName := fmt.Sprintf("%s-victoria-metrics-operator", releaseName)
	k8s.WaitUntilDeploymentAvailable(t, k8sOpts, operatorName, retries, pollingInterval)

	// Verify kube-state-metrics components
	kubeStateMetricsName := fmt.Sprintf("%s-kube-state-metrics", releaseName)
	k8s.WaitUntilDeploymentAvailable(t, k8sOpts, kubeStateMetricsName, retries, pollingInterval)
	k8s.WaitUntilServiceAvailable(t, k8sOpts, kubeStateMetricsName, retries, pollingInterval)

	// Verify prometheus-node-exporter components (DaemonSet)
	promNodeExporterName := fmt.Sprintf("%s-prometheus-node-exporter", releaseName)
	var daemonset *appsv1.DaemonSet
	err = wait.PollUntilContextTimeout(context.Background(), pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		daemonset, err = k8sClient.AppsV1().DaemonSets(namespaceName).Get(ctx, promNodeExporterName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		return daemonset.Status.CurrentNumberScheduled == daemonset.Status.DesiredNumberScheduled &&
			daemonset.Status.NumberReady == daemonset.Status.DesiredNumberScheduled, nil
	})
	require.NoError(t, err)
	require.NotNil(t, daemonset)
	k8s.WaitUntilServiceAvailable(t, k8sOpts, promNodeExporterName, retries, pollingInterval)

	// Verify Grafana components (if enabled by default)
	grafanaName := fmt.Sprintf("%s-grafana", releaseName)
	// Check if grafana deployment exists before waiting, as it might be optional (e.g., if it's set to replicaCount: 0 or disabled)
	k8s.WaitUntilDeploymentAvailable(t, k8sOpts, grafanaName, retries, pollingInterval)
	k8s.WaitUntilServiceAvailable(t, k8sOpts, grafanaName, retries, pollingInterval)
	k8s.WaitUntilSecretAvailable(t, k8sOpts, grafanaName, retries, pollingInterval)
	k8s.WaitUntilConfigMapAvailable(t, k8sOpts, grafanaName, retries, pollingInterval)
	k8s.WaitUntilConfigMapAvailable(t, k8sOpts, fmt.Sprintf("%s-grafana-config-dashboards", releaseName), retries, pollingInterval)
}
