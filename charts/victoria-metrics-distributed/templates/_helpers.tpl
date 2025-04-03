{{/*
Creates vmcluster spec map, insert zone's nodeselector and topologySpreadConstraints to all the components
*/}}
{{- define "vm.per-zone.cluster.spec" -}}
  {{- $ctx := (.helm) | default . }}
  {{- $Values := $ctx.Values }}
  {{- $zones := (dict) -}}
  {{- $commonClusterSpec := ((($Values.common).vmcluster).spec) | default dict -}}
  {{- range $idx, $z := $Values.availabilityZones -}}
    {{- $rolloutZone := mergeOverwrite (deepCopy $.Values.zoneTpl) $z }}
    {{- $fullname := $rolloutZone.name }}
    {{- if $rolloutZone.vmcluster.name -}}
      {{- $fullname = $rolloutZone.vmcluster.name -}}
    {{- end -}}
    {{- $fullname = tpl $fullname (dict "zone" $rolloutZone) -}}
    {{- $commonSpec := $rolloutZone.common.spec | default dict -}}
    {{- $clusterSpec := mergeOverwrite (deepCopy $commonClusterSpec) (deepCopy $rolloutZone.vmcluster.spec) -}}
    {{- range $name, $config := $clusterSpec -}}
      {{- if and (hasPrefix "vm" $name) (kindIs "map" $config) -}}
        {{ $config = mergeOverwrite (deepCopy $commonSpec) (deepCopy $config) }}
        {{- $_ := set $clusterSpec $name $config -}}
      {{- end -}}
    {{- end -}}
    {{- $clusterSpec = fromYaml (tpl (toYaml $clusterSpec) (dict "zone" $rolloutZone)) -}}
    {{- if $rolloutZone.vmcluster.enabled -}}
      {{- $_ := set $zones $fullname $clusterSpec -}}
    {{- end -}}
  {{- end -}}
  {{- tpl (toYaml $zones) $ctx -}}
{{- end -}}

{{/*
Creates vmsingle spec map, insert zone's nodeselector and topologySpreadConstraints to all the components
*/}}
{{- define "vm.per-zone.single.spec" -}}
  {{- $ctx := (.helm) | default . }}
  {{- $Values := $ctx.Values }}
  {{- $zones := (dict) -}}
  {{- $commonSingleSpec := ((($Values.common).vmsingle).spec) | default dict -}}
  {{- range $idx, $z := $Values.availabilityZones -}}
    {{- $rolloutZone := mergeOverwrite (deepCopy $.Values.zoneTpl) $z }}
    {{- $fullname := $rolloutZone.name }}
    {{- if $rolloutZone.vmsingle.name -}}
      {{- $fullname = $rolloutZone.vmsingle.name -}}
    {{- end -}}
    {{- $fullname = tpl $fullname (dict "zone" $rolloutZone) -}}
    {{- $commonSpec := $rolloutZone.common.spec | default dict -}}
    {{- $singleSpec := mergeOverwrite (deepCopy $commonSingleSpec) (deepCopy $rolloutZone.vmsingle.spec) -}}
    {{- $singleSpec := mergeOverwrite (deepCopy $commonSpec) (deepCopy $singleSpec) }}
    {{- $singleSpec = fromYaml (tpl (toYaml $singleSpec) (dict "zone" $rolloutZone)) -}}
    {{- if $rolloutZone.vmsingle.enabled -}}
      {{- $_ := set $zones $fullname $singleSpec -}}
    {{- end -}}
  {{- end -}}
  {{- tpl (toYaml $zones) $ctx -}}
{{- end -}}
