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

// TestVictoriaLogsClusterInstallDefault tests that the victoria-logs-cluster chart can be installed with default values.
func TestVictoriaLogsClusterInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-logs-cluster"
	ctx := context.Background()
	cp := chartInstall(t, name, nil)
	defer chartCleanup(t, ctx, cp)

	logStorageStatefulSetName := fmt.Sprintf("%s-%s-vlstorage", cp.releaseName, name)
	var logStorageStatefulSet *appsv1.StatefulSet
	err := wait.PollUntilContextTimeout(ctx, pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		logStorageStatefulSet, err = cp.client.AppsV1().StatefulSets(cp.namespace).Get(ctx, logStorageStatefulSetName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		return logStorageStatefulSet.Status.ReadyReplicas == *logStorageStatefulSet.Spec.Replicas && *logStorageStatefulSet.Spec.Replicas > 0, nil
	})
	require.NoError(t, err)
	require.NotNil(t, logStorageStatefulSet)

	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, fmt.Sprintf("%s-%s-vlinsert", cp.releaseName, name))
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, fmt.Sprintf("%s-%s-vlselect", cp.releaseName, name))
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, fmt.Sprintf("%s-%s-vlstorage", cp.releaseName, name))
}
