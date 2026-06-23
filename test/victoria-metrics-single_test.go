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

func setupVictoriaMetricsSingle(t *testing.T) *chartParams {
	name := "victoria-metrics-single"
	cp := chartInstall(t, name, nil)

	statefulSetName := fmt.Sprintf("%s-%s-server", cp.releaseName, name)
	var statefulSet *appsv1.StatefulSet
	err := wait.PollUntilContextTimeout(context.Background(), pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		statefulSet, err = cp.client.AppsV1().StatefulSets(cp.namespace).Get(ctx, statefulSetName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		return statefulSet.Status.ReadyReplicas == *statefulSet.Spec.Replicas && *statefulSet.Spec.Replicas > 0, nil
	})
	require.NoError(t, err)
	require.NotNil(t, statefulSet)

	waitUntilServiceAvailable(t, context.Background(), cp.client, cp.namespace, statefulSetName)
	return cp
}

// TestVictoriaMetricsSingleInstallDefault tests that the victoria-metrics-single chart can be installed with default values.
func TestVictoriaMetricsSingleInstallDefault(t *testing.T) {
	t.Parallel()
	cp := setupVictoriaMetricsSingle(t)
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)
}
