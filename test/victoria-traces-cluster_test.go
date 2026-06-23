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

// TestVictoriaTracesClusterInstallDefault tests that the victoria-traces-cluster chart can be installed with default values.
func TestVictoriaTracesClusterInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-traces-cluster"
	chartName := "vt-cluster"
	cp := chartInstall(t, name, nil)
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	vtStorageName := fmt.Sprintf("%s-%s-vtstorage", cp.releaseName, chartName)
	var vtStorageStatefulSet *appsv1.StatefulSet
	err := wait.PollUntilContextTimeout(ctx, pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		vtStorageStatefulSet, err = cp.client.AppsV1().StatefulSets(cp.namespace).Get(ctx, vtStorageName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		return vtStorageStatefulSet.Status.ReadyReplicas == *vtStorageStatefulSet.Spec.Replicas && *vtStorageStatefulSet.Spec.Replicas > 0, nil
	})
	require.NoError(t, err)
	require.NotNil(t, vtStorageStatefulSet)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, vtStorageName)

	vtInsertName := fmt.Sprintf("%s-%s-vtinsert", cp.releaseName, chartName)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, vtInsertName)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, vtInsertName)

	vtSelectName := fmt.Sprintf("%s-%s-vtselect", cp.releaseName, chartName)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, vtSelectName)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, vtSelectName)
}
