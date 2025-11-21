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

// TestVictoriaMetricsAlertInstallDefault tests that the victoria-metrics-alert chart can be installed with default values.
func TestVictoriaMetricsAlertInstallDefault(t *testing.T) {
	const helmChartPath = "../charts/victoria-metrics-alert"

	namespaceName := fmt.Sprintf("vmalert-%s", strings.ToLower(random.UniqueId()))
	k8sOpts := k8s.NewKubectlOptions("", "", namespaceName)

	helmOpts := &helm.Options{
		BuildDependencies: true,
		KubectlOptions:    k8sOpts,
		ExtraArgs: map[string][]string{
			"upgrade": {"--create-namespace", "--wait"},
		},
		SetValues: map[string]string{
			"server.datasource.url": "http://example.com",
		},
	}

	// Install the chart and verify no errors occurred.
	releaseName := fmt.Sprintf("vmalert-%s", strings.ToLower(random.UniqueId()))
	defer helmCleanup(context.Background(), t, k8sOpts, helmOpts, releaseName)
	helm.Upgrade(t, helmOpts, helmChartPath, releaseName)

	// Verify the Deployment was created and is ready using manual polling
	vmAlertName := fmt.Sprintf("%s-victoria-metrics-alert-server", releaseName)
	k8s.WaitUntilDeploymentAvailable(t, k8sOpts, vmAlertName, retries, pollingInterval)
	k8s.WaitUntilServiceAvailable(t, k8sOpts, vmAlertName, retries, pollingInterval)
}
