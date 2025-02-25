

![Version](https://img.shields.io/badge/0.8.0-gray?logo=Helm&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fhelm%2Fvictoria-metrics-distributed%2Fchangelog%2F%23080)
![ArtifactHub](https://img.shields.io/badge/ArtifactHub-informational?logoColor=white&color=417598&logo=artifacthub&link=https%3A%2F%2Fartifacthub.io%2Fpackages%2Fhelm%2Fvictoriametrics%2Fvictoria-metrics-distributed)
![License](https://img.shields.io/github/license/VictoriaMetrics/helm-charts?labelColor=green&label=&link=https%3A%2F%2Fgithub.com%2FVictoriaMetrics%2Fhelm-charts%2Fblob%2Fmaster%2FLICENSE)
![Slack](https://img.shields.io/badge/Join-4A154B?logo=slack&link=https%3A%2F%2Fslack.victoriametrics.com)
![X](https://img.shields.io/twitter/follow/VictoriaMetrics?style=flat&label=Follow&color=black&logo=x&labelColor=black&link=https%3A%2F%2Fx.com%2FVictoriaMetrics)
![Reddit](https://img.shields.io/reddit/subreddit-subscribers/VictoriaMetrics?style=flat&label=Join&labelColor=red&logoColor=white&logo=reddit&link=https%3A%2F%2Fwww.reddit.com%2Fr%2FVictoriaMetrics)

A Helm chart for Running VMCluster on Multiple Availability Zones

## Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](https://docs.victoriametrics.com/helm/requirements/).

* PV support on underlying infrastructure.

* Multiple availability zones.

## Chart Details

This chart sets up multiple VictoriaMetrics cluster instances on multiple [availability zones](https://kubernetes.io/docs/setup/best-practices/multiple-zones/), provides both global write and read entrypoints.

The default setup is as shown below:

![victoriametrics-distributed-topology](./img/victoriametrics-distributed-topology.webp)

For write:
1. extra-vmagent(optional): scrapes external targets and all the components installed by this chart, sends data to global write entrypoint.
2. vmauth-global-write: global write entrypoint, proxies requests to one of the zone `vmagent` with `least_loaded` policy.
3. vmagent(per-zone): remote writes data to availability zones that enabled `.Values.availabilityZones[*].write.allow`, and [buffer data on disk](https://docs.victoriametrics.com/vmagent/#calculating-disk-space-for-persistence-queue) when zone is unavailable to ingest.
4. vmauth-write-balancer(per-zone): proxies requests to vminsert instances inside it's zone with `least_loaded` policy.
5. vmcluster(per-zone): processes write requests and stores data.

For read:
1. vmcluster(per-zone): processes query requests and returns results.
2. vmauth-read-balancer(per-zone): proxies requests to vmselect instances inside it's zone with `least_loaded` policy.
3. vmauth-read-proxy(per-zone): uses all the `vmauth-read-balancer` as servers if zone has `.Values.availabilityZones[*].read.allow` enabled, always prefer "local" `vmauth-read-balancer` to reduce cross-zone traffic with `first_available` policy.
4. vmauth-global-read: global query entrypoint, proxies requests to one of the zone `vmauth-read-proxy` with `first_available` policy.
5. grafana(optional): uses `vmauth-global-read` as default datasource.

>Note:
As the topology shown above, this chart doesn't include components like vmalert, alertmanager, etc by default.
You can install them using dependency [victoria-metrics-k8s-stack](https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-k8s-stack) or having separate release.

### Why use `victoria-metrics-distributed` chart?

One of the best practice of running production kubernetes cluster is running with [multiple availability zones](https://kubernetes.io/docs/setup/best-practices/multiple-zones/). And apart from kubernetes control plane components, we also want to spread our application pods on multiple zones, to continue serving even if zone outage happens.

VictoriaMetrics supports [data replication](https://docs.victoriametrics.com/cluster-victoriametrics/#replication-and-data-safety) natively which can guarantees data availability when part of the vmstorage instances failed. But it doesn't works well if vmstorage instances are spread on multiple availability zones, since data replication could be stored on single availability zone, which will be lost when zone outage happens.
To avoid this, vmcluster must be installed on multiple availability zones, each containing a 100% copy of data. As long as one zone is available, both global write and read entrypoints should work without interruption.

### How to write data?

The chart provides `vmauth-global-write` as global write entrypoint, it supports [push-based data ingestion protocols](https://docs.victoriametrics.com/vmagent/#how-to-push-data-to-vmagent) as VictoriaMetrics does.
Optionally, you can push data to any of the per-zone vmagents, and they will replicate the received data across zones.

### How to query data?

The chart provides `vmauth-global-read` as global read entrypoint, it picks the first available zone (see [first_available](https://docs.victoriametrics.com/vmauth/#high-availability) policy) as it's preferred datasource and switches automatically to next zone if first one is unavailable, check [vmauth `first_available`](https://docs.victoriametrics.com/vmauth/#high-availability) for more details.
If you have services like [vmalert](https://docs.victoriametrics.com/vmalert) or Grafana deployed in each zone, then configure them to use local `vmauth-read-proxy`. Per-zone `vmauth-read-proxy` always prefers "local" vmcluster for querying and reduces cross-zone traffic.

You can also pick other proxies like kubernetes service which supports [Topology Aware Routing](https://kubernetes.io/docs/concepts/services-networking/topology-aware-routing/) as global read entrypoint.

### What happens if zone outage happen?

If availability zone `zone-eu-1` is experiencing an outage, `vmauth-global-write` and `vmauth-global-read` will work without interruption:
1. `vmauth-global-write` stops proxying write requests to `zone-eu-1` automatically;
2. `vmauth-global-read` and `vmauth-read-proxy` stops proxying read requests to `zone-eu-1` automatically;
3. `vmagent` on `zone-us-1` fails to send data to `zone-eu-1.vmauth-write-balancer`, starts to buffer data on disk(unless `-remoteWrite.disableOnDiskQueue` is specified, which is not recommended for this topology);
To keep data completeness for all the availability zones, make sure you have enough disk space on vmagent for buffer, see [this doc](https://docs.victoriametrics.com/vmagent/#calculating-disk-space-for-persistence-queue) for size recommendation.

And to avoid getting incomplete responses from `zone-eu-1` which gets recovered from outage, check vmagent on `zone-us-1` to see if persistent queue has been drained. If not, remove `zone-eu-1` from serving query by setting `.Values.availabilityZones.{zone-eu-1}.read.allow=false` and change it back after confirm all data are restored.

### How to use [multitenancy](https://docs.victoriametrics.com/cluster-victoriametrics/#multitenancy)?

By default, all the data that written to `vmauth-global-write` belong to tenant `0`. To write data to different tenants, set `.Values.enableMultitenancy=true` and create new tenant users for `vmauth-global-write`.
For example, writing data to tenant `1088` with following steps:
1. create tenant VMUser for vmauth `vmauth-global-write` to use:
```
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMUser
metadata:
  name: tenant-1088-rw
  labels:
    tenant-test: "true"
spec:
  targetRefs:
  - static:
      ## list all the zone vmagent here
      url: "http://vmagent-vmagent-zone-eu-1:8429"
      url: "http://vmagent-vmagent-zone-us-1:8429"
    paths:
    - "/api/v1/write"
    - "/prometheus/api/v1/write"
    - "/write"
    - "/api/v1/import"
    - "/api/v1/import/.+"
    target_path_suffix: /insert/1088/
  username: tenant-1088
  password: secret
```

Add extra VMUser selector in vmauth `vmauth-global-write`
```
spec:
  userSelector:
    matchLabels:
      tenant-test: "true"
```

2. send data to `vmauth-global-write` using above token.
Example command using vmagent:
```
/path/to/vmagent -remoteWrite.url=http://vmauth-vmauth-global-write-$ReleaseName-vm-distributed:8427/prometheus/api/v1/write -remoteWrite.basicAuth.username=tenant-1088 -remoteWrite.basicAuth.password=secret
```

## How to install

Access a Kubernetes cluster.

### Setup chart repository (can be omitted for OCI repositories)

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```
List versions of `vm/victoria-metrics-distributed` chart available to installation:

```console
helm search repo vm/victoria-metrics-distributed -l
```

### Install `victoria-metrics-distributed` chart

Export default values of `victoria-metrics-distributed` chart to file `values.yaml`:

  - For HTTPS repository

    ```console
    helm show values vm/victoria-metrics-distributed > values.yaml
    ```
  - For OCI repository

    ```console
    helm show values oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-distributed > values.yaml
    ```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

  - For HTTPS repository

    ```console
    helm install vmd vm/victoria-metrics-distributed -f values.yaml -n NAMESPACE --debug --dry-run
    ```

  - For OCI repository

    ```console
    helm install vmd oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-distributed -f values.yaml -n NAMESPACE --debug --dry-run
    ```

Install chart with command:

  - For HTTPS repository

    ```console
    helm install vmd vm/victoria-metrics-distributed -f values.yaml -n NAMESPACE
    ```

  - For OCI repository

    ```console
    helm install vmd oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-distributed -f values.yaml -n NAMESPACE
    ```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'vmd'
```

Get the application by running this command:

```console
helm list -f vmd -n NAMESPACE
```

See the history of versions of `vmd` application with command.

```console
helm history vmd -n NAMESPACE
```

## How to upgrade

In order to serving query and ingestion while upgrading components version or changing configurations, it's recommended to perform maintenance on availability zone one by one.
First, performing update on availability zone `zone-eu-1`:
1. remove `zone-eu-1` from serving query by setting `.Values.availabilityZones.{zone-eu-1}.read.allow=false`;
2. run `helm upgrade vm-dis -n NAMESPACE` with updated configurations for `zone-eu-1` in `values.yaml`;
3. wait for all the components on zone `zone-eu-1` running;
4. wait `zone-us-1` vmagent persistent queue for `zone-eu-1` been drained, add `zone-eu-1` back to serving query by setting `.Values.availabilityZones.{zone-eu-1}.read.allow=true`.

Then, perform update on availability zone `zone-us-1` with the same steps1~4.

### Upgrade to 0.5.0

This release was refactored, names of the parameters was changed:

- `vmauthIngestGlobal` was changed to `write.global.vmauth`
- `vmauthQueryGlobal` was changed to `read.global.vmauth`
- `availabilityZones[*].allowIngest` was changed to `availabilityZones[*].write.allow`
- `availabilityZones[*].allowRead` was changed to `availabilityZones[*].read.allow`
- `availabilityZones[*].nodeSelector` was moved to `availabilityZones[*].common.spec.nodeSelector`
- `availabilityZones[*].extraAffinity` was moved to `availabilityZones[*].common.spec.affinity`
- `availabilityZones[*].topologySpreadConstraints` was moved to `availabilityZones[*].common.spec.topologySpreadConstraints`
- `availabilityZones[*].vmauthIngest` was moved to `availabilityZones[*].write.vmauth`
- `availabilityZones[*].vmauthQueryPerZone` was moved to `availabilityZones[*].read.perZone.vmauth`
- `availabilityZones[*].vmauthCrossAZQuery` was moved to `availabilityZones[*].read.crossZone.vmauth`

Example:

If before an upgrade you had given below configuration

```yaml
vmauthIngestGlobal:
  spec:
    extraArgs:
      discoverBackendIPs: "true"
vmauthQueryGlobal:
  spec:
    extraArgs:
      discoverBackendIPs: "true"
availabilityZones:
  - name: zone-eu-1
    vmauthIngest:
      spec:
        extraArgs:
          discoverBackendIPs: "true"
    vmcluster:
      spec:
        retentionPeriod: "14"
```

after upgrade it will look like this:

```yaml
write:
  global:
    vmauth:
      spec:
        extraArgs:
          discoverBackendIPs: "true"
read:
  global:
    vmauth:
      spec:
        extraArgs:
          discoverBackendIPs: "true"
availabilityZones:
  - name: zone-eu-1
    write:
      vmauth:
        spec:
          extraArgs:
            discoverBackendIPs: "true"
    vmcluster:
      spec:
        retentionPeriod: "14"
```

## How to uninstall

Remove application with command.

```console
helm uninstall vmd -n NAMESPACE
```

## Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](https://docs.victoriametrics.com/helm/requirements/).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-distributed

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

## Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-distributed`/values.yaml`` file.

<a id="helm-value-availabilityzones" href="#helm-value-availabilityzones" aria-hidden="true" tabindex="-1"></a>
[`availabilityZones`](#helm-value-availabilityzones)`(list)`: Config for all availability zones. Each element represents custom zone config, which overrides a default one from `zoneTpl`
  ```helm-default
  - name: zone-eu-1
  - name: zone-us-1
  ```
   
<a id="helm-value-availabilityzones-0--name" href="#helm-value-availabilityzones-0--name" aria-hidden="true" tabindex="-1"></a>
[`availabilityZones[0].name`](#helm-value-availabilityzones-0--name)`(string)`: Availability zone name
  ```helm-default
  zone-eu-1
  ```
   
<a id="helm-value-availabilityzones-1--name" href="#helm-value-availabilityzones-1--name" aria-hidden="true" tabindex="-1"></a>
[`availabilityZones[1].name`](#helm-value-availabilityzones-1--name)`(string)`: Availability zone name
  ```helm-default
  zone-us-1
  ```
   
<a id="helm-value-common-vmagent-spec" href="#helm-value-common-vmagent-spec" aria-hidden="true" tabindex="-1"></a>
[`common.vmagent.spec`](#helm-value-common-vmagent-spec)`(object)`: Common VMAgent spec, which can be overridden by each VMAgent configuration. Available parameters can be found [here](https://docs.victoriametrics.com/operator/api/index.html#vmagentspec)
  ```helm-default
  port: "8429"
  ```
   
<a id="helm-value-common-vmauth-spec-port" href="#helm-value-common-vmauth-spec-port" aria-hidden="true" tabindex="-1"></a>
[`common.vmauth.spec.port`](#helm-value-common-vmauth-spec-port)`(string)`:
  ```helm-default
  "8427"
  ```
   
<a id="helm-value-common-vmcluster-spec" href="#helm-value-common-vmcluster-spec" aria-hidden="true" tabindex="-1"></a>
[`common.vmcluster.spec`](#helm-value-common-vmcluster-spec)`(object)`: Common VMCluster spec, which can be overridden by each VMCluster configuration. Available parameters can be found [here](https://docs.victoriametrics.com/operator/api/index.html#vmclusterspec)
  ```helm-default
  vminsert:
      port: "8480"
      serviceSpec:
          spec:
              clusterIP: None
              type: ClusterIP
  vmselect:
      port: "8481"
  ```
   
<a id="helm-value-enablemultitenancy" href="#helm-value-enablemultitenancy" aria-hidden="true" tabindex="-1"></a>
[`enableMultitenancy`](#helm-value-enablemultitenancy)`(bool)`: Enable multitenancy mode see [here](https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-distributed#how-to-use-multitenancy)
  ```helm-default
  false
  ```
   
<a id="helm-value-extra" href="#helm-value-extra" aria-hidden="true" tabindex="-1"></a>
[`extra`](#helm-value-extra)`(object)`: Set up an extra vmagent to scrape all the scrape objects by default, and write data to above write-global endpoint.
  ```helm-default
  vmagent:
      enabled: true
      name: test-vmagent
      spec:
          selectAllByDefault: true
  ```
   
<a id="helm-value-fullnameoverride" href="#helm-value-fullnameoverride" aria-hidden="true" tabindex="-1"></a>
[`fullnameOverride`](#helm-value-fullnameoverride)`(string)`: Overrides the chart's computed fullname.
  ```helm-default
  ""
  ```
   
<a id="helm-value-global" href="#helm-value-global" aria-hidden="true" tabindex="-1"></a>
[`global`](#helm-value-global)`(object)`: Global chart properties
  ```helm-default
  cluster:
      dnsDomain: cluster.local.
  ```
   
<a id="helm-value-global-cluster-dnsdomain" href="#helm-value-global-cluster-dnsdomain" aria-hidden="true" tabindex="-1"></a>
[`global.cluster.dnsDomain`](#helm-value-global-cluster-dnsdomain)`(string)`: K8s cluster domain suffix, uses for building storage pods' FQDN. Details are [here](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/)
  ```helm-default
  cluster.local.
  ```
   
<a id="helm-value-nameoverride" href="#helm-value-nameoverride" aria-hidden="true" tabindex="-1"></a>
[`nameOverride`](#helm-value-nameoverride)`(string)`: Overrides the chart's name
  ```helm-default
  vm-distributed
  ```
   
<a id="helm-value-read-global-vmauth-enabled" href="#helm-value-read-global-vmauth-enabled" aria-hidden="true" tabindex="-1"></a>
[`read.global.vmauth.enabled`](#helm-value-read-global-vmauth-enabled)`(bool)`: Create vmauth as the global read entrypoint
  ```helm-default
  true
  ```
   
<a id="helm-value-read-global-vmauth-name" href="#helm-value-read-global-vmauth-name" aria-hidden="true" tabindex="-1"></a>
[`read.global.vmauth.name`](#helm-value-read-global-vmauth-name)`(string)`: Override the name of the vmauth object
  ```helm-default
  vmauth-global-read-{{ .fullname }}
  ```
   
<a id="helm-value-read-global-vmauth-spec" href="#helm-value-read-global-vmauth-spec" aria-hidden="true" tabindex="-1"></a>
[`read.global.vmauth.spec`](#helm-value-read-global-vmauth-spec)`(object)`: Spec for VMAuth CRD, see [here](https://docs.victoriametrics.com/operator/api#vmauthspec)
  ```helm-default
  {}
  ```
   
<a id="helm-value-victoria-metrics-k8s-stack" href="#helm-value-victoria-metrics-k8s-stack" aria-hidden="true" tabindex="-1"></a>
[`victoria-metrics-k8s-stack`](#helm-value-victoria-metrics-k8s-stack)`(object)`: Set up vm operator and other resources like vmalert, grafana if needed
  ```helm-default
  alertmanager:
      enabled: false
  enabled: true
  grafana:
      enabled: true
  victoria-metrics-operator:
      enabled: true
  vmagent:
      enabled: false
  vmalert:
      enabled: false
  vmcluster:
      enabled: false
  vmsingle:
      enabled: false
  ```
   
<a id="helm-value-write-global-vmauth-enabled" href="#helm-value-write-global-vmauth-enabled" aria-hidden="true" tabindex="-1"></a>
[`write.global.vmauth.enabled`](#helm-value-write-global-vmauth-enabled)`(bool)`: Create a vmauth as the global write entrypoint
  ```helm-default
  true
  ```
   
<a id="helm-value-write-global-vmauth-name" href="#helm-value-write-global-vmauth-name" aria-hidden="true" tabindex="-1"></a>
[`write.global.vmauth.name`](#helm-value-write-global-vmauth-name)`(string)`: Override the name of the vmauth object
  ```helm-default
  vmauth-global-write-{{ .fullname }}
  ```
   
<a id="helm-value-write-global-vmauth-spec" href="#helm-value-write-global-vmauth-spec" aria-hidden="true" tabindex="-1"></a>
[`write.global.vmauth.spec`](#helm-value-write-global-vmauth-spec)`(object)`: Spec for VMAuth CRD, see [here](https://docs.victoriametrics.com/operator/api#vmauthspec)
  ```helm-default
  {}
  ```
   
<a id="helm-value-zonetpl" href="#helm-value-zonetpl" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl`](#helm-value-zonetpl)`(object)`: Default config for each availability zone components, including vmagent, vmcluster, vmauth etc. Defines a template for each availability zone, which can be overridden for each availability zone at `availabilityZones[*]`
  ```helm-default
  common:
      spec:
          affinity: {}
          nodeSelector:
              topology.kubernetes.io/zone: '{{ (.zone).name }}'
          topologySpreadConstraints:
              - maxSkew: 1
                topologyKey: kubernetes.io/hostname
                whenUnsatisfiable: ScheduleAnyway
  read:
      allow: true
      crossZone:
          vmauth:
              enabled: true
              name: vmauth-read-proxy-{{ (.zone).name }}
              spec: {}
      perZone:
          vmauth:
              enabled: true
              name: vmauth-read-balancer-{{ (.zone).name }}
              spec:
                  extraArgs:
                      discoverBackendIPs: "true"
  vmagent:
      annotations: {}
      enabled: true
      name: vmagent-{{ (.zone).name }}
      spec: {}
  vmcluster:
      enabled: true
      name: vmcluster-{{ (.zone).name }}
      spec:
          replicationFactor: 2
          retentionPeriod: "14"
          vminsert:
              extraArgs: {}
              replicaCount: 2
              resources: {}
          vmselect:
              extraArgs: {}
              replicaCount: 2
              resources: {}
          vmstorage:
              replicaCount: 2
              resources: {}
              storageDataPath: /vm-data
  write:
      allow: true
      vmauth:
          enabled: true
          name: vmauth-write-balancer-{{ (.zone).name }}
          spec:
              extraArgs:
                  discoverBackendIPs: "true"
  ```
   
<a id="helm-value-zonetpl-common-spec" href="#helm-value-zonetpl-common-spec" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.common.spec`](#helm-value-zonetpl-common-spec)`(object)`: Common for [VMAgent](https://docs.victoriametrics.com/operator/api/#vmagentspec), [VMAuth](https://docs.victoriametrics.com/operator/api/#vmauthspec), [VMCluster](https://docs.victoriametrics.com/operator/api/#vmclusterspec) spec params, like nodeSelector, affinity, topologySpreadConstraint, etc
  ```helm-default
  affinity: {}
  nodeSelector:
      topology.kubernetes.io/zone: '{{ (.zone).name }}'
  topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: ScheduleAnyway
  ```
   
<a id="helm-value-zonetpl-read-allow" href="#helm-value-zonetpl-read-allow" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.read.allow`](#helm-value-zonetpl-read-allow)`(bool)`: Allow data query from this zone through global query endpoint
  ```helm-default
  true
  ```
   
<a id="helm-value-zonetpl-read-crosszone-vmauth-enabled" href="#helm-value-zonetpl-read-crosszone-vmauth-enabled" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.read.crossZone.vmauth.enabled`](#helm-value-zonetpl-read-crosszone-vmauth-enabled)`(bool)`: Create a vmauth with all the zone with `allow: true` as query backends
  ```helm-default
  true
  ```
   
<a id="helm-value-zonetpl-read-crosszone-vmauth-name" href="#helm-value-zonetpl-read-crosszone-vmauth-name" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.read.crossZone.vmauth.name`](#helm-value-zonetpl-read-crosszone-vmauth-name)`(string)`: Override the name of the vmauth object
  ```helm-default
  vmauth-read-proxy-{{ (.zone).name }}
  ```
   
<a id="helm-value-zonetpl-read-crosszone-vmauth-spec" href="#helm-value-zonetpl-read-crosszone-vmauth-spec" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.read.crossZone.vmauth.spec`](#helm-value-zonetpl-read-crosszone-vmauth-spec)`(object)`: Spec for VMAuth CRD, see [here](https://docs.victoriametrics.com/operator/api#vmauthspec)
  ```helm-default
  {}
  ```
   
<a id="helm-value-zonetpl-read-perzone-vmauth-enabled" href="#helm-value-zonetpl-read-perzone-vmauth-enabled" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.read.perZone.vmauth.enabled`](#helm-value-zonetpl-read-perzone-vmauth-enabled)`(bool)`: Create vmauth as a local read endpoint
  ```helm-default
  true
  ```
   
<a id="helm-value-zonetpl-read-perzone-vmauth-name" href="#helm-value-zonetpl-read-perzone-vmauth-name" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.read.perZone.vmauth.name`](#helm-value-zonetpl-read-perzone-vmauth-name)`(string)`: Override the name of the vmauth object
  ```helm-default
  vmauth-read-balancer-{{ (.zone).name }}
  ```
   
<a id="helm-value-zonetpl-read-perzone-vmauth-spec" href="#helm-value-zonetpl-read-perzone-vmauth-spec" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.read.perZone.vmauth.spec`](#helm-value-zonetpl-read-perzone-vmauth-spec)`(object)`: Spec for VMAuth CRD, see [here](https://docs.victoriametrics.com/operator/api#vmauthspec)
  ```helm-default
  extraArgs:
      discoverBackendIPs: "true"
  ```
   
<a id="helm-value-zonetpl-vmagent-annotations" href="#helm-value-zonetpl-vmagent-annotations" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.vmagent.annotations`](#helm-value-zonetpl-vmagent-annotations)`(object)`: VMAgent remote write proxy annotations
  ```helm-default
  {}
  ```
   
<a id="helm-value-zonetpl-vmagent-enabled" href="#helm-value-zonetpl-vmagent-enabled" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.vmagent.enabled`](#helm-value-zonetpl-vmagent-enabled)`(bool)`: Create VMAgent remote write proxy
  ```helm-default
  true
  ```
   
<a id="helm-value-zonetpl-vmagent-name" href="#helm-value-zonetpl-vmagent-name" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.vmagent.name`](#helm-value-zonetpl-vmagent-name)`(string)`: Override the name of the vmagent object
  ```helm-default
  vmagent-{{ (.zone).name }}
  ```
   
<a id="helm-value-zonetpl-vmagent-spec" href="#helm-value-zonetpl-vmagent-spec" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.vmagent.spec`](#helm-value-zonetpl-vmagent-spec)`(object)`: Spec for VMAgent CRD, see [here](https://docs.victoriametrics.com/operator/api#vmagentspec)
  ```helm-default
  {}
  ```
   
<a id="helm-value-zonetpl-vmcluster-enabled" href="#helm-value-zonetpl-vmcluster-enabled" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.vmcluster.enabled`](#helm-value-zonetpl-vmcluster-enabled)`(bool)`: Create VMCluster
  ```helm-default
  true
  ```
   
<a id="helm-value-zonetpl-vmcluster-name" href="#helm-value-zonetpl-vmcluster-name" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.vmcluster.name`](#helm-value-zonetpl-vmcluster-name)`(string)`: Override the name of the vmcluster, by default is <zoneName>
  ```helm-default
  vmcluster-{{ (.zone).name }}
  ```
   
<a id="helm-value-zonetpl-vmcluster-spec" href="#helm-value-zonetpl-vmcluster-spec" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.vmcluster.spec`](#helm-value-zonetpl-vmcluster-spec)`(object)`: Spec for VMCluster CRD, see [here](https://docs.victoriametrics.com/operator/api#vmclusterspec)
  ```helm-default
  replicationFactor: 2
  retentionPeriod: "14"
  vminsert:
      extraArgs: {}
      replicaCount: 2
      resources: {}
  vmselect:
      extraArgs: {}
      replicaCount: 2
      resources: {}
  vmstorage:
      replicaCount: 2
      resources: {}
      storageDataPath: /vm-data
  ```
   
<a id="helm-value-zonetpl-write-allow" href="#helm-value-zonetpl-write-allow" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.write.allow`](#helm-value-zonetpl-write-allow)`(bool)`: Allow data ingestion to this zone
  ```helm-default
  true
  ```
   
<a id="helm-value-zonetpl-write-vmauth-enabled" href="#helm-value-zonetpl-write-vmauth-enabled" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.write.vmauth.enabled`](#helm-value-zonetpl-write-vmauth-enabled)`(bool)`: Create vmauth as a local write endpoint
  ```helm-default
  true
  ```
   
<a id="helm-value-zonetpl-write-vmauth-name" href="#helm-value-zonetpl-write-vmauth-name" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.write.vmauth.name`](#helm-value-zonetpl-write-vmauth-name)`(string)`: Override the name of the vmauth object
  ```helm-default
  vmauth-write-balancer-{{ (.zone).name }}
  ```
   
<a id="helm-value-zonetpl-write-vmauth-spec" href="#helm-value-zonetpl-write-vmauth-spec" aria-hidden="true" tabindex="-1"></a>
[`zoneTpl.write.vmauth.spec`](#helm-value-zonetpl-write-vmauth-spec)`(object)`: Spec for VMAuth CRD, see [here](https://docs.victoriametrics.com/operator/api#vmauthspec)
  ```helm-default
  extraArgs:
      discoverBackendIPs: "true"
  ```
   

