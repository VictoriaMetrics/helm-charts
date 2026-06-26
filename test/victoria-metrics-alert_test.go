package test

import (
	"context"
	"fmt"
	"testing"
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

	vmAlertName := fmt.Sprintf("%s-%s-server", cp.releaseName, name)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, vmAlertName)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, vmAlertName)
}
