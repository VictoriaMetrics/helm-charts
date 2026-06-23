package test

import (
	"context"
	"fmt"
	"testing"
)

// TestVictoriaMetricsOperatorInstallDefault tests that the victoria-metrics-operator chart can be installed with default values.
func TestVictoriaMetricsOperatorInstallDefault(t *testing.T) {
	name := "victoria-metrics-operator"
	cp := chartInstall(t, name, nil)
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	deploymentName := fmt.Sprintf("%s-%s", cp.releaseName, name)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, deploymentName)
}
