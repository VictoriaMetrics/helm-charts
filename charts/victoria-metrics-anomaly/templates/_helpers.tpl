{{- define "vmanomaly.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $args := default dict -}}
  {{- $_ := set . "flagStyle" "kebab" -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $Values.extraArgs -}}
  {{- $output := (fromYaml (include "vm.args" $args)).args -}}
  {{- $output = concat (list "--watch" "/etc/config/config.yml") $output -}}
  {{- toYaml $output -}}
{{- end -}}
