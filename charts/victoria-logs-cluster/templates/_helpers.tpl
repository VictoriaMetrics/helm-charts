{{- define "vlinsert.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vlinsert -}}
  {{- $args := default dict -}}
  {{- $_ := set . "style" "plain" }}
  {{- $_ := set . "appKey" "vlstorage" }}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- $storage := $Values.vlstorage }}
  {{- if and (not $app.suppressStorageFQDNsRender) $storage.enabled $storage.replicaCount }}
    {{- $storageNodes := default list }}
    {{- $fqdn := include "vm.fqdn" . }}
    {{- $port := include "vm.port.from.flag" (dict "flag" $Values.vlstorage.extraArgs.httpListenAddr "default" "9491") }}
    {{- range $i := until ($storage.replicaCount | int) -}}
      {{- if not (has (float64 $i) $app.excludeStorageIDs) -}}
        {{- $_ := set $ "appIdx" $i }}
        {{- $storageNode := include "vm.fqdn" $ -}}
        {{- $storageNodes = append $storageNodes (printf "%s:%s" $storageNode $port) -}}
      {{- end -}}
    {{- end -}}
    {{- $_ := unset $ "appIdx" }}
    {{- $_ := set $args "storageNode" (concat ($args.storageNode | default list) $storageNodes) }}
  {{- end -}}
  {{- if empty $args.storageNode }}
    {{- fail "no storageNodes found. Either set vlstorage.enabled to true or add nodes to vlinsert.extraArgs.storageNode"}}
  {{- end }}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmauth.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $app := $Values.vmauth -}}
  {{- $args := default dict -}}
  {{- $_ := set $args "auth.config" "/config/auth.yml" -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vlselect.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vlselect -}}
  {{- $args := default dict -}}
  {{- $_ := set . "style" "plain" }}
  {{- $_ := set . "appKey" "vlstorage" }}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- $storage := $Values.vlstorage }}
  {{- if and (not $app.suppressStorageFQDNsRender) $storage.enabled $storage.replicaCount }}
    {{- $storageNodes := default list }}
    {{- $fqdn := include "vm.fqdn" . }}
    {{- $port := include "vm.port.from.flag" (dict "flag" $Values.vlstorage.extraArgs.httpListenAddr "default" "9491") }}
    {{- range $i := until ($storage.replicaCount | int) -}}
      {{- $_ := set $ "appIdx" $i }}
      {{- $storageNode := include "vm.fqdn" $ -}}
      {{- $storageNodes = append $storageNodes (printf "%s:%s" $storageNode $port) -}}
    {{- end -}}
    {{- $_ := unset . "appIdx" }}
    {{- $_ := set $args "storageNode" (concat ($args.storageNode | default list) $storageNodes) }}
  {{- end }}
  {{- if empty $args.storageNode }}
    {{- fail "no storageNodes found. Either set vlstorage.enabled to true or add nodes to vlselect.extraArgs.storageNode"}}
  {{- end }}
  {{- $_ := unset . "style" }}
  {{- $_ := unset . "appKey" }}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vlstorage.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vlstorage -}}
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
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vlselect.ports" -}}
{{- $service := .service }}
{{- $extraArgs := .extraArgs -}}
- name: http
  port: {{ $service.servicePort }}
  protocol: TCP
  targetPort: {{ $service.targetPort }}
{{- range $service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: TCP
  targetPort: {{ .targetPort }}
{{- end }}
{{- end -}}

{{- define "vlinsert.ports" -}}
{{- $service := .service }}
{{- $extraArgs := .extraArgs -}}
- name: http
  port: {{ $service.servicePort }}
  protocol: TCP
  targetPort: {{ $service.targetPort }}
{{- range $service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: {{ .protocol | default "TCP" }}
  targetPort: {{ .targetPort }}
{{- end }}
{{- end -}}

{{- define "vlstorage.ports" -}}
{{- $service := .service -}}
- port: {{ $service.servicePort }}
  targetPort: http
  protocol: TCP
  name: http
{{- range $service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: TCP
  targetPort: {{ .targetPort }}
{{- end }}
{{- end -}}

{{- define "vmauth.ports" -}}
{{- $service := .service -}}
- port: {{ $service.servicePort }}
  targetPort: http
  protocol: TCP 
  name: http 
{{- range $service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: TCP
  targetPort: {{ .targetPort }}
{{- end }}
{{- end -}}

{{- define "vlogs.es.urls" -}}
  {{- $_ := set . "path" "/insert/elasticsearch" -}}
  {{- include "vlinsert.urls" . -}}
{{- end -}}

{{- define "vlinsert.urls" -}}
  {{- $ctx := . -}}
  {{- $path := .path -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.server }}
  {{- $port := int $app.service.servicePort -}}
  {{- if $Values.vmauth.enabled }}
    {{- $_ := set $ctx "appKey" "vmauth" }}
  {{- else }}
    {{- $_ := set $ctx "appKey" "vlinsert" }}
  {{- end }}
  {{- $fullname := include "vm.plain.fullname" $ctx }}
  {{- $urls := default list }}
  {{- $urls = append $urls (printf "%s%s" (include "vm.url" $ctx) $path) }}
  {{- toJson $urls -}}
{{- end -}}
