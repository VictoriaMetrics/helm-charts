{{/*
Common labels
*/}}
{{- define "chart.labels" -}}
{{- $Release := (.helm).Release | default .Release -}}
{{- $Chart := (.helm).Chart | default .Chart -}}
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

{{- define "vmauth.args" -}}
  {{- $args := default dict -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $_ := set $args "auth.config" "/config/auth.yml" -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $Values.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}
