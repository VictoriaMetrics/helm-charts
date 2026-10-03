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

{{- /*
vmanomaly.volume.name returns the storage volume name.
It matches the name used by the VictoriaMetrics operator when legacy naming is disabled.
*/ -}}
{{- define "vmanomaly.volume.name" -}}
  {{- ternary "vmanomaly-storage" "models-dump" (eq (include "vm.useLegacyNaming" .) "false") -}}
{{- end -}}
