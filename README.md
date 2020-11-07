# Victoria Metrics Helm Charts

This repository contains Victoria Metrics helm chart

### Usage 

#### Add a chart helm repository  
```console
helm repo add vm https://victoriametrics.github.io/helm-charts/
``` 

#### Test the helm repository

##### for helm v2
 ```console
helm search vm
```
The command must display existing helm chart e.g.
```console
NAME                       	CHART VERSION	APP VERSION	DESCRIPTION
vm/victoria-metrics-agent  	0.6.3        	v1.46.0    	Victoria Metrics Agent - collects metrics from ...
vm/victoria-metrics-cluster	0.7.2        	1.46.0     	Victoria Metrics Cluster version - high-perform...
vm/victoria-metrics-single 	0.6.2        	1.46.0     	Victoria Metrics Single version - high-performa...
```

##### for helm v3
```console
helm search repo vm
```
The command must display existing helm chart e.g.
```console
NAME                       	CHART VERSION	APP VERSION	DESCRIPTION
vm/victoria-metrics-agent  	0.6.3        	v1.46.0    	Victoria Metrics Agent - collects metrics from ...
vm/victoria-metrics-cluster	0.7.2        	1.46.0     	Victoria Metrics Cluster version - high-perform...
vm/victoria-metrics-single 	0.6.2        	1.46.0     	Victoria Metrics Single version - high-performa...
```


#### Installing the chart

##### for helm v2
```console
helm install -n victoria-metrics-cluster vm/victoria-metrics-cluster
```

##### for helm v3
```console
helm install victoria-metrics-cluster vm/victoria-metrics-cluster
```

## List of Charts 
- [Victoria Metrics Agent](https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-agent)
- [Victoria Metrics Alert](https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-alert)
- [Victoria Metrics Single-node](https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-single/README.md)
- [Victoria Metrics Cluster](https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-cluster/README.md)
