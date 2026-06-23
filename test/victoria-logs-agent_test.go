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

// TestVictoriaLogsAgentInstallDefault tests that the victoria-logs-agent chart can be installed with default values.
func TestVictoriaLogsAgentInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-logs-agent"
	cp := chartInstall(t, name, map[string]string{
		"remoteWrite[0].url": "http://example.com:9428",
		"service.enabled":    "true",
	})
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	statefulSetName := fmt.Sprintf("%s-%s", cp.releaseName, name)
	var statefulSet *appsv1.StatefulSet
	err := wait.PollUntilContextTimeout(ctx, pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		statefulSet, err = cp.client.AppsV1().StatefulSets(cp.namespace).Get(ctx, statefulSetName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		return statefulSet.Status.ReadyReplicas == *statefulSet.Spec.Replicas && *statefulSet.Spec.Replicas > 0, nil
	})
	require.NoError(t, err)
	require.NotNil(t, statefulSet)

	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, statefulSetName)
}
