{{- define "vmestimator.validate" -}}
  {{- if not (has .Values.mode (list "single" "cluster")) -}}
    {{- fail ".Values.mode must be either single or cluster" -}}
  {{- end -}}
  {{- if and (eq .Values.mode "cluster") (lt (int .Values.storage.replicaCount) 1) -}}
    {{- fail ".Values.storage.replicaCount must be at least 1 in cluster mode" -}}
  {{- end -}}
  {{- include "vmestimator.validateNaming" (dict "root" .) -}}
  {{- $components := ternary (list "single") (list "storage" "select") (eq .Values.mode "single") -}}
  {{- range $component := $components -}}
    {{- include "vmestimator.validateNaming" (dict "root" $ "component" $component) -}}
  {{- end -}}
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
Pass "component" as one of "single", "storage" or "select" for a
per-component resource, or omit it for a chart-wide shared resource
(ConfigMap, ServiceAccount) — the latter honors a root-level
fullnameOverride/global.fullnameOverride, matching every other chart.
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
vmestimator.appValues resolves the configuration dict for a workload component.
"single" falls back to "storage" for any field not set under the deprecated
.Values.single. "storage" and "select" read their own block directly.
*/ -}}
{{- define "vmestimator.appValues" -}}
  {{- $root := .root -}}
  {{- $component := .component -}}
  {{- if eq $component "single" -}}
    {{- mergeOverwrite (deepCopy $root.Values.storage) (deepCopy ($root.Values.single | default dict)) | toYaml -}}
  {{- else -}}
    {{- index $root.Values $component | toYaml -}}
  {{- end -}}
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
  replicas: {{ ternary 1 $app.replicaCount (eq $component "single") }}
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
        - name: vmestimator
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

{{- define "vmestimator.serviceName" -}}
  {{- $nameSuffix := .nameSuffix | default "" -}}
  {{- printf "%s%s" ((include "vmestimator.fullname" (dict "root" .root "component" .component)) | trunc (int (sub 63 (len $nameSuffix)))) $nameSuffix | trimSuffix "-" -}}
{{- end -}}

{{- define "vmestimator.service" -}}
  {{- $root := .root -}}
  {{- $component := .component -}}
  {{- $headless := .headless | default false -}}
  {{- $nameSuffix := .nameSuffix | default "" -}}
  {{- $app := fromYaml (include "vmestimator.appValues" (dict "root" $root "component" $component)) -}}
  {{- $addrFlag := ($app.extraArgs | default dict).httpListenAddr -}}
  {{- $port := include "vm.port.from.flag" (dict "flag" $addrFlag "default" $app.service.port) -}}
  {{- $ctx := dict "helm" $root "appKey" $component "kindOverride" (include "vmestimator.kind" $component) "extraLabels" $app.service.labels -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "vmestimator.serviceName" (dict "root" $root "component" $component "nameSuffix" $nameSuffix) }}
  namespace: {{ include "vm.namespace" $ctx }}
  labels: {{ include "vm.labels" $ctx | nindent 4 }}
  {{- $_ := unset $ctx "extraLabels" }}
  {{- with $app.service.annotations }}
  annotations: {{ toYaml . | nindent 4 }}
  {{- end }}
spec:
  type: {{ ternary "ClusterIP" $app.service.type $headless }}
  {{- if $headless }}
  clusterIP: None
  publishNotReadyAddresses: true
  {{- end }}
  ports:
    - name: http
      port: {{ $port }}
      targetPort: http
      protocol: TCP
  selector: {{ include "vm.selectorLabels" $ctx | nindent 4 }}
{{- end -}}

{{- /*
vmestimator.kind returns the resource kind of the given component ("single", "storage" or "select"),
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
