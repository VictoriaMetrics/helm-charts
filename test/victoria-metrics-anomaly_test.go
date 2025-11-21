package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
)

// TestVictoriaMetricsAnomalyInstallDefault tests that the victoria-metrics-anomaly chart can be installed with default values.
func TestVictoriaMetricsAnomalyInstallDefault(t *testing.T) {
	const helmChartPath = "../charts/victoria-metrics-anomaly"

	namespaceName := fmt.Sprintf("vmanomaly-%s", strings.ToLower(random.UniqueId()))
	k8sOpts := k8s.NewKubectlOptions("", "", namespaceName)
	k8s.CreateNamespace(t, k8sOpts, namespaceName)
	defer k8s.DeleteNamespace(t, k8sOpts, namespaceName)

	// TODO: this needs license details
	// options := &helm.Options{
	// 	BuildDependencies: true,
	// 	KubectlOptions:    kubectlOptions,
	// }

}
