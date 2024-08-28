{{- define "vm.validate.args" -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- if empty $Chart -}}
    {{- fail "invalid template data" -}}
  {{- end -}}
{{- end -}}

{{- /* Expand the name of the chart. */ -}}
{{- define "vm.name" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $Values.nameOverride | default $Values.global.nameOverride | default $Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- /*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/ -}}
{{- define "vm.fullname" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $appKey := .appKey -}}
  {{- $fullname := default list -}}
  {{- if $Values.fullnameOverride -}}
    {{- $fullname = append $fullname .Values.fullnameOverride -}}
  {{- else if and $appKey (dig $Chart.Name $appKey "fullnameOverride" "" ($Values.global)) -}}
    {{- $fullname = append $fullname (index .Values.global $Chart.Name $appKey "fullnameOverride") -}}
  {{- else }}
    {{- $fullname = append $fullname $Release.Name -}}
    {{- $name := default $Chart.Name $Values.nameOverride -}}
    {{- if not (contains $name ($fullname | join "-")) -}}
      {{- $fullname = append $fullname $name -}}
    {{- end -}}
    {{- if $appKey -}}
      {{- $suffix := (index $Values $appKey "name") | default (dig $Chart.Name $appKey "name" "" $Values.global) -}}
      {{- if $suffix -}}
        {{- $fullname = append $fullname $suffix -}}
      {{- end -}}
    {{- end -}}
  {{- end }}
  {{- $fullname | join "-" | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- /* Create chart name and version as used by the chart label. */ -}}
{{- define "vm.chart" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- printf "%s-%s" $Chart.Name $Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- /* Create the name of the service account to use */ -}}
{{- define "vm.sa.name" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- if $Values.serviceAccount.create }}
    {{- default (include "vm.fullname" .) $Values.serviceAccount.name }}
  {{- else -}}
    {{- default "default" $Values.serviceAccount.name -}}
  {{- end }}
{{- end }}

{{- define "vm.metaLabels" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $labels := .extraLabels | default dict -}}
  {{- $_ := set $labels "helm.sh/chart" (include "vm.chart" .) -}}
  {{- $_ := set $labels "app.kubernetes.io/managed-by" $Release.Service -}}
  {{- toYaml $labels -}}
{{- end -}}

{{- /* Common labels */ -}}
{{- define "vm.labels" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $labels := fromYaml (include "vm.selectorLabels" .) -}}
  {{- $labels = mergeOverwrite $labels (fromYaml (include "vm.metaLabels" .)) -}}
  {{- with $Chart.AppVersion -}}
    {{- $_ := set $labels "app.kubernetes.io/version" ($Chart.AppVersion) -}}
  {{- end -}}
  {{- toYaml $labels -}}
{{- end -}}

{{- define "vm.release" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- default $Release.Name $Values.argocdReleaseOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "vm.app.name" -}}
  {{- if .appKey -}}
    {{- $Values := (.helm).Values | default .Values -}}
    {{- $Chart := (.helm).Chart | default .Chart -}}
    {{- if (index $Values .appKey).name -}}
      {{- (index $Values .appKey).name -}}
    {{- else if dig $Chart.Name .appKey "name" "" ($Values.global) -}}
      {{- index $Values.global $Chart.Name .appKey "name" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- /* Selector labels */ -}}
{{- define "vm.selectorLabels" -}}
  {{- $labels := .extraLabels | default dict -}}
  {{- $_ := set $labels "app.kubernetes.io/name" (include "vm.name" .) -}}
  {{- $_ := set $labels "app.kubernetes.io/instance" (include "vm.release" .) -}}
  {{- with (include "vm.app.name" .) -}}
    {{- $_ := set $labels "app" . -}}
  {{- end -}}
  {{- toYaml $labels -}}
{{- end }}
