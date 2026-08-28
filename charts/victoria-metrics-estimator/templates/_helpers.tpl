{{- define "vmestimator.validate" -}}
  {{- if not (has .Values.mode (list "single" "cluster")) -}}
    {{- fail ".Values.mode must be either single or cluster" -}}
  {{- end -}}
  {{- if and (eq .Values.mode "cluster") (lt (int .Values.storage.replicaCount) 1) -}}
    {{- fail ".Values.storage.replicaCount must be at least 1 in cluster mode" -}}
  {{- end -}}
{{- end -}}

{{- define "vmestimator.configMapName" -}}
  {{- .Values.config.existingConfigMap | default (include "vmestimator.fullname" (dict "root" .)) -}}
{{- end -}}

{{- define "vmestimator.fullname" -}}
  {{- $root := .root -}}
  {{- $component := .component | default "" -}}
  {{- $ctx := dict "helm" $root -}}
  {{- $fullnameOverride := $root.Values.fullnameOverride | default $root.Values.global.fullnameOverride -}}
  {{- if $component -}}
    {{- $appKey := printf "vmestimator-%s" $component -}}
    {{- $app := deepCopy (index $root.Values $component) -}}
    {{- if and $fullnameOverride (not (hasKey $app "fullnameOverride")) -}}
      {{- $_ := set $app "fullnameOverride" (printf "%s-%s" $fullnameOverride $component) -}}
    {{- end -}}
    {{- $_ := set $root.Values $appKey $app -}}
    {{- $_ := set $ctx "appKey" $appKey -}}
    {{- $_ := set $ctx $appKey $app -}}
  {{- else if $fullnameOverride -}}
    {{- $_ := set $ctx "appKey" "vmestimator" -}}
    {{- $_ := set $ctx "vmestimator" (dict "fullnameOverride" $fullnameOverride) -}}
  {{- end -}}
  {{- include "vm.plain.fullname" $ctx -}}
{{- end -}}

{{- define "vmestimator.args" -}}
  {{- $root := .root -}}
  {{- $component := .component -}}
  {{- $app := index $root.Values $component -}}
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
    {{- range $i := until (int $root.Values.storage.replicaCount) -}}
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
  {{- $app := index $root.Values $component -}}
  {{- $addrFlag := ($app.extraArgs | default dict).httpListenAddr -}}
  {{- $port := include "vm.port.from.flag" (dict "flag" $addrFlag "default" $app.service.port) -}}
  {{- $configChecksum := and (ne $component "select") (not $root.Values.config.existingConfigMap) -}}
  {{- $ctx := dict "helm" $root "appKey" $component -}}
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
  {{- $app := index $root.Values $component -}}
  {{- $addrFlag := ($app.extraArgs | default dict).httpListenAddr -}}
  {{- $port := include "vm.port.from.flag" (dict "flag" $addrFlag "default" $app.service.port) -}}
  {{- $ctx := dict "helm" $root "appKey" $component "extraLabels" $app.service.labels -}}
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
