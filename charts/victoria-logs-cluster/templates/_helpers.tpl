{{- define "vlinsert.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vlinsert -}}
  {{- $args := dict "select.disable" "true" -}}
  {{- $ctx := dict "style" "plain" "appKey" "vlstorage" "helm" .helm }}
  {{- $extraArgs := $app.extraArgs | default dict }}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" $ctx)) -}}
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- end -}}
  {{- if and (empty (index $extraArgs "syslog.listenAddr.tcp")) (empty (index $extraArgs "syslog.listenAddr.udp")) -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vl.syslog.args" $app.syslog)) -}}
  {{- end -}}
  {{- $storage := $Values.vlstorage }}
  {{- if and (not $app.suppressStorageFQDNsRender) $storage.enabled $storage.replicaCount }}
    {{- $storageNodes := list }}
    {{- $fqdn := include "vm.fqdn" $ctx }}
    {{- $addrFlag := ($Values.vlstorage.extraArgs | default dict).httpListenAddr -}}
    {{- if empty $addrFlag -}}
      {{- $addrFlag = include "vm.addr.primary" $Values.vlstorage.http -}}
    {{- end -}}
    {{- $port := include "vm.port.from.flag" (dict "flag" $addrFlag "default" "9491") }}
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
    {{- fail "no storageNodes found. Either set vlstorage.enabled to true or add nodes to vlinsert.extraArgs.storageNode"}}
  {{- end }}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmauth.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $app := $Values.vmauth -}}
  {{- $args := dict -}}
  {{- $extraArgs := $app.extraArgs | default dict }}
  {{- $_ := set $args "auth.config" "/config/auth.yml" -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- end -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vlselect.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vlselect -}}
  {{- $args := dict "insert.disable" "true" -}}
  {{- $ctx := dict "style" "plain" "appKey" "vlstorage" "helm" .helm }}
  {{- $extraArgs := $app.extraArgs | default dict }}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- end -}}
  {{- $storage := $Values.vlstorage }}
  {{- if and (not $app.suppressStorageFQDNsRender) $storage.enabled $storage.replicaCount }}
    {{- $storageNodes := list }}
    {{- $fqdn := include "vm.fqdn" $ctx }}
    {{- $addrFlag := ($Values.vlstorage.extraArgs | default dict).httpListenAddr -}}
    {{- if empty $addrFlag -}}
      {{- $addrFlag = include "vm.addr.primary" $Values.vlstorage.http -}}
    {{- end -}}
    {{- $port := include "vm.port.from.flag" (dict "flag" $addrFlag "default" "9491") }}
    {{- range $i := until ($storage.replicaCount | int) -}}
      {{- $_ := set $ctx "appIdx" $i }}
      {{- $storageNode := include "vm.fqdn" $ctx -}}
      {{- $storageNodes = append $storageNodes (printf "%s:%s" $storageNode $port) -}}
    {{- end -}}
    {{- $_ := unset $ctx "appIdx" }}
    {{- $_ := set $args "storageNode" (concat ($args.storageNode | default list) $storageNodes) }}
  {{- end }}
  {{- if empty $args.storageNode }}
    {{- fail "no storageNodes found. Either set vlstorage.enabled to true or add nodes to vlselect.extraArgs.storageNode"}}
  {{- end }}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vlstorage.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vlstorage -}}
  {{- $args := dict -}}
  {{- $extraArgs := $app.extraArgs | default dict }}
  {{- if and (empty $app.retentionPeriod) (empty $app.retentionDiskSpaceUsage) (empty $app.retentionMaxDiskUsagePercent) -}}
    {{- fail "either .Values.server.retentionPeriod, .Values.server.retentionDiskSpaceUsage or .Values.server.retentionMaxDiskUsagePercent should be defined" -}}
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
  {{- with $app.retentionMaxDiskUsagePercent -}}
    {{- $_ := set $args "retention.maxDiskUsagePercent" $app.retentionMaxDiskUsagePercent -}}
  {{- end -}}
  {{- $_ := set $args "storageDataPath" $app.persistentVolume.mountPath -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- end -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vlselect.ports" -}}
{{- $service := .service -}}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- $ports := ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
{{- range $ports }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "9471") }}
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

{{- define "vlinsert.ports" -}}
{{- $service := .service -}}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- $ports := ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
{{- range $ports }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "9481") }}
  port: {{ ternary ($service.servicePort | default $port) $port (and (.primary | default false) (not (empty $service.servicePort))) }}
  protocol: TCP
  targetPort: {{ ternary $service.targetPort .name (and (.primary | default false) (not (empty $service.targetPort))) }}
  {{- if and (.primary | default false) $service.nodePort }}
  nodePort: {{ $service.nodePort }}
  {{- end }}
{{- end }}
{{- $syslogTCPAddr := index $extraArgs "syslog.listenAddr.tcp" -}}
{{- $tcpPorts := ternary .syslog.tcp (list (dict "name" "syslog-tcp" "value" $syslogTCPAddr)) (empty $syslogTCPAddr) }}
{{- range $tcpPorts }}
- name: {{ .name }}
  port: {{ include "vm.port.from.flag" (dict "flag" .value) }}
  protocol: TCP
  targetPort: {{ .name }}
{{- end }}
{{- $syslogUDPAddr := index $extraArgs "syslog.listenAddr.udp" -}}
{{- $udpPorts := ternary .syslog.udp (list (dict "name" "syslog-udp" "value" $syslogUDPAddr)) (empty $syslogUDPAddr) }}
{{- range $udpPorts }}
- name: {{ .name }}
  port: {{ include "vm.port.from.flag" (dict "flag" .value) }}
  protocol: UDP
  targetPort: {{ .name }}
{{- end }}
{{- range $service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: {{ .protocol | default "TCP" }}
  targetPort: {{ .targetPort }}
{{- end }}
{{- end -}}

{{- define "vlstorage.ports" -}}
{{- $service := .service -}}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- $ports := ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
{{- range $ports }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "9491") }}
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
