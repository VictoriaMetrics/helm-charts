package test

import (
	"context"
	"fmt"
	"testing"
)

// TestVictoriaMetricsAuthInstallDefault tests that the victoria-metrics-auth chart can be installed with default values.
func TestVictoriaMetricsAuthInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-metrics-auth"
	cp := chartInstall(t, name, nil)
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	vmAuthName := fmt.Sprintf("%s-%s", cp.releaseName, name)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, vmAuthName)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, vmAuthName)
}
