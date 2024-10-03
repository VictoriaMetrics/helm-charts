{{/*
Create unified labels for victoria-metrics components
*/}}
{{- define "victoria-metrics.common.matchLabels" -}}
{{- $Release := (.helm).Release | default .Release -}}
app.kubernetes.io/name: {{ include "vm.name" . }}
app.kubernetes.io/instance: {{ $Release.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "victoria-metrics.common.metaLabels" -}}
{{- $Release := (.helm).Release | default .Release -}}
helm.sh/chart: {{ include "vm.chart" . }}
app.kubernetes.io/managed-by: {{ $Release.Service | trunc 63 | trimSuffix "-" }}
{{- with .extraLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "victoria-metrics.common.podLabels" -}}
{{- $Release := (.helm).Release | default .Release -}}
app.kubernetes.io/managed-by: {{ $Release.Service | trunc 63 | trimSuffix "-" }}
{{- with .extraLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "victoria-metrics.vmstorage.labels" -}}
{{ include "victoria-metrics.vmstorage.matchLabels" . }}
{{ include "victoria-metrics.common.metaLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vmstorage.podLabels" -}}
{{ include "victoria-metrics.vmstorage.matchLabels" . }}
{{ include "victoria-metrics.common.podLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vmstorage.matchLabels" -}}
{{- $Values := (.helm).Values | default .Values -}}
app: {{ $Values.vmstorage.name | default "vmstorage" }}
{{ include "victoria-metrics.common.matchLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vmselect.labels" -}}
{{ include "victoria-metrics.vmselect.matchLabels" . }}
{{ include "victoria-metrics.common.metaLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vmselect.podLabels" -}}
{{ include "victoria-metrics.vmselect.matchLabels" . }}
{{ include "victoria-metrics.common.podLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vmselect.matchLabels" -}}
{{- $Values := (.helm).Values | default .Values -}}
app: {{ $Values.vmselect.name | default "vmselect" }}
{{ include "victoria-metrics.common.matchLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vminsert.labels" -}}
{{ include "victoria-metrics.vminsert.matchLabels" . }}
{{ include "victoria-metrics.common.metaLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vminsert.podLabels" -}}
{{ include "victoria-metrics.vminsert.matchLabels" . }}
{{ include "victoria-metrics.common.podLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vminsert.matchLabels" -}}
{{- $Values := (.helm).Values | default .Values -}}
app: {{ $Values.vminsert.name | default "vminsert" }}
{{ include "victoria-metrics.common.matchLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vmauth.labels" -}}
{{ include "victoria-metrics.vmauth.matchLabels" . }}   
{{ include "victoria-metrics.common.metaLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vmauth.podLabels" -}}
{{ include "victoria-metrics.vmauth.matchLabels" . }}
{{ include "victoria-metrics.common.podLabels" . }}
{{- end -}}

{{- define "victoria-metrics.vmauth.matchLabels" -}}
{{- $Values := (.helm).Values | default .Values -}}
app: {{ $Values.vmauth.name | default "vmauth" }}
{{ include "victoria-metrics.common.matchLabels" . }}
{{- end -}}

{{- define "vminsert.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vminsert -}}
  {{- $args := default dict -}}
  {{- $_ := set . "style" "plain" }}
  {{- $_ := set . "appKey" "vmstorage" }}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- $storage := $Values.vmstorage }}
  {{- if and (not $app.suppressStorageFQDNsRender) (and $storage.enabled $storage.replicaCount) }}
    {{- $storageNodes := default list }}
    {{- $fqdn := include "vm.fqdn" . }}
    {{- if $Values.autoDiscovery }}
      {{- if eq (include "vm.enterprise.disabled" . ) "true" }}
        {{- fail "SRV autodiscovery is only supported in enterprise. Either define license or set `autoDiscovery` to `false`" }}
      {{- end }}
      {{- $storageNode := printf "srv+_vminsert._tcp.%s" $fqdn }}
      {{- $storageNodes = append $storageNodes $storageNode }}
    {{- else }}
      {{- $port := "8400" }}
      {{- range $i := until ($storage.replicaCount | int) -}}
        {{- if not (has (float64 $i) $app.excludeStorageIDs) -}}
          {{- $_ := set $ "appIdx" $i }}
          {{- $storageNode := include "vm.fqdn" $ -}}
          {{- $storageNodes = append $storageNodes (printf "%s:%s" $storageNode $port) -}}
        {{- end -}}
      {{- end -}}
      {{- $_ := unset $ "appIdx" }}
    {{- end }}
    {{- $_ := set $args "storageNode" (concat ($args.storageNode | default list) $storageNodes) }}
  {{- end -}}
  {{- if empty $args.storageNode }}
    {{- fail "no storageNodes found. Either set vmstorage.enabled to true or add nodes to vminsert.extraArgs.storageNode"}}
  {{- end }}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmauth.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $app := $Values.vmauth -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "auth.config" "/config/auth.yml" -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmselect.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vmselect -}}
  {{- $args := default dict -}}
  {{- $_ := set . "style" "plain" }}
  {{- $_ := set . "appKey" "vmstorage" }}
  {{- $_ := set $args "cacheDataPath" $app.cacheMountPath -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- $storage := $Values.vmstorage }}
  {{- if and (not $app.suppressStorageFQDNsRender) (and $storage.enabled $storage.replicaCount) }}
    {{- $storageNodes := default list }}
    {{- $fqdn := include "vm.fqdn" . }}
    {{- if $Values.autoDiscovery }}
      {{- if eq (include "vm.enterprise.disabled" . ) "true" }}
        {{- fail "SRV autodiscovery is only supported in enterprise. Either define license or set `autoDiscovery` to `false`" }}
      {{- end }}
      {{- $storageNode := printf "srv+_vmselect._tcp.%s" $fqdn }}
      {{- $storageNodes = append $storageNodes $storageNode }}
    {{- else }}
      {{- $port := "8401" }}
      {{- range $i := until ($storage.replicaCount | int) -}}
        {{- $_ := set $ "appIdx" $i }}
        {{- $storageNode := include "vm.fqdn" $ -}}
        {{- $storageNodes = append $storageNodes (printf "%s:%s" $storageNode $port) -}}
      {{- end -}}
      {{- $_ := unset . "appIdx" }}
    {{- end }}
    {{- $_ := set $args "storageNode" (concat ($args.storageNode | default list) $storageNodes) }}
  {{- end }}
  {{- if and $app.statefulSet.enabled $app.enabled $app.replicaCount }}
    {{- $selectNodes := default list }}
    {{- $_ := set . "appKey" "vmselect" }}
    {{- $fqdn := include "vm.fqdn" . }}
    {{- if $Values.autoDiscovery }}
      {{- if eq (include "vm.enterprise.disabled" . ) "true" }}
        {{- fail "SRV autodiscovery is only supported in enterprise. Either define license or set `autoDiscovery` to `false`" }}
      {{- end }}
      {{- $selectNode := printf "srv+_http._tcp.%s" $fqdn }}
      {{- $selectNodes = append $selectNodes $selectNode }}
    {{- else }}
      {{- $port := "8481" }}
      {{- with $app.extraArgs.httpListenAddr }}
        {{- $port = regexReplaceAll ".*:(\\d+)" . "${1}" }}
      {{- end -}}
      {{- range $i := until ($app.replicaCount | int) -}}
        {{- $_ := set $ "appIdx" $i }}
        {{- $selectNode := include "vm.fqdn" $ -}}
        {{- $selectNodes = append $selectNodes (printf "%s:%s" $selectNode $port) -}}
      {{- end -}}
      {{- $_ := unset $ "appIdx" }}
    {{- end }}
    {{- $_ := set $args "selectNode" (concat ($args.selectNode | default list) $selectNodes) }}
  {{- end -}}
  {{- if empty $args.storageNode }}
    {{- fail "no storageNodes found. Either set vmstorage.enabled to true or add nodes to vmselect.extraArgs.storageNode"}}
  {{- end }}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmstorage.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vmstorage -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "retentionPeriod" (toString $app.retentionPeriod) -}}
  {{- $_ := set $args "storageDataPath" $app.persistentVolume.mountPath -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmbackupmanager.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vmstorage -}}
  {{- $manager := $app.vmbackupmanager -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "disableHourly" $manager.disableHourly -}}
  {{- $_ := set $args "disableDaily" $manager.disableDaily -}}
  {{- $_ := set $args "disableWeekly" $manager.disableWeekly -}}
  {{- $_ := set $args "disableMonthly" $manager.disableMonthly -}}
  {{- $_ := set $args "keepLastHourly" $manager.retention.keepLastHourly -}}
  {{- $_ := set $args "keepLastDaily" $manager.retention.keepLastDaily -}}
  {{- $_ := set $args "keepLastWeekly" $manager.retention.keepLastWeekly -}}
  {{- $_ := set $args "keepLastMonthly" $manager.retention.keepLastMonthly -}}
  {{- $_ := set $args "storageDataPath" $app.persistentVolume.mountPath -}}
  {{- $_ := set $args "dst" (printf "%s/$(POD_NAME)" $manager.destination) -}}
  {{- $_ := set $args "snapshot.createURL" "http://localhost:8482/snapshot/create" -}}
  {{- $_ := set $args "snapshot.deleteURL" "http://localhost:8482/snapshot/delete" -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $manager.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmbackupmanager.restore.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vmstorage -}}
  {{- $manager := $app.vmbackupmanager -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "storageDataPath" $app.persistentVolume.mountPath -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $manager.extraArgs -}}
  {{- $output := (fromYaml (include "vm.args" $args)).args -}}
  {{- $output = concat (list "restore") $output -}}
  {{- toYaml $output -}}
{{- end -}}

{{- define "vmselect.ports" -}}
- name: http
  port: {{ .service.servicePort }}
  protocol: TCP
  targetPort: {{ .service.targetPort }}
{{- range .service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: TCP
  targetPort: {{ .targetPort }}
{{- end }}
{{- with .extraArgs.clusternativeListenAddr }}
- name: cluster-tcp
  protocol: TCP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: cluster-tcp
{{- end }}
{{- end -}}

{{- define "vminsert.ports" -}}
- name: http
  port: {{ .service.servicePort }}
  protocol: TCP
  targetPort: {{ .service.targetPort }}
{{- range .service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: TCP
  targetPort: {{ .targetPort }}
{{- end }}
{{- with .extraArgs.clusternativeListenAddr }}
- name: cluster-tcp
  protocol: TCP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: cluster-tcp
{{- end }}
{{- with .extraArgs.graphiteListenAddr }}
- name: graphite-tcp
  protocol: TCP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: graphite-tcp
- name: graphite-udp
  protocol: UDP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: graphite-udp
{{- end }}
{{- with .extraArgs.influxListenAddr }}
- name: influx-tcp
  protocol: TCP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: influx-tcp
- name: influx-udp
  protocol: UDP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: influx-udp
{{- end }}
{{- with .extraArgs.opentsdbHTTPListenAddr }}
- name: opentsdbhttp
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: opentsdbhttp
{{- end }}
{{- with .extraArgs.opentsdbListenAddr }}
{{- if or .service.udp (ne .service.type "LoadBalancer") }}
- name: opentsdb-udp
  protocol: UDP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: opentsdb-udp
{{- end }}
- name: opentsdb-tcp
  protocol: TCP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: opentsdb-tcp
{{- end }}
{{- end -}}

{{- define "vmstorage.ports" -}}
- port: {{ .service.servicePort }}
  targetPort: http
  protocol: TCP
  name: http
- port: {{ .service.vmselectPort }}
  targetPort: vmselect
  protocol: TCP
  name: vmselect
- port: {{ .service.vminsertPort }}
  targetPort: vminsert
  protocol: TCP
  name: vminsert
{{- range .service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: TCP
  targetPort: {{ .targetPort }}
{{- end }}
{{- end -}}

{{- define "vmauth.ports" -}} 
- port: {{ .service.servicePort }}
  targetPort: http
  protocol: TCP 
  name: http 
{{- range .service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: TCP
  targetPort: {{ .targetPort }}
{{- end }}
{{- end -}}
