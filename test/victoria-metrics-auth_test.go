package test

import (
	"context"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
)

// TestVictoriaMetricsAuthInstallDefault tests that the victoria-metrics-auth chart can be installed with default values.
func TestVictoriaMetricsAuthInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-metrics-auth"
	cp := chartInstall(t, name, nil)
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)
	releaseName := cp.releaseName
	o := cp.opts

	// Verify the Deployment was created and is ready
	vmAuthName := fmt.Sprintf("%s-%s", releaseName, name)
	k8s.WaitUntilDeploymentAvailable(t, o.KubectlOptions, vmAuthName, retries, pollingInterval)

	// Verify the Service was created and is available
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, vmAuthName, retries, pollingInterval)
}
