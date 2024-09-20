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
app: {{ include "vm.app.name" . }}
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
app: {{ include "vm.app.name" . }}
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
app: {{ include "vm.app.name" . }}
{{ include "victoria-metrics.common.matchLabels" . }}
{{- end -}}

{{- define "vminsert.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vminsert -}}
  {{- $args := default dict -}}
  {{- if not $app.suppressStorageFQDNsRender }}
    {{- $storageNodes := default list -}}
    {{- range $i := until ($Values.vmstorage.replicaCount | int) -}}
      {{- $_ := set $ "appIdx" $i -}}
      {{- $storageNodes = append $storageNodes (printf "%s:8400" (include "vm.fqdn" $)) }}
      {{- $_ := unset $ "appIdx" -}}
    {{- end }}
    {{- with $storageNodes -}}
      {{- $_ := set $args "storageNode" . -}}
    {{- end -}}
  {{- end -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmselect.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vmselect -}}
  {{- $args := default dict -}}
  {{- if not $app.suppressStorageFQDNsRender }}
    {{- $storageNodes := default list -}}
    {{- range $i := until ($Values.vmstorage.replicaCount | int) -}}
      {{- $_ := set $ "appIdx" $i -}}
      {{- $storageNodes = append $storageNodes (printf "%s:8401" (include "vm.fqdn" $)) }}
      {{- $_ := unset $ "appIdx" -}}
    {{- end }}
    {{- with $storageNodes -}}
      {{- $_ := set $args "storageNode" . -}}
    {{- end -}}
  {{- end -}}
  {{- if $Values.vmselect.statefulSet.enabled }}
    {{- $selectNodes := default list -}}
    {{- range $i := until ($Values.vmselect.replicaCount | int) -}}
      {{- $_ := set $ "appIdx" $i -}}
      {{- $selectNodes = append $selectNodes (include "vm.host" $) }}
      {{- $_ := unset $ "appIdx" $i -}}
    {{- end }}
    {{- with $selectNodes -}}
      {{- $_ := set $args "selectNode" . -}}
    {{- end -}}
  {{- end -}}
  {{- $_ := set $args "cacheDataPath" $app.cacheMountPath -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
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
