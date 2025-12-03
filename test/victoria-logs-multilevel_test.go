package test

import (
	"context"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
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

	// Verify log-storage StatefulSet was created and is ready using manual polling
	releaseName := cp.releaseName
	o := cp.opts
	logSelectDeploymentName := fmt.Sprintf("%s-%s-vlselect", releaseName, name)
	k8s.WaitUntilDeploymentAvailable(t, o.KubectlOptions, logSelectDeploymentName, retries, pollingInterval)

	// Verify vmauth Service was created and is available
	vmAuthName := fmt.Sprintf("%s-%s-vmauth", releaseName, name)
	k8s.WaitUntilServiceAvailable(t, o.KubectlOptions, vmAuthName, retries, resourceWaitTimeout)
}
