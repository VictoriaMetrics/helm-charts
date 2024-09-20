{{/*
Create unified labels for victoria-logs components
*/}}
{{- define "victoria-logs.common.matchLabels" -}}
{{- $Release := (.helm).Release | default .Release -}}
app.kubernetes.io/name: {{ include "vm.name" . }}
app.kubernetes.io/instance: {{ $Release.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "victoria-logs.common.metaLabels" -}}
{{- $Release := (.helm).Release | default .Release -}}
helm.sh/chart: {{ include "vm.chart" . }}
app.kubernetes.io/managed-by: {{ $Release.Service | trunc 63 | trimSuffix "-" }}
{{- with .extraLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "victoria-logs.server.labels" -}}
{{ include "victoria-logs.server.matchLabels" . }}
{{ include "victoria-logs.common.metaLabels" . }}
{{- end -}}

{{- define "victoria-logs.server.matchLabels" -}}
app: {{ include "vm.app.name" . }}
{{ include "victoria-logs.common.matchLabels" . }}
{{- end -}}

{{- define "vlogs.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $app := $Values.server -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "retentionPeriod" $app.retentionPeriod -}}
  {{- $_ := set $args "storageDataPath" $app.persistentVolume.mountPath -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}
