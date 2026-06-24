package main

import (
	"context"
	"fmt"
	"os"

	corev1 "k8s.io/api/core/v1"
	k8serrors "k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/runtime/schema"
	"k8s.io/client-go/dynamic"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
)

const managedByLabel = "app.kubernetes.io/managed-by"
const managedByValue = "sync-job"
const instanceLabel = "app.kubernetes.io/instance"

var grafanaDashboardGVR = schema.GroupVersionResource{
	Group:    "grafana.integreatly.org",
	Version:  "v1beta1",
	Resource: "grafanadashboards",
}

var vmruleGVR = schema.GroupVersionResource{
	Group:    "operator.victoriametrics.com",
	Version:  "v1beta1",
	Resource: "vmrules",
}

type kubeClient struct {
	cs             kubernetes.Interface
	dyn            dynamic.Interface
	namespace      string
	instance       string
	resourcePrefix string
	ownerRef       *metav1.OwnerReference
}

func newKubeClient(namespace, instance, resourcePrefix string) (*kubeClient, error) {
	cfg, err := rest.InClusterConfig()
	if err != nil {
		kubecfg := os.Getenv("KUBECONFIG")
		if kubecfg == "" {
			kubecfg = os.ExpandEnv("$HOME/.kube/config")
		}
		cfg, err = clientcmd.BuildConfigFromFlags("", kubecfg)
		if err != nil {
			return nil, fmt.Errorf("build kube config: %w", err)
		}
	}
	cs, err := kubernetes.NewForConfig(cfg)
	if err != nil {
		return nil, fmt.Errorf("create k8s client: %w", err)
	}
	dyn, err := dynamic.NewForConfig(cfg)
	if err != nil {
		return nil, fmt.Errorf("create dynamic client: %w", err)
	}
	if resourcePrefix == "" {
		resourcePrefix = "vm-k8s-stack"
	}
	return &kubeClient{cs: cs, dyn: dyn, namespace: namespace, instance: instance, resourcePrefix: resourcePrefix}, nil
}

func (k *kubeClient) baseLabels() map[string]any {
	labels := map[string]any{managedByLabel: managedByValue}
	if k.instance != "" {
		labels[instanceLabel] = k.instance
	}
	return labels
}

func (k *kubeClient) labelSelector() string {
	if k.instance != "" {
		return fmt.Sprintf("%s=%s,%s=%s", managedByLabel, managedByValue, instanceLabel, k.instance)
	}
	return fmt.Sprintf("%s=%s", managedByLabel, managedByValue)
}

func (k *kubeClient) applyConfigMap(ctx context.Context, name string, data map[string]string, extraLabels, extraAnnotations map[string]string) error {
	labels := map[string]string{
		managedByLabel: managedByValue,
		instanceLabel:  k.instance,
	}
	for key, val := range extraLabels {
		labels[key] = val
	}
	cm := &corev1.ConfigMap{
		ObjectMeta: metav1.ObjectMeta{
			Name:        name,
			Namespace:   k.namespace,
			Labels:      labels,
			Annotations: extraAnnotations,
		},
		Data: data,
	}
	if k.ownerRef != nil {
		cm.OwnerReferences = []metav1.OwnerReference{*k.ownerRef}
	}
	existing, err := k.cs.CoreV1().ConfigMaps(k.namespace).Get(ctx, name, metav1.GetOptions{})
	if k8serrors.IsNotFound(err) {
		_, err = k.cs.CoreV1().ConfigMaps(k.namespace).Create(ctx, cm, metav1.CreateOptions{})
		return err
	}
	if err != nil {
		return err
	}
	cm.ResourceVersion = existing.ResourceVersion
	_, err = k.cs.CoreV1().ConfigMaps(k.namespace).Update(ctx, cm, metav1.UpdateOptions{})
	return err
}

func (k *kubeClient) deleteConfigMap(ctx context.Context, name string) error {
	err := k.cs.CoreV1().ConfigMaps(k.namespace).Delete(ctx, name, metav1.DeleteOptions{})
	if k8serrors.IsNotFound(err) {
		return nil
	}
	return err
}

func (k *kubeClient) listManagedConfigMaps(ctx context.Context) ([]string, error) {
	list, err := k.cs.CoreV1().ConfigMaps(k.namespace).List(ctx, metav1.ListOptions{
		LabelSelector: k.labelSelector(),
	})
	if err != nil {
		return nil, err
	}
	names := make([]string, 0, len(list.Items))
	for _, cm := range list.Items {
		names = append(names, cm.Name)
	}
	return names, nil
}

func (k *kubeClient) applyGrafanaDashboard(ctx context.Context, name, jsonContent string, extraSpec map[string]any, extraLabels, extraAnnotations map[string]string) error {
	spec := map[string]any{"json": jsonContent}
	for key, val := range extraSpec {
		spec[key] = val
	}
	labels := k.baseLabels()
	for key, val := range extraLabels {
		labels[key] = val
	}
	metadata := map[string]any{
		"name":      name,
		"namespace": k.namespace,
		"labels":    labels,
	}
	if len(extraAnnotations) > 0 {
		annots := make(map[string]any, len(extraAnnotations))
		for key, val := range extraAnnotations {
			annots[key] = val
		}
		metadata["annotations"] = annots
	}
	if k.ownerRef != nil {
		metadata["ownerReferences"] = []any{map[string]any{
			"apiVersion": k.ownerRef.APIVersion,
			"kind":       k.ownerRef.Kind,
			"name":       k.ownerRef.Name,
			"uid":        string(k.ownerRef.UID),
		}}
	}
	obj := &unstructured.Unstructured{
		Object: map[string]any{
			"apiVersion": "grafana.integreatly.org/v1beta1",
			"kind":       "GrafanaDashboard",
			"metadata":   metadata,
			"spec":       spec,
		},
	}
	existing, err := k.dyn.Resource(grafanaDashboardGVR).Namespace(k.namespace).Get(ctx, name, metav1.GetOptions{})
	if k8serrors.IsNotFound(err) {
		_, err = k.dyn.Resource(grafanaDashboardGVR).Namespace(k.namespace).Create(ctx, obj, metav1.CreateOptions{})
		return err
	}
	if err != nil {
		return err
	}
	obj.SetResourceVersion(existing.GetResourceVersion())
	_, err = k.dyn.Resource(grafanaDashboardGVR).Namespace(k.namespace).Update(ctx, obj, metav1.UpdateOptions{})
	return err
}

func (k *kubeClient) deleteGrafanaDashboard(ctx context.Context, name string) error {
	err := k.dyn.Resource(grafanaDashboardGVR).Namespace(k.namespace).Delete(ctx, name, metav1.DeleteOptions{})
	if k8serrors.IsNotFound(err) {
		return nil
	}
	return err
}

func (k *kubeClient) listManagedGrafanaDashboards(ctx context.Context) ([]string, error) {
	list, err := k.dyn.Resource(grafanaDashboardGVR).Namespace(k.namespace).List(ctx, metav1.ListOptions{
		LabelSelector: k.labelSelector(),
	})
	if err != nil {
		return nil, err
	}
	names := make([]string, 0, len(list.Items))
	for _, item := range list.Items {
		names = append(names, item.GetName())
	}
	return names, nil
}

func (k *kubeClient) applyVMRule(ctx context.Context, name string, spec map[string]any, extraLabels, extraAnnotations map[string]string) error {
	labels := k.baseLabels()
	for key, val := range extraLabels {
		labels[key] = val
	}
	metadata := map[string]any{
		"name":      name,
		"namespace": k.namespace,
		"labels":    labels,
	}
	if len(extraAnnotations) > 0 {
		annots := make(map[string]any, len(extraAnnotations))
		for key, val := range extraAnnotations {
			annots[key] = val
		}
		metadata["annotations"] = annots
	}
	if k.ownerRef != nil {
		metadata["ownerReferences"] = []any{map[string]any{
			"apiVersion": k.ownerRef.APIVersion,
			"kind":       k.ownerRef.Kind,
			"name":       k.ownerRef.Name,
			"uid":        string(k.ownerRef.UID),
		}}
	}
	obj := &unstructured.Unstructured{
		Object: map[string]any{
			"apiVersion": "operator.victoriametrics.com/v1beta1",
			"kind":       "VMRule",
			"metadata":   metadata,
			"spec":       spec,
		},
	}
	existing, err := k.dyn.Resource(vmruleGVR).Namespace(k.namespace).Get(ctx, name, metav1.GetOptions{})
	if k8serrors.IsNotFound(err) {
		_, err = k.dyn.Resource(vmruleGVR).Namespace(k.namespace).Create(ctx, obj, metav1.CreateOptions{})
		return err
	}
	if err != nil {
		return err
	}
	obj.SetResourceVersion(existing.GetResourceVersion())
	_, err = k.dyn.Resource(vmruleGVR).Namespace(k.namespace).Update(ctx, obj, metav1.UpdateOptions{})
	return err
}

func (k *kubeClient) deleteVMRule(ctx context.Context, name string) error {
	err := k.dyn.Resource(vmruleGVR).Namespace(k.namespace).Delete(ctx, name, metav1.DeleteOptions{})
	if k8serrors.IsNotFound(err) {
		return nil
	}
	return err
}

func (k *kubeClient) resolveOwnerRef(ctx context.Context, saName string) error {
	sa, err := k.cs.CoreV1().ServiceAccounts(k.namespace).Get(ctx, saName, metav1.GetOptions{})
	if err != nil {
		return err
	}
	k.ownerRef = &metav1.OwnerReference{
		APIVersion: "v1",
		Kind:       "ServiceAccount",
		Name:       sa.Name,
		UID:        sa.UID,
	}
	return nil
}

func (k *kubeClient) listManagedVMRules(ctx context.Context) ([]string, error) {
	list, err := k.dyn.Resource(vmruleGVR).Namespace(k.namespace).List(ctx, metav1.ListOptions{
		LabelSelector: k.labelSelector(),
	})
	if err != nil {
		return nil, err
	}
	names := make([]string, 0, len(list.Items))
	for _, item := range list.Items {
		names = append(names, item.GetName())
	}
	return names, nil
}
