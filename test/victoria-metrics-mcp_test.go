package test

import (
	"context"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
)

// TestVictoriaMetricsMCPInstallDefault tests that the victoria-metrics-mcp chart can be installed with default values.
func TestVictoriaMetricsMCPInstallDefault(t *testing.T) {
	name := "victoria-metrics-mcp"
	cp := chartInstall(t, name, map[string]string{
		"vm.entrypoint": "http://example.com",
	})

	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)
	releaseName := cp.releaseName
	o := cp.opts

	// Verify the Deployment was created and is ready using manual polling
	vmMCPName := fmt.Sprintf("%s-victoria-metrics-mcp", releaseName)
	k8s.WaitUntilDeploymentAvailable(t, o.KubectlOptions, vmMCPName, retries, pollingInterval)
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, vmMCPName, retries, pollingInterval)
}
