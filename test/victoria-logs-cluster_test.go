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

// TestVictoriaLogsClusterInstallDefault tests that the victoria-logs-cluster chart can be installed with default values.
func TestVictoriaLogsClusterInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-logs-cluster"
	ctx := context.Background()
	cp := chartInstall(t, name, nil)
	defer chartCleanup(t, ctx, cp)

	// Verify log-storage StatefulSet was created and is ready using manual polling
	releaseName := cp.releaseName
	o := cp.opts
	namespaceName := o.KubectlOptions.Namespace
	logStorageStatefulSetName := fmt.Sprintf("%s-%s-vlstorage", releaseName, name)
	var logStorageStatefulSet *appsv1.StatefulSet
	err := wait.PollUntilContextTimeout(ctx, pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		logStorageStatefulSet, err = cp.client.AppsV1().StatefulSets(namespaceName).Get(ctx, logStorageStatefulSetName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		// Ensure all replicas are ready
		return logStorageStatefulSet.Status.ReadyReplicas == *logStorageStatefulSet.Spec.Replicas && *logStorageStatefulSet.Spec.Replicas > 0, nil
	})
	require.NoError(t, err)
	require.NotNil(t, logStorageStatefulSet)

	// Verify vlinsert Service was created and is available
	vlInsertName := fmt.Sprintf("%s-%s-vlinsert", releaseName, name)
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, vlInsertName, retries, resourceWaitTimeout)

	// Verify vlselect Service was created and is available
	vlSelectName := fmt.Sprintf("%s-%s-vlselect", releaseName, name)
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, vlSelectName, retries, resourceWaitTimeout)

	// Verify vlselect Service was created and is available
	vlStorage := fmt.Sprintf("%s-%s-vlstorage", releaseName, name)
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, vlStorage, retries, resourceWaitTimeout)
}
