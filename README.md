# Victoria Metrics Helm Charts

This repository contains Victoria Metrics helm charts.

# Add a chart helm repository

Access a Kubernetes cluster.

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```

List all charts and versions of ``vm`` repository available to installation:

##### for helm v2

 ```console
helm search vm/
```

The command must display existing helm chart e.g.

```console
NAME                          CHART VERSION  APP VERSION DESCRIPTION
vm/victoria-metrics-agent     0.7.21         v1.63.0     Victoria Metrics Agent - collects metrics from ...
vm/victoria-metrics-alert     0.4.1          v1.63.0     Victoria Metrics Alert - executes a list of giv...
vm/victoria-metrics-auth      0.2.24         1.63.0      Victoria Metrics Auth - is a simple auth proxy ...
vm/victoria-metrics-cluster   0.8.34         1.63.0      Victoria Metrics Cluster version - high-perform...
vm/victoria-metrics-k8s-stack 0.2.9          1.16.0      Kubernetes monitoring on VictoriaMetrics stack....
vm/victoria-metrics-operator  0.1.17         0.16.0      Victoria Metrics Operator
vm/victoria-metrics-single    0.7.6          1.63.0      Victoria Metrics Single version - high-performa...
```

##### for helm v3

```console
helm search repo vm/
```

The command must display existing helm chart e.g.

```console
NAME                          CHART VERSION  APP VERSION DESCRIPTION
vm/victoria-metrics-agent     0.7.21         v1.63.0     Victoria Metrics Agent - collects metrics from ...
vm/victoria-metrics-alert     0.4.1          v1.63.0     Victoria Metrics Alert - executes a list of giv...
vm/victoria-metrics-auth      0.2.24         1.63.0      Victoria Metrics Auth - is a simple auth proxy ...
vm/victoria-metrics-cluster   0.8.34         1.63.0      Victoria Metrics Cluster version - high-perform...
vm/victoria-metrics-k8s-stack 0.2.9          1.16.0      Kubernetes monitoring on VictoriaMetrics stack....
vm/victoria-metrics-operator  0.1.17         0.16.0      Victoria Metrics Operator
vm/victoria-metrics-single    0.7.6          1.63.0      Victoria Metrics Single version - high-performa...
```

# Installing the chart

Export default values of ``victoria-metrics-cluster`` chart to file ``values.yaml``:

```console
helm show values vm/victoria-metrics-cluster > values.yaml
```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

```console
helm install victoria-metrics vm/victoria-metrics-cluster -f values.yaml -n NAMESPACE --debug --dry-run
```

Install chart with command:

##### for helm v2

```console
helm install -n victoria-metrics-cluster vm/victoria-metrics-cluster -f values.yaml -n NAMESPACE
```

##### for helm v3

```console
helm install victoria-metrics vm/victoria-metrics-cluster -f values.yaml -n NAMESPACE
```

Get the pods lists by running these commands:

```console
kubectl get pods -A | grep 'victoria-metrics'

# or list all resorces of victoria-metrics

kubectl get all -n NAMESPACE | grep victoria
```

Get the application by running this commands:

```console
helm list -f victoria-metrics -n NAMESPACE
```

See the history of versions of ``victoria-metrics`` application with command.

```console
helm history victoria-metrics -n NAMESPACE
```

# How to uninstall VictoriaMetrics

Remove application with command.

```console
helm uninstall victoria-metrics -n NAMESPACE
```

# Kubernetes compatibility versions

helm charts tested at kubernetes versions from 1.13 to 1.20

# List of Charts

- [Victoria Metrics Agent](https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-agent)
- [Victoria Metrics Alert](https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-alert)
- [Victoria Metrics Auth](https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-auth/README.md)
- [Victoria Metrics Cluster](https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-cluster/README.md)
- [Victoria Metrics k8s Stask](https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-k8s-stack/README.md)
- [Victoria Metrics Operator](https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-operator/README.md)
- [Victoria Metrics Single-node](https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-single/README.md)
