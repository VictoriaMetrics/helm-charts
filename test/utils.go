package test

import (
	"context"
	"testing"
	"time"

	apiextensionsclientset "k8s.io/apiextensions-apiserver/pkg/client/clientset/clientset"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/tools/clientcmd"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/stretchr/testify/require"
)

const (
	pollingInterval     = 5 * time.Second
	pollingTimeout      = 10 * time.Minute
	resourceWaitTimeout = 1 * time.Minute
)

var (
	retries = int(resourceWaitTimeout.Seconds() / pollingInterval.Seconds())
)

func helmCleanup(ctx context.Context, t *testing.T, k8sOpts *k8s.KubectlOptions, helmOpts *helm.Options, releaseName string) {
	helm.Delete(t, helmOpts, releaseName, true)

	kubeConfigPath, err := k8sOpts.GetConfigPath(t)
	require.NoError(t, err)
	clientConfig := clientcmd.NewNonInteractiveDeferredLoadingClientConfig(
		&clientcmd.ClientConfigLoadingRules{ExplicitPath: kubeConfigPath}, &clientcmd.ConfigOverrides{})
	restConfig, err := clientConfig.ClientConfig()
	require.NoError(t, err)
	extendedClient, err := apiextensionsclientset.NewForConfig(restConfig)
	require.NoError(t, err)

	crds, err := extendedClient.ApiextensionsV1().CustomResourceDefinitions().List(ctx, metav1.ListOptions{})
	require.NoError(t, err)
	for _, crd := range crds.Items {
		if crd.Spec.Group == "operator.victoriametrics.com" {
			err = extendedClient.ApiextensionsV1().CustomResourceDefinitions().Delete(ctx, crd.Name, metav1.DeleteOptions{})
			require.NoError(t, err)
		}
	}
}
