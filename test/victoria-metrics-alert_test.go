package test

import (
	"context"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
)

// TestVictoriaMetricsAlertInstallDefault tests that the victoria-metrics-alert chart can be installed with default values.
func TestVictoriaMetricsAlertInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-metrics-alert"
	cp := chartInstall(t, name, map[string]string{
		"server.datasource.url": "http://example.com",
	})
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)
	releaseName := cp.releaseName
	o := cp.opts

	// Verify the Deployment was created and is ready using manual polling
	vmAlertName := fmt.Sprintf("%s-%s-server", releaseName, name)
	k8s.WaitUntilDeploymentAvailable(t, o.KubectlOptions, vmAlertName, retries, pollingInterval)
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, vmAlertName, retries, pollingInterval)
}
