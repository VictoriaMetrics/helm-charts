package test

import (
	"bytes"
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
	corev1 "k8s.io/api/core/v1"
	apiextensionsclientset "k8s.io/apiextensions-apiserver/pkg/client/clientset/clientset"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/wait"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	discovery "k8s.io/api/discovery/v1"
)

const (
	pollingInterval     = 2 * time.Second
	pollingTimeout      = 10 * time.Minute
	resourceWaitTimeout = 1 * time.Minute
)

// lineWriter prefixes each output line with timestamp and test name, writing
// directly to os.Stdout so output is visible in real-time for parallel tests.
type lineWriter struct {
	name string
	buf  []byte
}

func newLineWriter(t *testing.T) *lineWriter {
	return &lineWriter{name: t.Name()}
}

func (lw *lineWriter) Write(p []byte) (int, error) {
	lw.buf = append(lw.buf, p...)
	for {
		i := bytes.IndexByte(lw.buf, '\n')
		if i < 0 {
			break
		}
		fmt.Fprintf(os.Stdout, "%s %s\t%s\n", time.Now().Format("15:04:05"), lw.name, lw.buf[:i])
		lw.buf = lw.buf[i+1:]
	}
	return len(p), nil
}

type chartParams struct {
	namespace   string
	releaseName string
	name        string
	client      *kubernetes.Clientset
	kubeconfig  string
}

func getKubeconfig() string {
	if kc := os.Getenv("KUBECONFIG"); kc != "" {
		return kc
	}
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".kube", "config")
}

func uniqueID() string {
	b := make([]byte, 3)
	_, _ = rand.Read(b)
	return hex.EncodeToString(b)
}

func newKubeClient(kubeconfigPath string) (*kubernetes.Clientset, error) {
	cfg, err := clientcmd.BuildConfigFromFlags("", kubeconfigPath)
	if err != nil {
		return nil, err
	}
	return kubernetes.NewForConfig(cfg)
}

func chartInstall(t *testing.T, name string, values map[string]string) *chartParams {
	t.Helper()
	workdir, err := os.Getwd()
	require.NoError(t, err)
	chartDir := filepath.Join(filepath.Dir(workdir), "charts", name)

	var prefix string
	for _, p := range strings.Split(name, "-") {
		if len(p) > 0 {
			prefix += string(p[0])
		}
	}
	namespace := fmt.Sprintf("%s-%s", prefix, uniqueID())
	releaseName := fmt.Sprintf("%s-%s", prefix, uniqueID())

	kc := getKubeconfig()
	client, err := newKubeClient(kc)
	require.NoError(t, err)

	_, err = client.CoreV1().Namespaces().Create(context.Background(), &corev1.Namespace{
		ObjectMeta: metav1.ObjectMeta{Name: namespace},
	}, metav1.CreateOptions{})
	require.NoError(t, err)

	if n, ok := values["license.secret.name"]; ok {
		_, err = client.CoreV1().Secrets(namespace).Create(context.Background(), &corev1.Secret{
			ObjectMeta: metav1.ObjectMeta{Name: n},
			StringData: map[string]string{
				values["license.secret.key"]: os.Getenv("LICENSE_KEY"),
			},
		}, metav1.CreateOptions{})
		require.NoError(t, err)
	}

	helmArgs := []string{
		"install", releaseName, chartDir,
		"--kubeconfig", kc,
		"--namespace", namespace,
		"--wait",
		"--timeout", "10m0s",
	}
	for k, v := range values {
		helmArgs = append(helmArgs, "--set", k+"="+v)
	}
	w := newLineWriter(t)
	cmd := exec.Command("helm", helmArgs...)
	cmd.Stdout = w
	cmd.Stderr = w
	err = cmd.Run()
	require.NoError(t, err)

	return &chartParams{
		namespace:   namespace,
		releaseName: releaseName,
		name:        name,
		client:      client,
		kubeconfig:  kc,
	}
}

func chartCleanup(t *testing.T, ctx context.Context, p *chartParams) {
	t.Helper()
	w := newLineWriter(t)
	cmd := exec.Command("helm", "uninstall", p.releaseName,
		"--kubeconfig", p.kubeconfig,
		"--namespace", p.namespace,
		"--wait",
	)
	cmd.Stdout = w
	cmd.Stderr = w
	_ = cmd.Run()

	cfg, err := clientcmd.BuildConfigFromFlags("", p.kubeconfig)
	if err == nil {
		extClient, err := apiextensionsclientset.NewForConfig(cfg)
		if err == nil {
			crds, err := extClient.ApiextensionsV1().CustomResourceDefinitions().List(ctx, metav1.ListOptions{})
			if err == nil {
				for _, crd := range crds.Items {
					if crd.Spec.Group == "operator.victoriametrics.com" {
						_ = extClient.ApiextensionsV1().CustomResourceDefinitions().Delete(ctx, crd.Name, metav1.DeleteOptions{})
					}
				}
			}
		}
	}
	_ = p.client.CoreV1().Namespaces().Delete(ctx, p.namespace, metav1.DeleteOptions{})
}

func waitUntilDeploymentAvailable(t *testing.T, ctx context.Context, client *kubernetes.Clientset, namespace, name string) {
	t.Helper()
	err := wait.PollUntilContextTimeout(ctx, pollingInterval, pollingTimeout, true, func(ctx context.Context) (bool, error) {
		d, err := client.AppsV1().Deployments(namespace).Get(ctx, name, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		return d.Status.ReadyReplicas == d.Status.Replicas && d.Status.Replicas > 0, nil
	})
	require.NoError(t, err, "deployment %s not available", name)
}

func waitUntilServiceAvailable(t *testing.T, ctx context.Context, client *kubernetes.Clientset, namespace, name string) {
	t.Helper()
	err := wait.PollUntilContextTimeout(ctx, pollingInterval, pollingTimeout, true, func(ctx context.Context) (bool, error) {
		svc, err := client.CoreV1().Services(namespace).Get(ctx, name, metav1.GetOptions{})
		if err != nil {
			return false, nil
		}
		if svc.Spec.Type == corev1.ServiceTypeLoadBalancer && len(svc.Status.LoadBalancer.Ingress) == 0 {
			return false, nil
		}
		slices, err := client.DiscoveryV1().EndpointSlices(namespace).List(ctx, metav1.ListOptions{
			LabelSelector: discovery.LabelServiceName + "=" + name,
		})
		if err != nil {
			return false, nil
		}
		for _, slice := range slices.Items {
			for _, ep := range slice.Endpoints {
				if ep.Conditions.Ready != nil && *ep.Conditions.Ready {
					return true, nil
				}
			}
		}
		return false, nil
	})
	require.NoError(t, err, "service %s not available", name)
}

func waitUntilSecretAvailable(t *testing.T, ctx context.Context, client *kubernetes.Clientset, namespace, name string) {
	t.Helper()
	err := wait.PollUntilContextTimeout(ctx, pollingInterval, resourceWaitTimeout, true, func(ctx context.Context) (bool, error) {
		_, err := client.CoreV1().Secrets(namespace).Get(ctx, name, metav1.GetOptions{})
		return err == nil, nil
	})
	require.NoError(t, err, "secret %s not available", name)
}

func waitUntilConfigMapAvailable(t *testing.T, ctx context.Context, client *kubernetes.Clientset, namespace, name string) {
	t.Helper()
	err := wait.PollUntilContextTimeout(ctx, pollingInterval, resourceWaitTimeout, true, func(ctx context.Context) (bool, error) {
		_, err := client.CoreV1().ConfigMaps(namespace).Get(ctx, name, metav1.GetOptions{})
		return err == nil, nil
	})
	require.NoError(t, err, "configmap %s not available", name)
}
