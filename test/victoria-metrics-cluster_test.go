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

// TestVictoriaMetricsClusterInstallDefault tests that the victoria-metrics-cluster chart can be installed with default values.
func TestVictoriaMetricsClusterInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-metrics-cluster"
	cp := chartInstall(t, name, nil)
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	// Verify vminsert StatefulSet was created and is ready
	releaseName := cp.releaseName
	o := cp.opts
	namespaceName := o.KubectlOptions.Namespace
	vminsertName := fmt.Sprintf("%s-%s-vminsert", releaseName, name)
	k8s.WaitUntilDeploymentAvailable(t, o.KubectlOptions, vminsertName, retries, pollingInterval)

	// Verify vmselect StatefulSet was created and is ready
	vmselectName := fmt.Sprintf("%s-%s-vmselect", releaseName, name)
	k8s.WaitUntilDeploymentAvailable(t, o.KubectlOptions, vmselectName, retries, pollingInterval)

	// Verify vmstorage StatefulSet was created and is ready
	vmstorageName := fmt.Sprintf("%s-%s-vmstorage", releaseName, name)
	var statefulSet *appsv1.StatefulSet
	err := wait.PollUntilContextTimeout(context.Background(), pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		statefulSet, err = cp.client.AppsV1().StatefulSets(namespaceName).Get(ctx, vmstorageName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		// Ensure all replicas are ready
		return statefulSet.Status.ReadyReplicas == *statefulSet.Spec.Replicas && *statefulSet.Spec.Replicas > 0, nil
	})
	require.NoError(t, err)
	require.NotNil(t, statefulSet)

	// Verify vminsert Service was created and is available
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, vminsertName, retries, pollingInterval)

	// Verify vmselect Service was created and is available
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, vmselectName, retries, pollingInterval)

	// Verify vmstorage Service was created and is available (headless service for pods)
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, vmstorageName, retries, pollingInterval)
}
