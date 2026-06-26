package test

import (
	"context"
	"fmt"
	"testing"
)

// TestVictoriaMetricsMCPInstallDefault tests that the victoria-metrics-mcp chart can be installed with default values.
func TestVictoriaMetricsMCPInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-metrics-mcp"
	cp := chartInstall(t, name, map[string]string{
		"vm.entrypoint": "http://example.com",
	})
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	vmMCPName := fmt.Sprintf("%s-victoria-metrics-mcp", cp.releaseName)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, vmMCPName)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, vmMCPName)
}
