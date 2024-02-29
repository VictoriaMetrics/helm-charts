{{- /*
Generated file. Do not change in-place! In order to change this file first read following link:
https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack/hack
*/ -}}
{{- define "rules.names" }}
rules:
  - "etcd"
  - "general.rules"
  - "k8s.rules.container_cpu_usage_seconds_total"
  - "k8s.rules.container_memory_cache"
  - "k8s.rules.container_memory_rss"
  - "k8s.rules.container_memory_swap"
  - "k8s.rules.container_memory_workingSetBytes"
  - "k8s.rules.container_resource"
  - "k8s.rules.pod_owner"
  - "kube-apiserver-availability.rules"
  - "kube-apiserver-burnrate.rules"
  - "kube-apiserver-histogram.rules"
  - "kube-apiserver-slos"
  - "kube-apiserver.rules"
  - "kube-prometheus-general.rules"
  - "kube-prometheus-node-recording.rules"
  - "kube-scheduler.rules"
  - "kube-state-metrics"
  - "kubelet.rules"
  - "kubernetes-apps"
  - "kubernetes-resources"
  - "kubernetes-storage"
  - "kubernetes-system"
  - "kubernetes-system-apiserver"
  - "kubernetes-system-controller-manager"
  - "kubernetes-system-kubelet"
  - "kubernetes-system-scheduler"
  - "node-exporter"
  - "node-exporter.rules"
  - "node-network"
  - "node.rules"
  - "vmagent"
  - "alertmanager.rules"
  - "vmcluster"
  - "vmsingle"
  - "vm-health"
{{- end }}