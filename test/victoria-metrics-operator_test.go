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

// TestVictoriaMetricsOperatorInstallDefault tests that the victoria-metrics-operator chart can be installed with default values.
func TestVictoriaMetricsOperatorInstallDefault(t *testing.T) {
	const helmChartPath = "../charts/victoria-metrics-operator"

	namespaceName := fmt.Sprintf("vmoperator-%s", strings.ToLower(random.UniqueId()))
	k8sOpts := k8s.NewKubectlOptions("", "", namespaceName)

	helmOpts := &helm.Options{
		BuildDependencies: true,
		KubectlOptions:    k8sOpts,
		ExtraArgs: map[string][]string{
			"upgrade": {"--create-namespace", "--wait"},
		},
	}

	// Install the chart and verify no errors occurred.
	releaseName := fmt.Sprintf("vmoperator-%s", strings.ToLower(random.UniqueId()))
	defer helmCleanup(context.Background(), t, k8sOpts, helmOpts, releaseName)
	helm.Upgrade(t, helmOpts, helmChartPath, releaseName)

	// Verify the Deployment was created and is ready
	deploymentName := fmt.Sprintf("%s-victoria-metrics-operator", releaseName)
	k8s.WaitUntilDeploymentAvailable(t, k8sOpts, deploymentName, retries, pollingInterval)
}
