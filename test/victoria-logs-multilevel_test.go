package test

import (
	"context"
	"fmt"
	"testing"
)

// TestVictoriaLogsMultilevelInstallDefault tests that the victoria-logs-multilevel chart can be installed with default values.
func TestVictoriaLogsMultilevelInstallDefault(t *testing.T) {
	t.Parallel()
	name := "victoria-logs-multilevel"
	cp := chartInstall(t, name, map[string]string{
		"storageNodes[0]": "http://example.com:9428",
	})
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	logSelectDeploymentName := fmt.Sprintf("%s-%s-vlselect", cp.releaseName, name)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, logSelectDeploymentName)

	vmAuthName := fmt.Sprintf("%s-%s-vmauth", cp.releaseName, name)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, vmAuthName)
}
