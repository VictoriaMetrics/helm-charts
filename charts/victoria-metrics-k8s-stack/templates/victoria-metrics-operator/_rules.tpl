{{- /*
Generated file. Do not change in-place! In order to change this file first read following link:
https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack/hack
*/ -}}
{{- define "rules.names" }}
rules:
  - "etcd"
  - "kube-apiserver-availability.rules"
  - "kube-apiserver-burnrate.rules"
  - "kube-apiserver-histogram.rules"
  - "kube-apiserver-slos"
  - "kube-apiserver.rules"
  - "kube-scheduler.rules"
  - "kubelet.rules"
  - "kubernetes-system-apiserver"
  - "kubernetes-system-controller-manager"
  - "kubernetes-system-scheduler"
  - "vmagent"
{{- end }}