{{- define "vlogs.storage.nodes" -}}
  {{- $ctx := . -}}
  {{- $_ := set $ctx "style" "plain" }}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $storages := default list -}}
  {{- $common := $Values.server -}}
  {{- range $name, $server := $Values.servers -}}
    {{- $app := mergeOverwrite (deepCopy $common) (deepCopy $server) -}}
    {{- if eq $app.role "storage" -}}
      {{- $_ := set $ctx $name $app -}}
      {{- $_ := set $ctx "appKey" $name -}}
      {{- range $i := until (int $app.replicaCount) }}
        {{- $_ := set $ctx "appIdx" $i }}
        {{- $storages = append $storages (include "vm.host" $ctx) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml (dict "storages" $storages) -}}
{{- end -}}

{{- define "vlogs.args" -}}
  {{- $storages := .storages -}}
  {{- $app := .app -}}
  {{- $args := default dict -}}
  {{- $appKey := join "." .appKey }}
  {{- $role := $app.role | default "storage" }}
  {{- if eq $role "select" }}
    {{- $_ := set $args "internalinsert.disable" "true" -}}
    {{- $_ := set $args "storageNode" (concat $storages ($app.extraArgs.storageNode | default list)) -}}
  {{- else if eq $role "insert" }}
    {{- $_ := set $args "internalselect.disable" "true" -}}
    {{- $_ := set $args "storageNode" (concat $storages ($app.extraArgs.storageNode | default list)) -}}
  {{- else if eq $role "storage" }}
    {{- if and (empty $app.retentionPeriod) (empty $app.retentionDiskSpaceUsage) -}}
      {{- fail (printf "either .Values.servers.%s.retentionPeriod or .Values.servers.%s.retentionDiskSpaceUsage should be defined" $appKey $appKey) -}}
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
  {{- else -}}
    {{- fail (printf "VictoriaLogs %q role is not supported" $role) -}}
  {{- end }}
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
  {{- $common := $Values.server }}
  {{- $role := "storage" -}}
  {{- $servers := default dict -}}
  {{- range $name, $server :=  $Values.servers }}
    {{- $app := mergeOverwrite (deepCopy $common) (deepCopy $server) }}
    {{- if $app.enabled -}}
      {{- if eq $role "storage" -}}
        {{- if eq $app.role "storage" -}}
          {{- $_ := set $servers $name $app -}}
        {{- else if eq $app.role "insert" -}}
          {{- $role = "insert" -}}
          {{- $servers = dict $name $app -}}
        {{- end }}
      {{- else if eq $role "insert" -}}
        {{- if eq $app.role "insert" -}}
          {{- $_ := set $servers $name $app -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $urls := default list }}
  {{- range $name, $app := $servers }}
    {{- $_ := set $ctx $name $app -}}
    {{- $_ := set $ctx "appKey" $name -}}
    {{- $port := int $app.service.servicePort -}}
    {{- $fullname := include "vm.plain.fullname" $ctx }}
    {{- if and (eq $app.mode "statefulSet") (eq $app.role "storage") }}
      {{- range $i := until (int $app.replicaCount) }}
        {{- $_ := set $ctx "appIdx" $i }}
        {{- $urls = append $urls (printf "%s%s" (include "vm.url" $ctx) $path) }}
      {{- end }}
    {{- else }}
      {{- $urls = append $urls (printf "%s%s" (include "vm.url" $ctx) $path) }}
    {{- end -}}
  {{- end -}}
  {{- toJson $urls -}}
{{- end -}}
