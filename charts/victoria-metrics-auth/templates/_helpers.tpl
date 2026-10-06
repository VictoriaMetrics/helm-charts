{{- define "vmauth.args" -}}
  {{- $args := dict -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $_ := set $args "auth.config" "/config/auth.yml" -}}
  {{- $extraArgs := $Values.extraArgs | default dict }}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $Values.http)) -}}
  {{- end -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- /*
vmauth.config.name returns the name of the generated config secret.
It matches the operator naming (vmauth-config-<release>) when legacy naming is disabled. With `operator.enabled`
the operator owns that name, so the chart config passed as external config is named vmauth-<release>-config.
*/ -}}
{{- define "vmauth.config.name" -}}
  {{- $helm := .helm | default . -}}
  {{- if include "vm.operator.enabled" (dict "helm" $helm) -}}
    {{- printf "%s-config" (include "vm.plain.fullname" (dict "helm" $helm "kindOverride" "vmauth")) -}}
  {{- else -}}
    {{- include "vm.plain.fullname" (dict "helm" $helm "kindOverride" "vmauth-config") -}}
  {{- end -}}
{{- end -}}
