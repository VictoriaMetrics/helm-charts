package test

import (
	"context"
	"fmt"
	"testing"
)

// TestVictoriaTracesMCPInstallDefault tests that the victoria-traces-mcp chart can be installed with default values.
func TestVictoriaTracesMCPInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-traces-mcp"
	cp := chartInstall(t, name, map[string]string{
		"vt.entrypoint": "http://example.com",
	})
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	vtMCPName := fmt.Sprintf("%s-victoria-traces-mcp", cp.releaseName)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, vtMCPName)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, vtMCPName)
}
