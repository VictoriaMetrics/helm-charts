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

{{- define "vmauth.cr.spec" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $spec := include "vm.cr.component.spec" (dict "comp" $Values) | fromYaml -}}
  {{- if $Values.useLegacyNaming }}{{- $_ := set $spec "useLegacyNaming" true }}{{- end -}}
  {{- toYaml (mergeOverwrite $spec ($Values.spec | default dict)) -}}
{{- end -}}
