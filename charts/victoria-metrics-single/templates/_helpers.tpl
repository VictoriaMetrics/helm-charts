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
{{ toYaml .}}
{{- end }}
{{- end -}}

{{- define "victoria-metrics.server.labels" -}}
{{ include "victoria-metrics.server.matchLabels" . }}
{{ include "victoria-metrics.common.metaLabels" . }}
{{- end -}}

{{- define "victoria-metrics.server.matchLabels" -}}
  {{- $ctx := . -}}
  {{- if empty (index $ctx "helm") -}}
    {{- $ctx = dict "helm" . -}}
  {{- end -}}
  {{- $_ := set $ctx "appKey" "server" -}}
app: {{ include "vm.app.name" $ctx }}
{{ include "victoria-metrics.common.matchLabels" $ctx }}
{{- end -}}

{{/*
Defines the name of scrape configuration map
*/}}
{{- define "victoria-metrics.server.scrape.configname" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- if $Values.server.scrape.configMap -}}
    {{- $Values.server.scrape.configMap -}}
  {{- else -}}
    {{- include "vm.server.fullname" . -}}-scrapeconfig
  {{- end -}}
{{- end -}}

{{- define "vm.server.fullname" -}}
  {{- $ctx := . -}}
  {{- if empty (index $ctx "helm") -}}
    {{- $ctx = dict "helm" . -}}
  {{- end -}}
  {{- $_ := set $ctx "appKey" "server" -}}
  {{- include "vm.plain.fullname" $ctx -}}
{{- end -}}

{{/*
Defines the name of relabel configuration map
*/}}
{{- define "victoria-metrics.server.relabel.configname" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- if $Values.server.relabel.configMap -}}
    {{- $Values.server.relabel.configMap -}}
  {{- else -}}
    {{- include "vm.server.fullname" . -}}-relabelconfig
  {{- end -}}
{{- end -}}

{{- define "vmsingle.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $app := $Values.server -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "retentionPeriod" $app.retentionPeriod -}}
  {{- $_ := set $args "storageDataPath" $app.persistentVolume.mountPath -}}
  {{- if $app.scrape.enabled -}}
    {{- $_ := set $args "promscrape.config" "/scrapeconfig/scrape.yml" -}}
  {{- end -}}
  {{- if $app.relabel.enabled -}}
    {{- $_ := set $args "relabelConfig" "/relabelconfig/relabel.yml" -}}
  {{- end -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmbackupmanager.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $app := $Values.server -}}
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
  {{- $Values := (.helm).Values | default .Values }}
  {{- $app := $Values.server -}}
  {{- $manager := $app.vmbackupmanager -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "storageDataPath" $app.persistentVolume.mountPath -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $manager.extraArgs -}}
  {{- $output := (fromYaml (include "vm.args" $args)).args -}}
  {{- $output = concat (list "restore") $output -}}
  {{- toYaml $output -}}
{{- end -}}
