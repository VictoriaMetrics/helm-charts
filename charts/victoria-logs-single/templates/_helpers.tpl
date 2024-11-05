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
