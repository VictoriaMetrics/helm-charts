{{/*
Expand the name of the chart.
*/}}
{{- define "victoria-metrics-distributed.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "victoria-metrics-distributed.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create the name for global ingest vmauth
*/}}
{{- define "victoria-metrics-distributed.vmauthIngestGlobalName" -}}
{{- .Values.vmauthIngestGlobal.name | default (printf "vmauth-global-write-%s" (include "victoria-metrics-distributed.fullname" .)) | trunc 63 }}
{{- end }}

{{/*
Create the name for global query vmauth
*/}}
{{- define "victoria-metrics-distributed.vmauthQueryGlobalName" -}}
{{- .Values.vmauthQueryGlobal.name | default (printf "vmauth-global-read-%s" (include "victoria-metrics-distributed.fullname" .)) | trunc 63 }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "victoria-metrics-distributed.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "victoria-metrics-distributed.labels" -}}
helm.sh/chart: {{ include "victoria-metrics-distributed.chart" . }}
{{ include "victoria-metrics-distributed.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "victoria-metrics-distributed.selectorLabels" -}}
app.kubernetes.io/name: {{ include "victoria-metrics-distributed.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "victoria-metrics-distributed.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "victoria-metrics-distributed.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Lists all the ingest vmauth addresss as remote write addresses for per zone vmagent
*/}}
{{- define "per-zone-vmagent.remoteWriteAddr" -}}
{{- $multitenacySuffix := "/insert/0/prometheus/api/v1/write" }}
{{- if .Values.enableMultitenancy }}
  {{- $multitenacySuffix = "/insert/multitenant/prometheus/api/v1/write" }}
{{- end }}
{{- range $zone := .Values.availabilityZones }}
{{- if $zone.allowIngest }}
{{ printf "- url: http://vmauth-%s:8427%s" ( $zone.vmauthIngest.name | default (printf "vmauth-write-balancer-%s" $zone.name ) ) $multitenacySuffix | indent 2 }}
{{- end }}
{{- end }}
{{- end }}


{{/*
Creates vmclusterSpec map, insert zone's nodeselector and topologySpreadConstraints to all the componets
*/}}
{{- define "per-zone-vmcluster.vmclusterSpec" -}}
{{- $zonesMap := (dict) -}}
{{- range $idx, $rolloutZone := .Values.availabilityZones -}}
{{- $vmclusterSpec := deepCopy $rolloutZone.vmcluster.spec }}

{{- $newNodeSelector := deepCopy $rolloutZone.nodeSelector }}
{{- if $rolloutZone.vmcluster.spec.vminsert.nodeSelector }}
{{- $newNodeSelector = mergeOverwrite (deepCopy $rolloutZone.nodeSelector) $rolloutZone.vmcluster.spec.vminsert.nodeSelector }}
{{- end -}}
{{- $newTopologySpreadConstraints := deepCopy $rolloutZone.topologySpreadConstraints }}
{{- if $rolloutZone.vmcluster.spec.vminsert.topologySpreadConstraints }}
{{- $newTopologySpreadConstraints = mergeOverwrite (deepCopy $rolloutZone.topologySpreadConstraints) $rolloutZone.vmcluster.spec.vminsert.topologySpreadConstraints }}
{{- end -}}
{{- $newvminsert := mergeOverwrite (dict "nodeSelector" $newNodeSelector) $vmclusterSpec.vminsert }}
{{- $newvminsert = mergeOverwrite (dict "topologySpreadConstraints" $newTopologySpreadConstraints) $newvminsert }}
{{- $newvminsert = mergeOverwrite (dict "serviceSpec" (dict "spec" (dict "clusterIP" "None" "type" "ClusterIP"))) $newvminsert }}
{{- if or $rolloutZone.extraAffinity ( and $rolloutZone.vmcluster.spec.vminsert $rolloutZone.vmcluster.spec.vminsert.affinity ) }}
{{- $newAffinity := mergeOverwrite (deepCopy $rolloutZone.extraAffinity) ($rolloutZone.vmcluster.spec.vminsert.affinity | default (dict)) }}
{{- $newvminsert = mergeOverwrite (dict "affinity" $newAffinity) $newvminsert }}
{{- end -}}

{{- $newNodeSelector := deepCopy $rolloutZone.nodeSelector }}
{{- if $rolloutZone.vmcluster.spec.vmstorage.nodeSelector }}
{{- $newNodeSelector = mergeOverwrite (deepCopy $rolloutZone.nodeSelector) $rolloutZone.vmcluster.spec.vmstorage.nodeSelector }}
{{- end -}}
{{- $newTopologySpreadConstraints := deepCopy $rolloutZone.topologySpreadConstraints }}
{{- if $rolloutZone.vmcluster.spec.vmstorage.topologySpreadConstraints }}
{{- $newTopologySpreadConstraints = mergeOverwrite (deepCopy $rolloutZone.topologySpreadConstraints) $rolloutZone.vmcluster.spec.vmstorage.topologySpreadConstraints }}
{{- end -}}
{{- $newvmstorage := mergeOverwrite (dict "nodeSelector" $newNodeSelector) $vmclusterSpec.vmstorage }}
{{- $newvmstorage = mergeOverwrite (dict "topologySpreadConstraints" $newTopologySpreadConstraints) $newvmstorage }}
{{- if or $rolloutZone.extraAffinity ( and $rolloutZone.vmcluster.spec.vmstorage $rolloutZone.vmcluster.spec.vmstorage.affinity ) }}
{{- $newAffinity := mergeOverwrite (deepCopy $rolloutZone.extraAffinity) ($rolloutZone.vmcluster.spec.vmstorage.affinity | default (dict)) }}
{{- $newvmstorage = mergeOverwrite (dict "affinity" $newAffinity) $newvmstorage }}
{{- end -}}

{{- $newNodeSelector := deepCopy $rolloutZone.nodeSelector }}
{{- if $rolloutZone.vmcluster.spec.vmselect.nodeSelector }}
{{- $newNodeSelector = mergeOverwrite (deepCopy $rolloutZone.nodeSelector) $rolloutZone.vmcluster.spec.vmselect.nodeSelector }}
{{- end -}}
{{- $newTopologySpreadConstraints := deepCopy $rolloutZone.topologySpreadConstraints }}
{{- if $rolloutZone.vmcluster.spec.vmselect.topologySpreadConstraints }}
{{- $newTopologySpreadConstraints = mergeOverwrite (deepCopy $rolloutZone.topologySpreadConstraints) $rolloutZone.vmcluster.spec.vmselect.topologySpreadConstraints }}
{{- end -}}
{{- $newvmselect := mergeOverwrite (dict "nodeSelector" $newNodeSelector) $vmclusterSpec.vmselect }}
{{- $newvmselect = mergeOverwrite (dict "topologySpreadConstraints" $newTopologySpreadConstraints) $newvmselect }}
{{- if or $rolloutZone.extraAffinity ( and $rolloutZone.vmcluster.spec.vmselect $rolloutZone.vmcluster.spec.vmselect.affinity ) }}
{{- $newAffinity := mergeOverwrite (deepCopy $rolloutZone.extraAffinity) ($rolloutZone.vmcluster.spec.vmselect.affinity | default (dict)) }}
{{- $newvmselect = mergeOverwrite (dict "affinity" $newAffinity) $newvmselect }}
{{- end -}}

{{- $newvmclusterSpec := dict "vminsert" $newvminsert "vmstorage" $newvmstorage "vmselect" $newvmselect }}
{{- $vmclusterSpec = mergeOverwrite (deepCopy $vmclusterSpec) $newvmclusterSpec }}

{{- $_ := set $zonesMap $rolloutZone.name $vmclusterSpec -}}
{{- end -}}
{{- $zonesMap | toYaml }}
{{- end }}


{{/*
Gets global query entrance as grafana default datasource
*/}}
{{- define "victoria-metrics-distributed.globalQueryAddr" -}}
url: {{ printf "http://vmauth-%s.%s.svc:%s/select/0/prometheus/" (include "victoria-metrics-distributed.vmauthQueryGlobalName" .) (include "vm.namespace" .) (.Values.vmauthQueryGlobal.spec.port | default "8427") }}
{{- end }}


{{/*
Remote write spec for test-vmagent
*/}}
{{- define "victoria-metrics-distributed.extravmagentSpec" -}}
{{- $remoteWriteSpec := dict "remoteWrite" (list ( dict "url" (printf "http://vmauth-%s.%s.svc:%s/prometheus/api/v1/write" (include "victoria-metrics-distributed.vmauthIngestGlobalName" .) (include "vm.namespace" .) (.Values.vmauthIngestGlobal.spec.port | default "8427") ) )) }}
{{- tpl (deepCopy .Values.extraVMAgent.spec | mergeOverwrite $remoteWriteSpec | toYaml) . }}
{{- end }}
