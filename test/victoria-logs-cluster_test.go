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

// TestVictoriaLogsClusterInstallDefault tests that the victoria-logs-cluster chart can be installed with default values.
func TestVictoriaLogsClusterInstallDefault(t *testing.T) {
	const helmChartPath = "../charts/victoria-logs-cluster"

	namespaceName := fmt.Sprintf("vlogcluster-%s", strings.ToLower(random.UniqueId()))
	k8sOpts := k8s.NewKubectlOptions("", "", namespaceName)

	helmOpts := &helm.Options{
		BuildDependencies: true,
		KubectlOptions:    k8sOpts,
		ExtraArgs: map[string][]string{
			"upgrade": {"--create-namespace", "--wait"},
		},
	}

	// Install the chart and verify no errors occurred.
	releaseName := fmt.Sprintf("vlogcluster-%s", strings.ToLower(random.UniqueId()))
	defer helmCleanup(context.Background(), t, k8sOpts, helmOpts, releaseName)
	helm.Upgrade(t, helmOpts, helmChartPath, releaseName)

	k8sClient, err := k8s.GetKubernetesClientFromOptionsE(t, k8sOpts)
	require.NoError(t, err)

	// Verify log-storage StatefulSet was created and is ready using manual polling
	logStorageStatefulSetName := fmt.Sprintf("%s-victoria-logs-cluster-vlstorage", releaseName)
	var logStorageStatefulSet *appsv1.StatefulSet
	err = wait.PollUntilContextTimeout(context.Background(), pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		logStorageStatefulSet, err = k8sClient.AppsV1().StatefulSets(namespaceName).Get(ctx, logStorageStatefulSetName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		// Ensure all replicas are ready
		return logStorageStatefulSet.Status.ReadyReplicas == *logStorageStatefulSet.Spec.Replicas && *logStorageStatefulSet.Spec.Replicas > 0, nil
	})
	require.NoError(t, err)
	require.NotNil(t, logStorageStatefulSet)

	// Verify vlinsert Service was created and is available
	vlInsertName := fmt.Sprintf("%s-victoria-logs-cluster-vlinsert", releaseName)
	k8s.WaitUntilServiceAvailable(t, k8sOpts, vlInsertName, retries, resourceWaitTimeout)

	// Verify vlselect Service was created and is available
	vlSelectName := fmt.Sprintf("%s-victoria-logs-cluster-vlselect", releaseName)
	k8s.WaitUntilServiceAvailable(t, k8sOpts, vlSelectName, retries, resourceWaitTimeout)

	// Verify vlselect Service was created and is available
	vlStorage := fmt.Sprintf("%s-victoria-logs-cluster-vlstorage", releaseName)
	k8s.WaitUntilServiceAvailable(t, k8sOpts, vlStorage, retries, resourceWaitTimeout)
}
