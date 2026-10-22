{{- define "vm.namespace" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $componentNs := "" -}}
  {{- $appKey := .appKey -}}
  {{- if $appKey -}}
    {{- $firstKey := $appKey -}}
    {{- if kindIs "slice" $appKey -}}
      {{- $firstKey = first $appKey -}}
    {{- end -}}
    {{- if kindIs "string" $firstKey -}}
      {{- $component := index $Values $firstKey -}}
      {{- if kindIs "map" $component -}}
        {{- $componentNs = $component.namespaceOverride | default "" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $componentNs | default $Values.namespaceOverride | default ($Values.global).namespaceOverride | default $Release.Namespace -}}
{{- end -}}

{{- define "vm.validate.args" -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $Capabilities := (.helm).Capabilities | default .Capabilities -}}
  {{- if semverCompare "<3.14.0" $Capabilities.HelmVersion.Version }}
    {{- fail "This chart requires helm version 3.14.0 or higher" }}
  {{- end }}
  {{- if empty $Chart -}}
    {{- fail "invalid template data" -}}
  {{- end -}}
{{- end -}}

{{- /* Expand the name of the chart. */ -}}
{{- define "vm.name" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $nameOverride := $Values.nameOverride | default ($Values.global).nameOverride | default $Chart.Name -}}
  {{- if or ($Values.global).disableNameTruncation $Values.disableNameTruncation -}}
    {{- $nameOverride -}}
  {{- else -}}
    {{- $nameOverride | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}

{{- /*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/ -}}
{{- define "vm.fullname" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $fullname := "" -}}
  {{- if $Values.fullnameOverride -}}
    {{- $fullname = $Values.fullnameOverride -}}
  {{- else if ($Values.global).fullnameOverride -}}
    {{- $fullname = $Values.global.fullnameOverride -}}
  {{- else -}}
    {{- $name := default $Chart.Name $Values.nameOverride -}}
    {{- if contains $name $Release.Name -}}
      {{- $fullname = $Release.Name -}}
    {{- else -}}
      {{- $fullname = (printf "%s-%s" $Release.Name $name) }}
    {{- end -}}
  {{- end -}}
  {{- $fullname = tpl $fullname . -}}
  {{- if or ($Values.global).disableNameTruncation $Values.disableNameTruncation -}}
    {{- $fullname -}}
  {{- else -}}
    {{- $fullname | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end }}

{{- define "vm.cr.fullname" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- if eq (include "vm.useLegacyNaming" .) "true" -}}
    {{- fail "useLegacyNaming: true is not supported by this chart; CR names must remain stable regardless of naming style" -}}
  {{- end -}}
  {{- $_ := set . "overrideKey" "name" -}}
  {{- $fullname := include "vm.internal.key" . -}}
  {{- $_ := unset . "overrideKey" -}}
  {{- if empty $fullname -}}
    {{- $fullname = include "vm.fullname" . -}}
  {{- end -}}
  {{- $fullname = tpl $fullname . -}}
  {{- if or ($Values.global).disableNameTruncation $Values.disableNameTruncation -}}
    {{- $fullname -}}
  {{- else -}}
    {{- $fullname | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}

{{- define "vm.managed.fullname" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $_ := set . "overrideKey" "name" -}}
  {{- $fullname := include "vm.internal.key" . -}}
  {{- $_ := unset . "overrideKey" -}}
  {{- if empty $fullname -}}
    {{- $fullname = include "vm.fullname" . -}}
  {{- end -}}
  {{- $isLegacy := eq (include "vm.useLegacyNaming" .) "true" -}}
  {{- if include "vm.internal.key.default" . -}}
    {{- $prefix := include "vm.operator.kind" . -}}
    {{- if $isLegacy -}}
      {{- $fullname = printf "%s-%s" $fullname $prefix -}}
    {{- else -}}
      {{- $fullname = printf "%s-%s" $prefix $fullname -}}
    {{- end -}}
  {{- end -}}
  {{- $fullname = tpl $fullname . -}}
  {{- if or ($Values.global).disableNameTruncation $Values.disableNameTruncation -}}
    {{- $fullname -}}
  {{- else -}}
    {{- $fullname | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}

{{- /*
vm.operator.kind returns the operator resource-name prefix (e.g. "vlsingle",
"vminsert", or an explicit .kindOverride for names that don't fit that pattern).
*/ -}}
{{- define "vm.operator.kind" -}}
  {{- $kind := include "vm.labels.kind" . -}}
  {{- if not $kind -}}
    {{- fail (printf "vm.operator.kind: appKey %q is not vm/vl/vt-prefixed; pass an explicit \"kindOverride\" for the desired resource name" (include "vm.internal.key.default" .)) -}}
  {{- end -}}
  {{- $kind -}}
{{- end -}}

{{- /*
vm.useLegacyNaming resolves the effective useLegacyNaming setting for the current context.
It traverses the appKey path in Values so that per-component settings (e.g.
.Values.vmsingle.spec.useLegacyNaming) take precedence over the chart-level
.Values.useLegacyNaming.
Returns "true", "false", or "" (not set at any level).
*/ -}}
{{- define "vm.useLegacyNaming" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $result := "" -}}
  {{- if hasKey $Values "useLegacyNaming" -}}
    {{- $result = ternary "true" "false" $Values.useLegacyNaming -}}
  {{- end -}}
  {{- $appKey := list -}}
  {{- if .appKey -}}
    {{- $appKey = ternary (list .appKey) .appKey (kindIs "string" .appKey) -}}
  {{- end -}}
  {{- $values := $Values -}}
  {{- range $ak := $appKey -}}
    {{- if kindIs "map" $values -}}
      {{- $values = index $values $ak | default dict -}}
      {{- if and (kindIs "map" $values) (hasKey $values "useLegacyNaming") -}}
        {{- $result = ternary "true" "false" (index $values "useLegacyNaming") -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $result -}}
{{- end -}}

{{- define "vm.plain.fullname" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $_ := set . "overrideKey" "fullnameOverride" -}}
  {{- $fullname := include "vm.internal.key" . -}}
  {{- $_ := unset . "overrideKey" -}}
  {{- if empty $fullname -}}
    {{- if eq (include "vm.useLegacyNaming" .) "false" -}}
      {{- $base := ((.helm).Release | default .Release).Name -}}
      {{- if .appKey -}}
        {{- $base = $Values.fullnameOverride | default ($Values.global).fullnameOverride | default $base -}}
      {{- end -}}
      {{- $fullname = printf "%s-%s" (include "vm.operator.kind" .) $base -}}
    {{- else -}}
      {{- $fullname = include "vm.fullname" . -}}
      {{- with include "vm.internal.key.default" . -}}
        {{- $fullname = printf "%s-%s" $fullname . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $fullname = tpl $fullname . -}}
  {{- if or ($Values.global).disableNameTruncation $Values.disableNameTruncation -}}
    {{- $fullname -}}
  {{- else -}}
    {{- $fullname | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}

{{- define "vm.internal.key" -}}
  {{- include "vm.validate.args" . -}}
  {{- $overrideKey := .overrideKey | default "fullnameOverride" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $key := "" -}}
  {{- if .appKey -}}
    {{- $appKey := ternary (list .appKey) .appKey (kindIs "string" .appKey) -}}
    {{- $ctx := . -}}
    {{- $values := $Values -}}
    {{- range $ak := $appKey }}
      {{- $values = ternary (dict) (index $values $ak | default dict) (empty $values) -}}
      {{- $ctx = ternary (dict) (index $ctx $ak | default dict) (empty $ctx) -}}
      {{- if and (empty $values) (empty $ctx) -}}
        {{- fail (printf "No data for appKey %s" (join "->" $appKey)) -}}
      {{- end -}}
      {{- if and (kindIs "map" $values) (index $values $overrideKey) -}}
        {{- $key = index $values $overrideKey -}}
      {{- else if and (kindIs "map" $ctx) (index $ctx $overrideKey) -}}
        {{- $key = index $ctx $overrideKey -}}
      {{- end -}}
    {{- end }}
    {{- if and (empty $key) .fallback -}}
      {{- $key = include "vm.internal.key.default" . -}}
    {{- end -}}
  {{- else if eq $overrideKey "fullnameOverride" -}}
    {{- if $Values.fullnameOverride -}}
      {{- $key = $Values.fullnameOverride -}}
    {{- else if ($Values.global).fullnameOverride -}}
      {{- $key = $Values.global.fullnameOverride -}}
    {{- end -}}
  {{- end -}}
  {{- $key -}}
{{- end -}}

{{- define "vm.internal.key.default" -}}
  {{- with .appKey -}}
  {{- $key := ternary (list .) . (kindIs "string" .) -}}
  {{- last (without $key "spec") -}}
  {{- end -}}
{{- end -}}

{{- /* Create chart name and version as used by the chart label. */ -}}
{{- define "vm.chart" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $Chart := (.helm).Chart | default .Chart -}}
  {{- $chart := printf "%s-%s" $Chart.Name $Chart.Version | replace "+" "_" -}}
  {{- if or ($Values.global).disableNameTruncation $Values.disableNameTruncation -}}
    {{- $chart -}}
  {{- else -}}
    {{- $chart | trunc 63 | trimSuffix "-" -}}
  {{- end }}
{{- end }}

{{- define "vm.metaLabels" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $labels := .extraLabels | default dict -}}
  {{- $_ := set $labels "helm.sh/chart" (include "vm.chart" .) -}}
  {{- $_ := set $labels "app.kubernetes.io/managed-by" $Release.Service -}}
  {{- toYaml $labels -}}
{{- end -}}

{{- define "vm.podLabels" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $globalLabels := deepCopy (($Values.global).extraLabels | default dict) -}}
  {{- $labels := fromYaml (include "vm.selectorLabels" .) -}}
  {{- if and $labels.app (ne (include "vm.labels.operator" .) "true") -}}
    {{- $_ := set $labels "app.kubernetes.io/component" $labels.app -}}
  {{- end -}}
  {{- $labels = mergeOverwrite $globalLabels $labels (.extraLabels | default dict) -}}
  {{- $_ := set $labels "app.kubernetes.io/managed-by" $Release.Service -}}
  {{- toYaml $labels -}}
{{- end -}}

{{- define "vm.annotations" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $globalAnnotations := deepCopy (($Values.global).extraAnnotations | default dict) -}}
  {{- $annotations := mergeOverwrite $globalAnnotations (.extraAnnotations | default dict) -}}
  {{- if $annotations -}}
    {{- toYaml $annotations -}}
  {{- end -}}
{{- end -}}

{{- define "vm.keyValue" -}}
  {{- $pairs := list -}}
  {{- range $k, $v := . -}}
    {{- $pairs = append $pairs (printf "%s=%s" $k $v) -}}
  {{- end -}}
  {{- join "," ($pairs | sortAlpha) -}}
{{- end -}}

{{- /* Common labels */ -}}
{{- define "vm.labels" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $globalLabels := deepCopy (($Values.global).extraLabels | default dict) -}}
  {{- $labels := fromYaml (include "vm.commonLabels" .) -}}
  {{- $labels = mergeOverwrite $globalLabels $labels (fromYaml (include "vm.metaLabels" .)) -}}
  {{- with (include "vm.image.tag" .) }}
    {{- $_ := set $labels "app.kubernetes.io/version" (regexReplaceAll "(.*)(@sha.*)" . "${1}") -}}
  {{- end -}}
  {{- toYaml $labels -}}
{{- end -}}

{{- define "vm.release" -}}
  {{- include "vm.validate.args" . -}}
  {{- $Release := (.helm).Release | default .Release -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $release := default $Release.Name $Values.argocdReleaseOverride -}}
  {{- if or ($Values.global).disableNameTruncation $Values.disableNameTruncation -}}
    {{- $release -}}
  {{- else -}}
    {{- $release | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}

{{- define "vm.app.name" -}}
  {{- $_ := set . "overrideKey" "name" -}}
  {{- $_ := set . "fallback" true -}}
  {{- tpl (include "vm.internal.key" .) . -}}
  {{- $_ := unset . "overrideKey" -}}
  {{- $_ := unset . "fallback" -}}
{{- end -}}

{{- /*
vm.labels.kind returns the operator kind used in labels (e.g. "vmagent", "vmselect"),
taken from .kindOverride or from a vm/vl/vt-prefixed appKey. Unlike vm.operator.kind
it returns an empty string instead of failing when the kind can't be determined.
*/ -}}
{{- define "vm.labels.kind" -}}
  {{- if .kindOverride -}}
    {{- .kindOverride -}}
  {{- else -}}
    {{- $appKey := include "vm.internal.key.default" . -}}
    {{- if or (hasPrefix "vm" $appKey) (hasPrefix "vl" $appKey) (hasPrefix "vt" $appKey) -}}
      {{- $appKey -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- /*
vm.labels.operator returns "true" when labels follow the VictoriaMetrics operator convention:
`useLegacyNaming: false` and a known kind.
*/ -}}
{{- define "vm.labels.operator" -}}
  {{- if and (eq (include "vm.useLegacyNaming" .) "false") (include "vm.labels.kind" .) -}}
    true
  {{- end -}}
{{- end -}}

{{- /*
Selector labels.
With `useLegacyNaming: false` and a known kind the name, instance and component labels match
the ones the VictoriaMetrics operator sets for the same component. Ownership labels
(`managed-by`) are intentionally left as is.
*/ -}}
{{- define "vm.selectorLabels" -}}
  {{- $labels := .extraLabels | default dict -}}
  {{- if eq (include "vm.labels.operator" .) "true" -}}
    {{- $_ := set $labels "app.kubernetes.io/name" (include "vm.labels.kind" .) -}}
    {{- $_ := set $labels "app.kubernetes.io/instance" (include "vm.release" .) -}}
    {{- if not (hasKey $labels "app.kubernetes.io/component") -}}
      {{- $_ := set $labels "app.kubernetes.io/component" "monitoring" -}}
    {{- end -}}
  {{- else -}}
    {{- $_ := set $labels "app.kubernetes.io/name" (include "vm.name" .) -}}
    {{- $_ := set $labels "app.kubernetes.io/instance" (include "vm.release" .) -}}
    {{- with (include "vm.app.name" .) -}}
      {{- $_ := set $labels "app" . -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml $labels -}}
{{- end }}

{{- define "vm.commonLabels" -}}
  {{- $labels := fromYaml (include "vm.selectorLabels" . ) -}}
  {{- if and $labels.app (ne (include "vm.labels.operator" .) "true") -}}
    {{- $_ := set $labels "app.kubernetes.io/component" $labels.app -}}
    {{- $_ := unset $labels "app" -}}
  {{- end -}}
  {{- toYaml $labels -}}
{{- end -}}

{{- define "vm.mulDivFloor" -}}
  {{- $a := int64 .a -}}
  {{- $b := int64 .b -}}
  {{- $d := int64 .d -}}
  {{- $maxInt64 := int64 9223372036854775807 -}}
  {{- if or (lt $a 0) (lt $b 0) (le $d 0) -}}
    {{- fail "vm.mulDivFloor requires non-negative values and a positive divisor" -}}
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

{{- define "vm.memoryBytes" -}}
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
  {{- $wholeBytes := include "vm.mulDivFloor" (dict "a" (int64 $wholeDigits) "b" $unitNumerator "d" 1) | int64 -}}
  {{- $fractionalBytes := include "vm.mulDivFloor" (dict "a" (int64 $remainderDigits) "b" $unitNumerator "d" $denominator) | int64 -}}
  {{- if gt $wholeBytes (sub $maxInt64 $fractionalBytes) -}}
    {{- fail (printf "memory quantity %q is outside the supported int64 range" $quantity) -}}
  {{- end -}}
  {{- add $wholeBytes $fractionalBytes -}}
{{- end -}}

{{- define "vm.gomemlimit" -}}
  {{- $memory := toString .memory -}}
  {{- $percentText := toString .percent -}}
  {{- if not (regexMatch "^[0-9]{1,3}$" $percentText) -}}
    {{- fail (printf "goMemLimitPercent must be an integer between 1 and 100, got %q" $percentText) -}}
  {{- end -}}
  {{- $percent := int64 $percentText -}}
  {{- if or (lt $percent 1) (gt $percent 100) -}}
    {{- fail (printf "goMemLimitPercent must be an integer between 1 and 100, got %q" $percentText) -}}
  {{- end -}}
  {{- $memoryBytes := include "vm.memoryBytes" $memory | int64 -}}
  {{- $memoryMiB := include "vm.mulDivFloor" (dict "a" $memoryBytes "b" $percent "d" 104857600) | int64 -}}
  {{- if lt $memoryMiB 1 -}}
    {{- fail (printf "%d%% of memory quantity %q is less than 1MiB; automatic GOMEMLIMIT must be at least 1MiB" $percent $memory) -}}
  {{- end -}}
  {{- printf "%dMiB" $memoryMiB -}}
{{- end -}}
