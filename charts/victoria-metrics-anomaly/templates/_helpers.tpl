{{- define "vmanomaly.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $args := dict -}}
  {{- $_ := set . "flagStyle" "kebab" -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $Values.extraArgs -}}
  {{- $output := (fromYaml (include "vm.args" $args)).args -}}
  {{- $output = concat (list "--watch" "/etc/config/config.yml") $output -}}
  {{- toYaml $output -}}
{{- end -}}

{{- define "vmanomaly.cr.spec" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $spec := include "vm.cr.component.spec" (dict "comp" $Values) | fromYaml -}}
  {{- $_ := unset $spec "hpa" -}}
  {{- if $Values.useLegacyNaming }}{{- $_ := set $spec "useLegacyNaming" true }}{{- end -}}
  {{- toYaml (mergeOverwrite $spec ($Values.spec | default dict)) -}}
{{- end -}}
