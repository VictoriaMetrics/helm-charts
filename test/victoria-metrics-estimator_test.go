package test

import (
	"context"
	"fmt"
	"testing"
)

func TestVictoriaMetricsEstimatorInstallDefault(t *testing.T) {
	t.Parallel()
	cp := chartInstall(t, "victoria-metrics-estimator", nil)
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	deploymentName := fmt.Sprintf("vmestimator-single-%s", cp.releaseName)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, deploymentName)

	serviceName := fmt.Sprintf("vmestimator-%s", cp.releaseName)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, serviceName)

	insertServiceName := fmt.Sprintf("vmestimator-insert-%s", cp.releaseName)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, insertServiceName)
}
