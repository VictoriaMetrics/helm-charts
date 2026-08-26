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

	name := fmt.Sprintf("vmestimator-single-%s", cp.releaseName)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, name)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, name)
}
