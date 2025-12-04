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

// TestVictoriaLogsSingleInstallDefault tests that the victoria-logs-single chart can be installed with default values.
func TestVictoriaLogsSingleInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-logs-single"
	cp := chartInstall(t, name, nil)
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	// Verify the StatefulSet was created and is ready using manual polling
	releaseName := cp.releaseName
	o := cp.opts
	namespaceName := o.KubectlOptions.Namespace
	statefulSetName := fmt.Sprintf("%s-%s-server", releaseName, name)
	var statefulSet *appsv1.StatefulSet
	err := wait.PollUntilContextTimeout(ctx, pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		statefulSet, err = cp.client.AppsV1().StatefulSets(namespaceName).Get(ctx, statefulSetName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		// Ensure all replicas are ready
		return statefulSet.Status.ReadyReplicas == *statefulSet.Spec.Replicas && *statefulSet.Spec.Replicas > 0, nil
	})
	require.NoError(t, err)
	require.NotNil(t, statefulSet)

	// Verify the Service was created and is available
	serviceName := fmt.Sprintf("%s-%s-server", releaseName, name)
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, serviceName, retries, pollingInterval)
}
