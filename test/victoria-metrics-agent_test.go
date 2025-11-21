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

// TestVictoriaMetricsAgentInstallDefault tests that the victoria-metrics-agent chart can be installed with default values.
func TestVictoriaMetricsAgentInstallDefault(t *testing.T) {
	const helmChartPath = "../charts/victoria-metrics-agent"

	namespaceName := fmt.Sprintf("vmagent-%s", strings.ToLower(random.UniqueId()))
	k8sOpts := k8s.NewKubectlOptions("", "", namespaceName)

	helmOpts := &helm.Options{
		BuildDependencies: true,
		KubectlOptions:    k8sOpts,
		ExtraArgs: map[string][]string{
			"upgrade": {"--create-namespace", "--wait"},
		},
		SetValues: map[string]string{
			"remoteWrite[0].url": "http://example.com:9428",
		},
	}

	// Install the chart and verify no errors occurred.
	releaseName := fmt.Sprintf("vmagent-%s", strings.ToLower(random.UniqueId()))
	defer helmCleanup(context.Background(), t, k8sOpts, helmOpts, releaseName)
	helm.Upgrade(t, helmOpts, helmChartPath, releaseName)

	vmAgent := fmt.Sprintf("%s-victoria-metrics-agent", releaseName)
	k8s.WaitUntilDeploymentAvailable(t, k8sOpts, vmAgent, retries, pollingInterval)
}
