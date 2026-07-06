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
  {{- toYaml $rwcm -}}
{{- end -}}

{{- define "vmagent.scrape.config.name" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $fullname := include "vm.plain.fullname" . -}}
  {{- $Values.configMap | default (printf "%s-config" $fullname) -}}
{{- end -}}

{{- define "vmagent.cr.spec" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $spec := include "vm.cr.component.spec" (dict "comp" $Values) | fromYaml -}}
  {{- if eq $Values.mode "statefulSet" }}
    {{- $_ := set $spec "statefulMode" true -}}
    {{- if ($Values.persistentVolume).enabled }}
      {{- $pvc := $Values.persistentVolume -}}
      {{- $pvcSpec := dict "resources" (dict "requests" (dict "storage" $pvc.size)) -}}
      {{- with $pvc.accessModes }}{{- $_ := set $pvcSpec "accessModes" . }}{{- end -}}
      {{- with $pvc.storageClassName }}{{- $_ := set $pvcSpec "storageClassName" . }}{{- end -}}
      {{- $_ := set $spec "statefulStorage" (dict "volumeClaimTemplate" (dict "spec" $pvcSpec)) -}}
    {{- end -}}
  {{- else if eq $Values.mode "daemonSet" }}
    {{- $_ := set $spec "daemonSetMode" true -}}
  {{- end -}}
  {{- with $Values.remoteWrite }}{{- $_ := set $spec "remoteWrite" . }}{{- end -}}
  {{- if $Values.useLegacyNaming }}{{- $_ := set $spec "useLegacyNaming" true }}{{- end -}}
  {{- toYaml (mergeOverwrite $spec ($Values.spec | default dict)) -}}
{{- end -}}
