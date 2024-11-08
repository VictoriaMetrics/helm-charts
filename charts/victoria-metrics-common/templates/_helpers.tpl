{{- define "vm.namespace" -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $Capabilities := (.helm).Capabilities | default .Capabilities -}}
  {{- if semverCompare "<3.14.0" $Capabilities.HelmVersion.Version }}
    {{- fail "This chart requires helm version 3.14.0 or higher" }}
  {{- end }}
  {{- $Values.namespaceOverride | default ($Values.global).namespaceOverride | default $Release.Namespace -}}
{{- end -}}

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
  {{- $nameOverride := $Values.nameOverride | default ($Values.global).nameOverride | default $Chart.Name -}}
  {{- if or ($Values.global).disableNameTruncation $Values.disableNameTruncation -}}
    {{- $nameOverride -}}
  {{- else -}}
    {{- $nameOverride | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
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
  {{- $fullname := "" -}}
  {{- $appendDefault := true -}}
  {{- if .appKey -}}
    {{- $appKey := ternary (list .appKey) .appKey (kindIs "string" .appKey) -}}
    {{- $values := $Values -}}
    {{- range $ak := $appKey }}
      {{- if $values -}}
        {{- $values = (index $values $ak) | default dict -}}
      {{- end -}}
      {{- if and (kindIs "map" $values) $values.fullnameOverride -}}
        {{- $fullname = $values.fullnameOverride -}}
        {{- $appendDefault = false -}}
      {{- else if and (kindIs "map" $values) $values.name -}}
        {{- $fullname = $values.name -}}
      {{- end -}}
    {{- end }}
  {{- end -}}
  {{- if empty $fullname -}}
    {{- if $Values.fullnameOverride -}}
      {{- $fullname = $Values.fullnameOverride -}}
    {{- else if ($Values.global).fullnameOverride -}}
      {{- $fullname = $Values.global.fullnameOverride -}}
    {{- else -}}
      {{- $name := default $Chart.Name $Values.nameOverride -}}
      {{- if contains $name $Release.Name -}}
        {{- $fullname = $Release.Name -}}
      {{- else -}}
        {{- $fullname = (printf "%s-%s" $Release.Name $name) }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if $appendDefault -}}
    {{- $alias := .alias -}}
    {{- with .prefix -}}
      {{- $fullname = printf "%s-%s" (ternary . $alias (empty $alias)) $fullname -}}
    {{- end -}}
    {{- with .suffix -}}
      {{- $fullname = printf "%s-%s" $fullname (ternary . $alias (empty $alias)) }}
    {{- end -}}
  {{- end -}}
  {{- if or ($Values.global).disableNameTruncation $Values.disableNameTruncation -}}
    {{- $fullname -}}
  {{- else -}}
    {{- $fullname | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end }}

{{- define "vm.managed.fullname" -}}
  {{- $prefix := .appKey -}}
  {{- if kindIs "slice" $prefix -}}
    {{- $prefix = last $prefix -}}
  {{- end -}}
  {{- $prefix = ternary $prefix (printf "vm%s" $prefix) (or (hasPrefix "vm" $prefix) (hasPrefix "vl" $prefix)) -}}
  {{- if $prefix -}}
    {{- $_ := set $ "prefix" $prefix -}}
  {{- end -}}
  {{- include "vm.fullname" . -}}
{{- end -}}

{{- define "vm.plain.fullname" -}}
  {{- $suffix := .appKey -}}
  {{- if kindIs "slice" $suffix -}}
    {{- $suffix = last $suffix }}
  {{- end -}}
  {{- if $suffix -}}
    {{- $_ := set . "suffix" $suffix -}}
  {{- end -}}
  {{- include "vm.fullname" . -}}
{{- end -}}

{{- /* Create chart name and version as used by the chart label. */ -}}
{{- define "vm.chart" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $chart := printf "%s-%s" $Chart.Name $Chart.Version | replace "+" "_" -}}
  {{- if or ($Values.global).disableNameTruncation $Values.disableNameTruncation -}}
    {{- $chart -}}
  {{- else -}}
    {{- $chart | trunc 63 | trimSuffix "-" -}}
  {{- end }}
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

{{- define "vm.podLabels" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $labels := fromYaml (include "vm.selectorLabels" .) -}}
  {{- $labels = mergeOverwrite $labels (.extraLabels | default dict) -}}
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
  {{- $release := default $Release.Name $Values.argocdReleaseOverride -}}
  {{- if or ($Values.global).disableNameTruncation $Values.disableNameTruncation -}}
    {{- $release -}}
  {{- else -}}
    {{- $release | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}

{{- define "vm.app.name" -}}
  {{- if .appKey -}}
    {{- $Values := (.helm).Values | default .Values -}}
    {{- $values := $Values -}}
    {{- $appKey := ternary (list .appKey) .appKey (kindIs "string" .appKey) -}}
    {{- $name := last $appKey }}
    {{- range $ak := $appKey }}
      {{- $values = (index $values $ak) | default dict -}}
      {{- if $values.name -}}
        {{- $name = $values.name -}}
      {{- end -}}
    {{- end -}}
    {{- $name -}}
  {{- end -}}
{{- end -}}

{{- /* Selector labels */ -}}
{{- define "vm.selectorLabels" -}}
  {{- $labels := .extraLabels | default dict -}}
  {{- $_ := set $labels "app.kubernetes.io/name" (include "vm.name" .) -}}
  {{- $_ := set $labels "app.kubernetes.io/instance" (include "vm.release" .) -}}
  {{- with (include "vm.app.name" .) -}}
    {{- if eq $.style "managed" -}}
      {{- $_ := set $labels "app.kubernetes.io/component" (printf "%s-%s" (include "vm.name" $) .) -}}
    {{- else -}}
      {{- $_ := set $labels "app" . -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml $labels -}}
{{- end }}
