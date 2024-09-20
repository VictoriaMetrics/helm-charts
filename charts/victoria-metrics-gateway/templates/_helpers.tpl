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
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "vmgateway.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "clusterMode" $Values.clusterMode -}}
  {{- if hasKey $Values.rateLimiter "enable" }}
    {{- fail "`rateLimiter.enable` is deprecated. Use `rateLimiter.enabled` instead" }}
  {{- end }}
  {{- if $Values.rateLimiter.enabled -}}
    {{- $_ := set $args "ratelimit.config" "/config/rate-limiter.yml" -}}
    {{- $_ := set $args "datasource.url" $Values.rateLimiter.datasource.url -}}
    {{- $_ := set $args "enable.rateLimit" $Values.rateLimiter.enabled -}}
  {{- end -}}
  {{- $_ := set $args "enable.auth" $Values.auth.enabled -}}
  {{- $_ := set $args "read.url" $Values.read.url -}}
  {{- $_ := set $args "write.url" $Values.write.url -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $Values.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}
