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

// TestVictoriaLogsCollectorInstallDefault tests that the victoria-logs-collector chart can be installed with default values.
func TestVictoriaLogsCollectorInstallDefault(t *testing.T) {
	const helmChartPath = "../charts/victoria-logs-collector"

	namespaceName := fmt.Sprintf("vlogcollector-%s", strings.ToLower(random.UniqueId()))
	k8sOpts := k8s.NewKubectlOptions("", "", namespaceName)

	helmOpts := &helm.Options{
		BuildDependencies: true,
		KubectlOptions:    k8sOpts,
		ExtraArgs: map[string][]string{
			"upgrade": {"--create-namespace", "--wait"},
		},
		SetValues: map[string]string{
			"remoteWrite[0].url": "http://victoria-logs-1:9428",
		},
	}

	// Install the chart and verify no errors occurred.
	releaseName := fmt.Sprintf("vlog-collector-%s", strings.ToLower(random.UniqueId()))
	defer helmCleanup(context.Background(), t, k8sOpts, helmOpts, releaseName)
	helm.Upgrade(t, helmOpts, helmChartPath, releaseName)

	k8sClient, err := k8s.GetKubernetesClientFromOptionsE(t, k8sOpts)
	require.NoError(t, err)

	// Verify the DaemonSet was created and is ready using manual polling
	daemonSetName := fmt.Sprintf("%s-victoria-logs-collector", releaseName)
	var daemonset *appsv1.DaemonSet
	err = wait.PollUntilContextTimeout(context.Background(), pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		daemonset, err = k8sClient.AppsV1().DaemonSets(namespaceName).Get(ctx, daemonSetName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		return daemonset.Status.CurrentNumberScheduled == daemonset.Status.DesiredNumberScheduled &&
			daemonset.Status.NumberReady == daemonset.Status.DesiredNumberScheduled, nil
	})
	require.NoError(t, err)
	require.NotNil(t, daemonset)
}
