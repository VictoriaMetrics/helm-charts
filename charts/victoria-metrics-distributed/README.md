

![Version](https://img.shields.io/badge/0.13.0-gray?logo=Helm&labelColor=gray&link=https%3A%2F%2Fdocs.victoriametrics.com%2Fhelm%2Fvictoria-metrics-distributed%2Fchangelog%2F%230130)
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

### Upgrade to 0.13.0

Introduction of VMCluster's [`requestsLoadBalancer`](https://docs.victoriametrics.com/operator/resources/vmcluster/#requests-load-balancing) allowed to simplify distributed chart setup by removing VMAuth CRs for read and write load balancing. Some parameters are not needed anymore:

- removed `availabilityZones[*].write.vmauth`
- removed `availabilityZones[*].read.perZone.vmauth`
- removed `zoneTpl.write.vmauth`
- removed `zoneTpl.read.perZone.vmauth`
- moved `zoneTpl.read.crossZone.vmauth` to `zoneTpl.read.vmauth`
- moved `availabilityZones[*].read.perZone.vmauth` to `availabilityZones[*].read.vmauth`

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

<table class="helm-vars">
  <thead>
    <th class="helm-vars-key">Key</th>
    <th class="helm-vars-description">Description</th>
  </thead>
  <tbody>
    <tr id="availabilityzones">
      <td><a href="#availabilityzones"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">availabilityZones</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span>- <span class="nt">name</span><span class="p">:</span><span class="w"> </span><span class="l">zone-eu-1</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span>- <span class="nt">name</span><span class="p">:</span><span class="w"> </span><span class="l">zone-us-1</span></span></span></code></pre>
</a></td>
      <td><em><code>(list)</code></em><p>Config for all availability zones. Each element represents custom zone config, which overrides a default one from <code>zoneTpl</code></p>
</td>
    </tr>
    <tr id="availabilityzones[0]-name">
      <td><a href="#availabilityzones[0]-name"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">availabilityZones[0].name</span><span class="p">:</span><span class="w"> </span><span class="l">zone-eu-1</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Availability zone name</p>
</td>
    </tr>
    <tr id="availabilityzones[1]-name">
      <td><a href="#availabilityzones[1]-name"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">availabilityZones[1].name</span><span class="p">:</span><span class="w"> </span><span class="l">zone-us-1</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Availability zone name</p>
</td>
    </tr>
    <tr id="common-vmagent-spec">
      <td><a href="#common-vmagent-spec"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">common.vmagent.spec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">port</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;8429&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Common VMAgent spec, which can be overridden by each VMAgent configuration. Available parameters can be found <a href="https://docs.victoriametrics.com/operator/api/index.html#vmagentspec" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="common-vmauth-spec-port">
      <td><a href="#common-vmauth-spec-port"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">common.vmauth.spec.port</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;8427&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em></td>
    </tr>
    <tr id="common-vmcluster-spec">
      <td><a href="#common-vmcluster-spec"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">common.vmcluster.spec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">requestsLoadBalancer</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">spec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">replicaCount</span><span class="p">:</span><span class="w"> </span><span class="m">2</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">vminsert</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">port</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;8480&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">vmselect</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">port</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;8481&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Common VMCluster spec, which can be overridden by each VMCluster configuration. Available parameters can be found <a href="https://docs.victoriametrics.com/operator/api/index.html#vmclusterspec" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="common-vmsingle-spec">
      <td><a href="#common-vmsingle-spec"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">common.vmsingle.spec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">port</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;8428&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Common VMSingle spec, which can be overridden by each VMSingle configuration. Available parameters can be found <a href="https://docs.victoriametrics.com/operator/api/index.html#vmsinglespec" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="enablemultitenancy">
      <td><a href="#enablemultitenancy"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">enableMultitenancy</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Enable multitenancy mode see <a href="https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-distributed#how-to-use-multitenancy" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="extra">
      <td><a href="#extra"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">extra</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">vmagent</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">name</span><span class="p">:</span><span class="w"> </span><span class="l">test-vmagent</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">spec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">selectAllByDefault</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Set up an extra vmagent to scrape all the scrape objects by default, and write data to above write-global endpoint.</p>
</td>
    </tr>
    <tr id="fullnameoverride">
      <td><a href="#fullnameoverride"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">fullnameOverride</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Overrides the chart&rsquo;s computed fullname.</p>
</td>
    </tr>
    <tr id="global">
      <td><a href="#global"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">global</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">cluster</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">dnsDomain</span><span class="p">:</span><span class="w"> </span><span class="l">cluster.local.</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Global chart properties</p>
</td>
    </tr>
    <tr id="global-cluster-dnsdomain">
      <td><a href="#global-cluster-dnsdomain"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">global.cluster.dnsDomain</span><span class="p">:</span><span class="w"> </span><span class="l">cluster.local.</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>K8s cluster domain suffix, uses for building storage pods&rsquo; FQDN. Details are <a href="https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="nameoverride">
      <td><a href="#nameoverride"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">nameOverride</span><span class="p">:</span><span class="w"> </span><span class="l">vm-distributed</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Overrides the chart&rsquo;s name</p>
</td>
    </tr>
    <tr id="read-global-vmauth-enabled">
      <td><a href="#read-global-vmauth-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">read.global.vmauth.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Create vmauth as the global read entrypoint</p>
</td>
    </tr>
    <tr id="read-global-vmauth-name">
      <td><a href="#read-global-vmauth-name"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">read.global.vmauth.name</span><span class="p">:</span><span class="w"> </span><span class="l">vmauth-global-read-{{ .fullname }}</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Override the name of the vmauth object</p>
</td>
    </tr>
    <tr id="read-global-vmauth-spec">
      <td><a href="#read-global-vmauth-spec"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">read.global.vmauth.spec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">unauthorizedUserAccessSpec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">url_map</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">load_balancing_policy</span><span class="p">:</span><span class="w"> </span><span class="l">first_available</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">retry_status_codes</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="m">500</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="m">502</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="m">503</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Spec for VMAuth CRD, see <a href="https://docs.victoriametrics.com/operator/api#vmauthspec" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="victoria-metrics-k8s-stack">
      <td><a href="#victoria-metrics-k8s-stack"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">victoria-metrics-k8s-stack</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">alertmanager</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">grafana</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">victoria-metrics-operator</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">vmagent</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">vmalert</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">vmcluster</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">vmsingle</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Set up vm operator and other resources like vmalert, grafana if needed</p>
</td>
    </tr>
    <tr id="write-global-vmauth-enabled">
      <td><a href="#write-global-vmauth-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">write.global.vmauth.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Create a vmauth as the global write entrypoint</p>
</td>
    </tr>
    <tr id="write-global-vmauth-name">
      <td><a href="#write-global-vmauth-name"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">write.global.vmauth.name</span><span class="p">:</span><span class="w"> </span><span class="l">vmauth-global-write-{{ .fullname }}</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Override the name of the vmauth object</p>
</td>
    </tr>
    <tr id="write-global-vmauth-spec">
      <td><a href="#write-global-vmauth-spec"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">write.global.vmauth.spec</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Spec for VMAuth CRD, see <a href="https://docs.victoriametrics.com/operator/api#vmauthspec" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="zonetpl">
      <td><a href="#zonetpl"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">common</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">spec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">affinity</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">nodeSelector</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span><span class="nt">topology.kubernetes.io/zone</span><span class="p">:</span><span class="w"> </span><span class="s1">&#39;{{ (.zone).name }}&#39;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">topologySpreadConstraints</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="nt">maxSkew</span><span class="p">:</span><span class="w"> </span><span class="m">1</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                  </span><span class="nt">topologyKey</span><span class="p">:</span><span class="w"> </span><span class="l">kubernetes.io/hostname</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                  </span><span class="nt">whenUnsatisfiable</span><span class="p">:</span><span class="w"> </span><span class="l">ScheduleAnyway</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">read</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">allow</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">vmauth</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">name</span><span class="p">:</span><span class="w"> </span><span class="l">vmauth-read-proxy-{{ (.zone).name }}</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">spec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span><span class="nt">unauthorizedUserAccessSpec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                    </span><span class="nt">url_map</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                        </span>- <span class="nt">load_balancing_policy</span><span class="p">:</span><span class="w"> </span><span class="l">first_available</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                          </span><span class="nt">retry_status_codes</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                            </span>- <span class="m">500</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                            </span>- <span class="m">502</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                            </span>- <span class="m">503</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">vmagent</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">annotations</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">name</span><span class="p">:</span><span class="w"> </span><span class="l">vmagent-{{ (.zone).name }}</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">spec</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">vmcluster</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">name</span><span class="p">:</span><span class="w"> </span><span class="l">vmcluster-{{ (.zone).name }}</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">spec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">replicationFactor</span><span class="p">:</span><span class="w"> </span><span class="m">2</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">retentionPeriod</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;14&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">vminsert</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span><span class="nt">extraArgs</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span><span class="nt">replicaCount</span><span class="p">:</span><span class="w"> </span><span class="m">2</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span><span class="nt">resources</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">vmselect</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span><span class="nt">extraArgs</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span><span class="nt">replicaCount</span><span class="p">:</span><span class="w"> </span><span class="m">2</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span><span class="nt">resources</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">vmstorage</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span><span class="nt">replicaCount</span><span class="p">:</span><span class="w"> </span><span class="m">2</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span><span class="nt">resources</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span><span class="nt">storageDataPath</span><span class="p">:</span><span class="w"> </span><span class="l">/vm-data</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">vmsingle</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">name</span><span class="p">:</span><span class="w"> </span><span class="s1">&#39;{{ (.zone).name }}&#39;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">spec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">extraArgs</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">replicaCount</span><span class="p">:</span><span class="w"> </span><span class="m">1</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">resources</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span><span class="nt">retentionPeriod</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;14&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">write</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">allow</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Default config for each availability zone components, including vmagent, vmcluster, vmsingle, vmauth etc. Defines a template for each availability zone, which can be overridden for each availability zone at <code>availabilityZones[*]</code></p>
</td>
    </tr>
    <tr id="zonetpl-common-spec">
      <td><a href="#zonetpl-common-spec"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl.common.spec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">affinity</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">nodeSelector</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">topology.kubernetes.io/zone</span><span class="p">:</span><span class="w"> </span><span class="s1">&#39;{{ (.zone).name }}&#39;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">topologySpreadConstraints</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span>- <span class="nt">maxSkew</span><span class="p">:</span><span class="w"> </span><span class="m">1</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">topologyKey</span><span class="p">:</span><span class="w"> </span><span class="l">kubernetes.io/hostname</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">          </span><span class="nt">whenUnsatisfiable</span><span class="p">:</span><span class="w"> </span><span class="l">ScheduleAnyway</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Common for <a href="https://docs.victoriametrics.com/operator/api/#vmagentspec" target="_blank">VMAgent</a>, <a href="https://docs.victoriametrics.com/operator/api/#vmauthspec" target="_blank">VMAuth</a>, <a href="https://docs.victoriametrics.com/operator/api/#vmclusterspec" target="_blank">VMCluster</a> spec params, like nodeSelector, affinity, topologySpreadConstraint, etc</p>
</td>
    </tr>
    <tr id="zonetpl-read-allow">
      <td><a href="#zonetpl-read-allow"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl.read.allow</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Allow data query from this zone through global query endpoint</p>
</td>
    </tr>
    <tr id="zonetpl-read-vmauth-enabled">
      <td><a href="#zonetpl-read-vmauth-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl.read.vmauth.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Create a vmauth with all the zone with <code>allow: true</code> as query backends</p>
</td>
    </tr>
    <tr id="zonetpl-read-vmauth-name">
      <td><a href="#zonetpl-read-vmauth-name"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl.read.vmauth.name</span><span class="p">:</span><span class="w"> </span><span class="l">vmauth-read-proxy-{{ (.zone).name }}</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Override the name of the vmauth object</p>
</td>
    </tr>
    <tr id="zonetpl-read-vmauth-spec">
      <td><a href="#zonetpl-read-vmauth-spec"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl.read.vmauth.spec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">unauthorizedUserAccessSpec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">url_map</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">            </span>- <span class="nt">load_balancing_policy</span><span class="p">:</span><span class="w"> </span><span class="l">first_available</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">              </span><span class="nt">retry_status_codes</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="m">500</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="m">502</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">                </span>- <span class="m">503</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Spec for VMAuth CRD, see <a href="https://docs.victoriametrics.com/operator/api#vmauthspec" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="zonetpl-vmagent-annotations">
      <td><a href="#zonetpl-vmagent-annotations"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl.vmagent.annotations</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>VMAgent remote write proxy annotations</p>
</td>
    </tr>
    <tr id="zonetpl-vmagent-enabled">
      <td><a href="#zonetpl-vmagent-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl.vmagent.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Create VMAgent remote write proxy</p>
</td>
    </tr>
    <tr id="zonetpl-vmagent-name">
      <td><a href="#zonetpl-vmagent-name"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl.vmagent.name</span><span class="p">:</span><span class="w"> </span><span class="l">vmagent-{{ (.zone).name }}</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Override the name of the vmagent object</p>
</td>
    </tr>
    <tr id="zonetpl-vmagent-spec">
      <td><a href="#zonetpl-vmagent-spec"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl.vmagent.spec</span><span class="p">:</span><span class="w"> </span>{}</span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Spec for VMAgent CRD, see <a href="https://docs.victoriametrics.com/operator/api#vmagentspec" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="zonetpl-vmcluster-enabled">
      <td><a href="#zonetpl-vmcluster-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl.vmcluster.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Create VMCluster</p>
</td>
    </tr>
    <tr id="zonetpl-vmcluster-name">
      <td><a href="#zonetpl-vmcluster-name"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl.vmcluster.name</span><span class="p">:</span><span class="w"> </span><span class="l">vmcluster-{{ (.zone).name }}</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Override the name of the vmcluster, by default is <zoneName></p>
</td>
    </tr>
    <tr id="zonetpl-vmcluster-spec">
      <td><a href="#zonetpl-vmcluster-spec"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl.vmcluster.spec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">replicationFactor</span><span class="p">:</span><span class="w"> </span><span class="m">2</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">retentionPeriod</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;14&#34;</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">vminsert</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">extraArgs</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">replicaCount</span><span class="p">:</span><span class="w"> </span><span class="m">2</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">resources</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">vmselect</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">extraArgs</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">replicaCount</span><span class="p">:</span><span class="w"> </span><span class="m">2</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">resources</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">vmstorage</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">replicaCount</span><span class="p">:</span><span class="w"> </span><span class="m">2</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">resources</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">        </span><span class="nt">storageDataPath</span><span class="p">:</span><span class="w"> </span><span class="l">/vm-data</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Spec for VMCluster CRD, see <a href="https://docs.victoriametrics.com/operator/api#vmclusterspec" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="zonetpl-vmsingle-enabled">
      <td><a href="#zonetpl-vmsingle-enabled"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl.vmsingle.enabled</span><span class="p">:</span><span class="w"> </span><span class="kc">false</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Create VMSingle</p>
</td>
    </tr>
    <tr id="zonetpl-vmsingle-name">
      <td><a href="#zonetpl-vmsingle-name"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl.vmsingle.name</span><span class="p">:</span><span class="w"> </span><span class="s1">&#39;{{ (.zone).name }}&#39;</span></span></span></code></pre>
</a></td>
      <td><em><code>(string)</code></em><p>Override the name of the vmsingle, by default is <zoneName></p>
</td>
    </tr>
    <tr id="zonetpl-vmsingle-spec">
      <td><a href="#zonetpl-vmsingle-spec"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl.vmsingle.spec</span><span class="p">:</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">extraArgs</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">replicaCount</span><span class="p">:</span><span class="w"> </span><span class="m">1</span><span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">resources</span><span class="p">:</span><span class="w"> </span>{}<span class="w">
</span></span></span><span class="line"><span class="cl"><span class="w">    </span><span class="nt">retentionPeriod</span><span class="p">:</span><span class="w"> </span><span class="s2">&#34;14&#34;</span></span></span></code></pre>
</a></td>
      <td><em><code>(object)</code></em><p>Spec for VMSingle CRD, see <a href="https://docs.victoriametrics.com/operator/api#vmsinglespec" target="_blank">here</a></p>
</td>
    </tr>
    <tr id="zonetpl-write-allow">
      <td><a href="#zonetpl-write-allow"><pre class="chroma"><code><span class="line"><span class="cl"><span class="nt">zoneTpl.write.allow</span><span class="p">:</span><span class="w"> </span><span class="kc">true</span></span></span></code></pre>
</a></td>
      <td><em><code>(bool)</code></em><p>Allow data ingestion to this zone</p>
</td>
    </tr>
  </tbody>
</table>

