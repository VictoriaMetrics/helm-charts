{{/*
Common labels
*/}}
{{- define "chart.labels" -}}
{{- $Chart := (.helm).Chart | default .Chart -}}
{{- $Release := (.helm).Release | default .Release -}}
helm.sh/chart: {{ include "vm.chart" . }}
{{ include "chart.selectorLabels" . }}
{{- if $Chart.AppVersion }}
app.kubernetes.io/version: {{ $Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $Release.Service | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "chart.selectorLabels" -}}
{{- $Release := (.helm).Release | default .Release -}}
app.kubernetes.io/name: {{ include "vm.name" . }}
app.kubernetes.io/instance: {{ $Release.Name | trunc 63 | trimSuffix "-" }}
{{- with .extraLabels }}
{{ toYaml .}}
{{- end }}
{{- end -}}

{{/*
Defines the name of configuration map
*/}}
{{- define "chart.configname" -}}
{{- if .Values.configMap -}}
{{- .Values.configMap -}}
{{- else -}}
{{- include "vm.fullname" . -}}-config
{{- end -}}
{{- end -}}

{{- define "vmagent.args" -}}
  {{- $args := default dict -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- if empty $Values.remoteWriteUrls -}}
    {{- fail "Please define at least one remoteWriteUrl" -}}
  {{- end -}}
  {{- $_ := set $args "promscrape.config" "/config/scrape.yml" -}}
  {{- $_ := set $args "remoteWrite.tmpDataPath" "/tmpData" -}}
  {{- $_ := set $args "remoteWrite.url" $Values.remoteWriteUrls -}}
  {{- $_ := set $args "remoteWrite.multitenantURL" $Values.multiTenantUrls -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $Values.extraArgs -}}
  {{- if and $Values.statefulset.enabled $Values.statefulset.clusterMode }}
    {{- $_ := set $args "promscrape.cluster.membersCount" $Values.replicaCount -}}
    {{- $_ := set $args "promscrape.cluster.replicationFactor" $Values.statefulset.replicationFactor -}}
    {{- $_ := set $args "promscrape.cluster.memberNum" "$(POD_NAME)" -}}
  {{- end -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}
