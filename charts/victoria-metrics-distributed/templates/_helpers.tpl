{{/*
Creates vmclusterSpec map, insert zone's nodeselector and topologySpreadConstraints to all the componets
*/}}
{{- define "per-zone-vmcluster.vmclusterSpec" -}}
  {{- $ctx := (.helm) | default . }}
  {{- $Values := $ctx.Values }}
  {{- $zones := (dict) -}}
  {{- $commonClusterSpec := ((($Values.common).vmcluster).spec) | default dict -}}
  {{- range $idx, $rolloutZone := $Values.availabilityZones -}}
    {{- $commonSpec := $rolloutZone.common.spec | default dict -}}
    {{- $clusterSpec := mergeOverwrite (deepCopy $commonClusterSpec) (deepCopy $rolloutZone.vmcluster.spec) -}}
    {{- range $name, $config := $clusterSpec -}}
      {{- if and (hasPrefix "vm" $name) (kindIs "map" $config) -}}
        {{ $config = mergeOverwrite (deepCopy $commonSpec) (deepCopy $config) }}
        {{- $_ := set $clusterSpec $name $config -}}
      {{- end -}}
    {{- end -}}
    {{- $_ := set $zones $rolloutZone.name $clusterSpec -}}
  {{- end -}}
  {{- tpl (toYaml $zones) $ctx -}}
{{- end -}}
