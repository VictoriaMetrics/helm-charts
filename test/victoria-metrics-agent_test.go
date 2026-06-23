package test

import (
	"context"
	"fmt"
	"testing"
)

// TestVictoriaMetricsAgentInstallDefault tests that the victoria-metrics-agent chart can be installed with default values.
func TestVictoriaMetricsAgentInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-metrics-agent"
	cp := chartInstall(t, name, map[string]string{
		"remoteWrite[0].url": "http://example.com:9428",
	})
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	vmAgent := fmt.Sprintf("%s-%s", cp.releaseName, name)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, vmAgent)
}
