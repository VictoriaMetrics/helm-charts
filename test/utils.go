package test

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/stretchr/testify/require"
	corev1 "k8s.io/api/core/v1"
	apiextensionsclientset "k8s.io/apiextensions-apiserver/pkg/client/clientset/clientset"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
)

const (
	pollingInterval     = 5 * time.Second
	pollingTimeout      = 10 * time.Minute
	resourceWaitTimeout = 1 * time.Minute
)

var (
	retries = int(resourceWaitTimeout.Seconds() / pollingInterval.Seconds())
)

type chartParams struct {
	opts        *helm.Options
	releaseName string
	name        string
	client      *kubernetes.Clientset
}

func chartCleanup(t *testing.T, ctx context.Context, p *chartParams) {
	o := p.opts
	releaseName := p.releaseName
	namespaceName := o.KubectlOptions.Namespace
	helm.Delete(t, o, releaseName, true)

	kubeConfigPath, err := o.KubectlOptions.GetConfigPath(t)
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
	defer k8s.DeleteNamespace(t, o.KubectlOptions, namespaceName)
}

func chartInstall(t *testing.T, name string, values map[string]string) *chartParams {
	workdir, err := os.Getwd()
	require.NoError(t, err)
	chartDir := filepath.Join(filepath.Dir(workdir), "charts", name)
	var prefix string
	for _, p := range strings.Split(name, "-") {
		if len(p) > 0 {
			prefix += string(p[0])
		}
	}
	namespaceName := fmt.Sprintf("%s-%s", prefix, strings.ToLower(random.UniqueId()))
	releaseName := fmt.Sprintf("%s-%s", prefix, strings.ToLower(random.UniqueId()))
	k8sOpts := k8s.NewKubectlOptions("", "", namespaceName)
	client, err := k8s.GetKubernetesClientFromOptionsE(t, k8sOpts)
	require.NoError(t, err)
	if n, ok := values["license.secret.name"]; ok {
		k8s.CreateNamespace(t, k8sOpts, namespaceName)
		_, err := client.CoreV1().Secrets(namespaceName).Create(context.TODO(), &corev1.Secret{
			ObjectMeta: metav1.ObjectMeta{Name: n},
			StringData: map[string]string{
				values["license.secret.key"]: os.Getenv("LICENSE_KEY"),
			},
		}, metav1.CreateOptions{})
		require.NoError(t, err)
	}

	o := &helm.Options{
		BuildDependencies: true,
		KubectlOptions:    k8sOpts,
		ExtraArgs: map[string][]string{
			"upgrade": {"--create-namespace", "--wait"},
		},
		EnvVars: map[string]string{
			"HELM_CACHE_HOME": filepath.Join(workdir, ".cache", namespaceName),
		},
		SetValues: values,
	}
	helm.Upgrade(t, o, chartDir, releaseName)
	return &chartParams{
		releaseName: releaseName,
		name:        name,
		opts:        o,
		client:      client,
	}
}
