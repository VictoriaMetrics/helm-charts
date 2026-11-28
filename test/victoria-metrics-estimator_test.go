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

	name := fmt.Sprintf("vmestimator-storage-%s", cp.releaseName)
	waitUntilStatefulSetAvailable(t, ctx, cp.client, cp.namespace, name)
	waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, name)
}
