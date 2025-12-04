package test

import (
	"context"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
)

// TestVictoriaMetricsOperatorInstallDefault tests that the victoria-metrics-operator chart can be installed with default values.
func TestVictoriaMetricsOperatorInstallDefault(t *testing.T) {
	name := "victoria-metrics-operator"
	cp := chartInstall(t, name, nil)
	releaseName := cp.releaseName
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)
	o := cp.opts

	// Verify the Deployment was created and is ready
	deploymentName := fmt.Sprintf("%s-%s", releaseName, name)
	k8s.WaitUntilDeploymentAvailable(t, o.KubectlOptions, deploymentName, retries, pollingInterval)
}
