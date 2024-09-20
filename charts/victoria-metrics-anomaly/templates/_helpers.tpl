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
{{- end }}

{{/*
Selector labels
*/}}
{{- define "chart.selectorLabels" -}}
{{- $Release := (.helm).Release | default .Release -}}
app.kubernetes.io/name: {{ include "vm.name" . }}
app.kubernetes.io/instance: {{ $Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "vmanomaly.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $args := default dict -}}
  {{- $_ := set . "flagStyle" "kebab" -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $Values.extraArgs -}}
  {{- $output := (fromYaml (include "vm.args" $args)).args -}}
  {{- $output = concat (list "/etc/config/config.yml") $output -}}
  {{- toYaml $output -}}
{{- end -}}
