
{{- define "vtinsert.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vtinsert -}}
  {{- $args := dict -}}
  {{- $ctx := dict "style" "plain" "appKey" "vtstorage" "helm" .helm }}
  {{- $extraArgs := $app.extraArgs | default dict }}
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- end -}}
  {{- $storage := $Values.vtstorage }}
  {{- if and (not $app.suppressStorageFQDNsRender) $storage.enabled $storage.replicaCount }}
    {{- $storageNodes := list }}
    {{- $fqdn := include "vm.fqdn" $ctx }}
    {{- $addrFlag := ($Values.vtstorage.extraArgs | default dict).httpListenAddr -}}
    {{- if empty $addrFlag -}}
      {{- $addrFlag = include "vm.addr.primary" $Values.vtstorage.http -}}
    {{- end -}}
    {{- $port := include "vm.port.from.flag" (dict "flag" $addrFlag "default" "10491") }}
    {{- range $i := until ($storage.replicaCount | int) -}}
      {{- if not (has (float64 $i) $app.excludeStorageIDs) -}}
        {{- $_ := set $ctx "appIdx" $i }}
        {{- $storageNode := include "vm.fqdn" $ctx -}}
        {{- $storageNodes = append $storageNodes (printf "%s:%s" $storageNode $port) -}}
      {{- end -}}
    {{- end -}}
    {{- $_ := unset $ctx "appIdx" }}
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
  {{- $args := dict -}}
  {{- $extraArgs := $app.extraArgs | default dict }}
  {{- $_ := set $args "auth.config" "/config/auth.yml" -}}
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- end -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vtselect.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vtselect -}}
  {{- $args := dict -}}
  {{- $ctx := dict "style" "plain" "appKey" "vtstorage" "helm" .helm }}
  {{- $extraArgs := $app.extraArgs | default dict }}
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- end -}}
  {{- $storage := $Values.vtstorage }}
  {{- if and (not $app.suppressStorageFQDNsRender) $storage.enabled $storage.replicaCount }}
    {{- $storageNodes := list }}
    {{- $fqdn := include "vm.fqdn" $ctx }}
    {{- $addrFlag := ($Values.vtstorage.extraArgs | default dict).httpListenAddr -}}
    {{- if empty $addrFlag -}}
      {{- $addrFlag = include "vm.addr.primary" $Values.vtstorage.http -}}
    {{- end -}}
    {{- $port := include "vm.port.from.flag" (dict "flag" $addrFlag "default" "10491") }}
    {{- range $i := until ($storage.replicaCount | int) -}}
      {{- $_ := set $ctx "appIdx" $i }}
      {{- $storageNode := include "vm.fqdn" $ctx -}}
      {{- $storageNodes = append $storageNodes (printf "%s:%s" $storageNode $port) -}}
    {{- end -}}
    {{- $_ := unset $ctx "appIdx" }}
    {{- $_ := set $args "storageNode" (concat ($args.storageNode | default list) $storageNodes) }}
  {{- end }}
  {{- if empty $args.storageNode }}
    {{- fail "no storageNodes found. Either set vtstorage.enabled to true or add nodes to vtselect.extraArgs.storageNode"}}
  {{- end }}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vtstorage.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vtstorage -}}
  {{- $args := dict -}}
  {{- $extraArgs := $app.extraArgs | default dict }}
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
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- end -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vtselect.ports" -}}
{{- $service := .service -}}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- $ports := ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
{{- range $ports }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "10471") }}
  port: {{ ternary ($service.servicePort | default $port) $port (and (.primary | default false) (not (empty $service.servicePort))) }}
  protocol: TCP
  targetPort: {{ ternary $service.targetPort .name (and (.primary | default false) (not (empty $service.targetPort))) }}
  {{- if and (.primary | default false) $service.nodePort }}
  nodePort: {{ $service.nodePort }}
  {{- end }}
{{- end }}
{{- range $service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: TCP
  targetPort: {{ .targetPort }}
{{- end }}
{{- end -}}

{{- define "vtinsert.ports" -}}
{{- $service := .service -}}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- $ports := ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
{{- range $ports }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "10481") }}
  port: {{ ternary ($service.servicePort | default $port) $port (and (.primary | default false) (not (empty $service.servicePort))) }}
  protocol: TCP
  targetPort: {{ ternary $service.targetPort .name (and (.primary | default false) (not (empty $service.targetPort))) }}
  {{- if and (.primary | default false) $service.nodePort }}
  nodePort: {{ $service.nodePort }}
  {{- end }}
{{- end }}
{{- with .extraArgs.otlpGRPCListenAddr }}
- name: otlpgrpc-tcp
  protocol: TCP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: otlpgrpc-tcp
{{- end }}
{{- range $service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: {{ .protocol | default "TCP" }}
  targetPort: {{ .targetPort }}
{{- end }}
{{- end -}}

{{- define "vtstorage.ports" -}}
{{- $service := .service -}}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- $ports := ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
{{- range $ports }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "10491") }}
  port: {{ ternary ($service.servicePort | default $port) $port (and (.primary | default false) (not (empty $service.servicePort))) }}
  protocol: TCP
  targetPort: {{ ternary $service.targetPort .name (and (.primary | default false) (not (empty $service.targetPort))) }}
  {{- if and (.primary | default false) $service.nodePort }}
  nodePort: {{ $service.nodePort }}
  {{- end }}
{{- end }}
{{- range $service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: TCP
  targetPort: {{ .targetPort }}
{{- end }}
{{- end -}}

{{- define "vmauth.ports" -}}
{{- $service := .service -}}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- $ports := ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
{{- range $ports }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "8427") }}
  port: {{ ternary ($service.servicePort | default $port) $port (and (.primary | default false) (not (empty $service.servicePort))) }}
  targetPort: {{ ternary $service.targetPort .name (and (.primary | default false) (not (empty $service.targetPort))) }}
  protocol: TCP
  {{- if and (.primary | default false) $service.nodePort }}
  nodePort: {{ $service.nodePort }}
  {{- end }}
{{- end }}
{{- range $service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: TCP
  targetPort: {{ .targetPort }}
{{- end }}
{{- end -}}
