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

// TestVictoriaTracesClusterInstallDefault tests that the victoria-traces-cluster chart can be installed with default values.
func TestVictoriaTracesClusterInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-traces-cluster"
	chartName := "vt-cluster"
	cp := chartInstall(t, name, nil)
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)
	releaseName := cp.releaseName
	o := cp.opts
	namespaceName := o.KubectlOptions.Namespace

	// Verify trace-ingester StatefulSet was created and is ready using manual polling
	vtStorageName := fmt.Sprintf("%s-%s-vtstorage", releaseName, chartName)
	var vtStorageStatefulSet *appsv1.StatefulSet
	err := wait.PollUntilContextTimeout(context.Background(), pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		vtStorageStatefulSet, err = cp.client.AppsV1().StatefulSets(namespaceName).Get(ctx, vtStorageName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		// Ensure all replicas are ready
		return vtStorageStatefulSet.Status.ReadyReplicas == *vtStorageStatefulSet.Spec.Replicas && *vtStorageStatefulSet.Spec.Replicas > 0, nil
	})
	require.NoError(t, err)
	require.NotNil(t, vtStorageStatefulSet)
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, vtStorageName, retries, pollingInterval)

	// Verify vtinsert Deployment was created and is ready using manual polling
	vtInsertName := fmt.Sprintf("%s-%s-vtinsert", releaseName, chartName)
	k8s.WaitUntilDeploymentAvailable(t, o.KubectlOptions, vtInsertName, retries, pollingInterval)
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, vtInsertName, retries, pollingInterval)

	// Verify vtselect Deployment was created and is ready using manual polling
	vtSelectName := fmt.Sprintf("%s-%s-vtselect", releaseName, chartName)
	k8s.WaitUntilDeploymentAvailable(t, o.KubectlOptions, vtSelectName, retries, pollingInterval)
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, vtSelectName, retries, pollingInterval)
}
