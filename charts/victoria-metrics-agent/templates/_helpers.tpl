{{- define "vmagent.gomemlimit" -}}
  {{- $quantity := toString . -}}
  {{- $quantityPattern := "^[+]?([0-9]+([.][0-9]*)?|[.][0-9]+)([eE][+-]?[0-9]+|(Ki|Mi|Gi|Ti|Pi|Ei|n|u|m|k|M|G|T|P|E))?$" -}}
  {{- if not (regexMatch $quantityPattern $quantity) -}}
    {{- fail (printf "invalid memory quantity %q for automatic GOMEMLIMIT" $quantity) -}}
  {{- end -}}
  {{- $suffix := regexFind "(Ki|Mi|Gi|Ti|Pi|Ei|n|u|m|k|M|G|T|P|E)$" $quantity -}}
  {{- $numberText := trimSuffix $suffix $quantity -}}
  {{- $number := float64 $numberText -}}
  {{- $multipliers := dict "n" 0.000000001 "u" 0.000001 "m" 0.001 "k" 1000.0 "M" 1000000.0 "G" 1000000000.0 "T" 1000000000000.0 "P" 1000000000000000.0 "E" 1000000000000000000.0 "Ki" 1024.0 "Mi" 1048576.0 "Gi" 1073741824.0 "Ti" 1099511627776.0 "Pi" 1125899906842624.0 "Ei" 1152921504606846976.0 -}}
  {{- $multiplier := 1.0 -}}
  {{- if hasKey $multipliers $suffix -}}
    {{- $multiplier = index $multipliers $suffix -}}
  {{- end -}}
  {{- $memoryMiB := mulf (divf (mulf $number $multiplier) 1048576.0) 0.85 | floor -}}
  {{- if lt $memoryMiB 1.0 -}}
    {{- fail (printf "85%% of memory quantity %q is less than 1MiB; automatic GOMEMLIMIT must be at least 1MiB" $quantity) -}}
  {{- end -}}
  {{- printf "%.0fMiB" $memoryMiB -}}
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
