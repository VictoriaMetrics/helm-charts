package test

import (
	"context"
	"fmt"
	"os"
	"testing"
)

// TestVictoriaMetricsGatewayInstallDefault tests that the victoria-metrics-gateway chart can be installed with default values.
func TestVictoriaMetricsGatewayInstallDefault(t *testing.T) {
	if os.Getenv("LICENSE_KEY") == "" {
		t.Skip("Skipping test in repo fork")
	}
	t.Parallel()
	name := "victoria-metrics-gateway"
	cp := chartInstall(t, name, map[string]string{
		"clusterMode":         "true",
		"auth.enabled":        "true",
		"license.secret.name": "license",
		"license.secret.key":  "key",
		"read.url":            "http://cluster-victoria-metrics-cluster-vmselect.default.svc.cluster.local:8481",
		"write.url":           "http://cluster-victoria-metrics-cluster-vminsert.default.svc.cluster.local:8480",
	})
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	vmGatewayName := fmt.Sprintf("%s-%s", cp.releaseName, name)
	waitUntilDeploymentAvailable(t, ctx, cp.client, cp.namespace, vmGatewayName)
}
