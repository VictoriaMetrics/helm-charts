{{/*
Creates vmcluster spec map, insert zone's nodeselector and topologySpreadConstraints to all the components
*/}}
{{- define "vm.per-zone.cluster.spec" -}}
  {{- $ctx := (.helm) | default . }}
  {{- $Values := $ctx.Values }}
  {{- $zones := (dict) -}}
  {{- $components := default dict }}
  {{- $_ := set $components "vmstorage" (default list) }}
  {{- $_ := set $components "vmselect" (default list) }}
  {{- $_ := set $components "vminsert" (default list) }}
  {{- $_ := set $components "requestsLoadBalancer" (list "spec") }}
  {{- $commonClusterSpec := ((($Values.common).vmcluster).spec) | default dict -}}
  {{- range $idx, $z := $Values.availabilityZones -}}
    {{- $rolloutZone := mergeOverwrite (deepCopy $.Values.zoneTpl) $z }}
    {{- $fullname := $rolloutZone.name }}
    {{- if $rolloutZone.vmcluster.name -}}
      {{- $fullname = $rolloutZone.vmcluster.name -}}
    {{- end -}}
    {{- $fullname = tpl $fullname (dict "zone" $rolloutZone) -}}
    {{- $commonSpec := deepCopy ($rolloutZone.common.spec | default dict) -}}
    {{- if not $commonSpec.nodeSelector }}
      {{- $_ := set $commonSpec "nodeSelector" (dict "topology.kubernetes.io/zone" "{{ (.zone).name }}") }}
    {{- end }}
    {{- $clusterSpec := mergeOverwrite (deepCopy $commonClusterSpec) (deepCopy $rolloutZone.vmcluster.spec) -}}
    {{- range $name, $config := $clusterSpec -}}
      {{- if and (hasKey $components $name) (kindIs "map" $config) -}}
        {{- $mergeSpec := (deepCopy $commonSpec) }}
        {{- range (reverse (get $components $name)) }}
          {{- $mergeSpec = (dict . $mergeSpec) }}
        {{- end }}
        {{- $config = mergeOverwrite (deepCopy $mergeSpec) (deepCopy $config) }}
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
    {{- if not $singleSpec.nodeSelector }}
      {{- $_ := set $singleSpec "nodeSelector" (dict "topology.kubernetes.io/zone" "{{ (.zone).name }}") }}
    {{- end }}
    {{- $singleSpec = fromYaml (tpl (toYaml $singleSpec) (dict "zone" $rolloutZone)) -}}
    {{- if $rolloutZone.vmsingle.enabled -}}
      {{- $_ := set $zones $fullname $singleSpec -}}
    {{- end -}}
  {{- end -}}
  {{- tpl (toYaml $zones) $ctx -}}
{{- end -}}
