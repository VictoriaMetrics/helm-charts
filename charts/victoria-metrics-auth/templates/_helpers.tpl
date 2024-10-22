{{- define "vmauth.args" -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "auth.config" "/config/auth.yml" -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args .Values.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}
