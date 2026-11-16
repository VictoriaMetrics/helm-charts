---
weight: 0
title: Helm Charts
description: "All VictoriaMetrics Helm charts. Add repo, install, and upgrade."
menu:
  docs:
    weight: 35
    identifier: helm
    pageRef: /helm/
aliases:
  - /helm
  - /helm/index.html
tags:
  - logs
  - kubernetes
  - metrics
---
![Artifact Hub](https://img.shields.io/badge/ArtifactHub-informational?logoColor=white&color=417598&logo=artifacthub&link=https%3A%2F%2Fartifacthub.io%2Fpackages%2Fsearch%3Frepo%3Dvictoriametrics%26verified_publisher%3Dtrue)
![Helm: v3](https://img.shields.io/badge/Helm-v3.14%2B-gray?logo=helm&link=https%3A%2F%2Fgithub.com%2Fhelm%2Fhelm%2Freleases%2Ftag%2Fv3.14.0)
![License](https://img.shields.io/github/license/VictoriaMetrics/helm-charts?labelColor=green&label=&link=https%3A%2F%2Fgithub.com%2FVictoriaMetrics%2Fhelm-charts%2Fblob%2Fmaster%2FLICENSE)
![Slack](https://img.shields.io/badge/Join-4A154B?logo=slack&link=https%3A%2F%2Fslack.victoriametrics.com)
![X](https://img.shields.io/twitter/follow/VictoriaMetrics?style=flat&label=Follow&color=black&logo=x&labelColor=black&link=https%3A%2F%2Fx.com%2FVictoriaMetrics)
![Reddit](https://img.shields.io/reddit/subreddit-subscribers/VictoriaMetrics?style=flat&label=Join&labelColor=red&logoColor=white&logo=reddit&link=https%3A%2F%2Fwww.reddit.com%2Fr%2FVictoriaMetrics)

This repository contains helm charts for VictoriaMetrics and VictoriaLogs.

## Add a chart helm repository (can be skipped for OCI repository)

Access a Kubernetes cluster.

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```

List [all charts](https://docs.victoriametrics.com/helm/#list-of-charts) and versions of `vm` repository available to installation:
    
```console
helm search repo vm/
```

The command must display existing helm chart e.g.

```shell
NAME                             	CHART VERSION	APP VERSION	DESCRIPTION
vm/victoria-logs-agent           	0.2.11       	v1.54.0    	VictoriaLogs Agent - accepts logs from various ...
vm/victoria-logs-cluster         	0.2.12       	v1.54.0    	The VictoriaLogs cluster Helm chart deploys Vic...
vm/victoria-logs-collector       	0.3.9        	v1.54.0    	VictoriaLogs Collector - collects logs from Kub...
vm/victoria-logs-mcp             	0.2.0        	v1.9.0     	A Helm chart for VictoriaLogs MCP server
vm/victoria-logs-multilevel      	0.2.11       	v1.54.0    	The VictoriaLogs multilevel Helm chart deploys ...
vm/victoria-logs-single          	0.13.13      	v1.54.0    	The VictoriaLogs single Helm chart deploys Vict...
vm/victoria-metrics-agent        	0.52.0       	v1.156.0   	VictoriaMetrics Agent - collects metrics from v...
vm/victoria-metrics-alert        	0.53.0       	v1.156.0   	VictoriaMetrics Alert - executes a list of give...
vm/victoria-metrics-anomaly      	1.12.21      	v1.32.0    	VictoriaMetrics Anomaly Detection - a service t...
vm/victoria-metrics-auth         	0.46.0       	v1.156.0   	VictoriaMetrics Auth - is a simple auth proxy a...
vm/victoria-metrics-cluster      	0.55.0       	v1.156.0   	VictoriaMetrics Cluster version - high-performa...
vm/victoria-metrics-common       	0.4.5        	           	VictoriaMetrics Common - contains shared templa...
vm/victoria-metrics-distributed  	0.50.0       	v1.156.0   	A Helm chart for Running VMCluster on Multiple ...
vm/victoria-metrics-estimator    	0.2.2        	v0.1.18    	A Helm chart for VictoriaMetrics vmestimator
vm/victoria-metrics-gateway      	0.43.0       	v1.156.0   	VictoriaMetrics Gateway - Auth & Rate-Limitting...
vm/victoria-metrics-k8s-stack    	0.98.1       	v1.156.0   	Kubernetes monitoring on VictoriaMetrics stack....
vm/victoria-metrics-mcp          	0.4.1        	v1.21.0    	A Helm chart for VictoriaMetrics MCP server
vm/victoria-metrics-operator     	0.68.2       	v0.75.2    	VictoriaMetrics Operator
vm/victoria-metrics-operator-crds	0.15.2       	v0.75.2    	VictoriaMetrics Operator CRDs
vm/victoria-metrics-single       	0.51.0       	v1.156.0   	VictoriaMetrics Single version - high-performan...
vm/victoria-traces-agent         	0.2.2        	v0.13.0    	VictoriaTraces Agent - accepts trace spans via ...
vm/victoria-traces-cluster       	0.2.13       	v0.13.0    	The VictoriaTraces cluster Helm chart deploys V...
vm/victoria-traces-mcp           	0.2.0        	v1.5.0     	A Helm chart for VictoriaTraces MCP server
vm/victoria-traces-single        	0.1.13       	v0.13.0    	The VictoriaTraces single Helm chart deploys Vi...
```

## Installing the chart

Export default values of `victoria-metrics-cluster` chart to file `values.yaml`:

  - For HTTPS repository

    ```console
    helm show values vm/victoria-metrics-cluster > values.yaml
    ```
  - For OCI repository

    ```console
    helm show values oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-agent > values.yaml
    ```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

  - For HTTPS repository

    ```console
    helm install victoria-metrics vm/victoria-metrics-cluster -f values.yaml -n NAMESPACE --debug --dry-run
    ```

  - For OCI repository

    ```console
    helm install victoria-metrics oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-cluster -f values.yaml -n NAMESPACE --debug --dry-run
    ```

Install chart with command:

  - For HTTPS repository
    
    ```console
    helm install victoria-metrics vm/victoria-metrics-cluster -f values.yaml -n NAMESPACE
    ```

  - For OCI repository

    ```console
    helm install victoria-metrics oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-cluster -f values.yaml -n NAMESPACE
    ```

## Validate installation

Get the pods lists by running these commands:

```console
kubectl get pods -A | grep 'victoria-metrics'

# or list all resources of victoria-metrics

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

## How to uninstall VictoriaMetrics

Remove application with command.

```console
helm uninstall victoria-metrics -n NAMESPACE
```

## Kubernetes compatibility versions

helm charts tested at kubernetes versions from 1.28 to 1.30.

## List of Charts

- [VictoriaLogs Single](https://docs.victoriametrics.com/helm/victoria-logs-single/)
- [VictoriaLogs Cluster](https://docs.victoriametrics.com/helm/victoria-logs-cluster/)
- [VictoriaLogs Collector](https://docs.victoriametrics.com/helm/victoria-logs-collector/)
- [VictoriaMetrics Single](https://docs.victoriametrics.com/helm/victoria-metrics-single/)
- [VictoriaMetrics Cluster](https://docs.victoriametrics.com/helm/victoria-metrics-cluster/)
- [VictoriaMetrics Agent](https://docs.victoriametrics.com/helm/victoria-metrics-agent/)
- [VictoriaMetrics Alert](https://docs.victoriametrics.com/helm/victoria-metrics-alert/)
- [VictoriaMetrics Anomaly](https://docs.victoriametrics.com/helm/victoria-metrics-anomaly/)
- [VictoriaMetrics Auth](https://docs.victoriametrics.com/helm/victoria-metrics-auth/)
- [VictoriaMetrics Gateway](https://docs.victoriametrics.com/helm/victoria-metrics-gateway/)
- [VictoriaMetrics Distributed](https://docs.victoriametrics.com/helm/victoria-metrics-distributed/)
- [VictoriaMetrics K8s Stack](https://docs.victoriametrics.com/helm/victoria-metrics-k8s-stack/)
- [VictoriaMetrics Operator](https://docs.victoriametrics.com/helm/victoria-metrics-operator/)
- [VictoriaMetrics Operator CRDs](https://docs.victoriametrics.com/helm/victoria-metrics-operator-crds/)
- [VictoriaTraces Single](https://docs.victoriametrics.com/helm/victoria-traces-single/)
- [VictoriaTraces Cluster](https://docs.victoriametrics.com/helm/victoria-traces-cluster/)

### Operator-based charts

Most charts render Kubernetes workloads (Deployments, StatefulSets, DaemonSets, Services) directly, so their workload settings are configured through chart values.
The following charts render [VictoriaMetrics operator](https://docs.victoriametrics.com/operator/) custom resources instead, and the operator creates the workloads from them:

- [VictoriaMetrics K8s Stack](https://docs.victoriametrics.com/helm/victoria-metrics-k8s-stack/) installs the operator by default (`victoria-metrics-operator.enabled`);
- [VictoriaMetrics Distributed](https://docs.victoriametrics.com/helm/victoria-metrics-distributed/) installs the operator by default through its `victoria-metrics-k8s-stack` dependency; if that dependency or its `victoria-metrics-operator` subchart is disabled, the operator must already be installed.

For VictoriaMetrics, VictoriaLogs and VictoriaTraces components of these charts, workloads can be configured only through the fields of the custom resource spec, see the [operator API reference](https://docs.victoriametrics.com/operator/api/).
Bundled third-party subcharts, such as grafana and kube-state-metrics, are still configured with their chart values.
If you need full control over Kubernetes resources, use the standalone charts for each component instead.
