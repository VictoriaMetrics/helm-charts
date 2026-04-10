package test

import (
	"context"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
)

// TestVictoriaLogsMCPInstallDefault tests that the victoria-logs-mcp chart can be installed with default values.
func TestVictoriaLogsMCPInstallDefault(t *testing.T) {
	name := "victoria-logs-mcp"
	cp := chartInstall(t, name, map[string]string{
		"vl.entrypoint": "http://example.com",
	})

	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)
	releaseName := cp.releaseName
	o := cp.opts

	// Verify the Deployment was created and is ready using manual polling
	vmMCPName := fmt.Sprintf("%s-victoria-logs-mcp", releaseName)
	k8s.WaitUntilDeploymentAvailable(t, o.KubectlOptions, vmMCPName, retries, pollingInterval)
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, vmMCPName, retries, pollingInterval)
}
