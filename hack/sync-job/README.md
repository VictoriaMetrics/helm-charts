# sync-job

A Go binary that runs as a Kubernetes Job on every Helm install/upgrade. It fetches Grafana dashboards and alerting/recording rules from upstream URLs, patches them for the local cluster configuration, and applies them directly as Kubernetes resources — ConfigMaps (or GrafanaDashboard CRDs) for dashboards, and VMRule CRDs for rules.

## How it works

1. **Fetch** — downloads each enabled source URL. Local file paths and HTTP/HTTPS URLs are both supported. HTTP requests are retried up to 3 times with exponential backoff.
2. **Patch** — rewrites expressions and metadata to match the local cluster: datasource types, cluster label names, runbook/Grafana URLs, and optional namespace filters.
3. **Apply** — creates or updates ConfigMaps / GrafanaDashboard CRDs / VMRules in the cluster. All managed resources are labelled with `app.kubernetes.io/managed-by=sync-job` and the Helm release name.
4. **Prune** — when enabled, deletes any previously managed resources that are no longer produced by the current config.

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `CONFIG` | `/etc/config/config.yaml` | Path to the config file |
| `NAMESPACE` | `default` | Namespace where resources are created |
| `RELEASE` | _(empty)_ | Helm release name; scopes managed resources per release via `app.kubernetes.io/instance` |
| `RESOURCE_PREFIX` | value of `RELEASE` | Prefix for managed resource names (`<prefix>-rule-<group>`, `<prefix>-dashboard-<name>`). Defaults to `RELEASE`; falls back to `vm-k8s-stack` when both are unset. |
| `PRUNE` | `true` | Set to `false` to disable deletion of orphaned resources |
| `OWNER_REFERENCES` | `true` | Set to `false` to disable setting owner references on managed resources |
| `OUTPUT` | _(empty)_ | Write manifests to this path instead of applying to the cluster. Use `-` for stdout. See [Manifest generation](#manifest-generation). |

Standard `HTTP_PROXY`, `HTTPS_PROXY`, and `NO_PROXY` environment variables are respected for all outbound HTTP requests.

## Manifest generation

Setting `OUTPUT` switches the sync-job from apply mode to generate mode: it fetches and patches all sources exactly as normal, but writes the resulting manifests as YAML to the specified path (or stdout when `-`) instead of applying them to the cluster. No Kubernetes connection is required.

This is useful for:

- **GitOps workflows** — run the sync-job in CI, commit the output to your repository, and deploy the manifests with ArgoCD, Flux, or any other tool. Changes to upstream dashboards and rules become visible as normal Git diffs.
- **Air-gapped clusters** — generate manifests where internet access is available, then deploy the committed output inside the cluster without outbound connectivity.

```sh
docker run \
  -e OUTPUT=- \
  -e CONFIG=/path/to/config.yaml \
  -e NAMESPACE=monitoring \
  -e RELEASE=my-release \
  victoriametrics/sync-job > manifests.yaml
```

### Air-gapped environments

Two approaches are available depending on infrastructure:

- **Manifest generation** — generate manifests in a network-connected environment (CI, developer laptop) and commit them as described above.
- **Private source URLs** — mirror the upstream dashboard and rule files to an internal HTTP server or object storage, then override the `sources` URLs in `values.yaml` to point to your internal endpoints. The sync-job fetches from whatever URLs are configured; no code changes are required. If the internal server requires a proxy, set `HTTP_PROXY`/`HTTPS_PROXY` accordingly.

## Config file

```yaml
common:
  clusterLabel: cluster      # label name used for the cluster dimension
  multicluster: false        # when true, injects clusterLabel into every aggregation modifier

dashboards:
  common:
    grafana:
      labelName: grafana_dashboard   # ConfigMap label that Grafana sidecar watches
      labelValue: "1"
      datasource: prometheus         # datasource type to use in patched expressions
      operator:                      # optional: emit GrafanaDashboard CRDs instead of ConfigMaps
        spec: {}
    labels: {}       # extra labels added to every dashboard resource
    annotations: {}
  dashboards:        # per-dashboard overrides keyed by dashboard name (derived from JSON title)
    my-dashboard:
      enabled: false
      clusterMetric: vm_app_version  # metric used to build the cluster template variable
  sources:
    - url: https://example.com/dashboard.json
      enabled: true   # omit or set true to include; false to skip

rules:
  common:
    runbookUrl: https://runbooks.prometheus-operator.dev/runbooks
    grafanaUrl: ""
    extraGroupByLabels: []   # extra labels appended to every by(...) modifier
    jobNamespaces: {}        # job name → namespace regex; injects namespace filter into matching selectors
    group: {}        # spec fields applied to every VMRule group
    rule: {}         # merged into every rule
    alerting: {}     # merged into every alerting rule
    recording: {}    # merged into every recording rule
    labels: {}
    annotations: {}
  rules:             # per-rule overrides keyed by alert or record name
    CPUThrottlingHigh:
      enabled: false
  groups:            # per-group overrides keyed by upstream group name
    kubernetes-apps:
      enabled: true
      jobNamespaces:
        kube-state-metrics: ".*"
      rule: {}
      alerting: {}
      recording: {}
      rules:
        KubePodCrashLooping:
          enabled: false
  sources:
    - url: https://example.com/rules.yaml
      enabled: true
```

### Group name matching

Group keys under `rules.groups` are matched against upstream group names in this order:

1. Exact match — `kubernetes-apps`
2. Without `.rules` suffix — `kubelet` matches `kubelet.rules`
3. camelCase — `kubernetesApps` matches `kubernetes-apps`

### Expression patching

**Rules:**
- The `cluster` label in `by(...)` / `on(...)` modifiers is renamed to `clusterLabel`.
- In multicluster mode, `clusterLabel` is appended to every aggregation modifier that doesn't already include it.
- `extraGroupByLabels` are appended to every aggregation modifier.
- `jobNamespaces` injects a `namespace=~"<regex>"` filter into metric selectors that have an exact `job="<name>"` match and no existing `namespace` filter. Only applies to jobs whose metrics always carry a namespace label; avoid using it for jobs like `kubelet` where some metrics (e.g. `up`) are not namespace-scoped.
- Grafana variables (`$__rate_interval`, `$__interval`, etc.) are preserved.

**Dashboards:**
- The `cluster` label filter in metric selectors is renamed to `clusterLabel`.
- A `clusterLabel=~"$cluster"` filter is added to multi-label selectors that lack one (skipped for the cluster variable query itself).
- Datasource type and UID are rewritten: `${DS_*}` import inputs are replaced with the configured datasource name; `${variable}` references are preserved.
- Runbook and Grafana URL prefixes in rule annotations are rewritten to the configured values.

## Building

Requires Go 1.24+ with `GOEXPERIMENT=jsonv2`.

```sh
GOEXPERIMENT=jsonv2 go build -o sync-job .
```

## Docker

```sh
docker build -t sync-job .
```

Two-stage build: the final image is `scratch` with the statically linked binary and the system CA certificate bundle.

## Testing

```sh
GOEXPERIMENT=jsonv2 go test ./...
```
