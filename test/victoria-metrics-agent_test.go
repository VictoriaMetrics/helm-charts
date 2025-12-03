package test

import (
	"context"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
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

	// Install the chart and verify no errors occurred.
	releaseName := cp.releaseName
	o := cp.opts
	vmAgent := fmt.Sprintf("%s-%s", releaseName, name)
	k8s.WaitUntilDeploymentAvailable(t, o.KubectlOptions, vmAgent, retries, pollingInterval)
}
