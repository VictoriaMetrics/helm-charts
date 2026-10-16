
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
{{- $overrides := $service.portOverrides | default dict }}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- $ports := ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
{{- range $ports }}
{{- $override := dig .name dict $overrides }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "10471") }}
  {{- $defaultPort := ternary ($service.servicePort | default $port) $port (and (.primary | default false) (not (empty $service.servicePort))) }}
  port: {{ $override.port | default $defaultPort }}
  protocol: {{ $override.protocol | default "TCP" }}
  {{- $defaultTargetPort := ternary $service.targetPort .name (and (.primary | default false) (not (empty $service.targetPort))) }}
  targetPort: {{ $override.targetPort | default $defaultTargetPort }}
  {{- $defaultNodePort := "" }}
  {{- if and (.primary | default false) $service.nodePort }}
  {{- $defaultNodePort = $service.nodePort }}
  {{- end }}
  {{- with ($override.nodePort | default $defaultNodePort) }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- end }}
{{- range $service.extraPorts }}
{{- $override := dig .name dict $overrides }}
- name: {{ .name }}
  port: {{ $override.port | default .port }}
  protocol: {{ $override.protocol | default (.protocol | default "TCP") }}
  targetPort: {{ $override.targetPort | default .targetPort }}
  {{- with $override.nodePort }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "vtinsert.ports" -}}
{{- $service := .service -}}
{{- $overrides := $service.portOverrides | default dict }}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- $ports := ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
{{- range $ports }}
{{- $override := dig .name dict $overrides }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "10481") }}
  {{- $defaultPort := ternary ($service.servicePort | default $port) $port (and (.primary | default false) (not (empty $service.servicePort))) }}
  port: {{ $override.port | default $defaultPort }}
  protocol: {{ $override.protocol | default "TCP" }}
  {{- $defaultTargetPort := ternary $service.targetPort .name (and (.primary | default false) (not (empty $service.targetPort))) }}
  targetPort: {{ $override.targetPort | default $defaultTargetPort }}
  {{- $defaultNodePort := "" }}
  {{- if and (.primary | default false) $service.nodePort }}
  {{- $defaultNodePort = $service.nodePort }}
  {{- end }}
  {{- with ($override.nodePort | default $defaultNodePort) }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- end }}
{{- with .extraArgs.otlpGRPCListenAddr }}
{{- $override := dig "otlpgrpc-tcp" dict $overrides }}
- name: otlpgrpc-tcp
  protocol: {{ $override.protocol | default "TCP" }}
  port: {{ $override.port | default (include "vm.port.from.flag" (dict "flag" .)) }}
  targetPort: {{ $override.targetPort | default "otlpgrpc-tcp" }}
  {{- with $override.nodePort }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- end }}
{{- range $service.extraPorts }}
{{- $override := dig .name dict $overrides }}
- name: {{ .name }}
  port: {{ $override.port | default .port }}
  protocol: {{ $override.protocol | default (.protocol | default "TCP") }}
  targetPort: {{ $override.targetPort | default .targetPort }}
  {{- with $override.nodePort }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "vtstorage.ports" -}}
{{- $service := .service -}}
{{- $overrides := $service.portOverrides | default dict }}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- $ports := ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
{{- range $ports }}
{{- $override := dig .name dict $overrides }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "10491") }}
  {{- $defaultPort := ternary ($service.servicePort | default $port) $port (and (.primary | default false) (not (empty $service.servicePort))) }}
  port: {{ $override.port | default $defaultPort }}
  protocol: {{ $override.protocol | default "TCP" }}
  {{- $defaultTargetPort := ternary $service.targetPort .name (and (.primary | default false) (not (empty $service.targetPort))) }}
  targetPort: {{ $override.targetPort | default $defaultTargetPort }}
  {{- $defaultNodePort := "" }}
  {{- if and (.primary | default false) $service.nodePort }}
  {{- $defaultNodePort = $service.nodePort }}
  {{- end }}
  {{- with ($override.nodePort | default $defaultNodePort) }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- end }}
{{- range $service.extraPorts }}
{{- $override := dig .name dict $overrides }}
- name: {{ .name }}
  port: {{ $override.port | default .port }}
  protocol: {{ $override.protocol | default (.protocol | default "TCP") }}
  targetPort: {{ $override.targetPort | default .targetPort }}
  {{- with $override.nodePort }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "vmauth.ports" -}}
{{- $service := .service -}}
{{- $overrides := $service.portOverrides | default dict }}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- $ports := ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
{{- range $ports }}
{{- $override := dig .name dict $overrides }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "8427") }}
  {{- $defaultPort := ternary ($service.servicePort | default $port) $port (and (.primary | default false) (not (empty $service.servicePort))) }}
  port: {{ $override.port | default $defaultPort }}
  {{- $defaultTargetPort := ternary $service.targetPort .name (and (.primary | default false) (not (empty $service.targetPort))) }}
  targetPort: {{ $override.targetPort | default $defaultTargetPort }}
  protocol: {{ $override.protocol | default "TCP" }}
  {{- $defaultNodePort := "" }}
  {{- if and (.primary | default false) $service.nodePort }}
  {{- $defaultNodePort = $service.nodePort }}
  {{- end }}
  {{- with ($override.nodePort | default $defaultNodePort) }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- end }}
{{- range $service.extraPorts }}
{{- $override := dig .name dict $overrides }}
- name: {{ .name }}
  port: {{ $override.port | default .port }}
  protocol: {{ $override.protocol | default (.protocol | default "TCP") }}
  targetPort: {{ $override.targetPort | default .targetPort }}
  {{- with $override.nodePort }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- end }}
{{- end -}}

{{- /*
vtstorage.volume.name returns the default storage volume name.
It matches the name used by the VictoriaMetrics operator when legacy naming is disabled.
*/ -}}
{{- define "vtstorage.volume.name" -}}
  {{- ternary "vtstorage-db" "vtstorage-volume" (eq (include "vm.useLegacyNaming" .) "false") -}}
{{- end -}}
