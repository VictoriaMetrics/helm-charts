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

	waitUntilStatefulSetAvailable(t, ctx, cp.client, cp.namespace, fmt.Sprintf("vmestimator-storage-%s", cp.releaseName))

	for _, role := range []string{"select", "storage"} {
		waitUntilServiceAvailable(t, ctx, cp.client, cp.namespace, fmt.Sprintf("vmestimator-%s-%s", role, cp.releaseName))
	}
}
