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

{{- define "vlogs.es.urls" -}}
  {{- $_ := set . "path" "/insert/elasticsearch" -}}
  {{- include "vlogs.urls" . -}}
{{- end -}}

{{- define "vlogs.urls" -}}
  {{- $ctx := . -}}
  {{- $path := .path -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $port := int $Values.server.service.servicePort -}}
  {{- $fullname := include "vm.plain.fullname" $ctx }}
  {{- $replicaCount := ternary (int $Values.server.replicaCount) 1 $Values.server.statefulSet.enabled }}
  {{- $urls := default list }}
  {{- range $i := until $replicaCount }}
    {{- if gt $replicaCount 1 }}
      {{- $_ := set $ctx "appIdx" $i }}
    {{- end }}
    {{- $urls = append $urls (printf "http://%s:%d%s" (include "vm.fqdn" $ctx) $port $path) }}
  {{- end }}
  {{- toJson $urls -}}
{{- end -}}
