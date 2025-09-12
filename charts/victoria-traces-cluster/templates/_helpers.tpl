{{- define "vtinsert.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vtinsert -}}
  {{- $args := default dict -}}
  {{- $_ := set . "style" "plain" }}
  {{- $_ := set . "appKey" "vtstorage" }}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- $storage := $Values.vtstorage }}
  {{- if and (not $app.suppressStorageFQDNsRender) $storage.enabled $storage.replicaCount }}
    {{- $storageNodes := default list }}
    {{- $fqdn := include "vm.fqdn" . }}
    {{- $port := include "vm.port.from.flag" (dict "flag" $Values.vtstorage.extraArgs.httpListenAddr "default" "10491") }}
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
    {{- fail "no storageNodes found. Either set vtstorage.enabled to true or add nodes to vtinsert.extraArgs.storageNode"}}
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

{{- define "vtselect.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vtselect -}}
  {{- $args := default dict -}}
  {{- $_ := set . "style" "plain" }}
  {{- $_ := set . "appKey" "vtstorage" }}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- $storage := $Values.vtstorage }}
  {{- if and (not $app.suppressStorageFQDNsRender) $storage.enabled $storage.replicaCount }}
    {{- $storageNodes := default list }}
    {{- $fqdn := include "vm.fqdn" . }}
    {{- $port := include "vm.port.from.flag" (dict "flag" $Values.vtstorage.extraArgs.httpListenAddr "default" "10491") }}
    {{- range $i := until ($storage.replicaCount | int) -}}
      {{- $_ := set $ "appIdx" $i }}
      {{- $storageNode := include "vm.fqdn" $ -}}
      {{- $storageNodes = append $storageNodes (printf "%s:%s" $storageNode $port) -}}
    {{- end -}}
    {{- $_ := unset . "appIdx" }}
    {{- $_ := set $args "storageNode" (concat ($args.storageNode | default list) $storageNodes) }}
  {{- end }}
  {{- if empty $args.storageNode }}
    {{- fail "no storageNodes found. Either set vtstorage.enabled to true or add nodes to vtselect.extraArgs.storageNode"}}
  {{- end }}
  {{- $_ := unset . "style" }}
  {{- $_ := unset . "appKey" }}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vtstorage.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vtstorage -}}
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

{{- define "vtselect.ports" -}}
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

{{- define "vtinsert.ports" -}}
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

{{- define "vtstorage.ports" -}}
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
