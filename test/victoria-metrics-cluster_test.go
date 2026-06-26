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

// TestVictoriaMetricsClusterInstallDefault tests that the victoria-metrics-cluster chart can be installed with default values.
func TestVictoriaMetricsClusterInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-metrics-cluster"
	cp := chartInstall(t, name, nil)
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	vminsertName := fmt.Sprintf("%s-%s-vminsert", cp.releaseName, name)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, vminsertName)

	vmselectName := fmt.Sprintf("%s-%s-vmselect", cp.releaseName, name)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, vmselectName)

	vmstorageName := fmt.Sprintf("%s-%s-vmstorage", cp.releaseName, name)
	var statefulSet *appsv1.StatefulSet
	err := wait.PollUntilContextTimeout(ctx, pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		statefulSet, err = cp.client.AppsV1().StatefulSets(cp.namespace).Get(ctx, vmstorageName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		return statefulSet.Status.ReadyReplicas == *statefulSet.Spec.Replicas && *statefulSet.Spec.Replicas > 0, nil
	})
	require.NoError(t, err)
	require.NotNil(t, statefulSet)

	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, vminsertName)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, vmselectName)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, vmstorageName)
}
