# Victoria Metrics Helm Charts

This repository contains Victoria Metrics helm chart

### Usage 

#### Add a chart helm repository  
```console
helm repo add vm https://victoriametrics.github.io/helm-charts/
``` 

#### Test the helm repository
 ```console
helm search vm
```
The command must display existing helm chart e.g.
```
NAME                       	CHART VERSION	APP VERSION	DESCRIPTION
vm/victoria-metrics-cluster	0.1.0        	1.31.4     	Victoria Metrics Cluster version - high-performance, cost...
```

#### Installing the chart

```console
helm install -n victoria-metrics-cluster vm/victoria-metrics-cluster
```

## List of Charts 

- [Victoria Metrics Cluster](https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-cluster/README.md)
