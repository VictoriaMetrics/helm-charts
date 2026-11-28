{{- define "vmestimator.validate" -}}
  {{- if hasKey .Values "mode" -}}
    {{- fail "`.Values.mode` is removed, storage nodes always run, set `.Values.select.enabled: true` to merge estimations of several storage nodes" -}}
  {{- end -}}
  {{- if hasKey .Values "single" -}}
    {{- fail "`.Values.single` is removed, use `.Values.storage` instead" -}}
  {{- end -}}
  {{- if and (lt (int .Values.storage.replicaCount) 1) (not (and .Values.select.enabled (.Values.select.extraArgs | default dict).storageNode)) -}}
    {{- fail ".Values.storage.replicaCount must be positive, unless .Values.select.extraArgs.storageNode points to external storage nodes" -}}
  {{- end -}}
  {{- include "vmestimator.validateNaming" (dict "root" .) -}}
  {{- range $component := include "vmestimator.components" . | fromYamlArray -}}
    {{- include "vmestimator.validateNaming" (dict "root" $ "component" $component) -}}
  {{- end -}}
{{- end -}}

{{- define "vmestimator.components" -}}
  {{- ternary (list "storage" "select") (list "storage") (eq (toString .Values.select.enabled) "true") | toYaml -}}
{{- end -}}

{{- /*
vmestimator.queryComponent returns the component exposing cardinality estimations of all storage nodes:
select if it's enabled and has replicas, storage otherwise.
*/ -}}
{{- define "vmestimator.queryComponent" -}}
  {{- $select := .Values.select -}}
  {{- ternary "select" "storage" (and (eq (toString $select.enabled) "true") (gt (int $select.replicaCount) 0)) -}}
{{- end -}}

{{- define "vmestimator.validateNaming" -}}
  {{- if eq (include "vm.useLegacyNaming" (dict "helm" .root "appKey" .component)) "true" -}}
    {{- fail "useLegacyNaming: true is not supported by the victoria-metrics-estimator chart; it only supports operator-style resource naming" -}}
  {{- end -}}
{{- end -}}

{{- define "vmestimator.configMapName" -}}
  {{- .Values.config.existingConfigMap | default (include "vmestimator.fullname" (dict "root" .)) -}}
{{- end -}}

{{- /*
vmestimator.fullname resolves the fully qualified name of a chart resource.
Pass "component" as "storage" or "select" for a per-component
resource, or omit it for a chart-wide shared resource (ConfigMap, ServiceAccount)
— the latter honors a root-level fullnameOverride/global.fullnameOverride,
matching every other chart.
*/ -}}
{{- define "vmestimator.fullname" -}}
  {{- include "vmestimator.validateNaming" . -}}
  {{- if not .component -}}
    {{- include "vm.plain.fullname" (dict "helm" .root "kindOverride" "vmestimator") -}}
  {{- else -}}
    {{- include "vm.plain.fullname" (dict "helm" .root "appKey" .component "kindOverride" (include "vmestimator.kind" .component)) -}}
  {{- end -}}
{{- end -}}

{{- /*
vmestimator.appValues resolves the configuration dict for a workload component. If select nodes run,
storage nodes expose local cardinality estimations at /cardinality/metrics unless set explicitly.
*/ -}}
{{- define "vmestimator.appValues" -}}
  {{- $app := deepCopy (index .root.Values .component | default dict) -}}
  {{- if and (eq .component "storage") (eq (include "vmestimator.queryComponent" .root) "select") -}}
    {{- $extraArgs := $app.extraArgs | default dict -}}
    {{- if not (hasKey $extraArgs "cardinalityMetrics.exposeAt") -}}
      {{- $_ := set $extraArgs "cardinalityMetrics.exposeAt" "/cardinality/metrics" -}}
      {{- $_ := set $app "extraArgs" $extraArgs -}}
    {{- end -}}
  {{- end -}}
  {{- $app | toYaml -}}
{{- end -}}

{{- define "vmestimator.port" -}}
  {{- $app := fromYaml (include "vmestimator.appValues" .) -}}
  {{- include "vm.port.from.flag" (dict "flag" ($app.extraArgs | default dict).httpListenAddr "default" $app.service.port) -}}
{{- end -}}

{{- /*
vmestimator.cardinalityPath resolves the effective HTTP path vmestimator exposes
cardinality_estimate metrics at for a component.
*/ -}}
{{- define "vmestimator.cardinalityPath" -}}
  {{- $root := .root -}}
  {{- $component := .component -}}
  {{- $app := fromYaml (include "vmestimator.appValues" (dict "root" $root "component" $component)) -}}
  {{- $extraArgs := $app.extraArgs | default dict -}}
  {{- if hasKey $extraArgs "cardinalityMetrics.exposeAt" -}}
    {{- index $extraArgs "cardinalityMetrics.exposeAt" -}}
  {{- else -}}
    /metrics
  {{- end -}}
{{- end -}}

{{- define "vmestimator.args" -}}
  {{- $root := .root -}}
  {{- $component := .component -}}
  {{- $app := fromYaml (include "vmestimator.appValues" (dict "root" $root "component" $component)) -}}
  {{- $args := dict "httpListenAddr" (printf ":%v" $app.service.port) -}}
  {{- if ne $component "select" -}}
    {{- $_ := set $args "config" (printf "/etc/vmestimator/%s" $root.Values.config.key) -}}
  {{- else -}}
    {{- $storage := $root.Values.storage -}}
    {{- $addrFlag := ($storage.extraArgs | default dict).httpListenAddr -}}
    {{- $port := include "vm.port.from.flag" (dict "flag" $addrFlag "default" $storage.service.port) -}}
    {{- $storageName := include "vmestimator.fullname" (dict "root" $root "component" "storage") -}}
    {{- $ns := include "vm.namespace" (dict "helm" $root "appKey" "storage") -}}
    {{- $nodes := list -}}
    {{- range $i := until (int $storage.replicaCount) -}}
      {{- $fqdn := printf "%s-%d.%s.%s.svc" $storageName $i $storageName $ns -}}
      {{- with $root.Values.global.cluster.dnsDomain -}}
        {{- $fqdn = printf "%s.%s" $fqdn . -}}
      {{- end -}}
      {{- $nodes = append $nodes (printf "http://%s:%s" $fqdn $port) -}}
    {{- end -}}
    {{- $_ := set $args "storageNode" $nodes -}}
  {{- end -}}
  {{- $args = mergeOverwrite $args ($app.extraArgs | default dict) -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmestimator.workload" -}}
  {{- $root := .root -}}
  {{- $component := .component -}}
  {{- $kind := .kind -}}
  {{- $app := fromYaml (include "vmestimator.appValues" (dict "root" $root "component" $component)) -}}
  {{- $addrFlag := ($app.extraArgs | default dict).httpListenAddr -}}
  {{- $port := include "vm.port.from.flag" (dict "flag" $addrFlag "default" $app.service.port) -}}
  {{- $configChecksum := and (ne $component "select") (not $root.Values.config.existingConfigMap) -}}
  {{- $ctx := dict "helm" $root "appKey" $component "kindOverride" (include "vmestimator.kind" $component) -}}
  {{- $name := include "vmestimator.fullname" (dict "root" $root "component" $component) -}}
  {{- $ns := include "vm.namespace" $ctx -}}
apiVersion: apps/v1
kind: {{ $kind }}
metadata:
  name: {{ $name }}
  namespace: {{ $ns }}
  labels: {{ include "vm.labels" $ctx | nindent 4 }}
spec:
  replicas: {{ $app.replicaCount }}
  {{- if eq $kind "StatefulSet" }}
  serviceName: {{ $name }}
  podManagementPolicy: Parallel
  {{- end }}
  selector:
    matchLabels: {{ include "vm.selectorLabels" $ctx | nindent 6 }}
  template:
    metadata:
      {{- if or $configChecksum $app.podAnnotations }}
      annotations:
        {{- if $configChecksum }}
        checksum/config: {{ toYaml $root.Values.config.data | sha256sum }}
        {{- end }}
        {{- with $app.podAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- end }}
      {{- $_ := set $ctx "extraLabels" $app.podLabels }}
      labels: {{ include "vm.podLabels" $ctx | nindent 8 }}
      {{- $_ := unset $ctx "extraLabels" }}
    spec:
      {{- if or $root.Values.serviceAccount.name $root.Values.serviceAccount.create }}
      serviceAccountName: {{ tpl ($root.Values.serviceAccount.name | default (include "vmestimator.fullname" (dict "root" $root))) $root }}
      automountServiceAccountToken: {{ $root.Values.serviceAccount.automountToken }}
      {{- end }}
      {{- if $root.Values.podSecurityContext.enabled }}
      securityContext: {{ include "vm.securityContext" (dict "securityContext" $root.Values.podSecurityContext "helm" $root) | nindent 8 }}
      {{- end }}
      {{- with ($root.Values.imagePullSecrets | default $root.Values.global.imagePullSecrets) }}
      imagePullSecrets: {{ toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ $component }}
          {{- if $root.Values.securityContext.enabled }}
          securityContext: {{ include "vm.securityContext" (dict "securityContext" $root.Values.securityContext "helm" $root) | nindent 12 }}
          {{- end }}
          image: {{ include "vm.image" (dict "helm" $root) }}
          imagePullPolicy: {{ $root.Values.image.pullPolicy }}
          {{- with $app.command }}
          command: {{ toYaml . | nindent 12 }}
          {{- end }}
          args: {{ include "vmestimator.args" (dict "root" $root "component" $component) | nindent 12 }}
          {{- with $app.envFrom }}
          envFrom: {{ toYaml . | nindent 12 }}
          {{- end }}
          {{- with $app.env }}
          env: {{ toYaml . | nindent 12 }}
          {{- end }}
          ports:
            - name: http
              containerPort: {{ $port }}
              protocol: TCP
          {{- with (fromYaml (include "vm.probe" (dict "app" (dict "probe" $root.Values.probe "extraArgs" $app.extraArgs) "type" "readiness" "helm" $root))) }}
          readinessProbe: {{ toYaml . | nindent 12 }}
          {{- end }}
          {{- with (fromYaml (include "vm.probe" (dict "app" (dict "probe" $root.Values.probe "extraArgs" $app.extraArgs) "type" "liveness" "helm" $root))) }}
          livenessProbe: {{ toYaml . | nindent 12 }}
          {{- end }}
          {{- with $app.resources }}
          resources: {{ toYaml . | nindent 12 }}
          {{- end }}
          {{- if ne $component "select" }}
          volumeMounts:
            - name: config
              mountPath: /etc/vmestimator
              readOnly: true
            {{- with $app.extraVolumeMounts }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
          {{- else }}
          {{- with $app.extraVolumeMounts }}
          volumeMounts: {{ toYaml . | nindent 12 }}
          {{- end }}
          {{- end }}
      {{- with $app.dnsConfig }}
      dnsConfig:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $app.nodeSelector }}
      nodeSelector: {{ toYaml . | nindent 8 }}
      {{- end }}
      {{- with $app.affinity }}
      affinity: {{ toYaml . | nindent 8 }}
      {{- end }}
      {{- with $app.tolerations }}
      tolerations: {{ toYaml . | nindent 8 }}
      {{- end }}
      {{- with $app.topologySpreadConstraints }}
      topologySpreadConstraints: {{ toYaml . | nindent 8 }}
      {{- end }}
      {{- if or (ne $component "select") $app.extraVolumes }}
      volumes:
        {{- if ne $component "select" }}
        - name: config
          configMap:
            name: {{ include "vmestimator.configMapName" $root }}
            items:
              - key: {{ $root.Values.config.key }}
                path: {{ $root.Values.config.key }}
        {{- end }}
        {{- with $app.extraVolumes }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- end }}
{{- end -}}

{{- /*
vmestimator.service renders the Service of a component. The storage Service is the headless governing
Service of the storage StatefulSet.
*/ -}}
{{- define "vmestimator.service" -}}
  {{- $root := .root -}}
  {{- $component := .component -}}
  {{- $headless := eq $component "storage" -}}
  {{- $app := fromYaml (include "vmestimator.appValues" (dict "root" $root "component" $component)) -}}
  {{- $ctx := dict "helm" $root "appKey" $component "kindOverride" (include "vmestimator.kind" $component) "extraLabels" $app.service.labels -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "vmestimator.fullname" (dict "root" $root "component" $component) }}
  namespace: {{ include "vm.namespace" $ctx }}
  labels: {{ include "vm.labels" $ctx | nindent 4 }}
  {{- $_ := unset $ctx "extraLabels" }}
  {{- with $app.service.annotations }}
  annotations: {{ toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if $headless }}
  type: ClusterIP
  clusterIP: None
  publishNotReadyAddresses: true
  {{- else }}
  type: {{ $app.service.type }}
  {{- end }}
  ports:
    - name: http
      port: {{ include "vmestimator.port" (dict "root" $root "component" $component) }}
      targetPort: http
      protocol: TCP
  selector: {{ include "vm.selectorLabels" $ctx | nindent 4 }}
{{- end -}}

{{- /*
vmestimator.monitor renders the VMServiceScrape of a component. It also collects cardinality
estimations of the query component if they're exposed at a separate path.
*/ -}}
{{- define "vmestimator.monitor" -}}
  {{- $root := .root -}}
  {{- $component := .component -}}
  {{- $ctx := dict "helm" $root "appKey" $component "kindOverride" (include "vmestimator.kind" $component) -}}
  {{- $paths := list "/metrics" -}}
  {{- if eq $component (include "vmestimator.queryComponent" $root) -}}
    {{- $paths = append $paths (include "vmestimator.cardinalityPath" (dict "root" $root "component" $component)) | compact | uniq -}}
  {{- end -}}
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMServiceScrape
metadata:
  name: {{ include "vmestimator.fullname" (dict "root" $root "component" $component) }}
  namespace: {{ include "vm.namespace" $ctx }}
  {{- $_ := set $ctx "extraLabels" $root.Values.serviceMonitor.extraLabels }}
  labels: {{ include "vm.labels" $ctx | nindent 4 }}
  {{- $_ := unset $ctx "extraLabels" }}
  {{- with $root.Values.serviceMonitor.annotations }}
  annotations: {{ toYaml . | nindent 4 }}
  {{- end }}
spec:
  endpoints:
    {{- range $paths }}
    - port: http
      path: {{ . }}
      {{- with $root.Values.serviceMonitor.interval }}
      interval: {{ . }}
      {{- end }}
      {{- with $root.Values.serviceMonitor.metricRelabelings }}
      metricRelabelConfigs: {{ toYaml . | nindent 8 }}
      {{- end }}
    {{- end }}
  namespaceSelector:
    matchNames:
      - {{ include "vm.namespace" $ctx }}
  selector:
    matchLabels: {{ include "vm.commonLabels" $ctx | nindent 6 }}
{{- end -}}

{{- /*
vmestimator.kind returns the resource kind of the given component ("storage" or "select"),
or of the chart-wide shared resources when the component is empty. It is used both as the
resource name prefix and as the `app.kubernetes.io/name` label value.
*/ -}}
{{- define "vmestimator.kind" -}}
  {{- if . -}}
    {{- printf "vmestimator-%s" . -}}
  {{- else -}}
    vmestimator
  {{- end -}}
{{- end -}}
