{{/*
Common labels
*/}}
{{- define "victoria-metrics-distributed.labels" -}}
{{- $Chart := (.helm).Chart | default .Chart -}}
{{- $Release := (.helm).Release | default .Release -}}
helm.sh/chart: {{ include "vm.chart" . }}
{{ include "victoria-metrics-distributed.selectorLabels" . }}
{{- if $Chart.AppVersion }}
app.kubernetes.io/version: {{ $Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "victoria-metrics-distributed.selectorLabels" -}}
{{- $Release := (.helm).Release | default .Release -}}
app.kubernetes.io/name: {{ include "vm.name" . }}
app.kubernetes.io/instance: {{ $Release.Name }}
{{- end }}

{{/*
Creates vmclusterSpec map, insert zone's nodeselector and topologySpreadConstraints to all the componets
*/}}
{{- define "per-zone-vmcluster.vmclusterSpec" -}}
  {{- $ctx := (.helm) | default . }}
  {{- $Values := $ctx.Values }}
  {{- $zones := (dict) -}}
  {{- $commonClusterSpec := ((($Values.common).vmcluster).spec) | default dict -}}
  {{- range $idx, $rolloutZone := $Values.availabilityZones -}}
    {{- $commonSpec := $rolloutZone.spec | default dict -}}
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
