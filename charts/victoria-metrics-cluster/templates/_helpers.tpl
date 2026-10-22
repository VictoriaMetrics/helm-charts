{{- define "vmstorage.mulDivFloor" -}}
  {{- $a := int64 .a -}}
  {{- $b := int64 .b -}}
  {{- $d := int64 .d -}}
  {{- $maxInt64 := int64 9223372036854775807 -}}
  {{- if or (lt $a 0) (lt $b 0) (le $d 0) -}}
    {{- fail "vmstorage.mulDivFloor requires non-negative values and a positive divisor" -}}
  {{- end -}}
  {{- $bits := list -}}
  {{- $remaining := $b -}}
  {{- range until 63 -}}
    {{- $bits = append $bits (mod $remaining 2) -}}
    {{- $remaining = div $remaining 2 -}}
  {{- end -}}
  {{- $quotient := int64 0 -}}
  {{- $remainder := int64 0 -}}
  {{- $aQuotient := div $a $d -}}
  {{- $aRemainder := mod $a $d -}}
  {{- range reverse $bits -}}
    {{- if gt $quotient (div $maxInt64 2) -}}
      {{- fail "memory quantity is outside the supported int64 range" -}}
    {{- end -}}
    {{- $quotient = mul $quotient 2 -}}
    {{- if ge $remainder (sub $d $remainder) -}}
      {{- $remainder = sub $remainder (sub $d $remainder) -}}
      {{- if eq $quotient $maxInt64 -}}
        {{- fail "memory quantity is outside the supported int64 range" -}}
      {{- end -}}
      {{- $quotient = add $quotient 1 -}}
    {{- else -}}
      {{- $remainder = add $remainder $remainder -}}
    {{- end -}}
    {{- if . -}}
      {{- if gt $quotient (sub $maxInt64 $aQuotient) -}}
        {{- fail "memory quantity is outside the supported int64 range" -}}
      {{- end -}}
      {{- $quotient = add $quotient $aQuotient -}}
      {{- if ge $remainder (sub $d $aRemainder) -}}
        {{- $remainder = sub $remainder (sub $d $aRemainder) -}}
        {{- if eq $quotient $maxInt64 -}}
          {{- fail "memory quantity is outside the supported int64 range" -}}
        {{- end -}}
        {{- $quotient = add $quotient 1 -}}
      {{- else -}}
        {{- $remainder = add $remainder $aRemainder -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $quotient -}}
{{- end -}}

{{- define "vmstorage.memoryBytes" -}}
  {{- $quantity := toString . -}}
  {{- $quantityPattern := "^[+]?([0-9]+([.][0-9]*)?|[.][0-9]+)([eE][+-]?[0-9]+|(Ki|Mi|Gi|Ti|Pi|Ei|n|u|m|k|M|G|T|P|E))?$" -}}
  {{- if not (regexMatch $quantityPattern $quantity) -}}
    {{- fail (printf "invalid memory quantity %q for automatic GOMEMLIMIT" $quantity) -}}
  {{- end -}}
  {{- $suffix := regexFind "(Ki|Mi|Gi|Ti|Pi|Ei|n|u|m|k|M|G|T|P|E)$" $quantity -}}
  {{- $numberText := trimSuffix $suffix $quantity -}}
  {{- $exponentText := regexFind "[eE][+-]?[0-9]+$" $numberText -}}
  {{- $numberText = trimSuffix $exponentText $numberText -}}
  {{- $numberText = trimPrefix "+" $numberText -}}
  {{- $fraction := regexFind "[.][0-9]*$" $numberText -}}
  {{- $whole := trimSuffix $fraction $numberText -}}
  {{- $fractionDigits := trimPrefix "." $fraction -}}
  {{- $exponent := int64 0 -}}
  {{- if $exponentText -}}
    {{- $exponentSign := regexFind "^[+-]" $exponentText -}}
    {{- $exponentDigits := regexReplaceAll "^0+" (regexReplaceAll "^[eE][+-]?" $exponentText "") "" -}}
    {{- if empty $exponentDigits -}}{{- $exponentDigits = "0" -}}{{- end -}}
    {{- if gt (len $exponentDigits) 2 -}}
      {{- fail (printf "memory quantity exponent in %q is outside the supported range" $quantity) -}}
    {{- end -}}
    {{- $exponent = int64 $exponentDigits -}}
    {{- if eq $exponentSign "-" -}}{{- $exponent = mul $exponent -1 -}}{{- end -}}
  {{- end -}}
  {{- $scalePower := sub (len $fractionDigits) $exponent -}}
  {{- $maxInt64 := int64 9223372036854775807 -}}
  {{- $unitNumerators := dict "k" 1000 "M" 1000000 "G" 1000000000 "T" 1000000000000 "P" 1000000000000000 "E" 1000000000000000000 "Ki" 1024 "Mi" 1048576 "Gi" 1073741824 "Ti" 1099511627776 "Pi" 1125899906842624 "Ei" 1152921504606846976 -}}
  {{- $unitNumerator := int64 1 -}}
  {{- if hasKey $unitNumerators $suffix -}}
    {{- $unitNumerator = int64 (index $unitNumerators $suffix) -}}
  {{- end -}}
  {{- $unitDenominatorPower := int64 0 -}}
  {{- if eq $suffix "n" -}}{{- $unitDenominatorPower = int64 9 -}}{{- else if eq $suffix "u" -}}{{- $unitDenominatorPower = int64 6 -}}{{- else if eq $suffix "m" -}}{{- $unitDenominatorPower = int64 3 -}}{{- end -}}
  {{- $denominatorPower := add $scalePower $unitDenominatorPower -}}
  {{- if or (gt $denominatorPower 18) (lt $denominatorPower -18) -}}
    {{- fail (printf "memory quantity precision in %q is outside the supported range" $quantity) -}}
  {{- end -}}
  {{- $digits := regexReplaceAll "^0+" (printf "%s%s" $whole $fractionDigits) "" -}}
  {{- if empty $digits -}}{{- $digits = "0" -}}{{- end -}}
  {{- $wholeDigits := $digits -}}
  {{- $remainderDigits := "0" -}}
  {{- $denominator := int64 1 -}}
  {{- if gt $denominatorPower 0 -}}
    {{- if gt (len $digits) $denominatorPower -}}
      {{- $wholeLength := int (sub (len $digits) $denominatorPower) -}}
      {{- $wholeDigits = substr 0 $wholeLength $digits -}}
      {{- $remainderDigits = substr $wholeLength -1 $digits -}}
    {{- else -}}
      {{- $wholeDigits = "0" -}}
      {{- $remainderDigits = $digits -}}
    {{- end -}}
    {{- range until (int $denominatorPower) -}}
      {{- if gt $denominator (div $maxInt64 10) -}}
        {{- fail (printf "memory quantity precision in %q is outside the supported range" $quantity) -}}
      {{- end -}}
      {{- $denominator = mul $denominator 10 -}}
    {{- end -}}
  {{- else if lt $denominatorPower 0 -}}
    {{- $wholeDigits = printf "%s%s" $digits (repeat (int (sub 0 $denominatorPower)) "0") -}}
  {{- end -}}
  {{- $wholeDigits = regexReplaceAll "^0+" $wholeDigits "" -}}
  {{- if empty $wholeDigits -}}{{- $wholeDigits = "0" -}}{{- end -}}
  {{- $remainderDigits = regexReplaceAll "^0+" $remainderDigits "" -}}
  {{- if empty $remainderDigits -}}{{- $remainderDigits = "0" -}}{{- end -}}
  {{- if or (gt (len $wholeDigits) 19) (and (eq (len $wholeDigits) 19) (gt $wholeDigits "9223372036854775807")) -}}
    {{- fail (printf "memory quantity %q is outside the supported int64 range" $quantity) -}}
  {{- end -}}
  {{- $wholeBytes := include "vmstorage.mulDivFloor" (dict "a" (int64 $wholeDigits) "b" $unitNumerator "d" 1) | int64 -}}
  {{- $fractionalBytes := include "vmstorage.mulDivFloor" (dict "a" (int64 $remainderDigits) "b" $unitNumerator "d" $denominator) | int64 -}}
  {{- if gt $wholeBytes (sub $maxInt64 $fractionalBytes) -}}
    {{- fail (printf "memory quantity %q is outside the supported int64 range" $quantity) -}}
  {{- end -}}
  {{- add $wholeBytes $fractionalBytes -}}
{{- end -}}

{{- define "vmstorage.gomemlimit" -}}
  {{- $memoryBytes := include "vmstorage.memoryBytes" . | int64 -}}
  {{- $memoryMiB := include "vmstorage.mulDivFloor" (dict "a" $memoryBytes "b" 17 "d" 20971520) | int64 -}}
  {{- if lt $memoryMiB 1 -}}
    {{- fail (printf "85%% of memory quantity %q is less than 1MiB; automatic GOMEMLIMIT must be at least 1MiB" .) -}}
  {{- end -}}
  {{- printf "%dMiB" $memoryMiB -}}
{{- end -}}

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
{{- $overrides := $service.portOverrides | default dict }}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- range ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
{{- $override := dig .name dict $overrides }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "8481") }}
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
{{- with $extraArgs.clusternativeListenAddr }}
{{- $override := dig "clusternative" dict $overrides }}
- name: clusternative
  protocol: {{ $override.protocol | default "TCP" }}
  port: {{ $override.port | default (include "vm.port.from.flag" (dict "flag" .)) }}
  targetPort: {{ $override.targetPort | default "clusternative" }}
  {{- with $override.nodePort }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "vminsert.ports" -}}
{{- $service := .service }}
{{- $overrides := $service.portOverrides | default dict }}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- range ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
{{- $override := dig .name dict $overrides }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "8480") }}
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
{{- with $extraArgs.clusternativeListenAddr }}
{{- $override := dig "clusternative" dict $overrides }}
- name: clusternative
  protocol: {{ $override.protocol | default "TCP" }}
  port: {{ $override.port | default (include "vm.port.from.flag" (dict "flag" .)) }}
  targetPort: {{ $override.targetPort | default "clusternative" }}
  {{- with $override.nodePort }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- end }}
{{- with $extraArgs.graphiteListenAddr }}
{{- $override := dig "graphite-tcp" dict $overrides }}
- name: graphite-tcp
  protocol: {{ $override.protocol | default "TCP" }}
  port: {{ $override.port | default (include "vm.port.from.flag" (dict "flag" .)) }}
  targetPort: {{ $override.targetPort | default "graphite-tcp" }}
  {{- with $override.nodePort }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- $override := dig "graphite-udp" dict $overrides }}
- name: graphite-udp
  protocol: {{ $override.protocol | default "UDP" }}
  port: {{ $override.port | default (include "vm.port.from.flag" (dict "flag" .)) }}
  targetPort: {{ $override.targetPort | default "graphite-udp" }}
  {{- with $override.nodePort }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- end }}
{{- with $extraArgs.influxListenAddr }}
{{- $override := dig "influx-tcp" dict $overrides }}
- name: influx-tcp
  protocol: {{ $override.protocol | default "TCP" }}
  port: {{ $override.port | default (include "vm.port.from.flag" (dict "flag" .)) }}
  targetPort: {{ $override.targetPort | default "influx-tcp" }}
  {{- with $override.nodePort }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- $override := dig "influx-udp" dict $overrides }}
- name: influx-udp
  protocol: {{ $override.protocol | default "UDP" }}
  port: {{ $override.port | default (include "vm.port.from.flag" (dict "flag" .)) }}
  targetPort: {{ $override.targetPort | default "influx-udp" }}
  {{- with $override.nodePort }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- end }}
{{- with $extraArgs.opentsdbHTTPListenAddr }}
{{- $override := dig "opentsdbhttp" dict $overrides }}
- name: opentsdbhttp
  port: {{ $override.port | default (include "vm.port.from.flag" (dict "flag" .)) }}
  {{- with $override.protocol }}
  protocol: {{ . }}
  {{- end }}
  targetPort: {{ $override.targetPort | default "opentsdbhttp" }}
  {{- with $override.nodePort }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- end }}
{{- with $extraArgs.opentsdbListenAddr }}
{{- if or $service.udp (ne $service.type "LoadBalancer") }}
{{- $override := dig "opentsdb-udp" dict $overrides }}
- name: opentsdb-udp
  protocol: {{ $override.protocol | default "UDP" }}
  port: {{ $override.port | default (include "vm.port.from.flag" (dict "flag" .)) }}
  targetPort: {{ $override.targetPort | default "opentsdb-udp" }}
  {{- with $override.nodePort }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- end }}
{{- $override := dig "opentsdb-tcp" dict $overrides }}
- name: opentsdb-tcp
  protocol: {{ $override.protocol | default "TCP" }}
  port: {{ $override.port | default (include "vm.port.from.flag" (dict "flag" .)) }}
  targetPort: {{ $override.targetPort | default "opentsdb-tcp" }}
  {{- with $override.nodePort }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "vmstorage.ports" -}}
{{- $service := .service -}}
{{- $overrides := $service.portOverrides | default dict }}
{{- $extraArgs := .extraArgs | default dict -}}
{{- $httpAddr := $extraArgs.httpListenAddr -}}
{{- range ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
{{- $override := dig .name dict $overrides }}
- name: {{ .name }}
  {{- $port := include "vm.port.from.flag" (dict "flag" .value "default" "8482") }}
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
{{- $override := dig "vmselect" dict $overrides }}
- port: {{ $override.port | default $service.vmselectPort }}
  targetPort: {{ $override.targetPort | default "vmselect" }}
  protocol: {{ $override.protocol | default "TCP" }}
  name: vmselect
  {{- with $override.nodePort }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
  {{- end }}
{{- $override := dig "vminsert" dict $overrides }}
- port: {{ $override.port | default $service.vminsertPort }}
  targetPort: {{ $override.targetPort | default "vminsert" }}
  protocol: {{ $override.protocol | default "TCP" }}
  name: vminsert
  {{- with $override.nodePort }}
  nodePort: {{ . }}
  {{- end }}
  {{- with $override.appProtocol }}
  appProtocol: {{ . }}
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
{{- range ternary .http (list (dict "name" "http" "value" $httpAddr "primary" true)) (empty $httpAddr) }}
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
vmstorage.volume.name returns the default storage volume name.
It matches the name used by the VictoriaMetrics operator when legacy naming is disabled.
*/ -}}
{{- define "vmstorage.volume.name" -}}
  {{- ternary "vmstorage-db" "vmstorage-volume" (eq (include "vm.useLegacyNaming" .) "false") -}}
{{- end -}}

{{- /*
vmselect.volume.name returns the default storage volume name.
It matches the name used by the VictoriaMetrics operator when legacy naming is disabled.
*/ -}}
{{- define "vmselect.volume.name" -}}
  {{- ternary "vmselect-cachedir" "cache-volume" (eq (include "vm.useLegacyNaming" .) "false") -}}
{{- end -}}
