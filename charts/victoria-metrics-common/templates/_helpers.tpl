{{- define "vm.namespace" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $Values.namespaceOverride | default ($Values.global).namespaceOverride | default $Release.Namespace -}}
{{- end -}}

{{- define "vm.validate.args" -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $Capabilities := (.helm).Capabilities | default .Capabilities -}}
  {{- if semverCompare "<3.14.0" $Capabilities.HelmVersion.Version }}
    {{- fail "This chart requires helm version 3.14.0 or higher" }}
  {{- end }}
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
  {{- $fullname = tpl $fullname . -}}
  {{- if or ($Values.global).disableNameTruncation $Values.disableNameTruncation -}}
    {{- $fullname -}}
  {{- else -}}
    {{- $fullname | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end }}

{{- define "vm.cr.fullname" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $_ := set . "overrideKey" "name" -}}
  {{- $fullname := include "vm.internal.key" . -}}
  {{- $_ := unset . "overrideKey" -}}
  {{- if empty $fullname -}}
    {{- $fullname = include "vm.fullname" . -}}
  {{- end -}}
  {{- $fullname = tpl $fullname . -}}
  {{- if or ($Values.global).disableNameTruncation $Values.disableNameTruncation -}}
    {{- $fullname -}}
  {{- else -}}
    {{- $fullname | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}

{{- define "vm.managed.fullname" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $_ := set . "overrideKey" "name" -}}
  {{- $fullname := include "vm.internal.key" . -}}
  {{- $_ := unset . "overrideKey" -}}
  {{- if empty $fullname -}}
    {{- $fullname = include "vm.fullname" . -}}
  {{- end -}}
  {{- $isLegacy := eq (include "vm.useLegacyNaming" .) "true" -}}
  {{- with include "vm.internal.key.default" . -}}
    {{- $prefix := ternary . (printf "vm%s" .) (or (hasPrefix "vm" .) (hasPrefix "vl" .) (hasPrefix "vt" .)) -}}
    {{- if $isLegacy -}}
      {{- $fullname = printf "%s-%s" $fullname $prefix -}}
    {{- else -}}
      {{- $fullname = printf "%s-%s" $prefix $fullname -}}
    {{- end -}}
  {{- end -}}
  {{- $fullname = tpl $fullname . -}}
  {{- if or ($Values.global).disableNameTruncation $Values.disableNameTruncation -}}
    {{- $fullname -}}
  {{- else -}}
    {{- $fullname | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}

{{- /*
vm.operator.kind returns the operator resource-name prefix for the current
component (e.g. "vlsingle", "vminsert", "vmalertmanager").
Rules (checked in order):
  1. appKey already has vm/vl/vt prefix → use as-is (cluster components)
  2. empty appKey or "server"           → derive from chart name
  3. other named sub-component          → chart prefix + appKey
*/ -}}
{{- define "vm.operator.kind" -}}
  {{- $appKey := include "vm.internal.key.default" . -}}
  {{- $Chart  := (.helm).Chart | default .Chart -}}
  {{- $p := "vm" -}}
  {{- if hasPrefix "victoria-logs" $Chart.Name -}}{{- $p = "vl" -}}{{- end -}}
  {{- if hasPrefix "victoria-traces" $Chart.Name -}}{{- $p = "vt" -}}{{- end -}}
  {{- if or (hasPrefix "vm" $appKey) (hasPrefix "vl" $appKey) (hasPrefix "vt" $appKey) -}}
    {{- $appKey -}}
  {{- else if or (empty $appKey) (eq $appKey "server") -}}
    {{- printf "%s%s" $p (regexReplaceAll "^victoria-(metrics|logs|traces)-" $Chart.Name "") -}}
  {{- else -}}
    {{- printf "%s%s" $p $appKey -}}
  {{- end -}}
{{- end -}}

{{- /*
vm.useLegacyNaming resolves the effective useLegacyNaming setting for the current context.
It traverses the appKey path in Values so that per-component settings (e.g.
.Values.vmsingle.spec.useLegacyNaming) take precedence over the chart-level
.Values.useLegacyNaming.
Returns "true", "false", or "" (not set at any level).
*/ -}}
{{- define "vm.useLegacyNaming" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $result := "" -}}
  {{- if hasKey $Values "useLegacyNaming" -}}
    {{- $result = ternary "true" "false" $Values.useLegacyNaming -}}
  {{- end -}}
  {{- $appKey := list -}}
  {{- if .appKey -}}
    {{- $appKey = ternary (list .appKey) .appKey (kindIs "string" .appKey) -}}
  {{- end -}}
  {{- $values := $Values -}}
  {{- range $ak := $appKey -}}
    {{- if kindIs "map" $values -}}
      {{- $values = index $values $ak | default dict -}}
      {{- if and (kindIs "map" $values) (hasKey $values "useLegacyNaming") -}}
        {{- $result = ternary "true" "false" (index $values "useLegacyNaming") -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $result -}}
{{- end -}}

{{- define "vm.plain.fullname" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $_ := set . "overrideKey" "fullnameOverride" -}}
  {{- $fullname := include "vm.internal.key" . -}}
  {{- $_ := unset . "overrideKey" -}}
  {{- if empty $fullname -}}
    {{- if eq (include "vm.useLegacyNaming" .) "false" -}}
      {{- $release := ((.helm).Release | default .Release).Name -}}
      {{- $fullname = printf "%s-%s" (include "vm.operator.kind" .) $release -}}
    {{- else -}}
      {{- $fullname = include "vm.fullname" . -}}
      {{- with include "vm.internal.key.default" . -}}
        {{- $fullname = printf "%s-%s" $fullname . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $fullname = tpl $fullname . -}}
  {{- if or ($Values.global).disableNameTruncation $Values.disableNameTruncation -}}
    {{- $fullname -}}
  {{- else -}}
    {{- $fullname | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}

{{- define "vm.internal.key" -}}
  {{- include "vm.validate.args" . -}}
  {{- $overrideKey := .overrideKey | default "fullnameOverride" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $key := "" -}}
  {{- if .appKey -}}
    {{- $appKey := ternary (list .appKey) .appKey (kindIs "string" .appKey) -}}
    {{- $ctx := . -}}
    {{- $values := $Values -}}
    {{- range $ak := $appKey }}
      {{- $values = ternary (dict) (index $values $ak | default dict) (empty $values) -}}
      {{- $ctx = ternary (dict) (index $ctx $ak | default dict) (empty $ctx) -}}
      {{- if and (empty $values) (empty $ctx) -}}
        {{- fail (printf "No data for appKey %s" (join "->" $appKey)) -}}
      {{- end -}}
      {{- if and (kindIs "map" $values) (index $values $overrideKey) -}}
        {{- $key = index $values $overrideKey -}}
      {{- else if and (kindIs "map" $ctx) (index $ctx $overrideKey) -}}
        {{- $key = index $ctx $overrideKey -}}
      {{- end -}}
    {{- end }}
    {{- if and (empty $key) .fallback -}}
      {{- $key = include "vm.internal.key.default" . -}}
    {{- end -}}
  {{- end -}}
  {{- $key -}}
{{- end -}}

{{- define "vm.internal.key.default" -}}
  {{- with .appKey -}}
  {{- $key := ternary (list .) . (kindIs "string" .) -}}
  {{- last (without $key "spec") -}}
  {{- end -}}
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
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $globalLabels := deepCopy (($Values.global).extraLabels | default dict) -}}
  {{- $labels := fromYaml (include "vm.selectorLabels" .) -}}
  {{- with $labels.app -}}
    {{- $_ := set $labels "app.kubernetes.io/component" . -}}
  {{- end -}}
  {{- $labels = mergeOverwrite $globalLabels $labels (.extraLabels | default dict) -}}
  {{- $_ := set $labels "app.kubernetes.io/managed-by" $Release.Service -}}
  {{- toYaml $labels -}}
{{- end -}}

{{- define "vm.annotations" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $globalAnnotations := deepCopy (($Values.global).extraAnnotations | default dict) -}}
  {{- $annotations := mergeOverwrite $globalAnnotations (.extraAnnotations | default dict) -}}
  {{- if $annotations -}}
    {{- toYaml $annotations -}}
  {{- end -}}
{{- end -}}

{{- define "vm.keyValue" -}}
  {{- $pairs := list -}}
  {{- range $k, $v := . -}}
    {{- $pairs = append $pairs (printf "%s=%s" $k $v) -}}
  {{- end -}}
  {{- join "," ($pairs | sortAlpha) -}}
{{- end -}}

{{- /* Common labels */ -}}
{{- define "vm.labels" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $globalLabels := deepCopy (($Values.global).extraLabels | default dict) -}}
  {{- $labels := fromYaml (include "vm.commonLabels" .) -}}
  {{- $labels = mergeOverwrite $globalLabels $labels (fromYaml (include "vm.metaLabels" .)) -}}
  {{- with (include "vm.image.tag" .) }}
    {{- $_ := set $labels "app.kubernetes.io/version" (regexReplaceAll "(.*)(@sha.*)" . "${1}") -}}
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
  {{- $_ := set . "overrideKey" "name" -}}
  {{- $_ := set . "fallback" true -}}
  {{- tpl (include "vm.internal.key" .) . -}}
  {{- $_ := unset . "overrideKey" -}}
  {{- $_ := unset . "fallback" -}}
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

{{- define "vm.commonLabels" -}}
  {{- $labels := fromYaml (include "vm.selectorLabels" . ) -}}
  {{- with $labels.app -}}
    {{- $_ := set $labels "app.kubernetes.io/component" . -}}
    {{- $_ := unset $labels "app" -}}
  {{- end -}}
  {{- toYaml $labels -}}
{{- end -}}
