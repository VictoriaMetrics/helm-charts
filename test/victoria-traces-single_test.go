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

// TestVictoriaTracesSingleInstallDefault tests that the victoria-traces-single chart can be installed with default values.
func TestVictoriaTracesSingleInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-traces-single"
	chartName := "vt-single"
	cp := chartInstall(t, name, nil)
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	singleName := fmt.Sprintf("%s-%s-server", cp.releaseName, chartName)
	var statefulSet *appsv1.StatefulSet
	err := wait.PollUntilContextTimeout(ctx, pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		statefulSet, err = cp.client.AppsV1().StatefulSets(cp.namespace).Get(ctx, singleName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		return statefulSet.Status.ReadyReplicas == *statefulSet.Spec.Replicas && *statefulSet.Spec.Replicas > 0, nil
	})
	require.NoError(t, err)
	require.NotNil(t, statefulSet)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, singleName)
}
