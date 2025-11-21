package test

import (
	"context"
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
)

// TestVictoriaMetricsAuthInstallDefault tests that the victoria-metrics-auth chart can be installed with default values.
func TestVictoriaMetricsAuthInstallDefault(t *testing.T) {
	const helmChartPath = "../charts/victoria-metrics-auth"

	namespaceName := fmt.Sprintf("vmauth-%s", strings.ToLower(random.UniqueId()))
	k8sOpts := k8s.NewKubectlOptions("", "", namespaceName)

	helmOpts := &helm.Options{
		BuildDependencies: true,
		KubectlOptions:    k8sOpts,
		ExtraArgs: map[string][]string{
			"upgrade": {"--create-namespace", "--wait"},
		},
	}

	// Install the chart and verify no errors occurred.
	releaseName := fmt.Sprintf("vmauth-%s", strings.ToLower(random.UniqueId()))
	defer helmCleanup(context.Background(), t, k8sOpts, helmOpts, releaseName)
	helm.Upgrade(t, helmOpts, helmChartPath, releaseName)

	// Verify the Deployment was created and is ready
	vmAuthName := fmt.Sprintf("%s-victoria-metrics-auth", releaseName)
	k8s.WaitUntilDeploymentAvailable(t, k8sOpts, vmAuthName, retries, pollingInterval)

	// Verify the Service was created and is available
	k8s.WaitUntilServiceAvailable(t, k8sOpts, vmAuthName, retries, pollingInterval)
}
