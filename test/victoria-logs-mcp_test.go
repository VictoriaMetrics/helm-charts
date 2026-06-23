package test

import (
	"context"
	"fmt"
	"testing"
)

// TestVictoriaLogsMCPInstallDefault tests that the victoria-logs-mcp chart can be installed with default values.
func TestVictoriaLogsMCPInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-logs-mcp"
	cp := chartInstall(t, name, map[string]string{
		"vl.entrypoint": "http://example.com",
	})
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	vmMCPName := fmt.Sprintf("%s-victoria-logs-mcp", cp.releaseName)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, vmMCPName)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, vmMCPName)
}
