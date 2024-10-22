{{- define "vmagent.args" -}}
  {{- $args := default dict -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- if empty $Values.remoteWrite -}}
    {{- fail "Please define at least one remoteWrite" -}}
  {{- end -}}
  {{- $_ := set $args "promscrape.config" "/config/scrape/scrape.yml" -}}
  {{- $_ := set $args "remoteWrite.tmpDataPath" "/tmpData" -}}
  {{- range $i, $rw := $Values.remoteWrite -}}
    {{- if not $rw.url -}}
      {{- fail (printf "`url` is not set for `remoteWrite` idx %d" $i) -}}
    {{- end -}}
    {{- range $rwKey, $rwValue := $rw -}}
      {{- $key := printf "remoteWrite.%s" $rwKey -}}
      {{- $param := index $args $key | default list -}}
      {{- if or (kindIs "slice" $rwValue) (kindIs "map" $rwValue) -}}
        {{- $param = append $param (printf "/config/rw/%d-%s.yaml" $i $rwKey) -}}
      {{- else -}}
        {{- $param = append $param $rwValue -}}
      {{- end -}}
      {{- $_ := set $args $key $param -}}
    {{- end -}}
  {{- end -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $args = mergeOverwrite $args $Values.extraArgs -}}
  {{- if and $Values.statefulset.enabled $Values.statefulset.clusterMode }}
    {{- $_ := set $args "promscrape.cluster.membersCount" $Values.replicaCount -}}
    {{- $_ := set $args "promscrape.cluster.replicationFactor" $Values.statefulset.replicationFactor -}}
    {{- $_ := set $args "promscrape.cluster.memberNum" "$(POD_NAME)" -}}
  {{- end -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end -}}

{{- define "vmagent.rw.config" -}}
  {{- $rwcm := default dict }}
  {{- range $i, $rw := .Values.remoteWrite }}
    {{- range $rwKey, $rwValue := $rw }}
      {{- if or (kindIs "slice" $rwValue) (kindIs "map" $rwValue) }}
        {{- $_ := set $rwcm (printf "%d-%s.yaml" $i $rwKey) (toYaml $rwValue) }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml $rwcm -}}
{{- end -}}
