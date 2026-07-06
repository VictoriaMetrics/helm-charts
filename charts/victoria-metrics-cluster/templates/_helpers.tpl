{{- define "vminsert.relabel.config.name" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vminsert }}
  {{- $fullname := include "vm.plain.fullname" . -}}
  {{- $app.relabel.configMap | default (printf "%s-relabelconfig" $fullname) -}}
{{- end -}}

{{- define "vminsert.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vminsert -}}
  {{- $args := dict -}}
  {{- $ctx := dict "style" "plain" "appKey" "vmstorage" "helm" .helm }}
  {{- $extraArgs := $app.extraArgs | default dict }}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" $ctx)) -}}
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- end -}}
  {{- $storage := $Values.vmstorage }}
  {{- if and (not $app.suppressStorageFQDNsRender) $storage.enabled $storage.replicaCount }}
    {{- $storageNodes := list }}
    {{- $fqdn := include "vm.fqdn" $ctx }}
    {{- if $Values.autoDiscovery }}
      {{- if eq (include "vm.enterprise.disabled" $ctx ) "true" }}
        {{- fail "SRV autodiscovery is only supported in enterprise. Either define license or set `autoDiscovery` to `false`" }}
      {{- end }}
      {{- $storageNode := printf "srv+_vminsert._tcp.%s" $fqdn }}
      {{- $storageNodes = append $storageNodes $storageNode }}
    {{- else }}
      {{- $port := "8400" }}
      {{- range $i := until ($storage.replicaCount | int) -}}
        {{- if not (has (float64 $i) $app.excludeStorageIDs) -}}
          {{- $_ := set $ctx "appIdx" $i }}
          {{- $storageNode := include "vm.fqdn" $ctx -}}
          {{- $storageNodes = append $storageNodes (printf "%s:%s" $storageNode $port) -}}
        {{- end -}}
      {{- end -}}
      {{- $_ := unset $ctx "appIdx" }}
    {{- end }}
    {{- $_ := set $args "storageNode" (concat ($args.storageNode | default list) $storageNodes) }}
  {{- end -}}
  {{- if $app.relabel.enabled -}}
    {{- $_ := set $args "relabelConfig" "/relabelconfig/relabel.yml" -}}
  {{- end -}}
  {{- if empty $args.storageNode }}
    {{- fail "no storageNodes found. Either set vmstorage.enabled to true or add nodes to vminsert.extraArgs.storageNode"}}
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

{{- define "vmselect.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vmselect -}}
  {{- $args := dict -}}
  {{- $ctx := dict "style" "plain" "appKey" "vmstorage" "helm" .helm }}
  {{- $_ := set $args "cacheDataPath" $app.cacheMountPath -}}
  {{- $extraArgs := $app.extraArgs | default dict }}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" $ctx)) -}}
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- end -}}
  {{- $storage := $Values.vmstorage }}
  {{- if and (not $app.suppressStorageFQDNsRender) $storage.enabled $storage.replicaCount }}
    {{- $storageNodes := list }}
    {{- $fqdn := include "vm.fqdn" $ctx }}
    {{- if $Values.autoDiscovery }}
      {{- if eq (include "vm.enterprise.disabled" $ctx) "true" }}
        {{- fail "SRV autodiscovery is only supported in enterprise. Either define license or set `autoDiscovery` to `false`" }}
      {{- end }}
      {{- $storageNode := printf "srv+_vmselect._tcp.%s" $fqdn }}
      {{- $storageNodes = append $storageNodes $storageNode }}
    {{- else }}
      {{- $port := "8401" }}
      {{- range $i := until ($storage.replicaCount | int) -}}
        {{- $_ := set $ctx "appIdx" $i }}
        {{- $storageNode := include "vm.fqdn" $ctx -}}
        {{- $storageNodes = append $storageNodes (printf "%s:%s" $storageNode $port) -}}
      {{- end -}}
      {{- $_ := unset $ctx "appIdx" }}
    {{- end }}
    {{- $_ := set $args "storageNode" (concat ($args.storageNode | default list) $storageNodes) }}
  {{- end }}
  {{- $mode := $app.mode }}
  {{- if and $mode (eq $mode "statefulSet") $app.enabled $app.replicaCount }}
    {{- $selectNodes := list }}
    {{- $_ := set $ctx "appKey" "vmselect" }}
    {{- $fqdn := include "vm.fqdn" $ctx }}
    {{- $addrFlag := $extraArgs.httpListenAddr -}}
    {{- if empty $addrFlag -}}
      {{- $addrFlag = include "vm.addr.primary" $app.http -}}
    {{- end -}}
    {{- $port := include "vm.port.from.flag" (dict "flag" $addrFlag "default" "8481") }}
    {{- range $i := until ($app.replicaCount | int) -}}
      {{- $_ := set $ctx "appIdx" $i }}
      {{- $selectNode := include "vm.fqdn" $ctx -}}
      {{- $selectNodes = append $selectNodes (printf "%s:%s" $selectNode $port) -}}
    {{- end -}}
    {{- $_ := unset $ctx "appIdx" }}
    {{- $_ := set $args "selectNode" (concat ($args.selectNode | default list) $selectNodes) }}
  {{- end -}}
  {{- if empty $args.storageNode }}
    {{- fail "no storageNodes found. Either set vmstorage.enabled to true or add nodes to vmselect.extraArgs.storageNode"}}
  {{- end }}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmstorage.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vmstorage -}}
  {{- $args := dict -}}
  {{- $_ := set $args "retentionPeriod" (toString $app.retentionPeriod) -}}
  {{- $_ := set $args "storageDataPath" $app.persistentVolume.mountPath -}}
  {{- $extraArgs := $app.extraArgs | default dict }}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $app.http)) -}}
  {{- end -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmbackupmanager.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vmstorage -}}
  {{- $manager := $app.vmbackupmanager -}}
  {{- $args := dict -}}
  {{- $_ := set $args "disableHourly" $manager.disableHourly -}}
  {{- $_ := set $args "disableDaily" $manager.disableDaily -}}
  {{- $_ := set $args "disableWeekly" $manager.disableWeekly -}}
  {{- $_ := set $args "disableMonthly" $manager.disableMonthly -}}
  {{- $_ := set $args "keepLastHourly" $manager.retention.keepLastHourly -}}
  {{- $_ := set $args "keepLastDaily" $manager.retention.keepLastDaily -}}
  {{- $_ := set $args "keepLastWeekly" $manager.retention.keepLastWeekly -}}
  {{- $_ := set $args "keepLastMonthly" $manager.retention.keepLastMonthly -}}
  {{- $_ := set $args "storageDataPath" $app.persistentVolume.mountPath -}}
  {{- $_ := set $args "dst" (printf "%s/$(POD_NAME)" $manager.destination) -}}
  {{- $_ := set $args "snapshot.createURL" "http://localhost:8482/snapshot/create" -}}
  {{- $_ := set $args "snapshot.deleteURL" "http://localhost:8482/snapshot/delete" -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $manager.extraArgs -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmbackupmanager.restore.args" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $app := $Values.vmstorage -}}
  {{- $manager := $app.vmbackupmanager -}}
  {{- $args := dict -}}
  {{- $_ := set $args "storageDataPath" $app.persistentVolume.mountPath -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $manager.extraArgs -}}
  {{- $output := (fromYaml (include "vm.args" $args)).args -}}
  {{- $output = concat (list "restore") $output -}}
  {{- toYaml $output -}}
{{- end -}}

{{- define "vmselect.ports" -}}
{{- $service := .service }}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- range ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "8481") }}
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
{{- with $extraArgs.clusternativeListenAddr }}
- name: cluster-tcp
  protocol: TCP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: cluster-tcp
{{- end }}
{{- end -}}

{{- define "vminsert.ports" -}}
{{- $service := .service }}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- range ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "8480") }}
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
  protocol: {{ .protocol | default "TCP" }}
  targetPort: {{ .targetPort }}
{{- end }}
{{- with $extraArgs.clusternativeListenAddr }}
- name: cluster-tcp
  protocol: TCP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: cluster-tcp
{{- end }}
{{- with $extraArgs.graphiteListenAddr }}
- name: graphite-tcp
  protocol: TCP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: graphite-tcp
- name: graphite-udp
  protocol: UDP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: graphite-udp
{{- end }}
{{- with $extraArgs.influxListenAddr }}
- name: influx-tcp
  protocol: TCP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: influx-tcp
- name: influx-udp
  protocol: UDP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: influx-udp
{{- end }}
{{- with $extraArgs.opentsdbHTTPListenAddr }}
- name: opentsdbhttp
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: opentsdbhttp
{{- end }}
{{- with $extraArgs.opentsdbListenAddr }}
{{- if or $service.udp (ne $service.type "LoadBalancer") }}
- name: opentsdb-udp
  protocol: UDP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: opentsdb-udp
{{- end }}
- name: opentsdb-tcp
  protocol: TCP
  port: {{ include "vm.port.from.flag" (dict "flag" .) }}
  targetPort: opentsdb-tcp
{{- end }}
{{- end -}}

{{- define "vmstorage.ports" -}}
{{- $service := .service -}}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- range ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "8482") }}
  port: {{ ternary ($service.servicePort | default $port) $port (and (.primary | default false) (not (empty $service.servicePort))) }}
  targetPort: {{ ternary $service.targetPort .name (and (.primary | default false) (not (empty $service.targetPort))) }}
  protocol: TCP
  {{- if and (.primary | default false) $service.nodePort }}
  nodePort: {{ $service.nodePort }}
  {{- end }}
{{- end }}
- port: {{ $service.vmselectPort }}
  targetPort: vmselect
  protocol: TCP
  name: vmselect
- port: {{ $service.vminsertPort }}
  targetPort: vminsert
  protocol: TCP
  name: vminsert
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
{{- range ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
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

{{- define "vmcluster.cr.spec" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $clusterSpec := dict -}}
  {{- if $Values.vminsert.enabled }}
    {{- $compSpec := include "vm.cr.component.spec" (dict "comp" $Values.vminsert) | fromYaml -}}
    {{- $_ := set $clusterSpec "vminsert" $compSpec -}}
  {{- end -}}
  {{- if $Values.vmselect.enabled }}
    {{- $comp := $Values.vmselect -}}
    {{- $compSpec := include "vm.cr.component.spec" (dict "comp" $comp) | fromYaml -}}
    {{- if ($comp.persistentVolume).enabled }}
      {{- $pvc := $comp.persistentVolume -}}
      {{- $storage := dict "resources" (dict "requests" (dict "storage" $pvc.size)) -}}
      {{- with $pvc.accessModes }}{{- $_ := set $storage "accessModes" . }}{{- end -}}
      {{- with $pvc.storageClassName }}{{- $_ := set $storage "storageClassName" . }}{{- end -}}
      {{- $_ := set $compSpec "storage" $storage -}}
    {{- end -}}
    {{- $_ := set $clusterSpec "vmselect" $compSpec -}}
  {{- end -}}
  {{- if $Values.vmstorage.enabled }}
    {{- $comp := $Values.vmstorage -}}
    {{- $compSpec := include "vm.cr.component.spec" (dict "comp" $comp) | fromYaml -}}
    {{- if ($comp.persistentVolume).enabled }}
      {{- $pvc := $comp.persistentVolume -}}
      {{- $storage := dict "resources" (dict "requests" (dict "storage" $pvc.size)) -}}
      {{- with $pvc.accessModes }}{{- $_ := set $storage "accessModes" . }}{{- end -}}
      {{- with $pvc.storageClassName }}{{- $_ := set $storage "storageClassName" . }}{{- end -}}
      {{- $_ := set $compSpec "storage" $storage -}}
    {{- end -}}
    {{- $_ := set $clusterSpec "vmstorage" $compSpec -}}
  {{- end -}}
  {{- if $Values.useLegacyNaming }}{{- $_ := set $clusterSpec "useLegacyNaming" true }}{{- end -}}
  {{- toYaml (mergeOverwrite $clusterSpec ($Values.spec | default dict)) -}}
{{- end -}}
