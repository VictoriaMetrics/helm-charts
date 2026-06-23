package test

import (
	"context"
	"fmt"
	"testing"
)

// TestVictoriaMetricsAnomalyInstallDefault tests that the victoria-metrics-anomaly chart can be installed with default values.
func TestVictoriaMetricsAnomalyInstallDefault(t *testing.T) {
	t.Parallel()
	scp := setupVictoriaMetricsSingle(t)
	ctx := context.Background()
	defer chartCleanup(t, ctx, scp)

	name := "victoria-metrics-anomaly"
	cp := chartInstall(t, name, map[string]string{
		"config.models.test.class":            "auto",
		"config.models.test.tuned_class_name": "zscore",
		"config.models.test.queries[0]":       "test",
		"config.reader.datasource_url":        fmt.Sprintf("http://%s-%s-server.%s.svc:8428", scp.releaseName, scp.name, scp.namespace),
		"config.reader.queries.test.expr":     "sum(test)",
		"config.writer.datasource_url":        fmt.Sprintf("http://%s-%s-server.%s.svc:8428", scp.releaseName, scp.name, scp.namespace),
		"config.schedulers.test.class":        "scheduler.periodic.PeriodicScheduler",
		"config.schedulers.test.infer_every":  "1m",
		"config.schedulers.test.fit_every":    "2m",
		"config.schedulers.test.fit_window":   "3h",
		"license.secret.name":                 "license",
		"license.secret.key":                  "key",
	})
	defer chartCleanup(t, ctx, cp)

	vmAnomalyName := fmt.Sprintf("%s-%s", cp.releaseName, name)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, vmAnomalyName)
}
