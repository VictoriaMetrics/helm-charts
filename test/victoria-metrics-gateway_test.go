package test

import (
	"context"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
)

// TestVictoriaMetricsGatewayInstallDefault tests that the victoria-metrics-gateway chart can be installed with default values.
func TestVictoriaMetricsGatewayInstallDefault(t *testing.T) {
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
	o := cp.opts
	ctx := context.Background()
	defer chartCleanup(t, ctx, cp)

	// Install the chart and verify no errors occurred.
	releaseName := cp.releaseName

	// Verify vmgateway Deployment was created and is ready
	vmGatewayName := fmt.Sprintf("%s-%s", releaseName, name)
	k8s.WaitUntilDeploymentAvailable(t, o.KubectlOptions, vmGatewayName, retries, pollingInterval)
}
