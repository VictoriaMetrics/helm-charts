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

// TestVictoriaMetricsClusterInstallDefault tests that the victoria-metrics-cluster chart can be installed with default values.
func TestVictoriaMetricsClusterInstallDefault(t *testing.T) {
	const helmChartPath = "../charts/victoria-metrics-cluster"

	namespaceName := fmt.Sprintf("vmcluster-%s", strings.ToLower(random.UniqueId()))
	k8sOpts := k8s.NewKubectlOptions("", "", namespaceName)

	helmOpts := &helm.Options{
		BuildDependencies: true,
		KubectlOptions:    k8sOpts,
		ExtraArgs: map[string][]string{
			"upgrade": {"--create-namespace", "--wait"},
		},
	}

	// Install the chart and verify no errors occurred.
	releaseName := fmt.Sprintf("vmcluster-%s", strings.ToLower(random.UniqueId()))
	defer helmCleanup(context.Background(), t, k8sOpts, helmOpts, releaseName)
	helm.Upgrade(t, helmOpts, helmChartPath, releaseName)

	k8sClient, err := k8s.GetKubernetesClientFromOptionsE(t, k8sOpts)
	require.NoError(t, err)

	// Verify vminsert StatefulSet was created and is ready
	vminsertName := fmt.Sprintf("%s-victoria-metrics-cluster-vminsert", releaseName)
	k8s.WaitUntilDeploymentAvailable(t, k8sOpts, vminsertName, retries, pollingInterval)

	// Verify vmselect StatefulSet was created and is ready
	vmselectName := fmt.Sprintf("%s-victoria-metrics-cluster-vmselect", releaseName)
	k8s.WaitUntilDeploymentAvailable(t, k8sOpts, vmselectName, retries, pollingInterval)

	// Verify vmstorage StatefulSet was created and is ready
	vmstorageName := fmt.Sprintf("%s-victoria-metrics-cluster-vmstorage", releaseName)
	var statefulSet *appsv1.StatefulSet
	err = wait.PollUntilContextTimeout(context.Background(), pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		statefulSet, err = k8sClient.AppsV1().StatefulSets(namespaceName).Get(ctx, vmstorageName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		// Ensure all replicas are ready
		return statefulSet.Status.ReadyReplicas == *statefulSet.Spec.Replicas && *statefulSet.Spec.Replicas > 0, nil
	})
	require.NoError(t, err)
	require.NotNil(t, statefulSet)

	// Verify vminsert Service was created and is available
	k8s.WaitUntilServiceAvailable(t, k8sOpts, vminsertName, retries, pollingInterval)

	// Verify vmselect Service was created and is available
	k8s.WaitUntilServiceAvailable(t, k8sOpts, vmselectName, retries, pollingInterval)

	// Verify vmstorage Service was created and is available (headless service for pods)
	k8s.WaitUntilServiceAvailable(t, k8sOpts, vmstorageName, retries, pollingInterval)
}
