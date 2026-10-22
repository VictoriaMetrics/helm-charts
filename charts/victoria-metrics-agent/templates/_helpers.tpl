{{- define "vmagent.mulDivFloor" -}}
  {{- $a := int64 .a -}}
  {{- $b := int64 .b -}}
  {{- $d := int64 .d -}}
  {{- $maxInt64 := int64 9223372036854775807 -}}
  {{- if or (lt $a 0) (lt $b 0) (le $d 0) -}}
    {{- fail "vmagent.mulDivFloor requires non-negative values and a positive divisor" -}}
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

{{- define "vmagent.memoryBytes" -}}
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
  {{- $digits := regexReplaceAll "^0+" (printf "%s%s" $whole $fractionDigits) "" -}}
  {{- if empty $digits -}}{{- $digits = "0" -}}{{- end -}}
  {{- if or (gt (len $digits) 19) (and (eq (len $digits) 19) (gt $digits "9223372036854775807")) -}}
    {{- fail (printf "memory quantity %q is outside the supported int64 range" $quantity) -}}
  {{- end -}}
  {{- $mantissa := int64 $digits -}}
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
  {{- if or (gt $scalePower 18) (lt $scalePower -18) -}}
    {{- fail (printf "memory quantity precision in %q is outside the supported range" $quantity) -}}
  {{- end -}}
  {{- $maxInt64 := int64 9223372036854775807 -}}
  {{- $scale := int64 1 -}}
  {{- if gt $scalePower 0 -}}
    {{- range until (int $scalePower) -}}
      {{- if gt $scale (div $maxInt64 10) -}}
        {{- fail (printf "memory quantity precision in %q is outside the supported range" $quantity) -}}
      {{- end -}}
      {{- $scale = mul $scale 10 -}}
    {{- end -}}
  {{- else if lt $scalePower 0 -}}
    {{- range until (int (sub 0 $scalePower)) -}}
      {{- if gt $mantissa (div $maxInt64 10) -}}
        {{- fail (printf "memory quantity %q is outside the supported int64 range" $quantity) -}}
      {{- end -}}
      {{- $mantissa = mul $mantissa 10 -}}
    {{- end -}}
  {{- end -}}
  {{- $unitNumerators := dict "k" 1000 "M" 1000000 "G" 1000000000 "T" 1000000000000 "P" 1000000000000000 "E" 1000000000000000000 "Ki" 1024 "Mi" 1048576 "Gi" 1073741824 "Ti" 1099511627776 "Pi" 1125899906842624 "Ei" 1152921504606846976 -}}
  {{- $unitNumerator := int64 1 -}}
  {{- $unitDenominator := int64 1 -}}
  {{- if hasKey $unitNumerators $suffix -}}
    {{- $unitNumerator = int64 (index $unitNumerators $suffix) -}}
  {{- else if eq $suffix "n" -}}
    {{- $unitDenominator = int64 1000000000 -}}
  {{- else if eq $suffix "u" -}}
    {{- $unitDenominator = int64 1000000 -}}
  {{- else if eq $suffix "m" -}}
    {{- $unitDenominator = int64 1000 -}}
  {{- end -}}
  {{- if gt $scale (div $maxInt64 $unitDenominator) -}}
    {{- fail (printf "85%% of memory quantity %q is less than 1MiB" $quantity) -}}
  {{- end -}}
  {{- $denominator := mul $scale $unitDenominator -}}
  {{- include "vmagent.mulDivFloor" (dict "a" $mantissa "b" $unitNumerator "d" $denominator) -}}
{{- end -}}

{{- define "vmagent.gomemlimit" -}}
  {{- $memoryBytes := include "vmagent.memoryBytes" . | int64 -}}
  {{- $memoryMiB := include "vmagent.mulDivFloor" (dict "a" $memoryBytes "b" 17 "d" 20971520) | int64 -}}
  {{- if lt $memoryMiB 1 -}}
    {{- fail (printf "85%% of memory quantity %q is less than 1MiB; automatic GOMEMLIMIT must be at least 1MiB" .) -}}
  {{- end -}}
  {{- printf "%dMiB" $memoryMiB -}}
{{- end -}}

{{- define "vmagent.args" -}}
  {{- $args := dict -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- if empty $Values.remoteWrite -}}
    {{- fail "Please define at least one remoteWrite" -}}
  {{- end -}}
  {{- $_ := set $args "promscrape.config" "/config/scrape/scrape.yml" -}}
  {{- $_ := set $args "remoteWrite.tmpDataPath" "/tmpData" -}}
  {{- $rwItems := list -}}
  {{- range $i, $rw := $Values.remoteWrite -}}
    {{- if not $rw.url -}}
      {{- fail (printf "`url` is not set for `remoteWrite` idx %d" $i) -}}
    {{- end -}}
    {{- $item := dict -}}
    {{- range $rwKey, $rwValue := $rw -}}
      {{- if or (kindIs "slice" $rwValue) (kindIs "map" $rwValue) -}}
        {{- $_ := set $item (printf "remoteWrite.%s" $rwKey) (printf "/config/rw/%d-%s.yaml" $i $rwKey) -}}
      {{- else -}}
        {{- $_ := set $item (printf "remoteWrite.%s" $rwKey) $rwValue -}}
      {{- end -}}
    {{- end -}}
    {{- $rwItems = append $rwItems $item -}}
  {{- end -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.args.positional" $rwItems)) -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $extraArgs := $Values.extraArgs | default dict }}
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $Values.http)) -}}
  {{- end -}}
  {{- if and (eq $Values.mode "statefulSet") $Values.statefulSet.clusterMode }}
    {{- $_ := set $args "promscrape.cluster.membersCount" $Values.replicaCount -}}
    {{- $_ := set $args "promscrape.cluster.replicationFactor" $Values.statefulSet.replicationFactor -}}
    {{- $_ := set $args "promscrape.cluster.memberNum" "$(POD_NAME)" -}}
  {{- end -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmagent.rw.config" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $rwcm := dict }}
  {{- range $i, $rw := $Values.remoteWrite }}
    {{- range $rwKey, $rwValue := $rw }}
      {{- if or (kindIs "slice" $rwValue) (kindIs "map" $rwValue) }}
        {{- $rwContent := toYaml $rwValue }}
        {{- if $Values.config.useTpl }}
          {{- $rwContent = tpl $rwContent $ | trim }}
        {{- end }}
        {{- $_ := set $rwcm (printf "%d-%s.yaml" $i $rwKey) $rwContent }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if $rwcm -}}
    {{- toYaml $rwcm -}}
  {{- end -}}
{{- end -}}

{{- define "vmagent.scrape.config.name" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $fullname := include "vm.plain.fullname" . -}}
  {{- $Values.configMap | default (printf "%s-config" $fullname) -}}
{{- end -}}

{{- /*
vmagent.volume.name returns the storage volume name.
It matches the name used by the VictoriaMetrics operator when legacy naming is disabled.
*/ -}}
{{- define "vmagent.volume.name" -}}
  {{- ternary "persistent-queue-data" "tmpdata" (eq (include "vm.useLegacyNaming" .) "false") -}}
{{- end -}}
