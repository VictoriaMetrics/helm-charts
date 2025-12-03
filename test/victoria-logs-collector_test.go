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

// TestVictoriaLogsCollectorInstallDefault tests that the victoria-logs-collector chart can be installed with default values.
func TestVictoriaLogsCollectorInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-logs-collector"
	cp := chartInstall(t, name, map[string]string{
		"remoteWrite[0].url": "http://victoria-logs-1:9428",
	})
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	// Verify the DaemonSet was created and is ready using manual polling
	releaseName := cp.releaseName
	o := cp.opts
	namespaceName := o.KubectlOptions.Namespace
	daemonSetName := fmt.Sprintf("%s-%s", releaseName, name)
	var daemonset *appsv1.DaemonSet
	err := wait.PollUntilContextTimeout(ctx, pollingInterval, pollingTimeout, true, func(ctx context.Context) (done bool, err error) {
		daemonset, err = cp.client.AppsV1().DaemonSets(namespaceName).Get(ctx, daemonSetName, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		return daemonset.Status.CurrentNumberScheduled == daemonset.Status.DesiredNumberScheduled &&
			daemonset.Status.NumberReady == daemonset.Status.DesiredNumberScheduled, nil
	})
	require.NoError(t, err)
	require.NotNil(t, daemonset)
}
