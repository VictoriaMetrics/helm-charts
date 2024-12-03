{{- define "vlogs.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $app := $Values.server -}}
  {{- $args := default dict -}}
  {{- if and (empty $app.retentionPeriod) (empty $app.retentionDiskSpaceUsage) -}}
    {{- fail "either .Values.server.retentionPeriod or .Values.server.retentionDiskSpaceUsage should be defined" -}}
  {{- end -}}
  {{- with $app.retentionPeriod -}}
    {{- $_ := set $args "retentionPeriod" $app.retentionPeriod -}}
  {{- end -}}
  {{- with $app.retentionDiskSpaceUsage -}}
    {{- $retentionDiskSpaceUsage := int $app.retentionDiskSpaceUsage -}}
    {{- if $retentionDiskSpaceUsage -}}
      {{- $_ := set $args "retention.maxDiskSpaceUsageBytes" (printf "%dGiB" $retentionDiskSpaceUsage) -}}
    {{- else -}}
      {{- $_ := set $args "retention.maxDiskSpaceUsageBytes" $app.retentionDiskSpaceUsage -}}
    {{- end -}}
  {{- end -}}
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
  {{- $urls := default list }}
  {{- if $Values.server.statefulSet.enabled }}
    {{- range $i := until (int $Values.server.replicaCount) }}
      {{- if $Values.server.statefulSet.enabled }}
        {{- $_ := set $ctx "appIdx" $i }}
      {{- end }}
      {{- $urls = append $urls (printf "%s%s" (include "vm.url" $ctx) $path) }}
    {{- end }}
  {{- else }}
    {{- $urls = append $urls (printf "%s%s" (include "vm.url" $ctx) $path) }}
  {{- end }}
  {{- toJson $urls -}}
{{- end -}}
