{{- define "vl.syslog.args" -}}
  {{- $args := dict }}
  {{- range $kind, $sls := . }}
    {{- range $i, $sl := $sls -}}
      {{- if not $sl.value -}}
        {{- fail (printf "`value` is not set for `syslog.%s` idx %d" $kind $i) -}}
      {{- end -}}
      {{- range $slKey, $slValue := (omit $sl "name") -}}
        {{- $key := ternary "listenAddr" $slKey (eq $slKey "value") -}}
        {{- $key = ternary (printf "syslog.%s" $key) (printf "syslog.%s.%s" $key $kind) (hasPrefix "tls" $key) -}}
        {{- $param := index $args $key | default list -}}
        {{- if $slValue -}}
          {{- range until (int (sub $i (len $param))) }}
            {{- $param = append $param "" }}
          {{- end }}
          {{- $param = append $param $slValue }}
          {{- $_ := set $args $key $param -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml $args -}}
{{- end -}}


{{- define "vlinsert.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vlinsert -}}
  {{- $args := dict "select.disable" "true" -}}
  {{- $ctx := dict "style" "plain" "appKey" "vlstorage" "helm" .helm }}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" $ctx)) -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vl.syslog.args" $app.syslog)) -}}
  {{- include "vl.check.extraArgs" $app.extraArgs -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- $storage := $Values.vlstorage }}
  {{- if and (not $app.suppressStorageFQDNsRender) $storage.enabled $storage.replicaCount }}
    {{- $storageNodes := list }}
    {{- $fqdn := include "vm.fqdn" $ctx }}
    {{- $port := include "vm.port.from.flag" (dict "flag" (include "vm.addr.primary" $Values.vlstorage.http) "default" "9491") }}
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
  {{- $_ := set $args "auth.config" "/config/auth.yml" -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- include "vm.check.extraArgs" $app.extraArgs -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vlselect.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vlselect -}}
  {{- $args := dict "insert.disable" "true" -}}
  {{- $ctx := dict "style" "plain" "appKey" "vlstorage" "helm" .helm }}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- include "vm.check.extraArgs" $app.extraArgs -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- $storage := $Values.vlstorage }}
  {{- if and (not $app.suppressStorageFQDNsRender) $storage.enabled $storage.replicaCount }}
    {{- $storageNodes := list }}
    {{- $fqdn := include "vm.fqdn" $ctx }}
    {{- $port := include "vm.port.from.flag" (dict "flag" (include "vm.addr.primary" $Values.vlstorage.http) "default" "9491") }}
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
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- include "vm.check.extraArgs" $app.extraArgs -}}
  {{- $args = mergeOverwrite $args $app.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vlselect.ports" -}}
{{- $service := .service -}}
{{- range .http }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "9471") }}
  port: {{ ternary ($service.servicePort | default $port) $port (and .primary (not (empty $service.servicePort))) }}
  protocol: TCP
  targetPort: {{ .name }}
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
{{- range .http }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "9481") }}
  port: {{ ternary ($service.servicePort | default $port) $port (and .primary (not (empty $service.servicePort))) }}
  protocol: TCP
  targetPort: {{ .name }}
{{- end }}
{{- range .syslog.tcp }}
- name: {{ .name }}
  port: {{ include "vm.port.from.flag" (dict "flag" .value) }}
  protocol: TCP
  targetPort: {{ .name }}
{{- end }}
{{- range .syslog.udp }}
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
{{- range .http }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "9491") }}
  port: {{ ternary ($service.servicePort | default $port) $port (and .primary (not (empty $service.servicePort))) }}
  protocol: TCP
  targetPort: {{ .name }}
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
{{- range .http }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "8427") }}
  port: {{ ternary ($service.servicePort | default $port) $port (and .primary (not (empty $service.servicePort))) }}
  protocol: TCP
  targetPort: {{ .name }}
{{- end }}
{{- range $service.extraPorts }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: TCP
  targetPort: {{ .targetPort }}
{{- end }}
{{- end -}}
