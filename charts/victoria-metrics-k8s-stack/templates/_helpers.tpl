{{- define "vm.read.endpoint" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $endpoint := dict -}}
  {{- $_ := set . "style" "managed" -}}
  {{- if $Values.vmsingle.enabled -}}
    {{- $_ := set . "appKey" (list "vmsingle" "spec") -}}
    {{- $_ := set $endpoint "url" (include "vm.url" .) -}}
  {{- else if and $Values.vmcluster.enabled $Values.vmcluster.spec.vmselect.enabled -}}
    {{- $_ := set . "appKey" (list "vmcluster" "spec" "vmselect") -}}
    {{- $_ := set $endpoint "url" (include "vm.url" .) -}}
  {{- else if $Values.vmdistributed.enabled -}}
    {{- $_ := set . "appKey" (list "vmdistributed" "spec" "vmauth" "spec") -}}
    {{- $_ := set $endpoint "url" (include "vm.url" .) -}}
  {{- else if $Values.external.vm.read.url -}}
    {{- $endpoint = $Values.external.vm.read -}}
  {{- end -}}
  {{- with $endpoint -}}
    {{- toYaml . -}}
  {{- end -}}
{{- end }}

{{- define "vm.write.endpoint" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $endpoint := dict -}}
  {{- $_ := set . "style" "managed" -}}
  {{- if $Values.vmsingle.enabled -}}
    {{- $_ := set . "appKey" (list "vmsingle" "spec") -}}
    {{- $_ := set $endpoint "url" (include "vm.url" .) -}}
  {{- else if and $Values.vmcluster.enabled $Values.vmcluster.spec.vminsert.enabled -}}
    {{- $_ := set . "appKey" (list "vmcluster" "spec" "vminsert") -}}
    {{- $_ := set $endpoint "url" (include "vm.url" .) -}}
  {{- else if $Values.vmdistributed.enabled -}}
    {{- $_ := set . "appKey" (list "vmdistributed" "spec" "vmauth" "spec") -}}
    {{- $_ := set $endpoint "url" (include "vm.url" .) -}}
  {{- else if $Values.external.vm.write.url -}}
    {{- $endpoint = $Values.external.vm.write -}}
  {{- end -}}
  {{- with $endpoint -}}
    {{- toYaml . -}}
  {{- end -}}
{{- end -}}

{{- /* vm.prometheus.read appends /select/<tenant>/prometheus to vm.read.endpoint for cluster/distributed deployments */ -}}
{{- define "vm.prometheus.read" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $endpoint := fromYaml (include "vm.read.endpoint" .) -}}
  {{- if $endpoint.url -}}
    {{- if or (and $Values.vmcluster.enabled $Values.vmcluster.spec.vmselect.enabled) $Values.vmdistributed.enabled -}}
      {{- $tenant := $Values.tenant | default 0 -}}
      {{- $_ := set $endpoint "url" (printf "%s/select/%d/prometheus" $endpoint.url (int $tenant)) -}}
    {{- end -}}
    {{- toYaml $endpoint -}}
  {{- end -}}
{{- end }}

{{- /* vm.prometheus.write appends the prometheus remote-write path to vm.write.endpoint */ -}}
{{- define "vm.prometheus.write" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $endpoint := fromYaml (include "vm.write.endpoint" .) -}}
  {{- if $endpoint.url -}}
    {{- if $Values.vmsingle.enabled -}}
      {{- $_ := set $endpoint "url" (printf "%s/api/v1/write" $endpoint.url) -}}
    {{- else if or (and $Values.vmcluster.enabled $Values.vmcluster.spec.vminsert.enabled) $Values.vmdistributed.enabled -}}
      {{- $tenant := $Values.tenant | default 0 -}}
      {{- $_ := set $endpoint "url" (printf "%s/insert/%d/prometheus/api/v1/write" $endpoint.url (int $tenant)) -}}
    {{- end -}}
    {{- toYaml $endpoint -}}
  {{- end -}}
{{- end -}}

{{- /* VMAlert remotes */ -}}
{{- define "vm.alert.remotes" -}}
  {{- $ctx := . -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $remotes := dict -}}
  {{- $fullname := include "vm.managed.fullname" . -}}
  {{- $_ := set $ctx "style" "managed" -}}
  {{- $vmRemoteWrite := include "vm.prometheus.write" $ctx | fromYaml -}}
  {{- if and $Values.vmalert.remoteWriteVMAgent $Values.vmagent.enabled -}}
    {{- $_ := set $ctx "appKey" (list "vmagent" "spec") -}}
    {{- $vmRemoteWrite = dict "url" (printf "%s/api/v1/write" (include "vm.url" $ctx)) -}}
    {{- $_ := unset $ctx "appKey" -}}
  {{- end -}}
  {{- with $vmRemoteWrite -}}
    {{- $_ := set $remotes "remoteWrite" . -}}
  {{- end -}}
  {{- $vmReadEndpoint := fromYaml (include "vm.prometheus.read" $ctx) -}}
  {{- $vlReadEndpoint := fromYaml (include "vl.read.endpoint" $ctx) -}}
  {{- with $vmReadEndpoint -}}
    {{- $_ := set $remotes "remoteRead" . -}}
  {{- end -}}
  {{- if and $vmReadEndpoint.url $vlReadEndpoint.url -}}
    {{- $_ := set $ctx "appKey" (list "internal" "vmauth" "spec") -}}
    {{- $_ := set $ctx "fullname" (include "vm.fullname" $ctx) -}}
    {{- $_ := set $remotes "datasource" (dict "url" (include "vm.url" $ctx)) -}}
    {{- $_ := unset $ctx "appKey" -}}
    {{- $_ := unset $ctx "fullname" -}}
  {{- else if $vmReadEndpoint.url -}}
    {{- $_ := set $remotes "datasource" $vmReadEndpoint -}}
  {{- else if $vlReadEndpoint.url -}}
    {{- $_ := set $remotes "datasource" $vlReadEndpoint -}}
  {{- end -}}
  {{- if not (($remotes.datasource).url) -}}
    {{- if or (not $Values.vmalert.spec.datasource) (not $Values.vmalert.spec.remoteRead) -}}
      {{- fail "datasource required for vmalert! Either set `vmalert.enabled: false` or provide a VM/VL read endpoint or `vmalert.spec.datasource.url` and `vmalert.spec.remoteRead.url`" -}}
    {{- end -}}
  {{- end -}}
  {{- if $Values.vmalert.additionalNotifierConfigs }}
    {{- $configName := printf "%s-additional-notifier" $fullname -}}
    {{- $notifierConfigRef := dict "name" $configName "key" "notifier-configs.yaml" -}}
    {{- $_ := set $remotes "notifierConfigRef" $notifierConfigRef -}}
  {{- else if $Values.alertmanager.enabled -}}
    {{- $notifiers := list -}}
    {{- $appSecure := not (empty ((($Values.alertmanager).spec).webConfig).tls_server_config) -}}
    {{- $_ := set $ctx "appKey" (list "alertmanager" "spec") -}}
    {{- $_ := set $ctx "appSecure" $appSecure -}}
    {{- $_ := set $ctx "appRoute" (($Values.alertmanager).spec).routePrefix -}}
    {{- $alertManagerReplicas := $Values.alertmanager.spec.replicaCount | default 1 | int -}}
    {{- range until $alertManagerReplicas -}}
      {{- $_ := set $ctx "appIdx" . -}}
      {{- $notifiers = append $notifiers (dict "url" (include "vm.url" $ctx)) -}}
      {{- $_ := unset $ctx "appIdx" }}
    {{- end }}
    {{- $_ := set $remotes "notifiers" $notifiers -}}
  {{- end -}}
  {{- toYaml $remotes -}}
{{- end -}}

{{- /* VMAlert templates */ -}}
{{- define "vm.alert.templates" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $cms :=  ($Values.vmalert.spec.configMaps | default list) -}}
  {{- if $Values.vmalert.templateFiles -}}
    {{- $fullname := include "vm.managed.fullname" . -}}
    {{- $cms = append $cms (printf "%s-extra-tpl" $fullname) -}}
  {{- end -}}
  {{- $output := dict "configMaps" (compact $cms) -}}
  {{- toYaml $output -}}
{{- end -}}

{{- define "vm.license.global" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $license := (deepCopy ($Values.global).license) | default dict -}}
  {{- if $license.key -}}
    {{- if hasKey $license "keyRef" -}}
      {{- $_ := unset $license "keyRef" -}}
    {{- end -}}
  {{- else if $license.keyRef.name -}}
    {{- if hasKey $license "key" -}}
      {{- $_ := unset $license "key" -}}
    {{- end -}}
  {{- else -}}
    {{- $license = dict -}}
  {{- end -}}
  {{- with $license -}}
    {{- toYaml . -}}
  {{- end -}}
{{- end -}}

{{- /* VMAlert spec */ -}}
{{- define "vm.alert.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $Chart := (.helm).Chart | default .Chart }}
  {{- $image := dict "tag" (include "vm.image.tag" .) }}
  {{- $extraArgs := dict "remoteWrite.disablePathAppend" "true" -}}
  {{- $fullname := include "vm.managed.fullname" . }}
  {{- if $Values.vmalert.templateFiles -}}
    {{- $ruleTmpl := printf "/etc/vm/configs/%s-extra-tpl/*.tmpl" $fullname -}}
    {{- $_ := set $extraArgs "rule.templates" $ruleTmpl -}}
  {{- end -}}
  {{- $vmAlertTemplates := include "vm.alert.templates" . | fromYaml -}}
  {{- $vmAlertRemotes := include "vm.alert.remotes" . | fromYaml -}}
  {{- $spec := dict "extraArgs" $extraArgs "image" $image -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- with concat ($vmAlertRemotes.notifiers | default list) ($Values.vmalert.spec.notifiers | default list) }}
    {{- $_ := set $vmAlertRemotes "notifiers" . }}
  {{- end }}
  {{- $spec := deepCopy (omit $Values.vmalert.spec "notifiers") | mergeOverwrite $vmAlertRemotes | mergeOverwrite $vmAlertTemplates | mergeOverwrite $spec }}
  {{- if not (or (hasKey $spec "notifier") (hasKey $spec "notifiers") (hasKey $spec "notifierConfigRef") (hasKey $spec.extraArgs "notifier.blackhole")) }}
    {{- fail "Neither `notifier`, `notifiers` nor `notifierConfigRef` is set for vmalert. If it's intentionally please consider setting `.vmalert.spec.extraArgs.['notifier.blackhole']` to `'true'`"}}
  {{- end }}
  {{- $output := deepCopy (omit $Values.vmalert.spec "notifiers") | mergeOverwrite $vmAlertRemotes | mergeOverwrite $vmAlertTemplates | mergeOverwrite $spec -}}
  {{- if or $Values.grafana.enabled $Values.external.grafana.host }}
    {{- if not (index $output.extraArgs "external.alert.source") -}}
      {{- $alertSourceTpl := `{"datasource":%q,"queries":[{"expr":{{"{{"}} .Expr|jsonEscape|queryEscape {{"}}"}},"refId":"A"}],"range":{"from":"{{"{{"}} .ActiveAt.UnixMilli {{"}}"}}","to":"now"}}` -}}
      {{- $alertSource := "" -}}
      {{- if $Values.external.grafana.host -}}
        {{- $alertSource = printf $alertSourceTpl $Values.external.grafana.datasource -}}
      {{- else -}}
        {{- $alertSource = printf $alertSourceTpl (index $Values.defaultDatasources.victoriametrics.datasources 0 "name") -}}
      {{- end -}}
      {{- $_ := set $output.extraArgs "external.alert.source" (printf "explore?left=%s" $alertSource) -}}
    {{- end -}}
    {{- if not (index $output.extraArgs "external.url") -}}
      {{- $_ := set $output.extraArgs "external.url" (include "vm-k8s-stack.grafana.addr" .) -}}
    {{- end -}}
  {{- end -}}
  {{- tpl ($output | toYaml) . -}}
{{- end -}}

{{- /* VM Agent remoteWrites */ -}}
{{- /* VMAgent/VLAgent spec. Accepts optional .agentKey and .writeEndpoint on context;
     defaults to vmagent with vm.prometheus.write when unset. */ -}}
{{- define "vm.agent.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $agentKey := .agentKey | default "vmagent" -}}
  {{- $agentValues := index $Values $agentKey -}}
  {{- $image := dict "tag" (include "vm.image.tag" .) }}
  {{- $remoteWrites := $agentValues.additionalRemoteWrites | default list }}
  {{- $rws := $agentValues.spec.remoteWrite | default list }}
  {{- $writeEndpoint := .writeEndpoint | default (include "vm.prometheus.write" .) -}}
  {{- with $writeEndpoint -}}
    {{- if $rws -}}
      {{- $rws = prepend (slice $rws 1) (mergeOverwrite (fromYaml .) (deepCopy (first $rws))) -}}
    {{- else -}}
      {{- $rws = append $rws (fromYaml .) -}}
    {{- end -}}
  {{- end -}}
  {{- $remoteWrites = concat $remoteWrites $rws }}
  {{- $spec := dict "remoteWrite" $remoteWrites -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- $_ := set $spec "image" $image -}}
  {{- tpl (mergeOverwrite (deepCopy $agentValues.spec) (deepCopy $spec) | toYaml) . -}}
{{- end }}

{{- /* Populates .vm, .vl and .vt on the context with read/write URL components */ -}}
{{- define "vm.auth.context" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $_ := set . "style" "managed" -}}
  {{- $vm := dict -}}
  {{- $vmRead := fromYaml (include "vm.read.endpoint" .) -}}
  {{- if $vmRead.url -}}
    {{- $url := urlParse $vmRead.url -}}
    {{- if and $Values.vmcluster.enabled $Values.vmcluster.spec.vmselect.enabled -}}
      {{- $_ := set $url "path" (printf "%s/select" $url.path) -}}
    {{- end -}}
    {{- $_ := set $vm "read" $url -}}
  {{- end -}}
  {{- $vmWrite := fromYaml (include "vm.write.endpoint" .) -}}
  {{- if $vmWrite.url -}}
    {{- $url := urlParse $vmWrite.url -}}
    {{- if and $Values.vmcluster.enabled $Values.vmcluster.spec.vminsert.enabled -}}
      {{- $_ := set $url "path" (printf "%s/insert" $url.path) -}}
    {{- end -}}
    {{- $_ := set $vm "write" $url -}}
  {{- end -}}
  {{- $_ := set . "vm" $vm -}}
  {{- $vl := dict -}}
  {{- $vlRead := fromYaml (include "vl.read.endpoint" .) -}}
  {{- if $vlRead.url -}}
    {{- $_ := set $vl "read" (urlParse $vlRead.url) -}}
  {{- end -}}
  {{- $vlWrite := fromYaml (include "vl.write.endpoint" .) -}}
  {{- if $vlWrite.url -}}
    {{- $_ := set $vl "write" (urlParse $vlWrite.url) -}}
  {{- end -}}
  {{- $_ := set . "vl" $vl -}}
  {{- $vt := dict -}}
  {{- $vtRead := fromYaml (include "vt.read.endpoint" .) -}}
  {{- if $vtRead.url -}}
    {{- $_ := set $vt "read" (urlParse $vtRead.url) -}}
  {{- end -}}
  {{- $vtWrite := fromYaml (include "vt.write.endpoint" .) -}}
  {{- if $vtWrite.url -}}
    {{- $_ := set $vt "write" (urlParse $vtWrite.url) -}}
  {{- end -}}
  {{- $_ := set . "vt" $vt -}}
{{- end -}}

{{- /* VMAuth spec */ -}}
{{- define "vm.auth.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $image := dict "tag" (include "vm.image.tag" .) }}
  {{- include "vm.auth.context" . -}}
  {{- $spec := deepCopy $Values.vmauth.spec }}
  {{- if $spec.unauthorizedUserAccessSpec }}
    {{- if $spec.unauthorizedUserAccessSpec.disabled }}
      {{- $_ := unset $spec "unauthorizedUserAccessSpec" }}
    {{- else -}}
      {{- $_ := unset $spec.unauthorizedUserAccessSpec "disabled" }}
    {{- end -}}
  {{- end -}}
  {{- $_ := set $spec "image" (mergeOverwrite (deepCopy $image) (deepCopy ($spec.image | default dict))) -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl (toYaml $spec) . -}}
{{- end -}}

{{- /* Alermanager spec */ -}}
{{- define "vm.alertmanager.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $fullname := include "vm.managed.fullname" . -}}
  {{- $app := $Values.alertmanager }}
  {{- $spec := $app.spec -}}
  {{- if and (not $spec.configRawYaml) (not $spec.configSecret) (not $Values.alertmanager.useManagedConfig) -}}
    {{- $_ := set $spec "configSecret" $fullname -}}
  {{- end -}}
  {{- $templates := $spec.templates | default list -}}
  {{- if $Values.alertmanager.monzoTemplate.enabled -}}
    {{- $configMap := printf "%s-monzo-tpl" $fullname -}}
    {{- $templates = append $templates (dict "name" $configMap "key" "monzo.tmpl") -}}
  {{- end -}}
  {{- $configMap := printf "%s-extra-tpl" $fullname -}}
  {{- range $key, $value := $Values.alertmanager.templateFiles | default dict -}}
    {{- $templates = append $templates (dict "name" $configMap "key" $key) -}}
  {{- end -}}
  {{- if and ($app.useManagedConfig) (not (hasKey $spec "disableNamespaceMatcher")) }}
    {{- $_ := set $spec "disableNamespaceMatcher" true }}
  {{- end }}
  {{- if (($spec).storage).volumeClaimTemplate -}}
    {{- if not $spec.securityContext }}
      {{- $_ := set $spec "securityContext" (dict "runAsUser" 1000 "runAsGroup" 1000 "fsGroup" 1000) }}
    {{- end -}}
  {{- end }}
  {{- $_ := set $spec "templates" $templates -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- /* Single spec */ -}}
{{- define "vm.single.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $Chart := (.helm).Chart | default .Chart }}
  {{- $image := dict "tag" (include "vm.image.tag" .) }}
  {{- $extraArgs := dict -}}
  {{- $_ := set . "style" "managed" -}}
  {{- if $Values.vmalert.enabled }}
    {{- $_ := set . "appKey" (list "vmalert" "spec") }}
    {{- $_ := set $extraArgs "vmalert.proxyURL" (include "vm.url" .) -}}
  {{- end -}}
  {{- $spec := dict "extraArgs" $extraArgs "image" $image -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl (deepCopy $Values.vmsingle.spec | mergeOverwrite $spec | toYaml) . -}}
{{- end }}

{{- /* Cluster spec */ -}}
{{- define "vm.select.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $Chart := (.helm).Chart | default .Chart }}
  {{- $extraArgs := dict -}}
  {{- $_ := set . "style" "managed" -}}
  {{- if $Values.vmalert.enabled -}}
    {{- $_ := set . "appKey" (list "vmalert" "spec") -}}
    {{- $_ := set $extraArgs "vmalert.proxyURL" (include "vm.url" .) -}}
  {{- end -}}
  {{- $spec := dict "extraArgs" $extraArgs -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- define "vm.cluster.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $Chart := (.helm).Chart | default .Chart }}
  {{- $selectSpec := include "vm.select.spec" . | fromYaml -}}
  {{- $clusterSpec := deepCopy $Values.vmcluster.spec -}}
  {{- $clusterSpec = mergeOverwrite (dict "clusterVersion" (printf "%s-cluster" (include "vm.image.tag" .))) $clusterSpec -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $clusterSpec "license" (fromYaml .) -}}
  {{- end -}}
  {{- if ($clusterSpec.requestsLoadBalancer).enabled }}
    {{- $balancerSpec := $clusterSpec.requestsLoadBalancer.spec | default dict }}
    {{- $authImage := dict "image" (dict "tag" (include "vm.image.tag" .)) }}
    {{- $_ := set $clusterSpec.requestsLoadBalancer "spec" (mergeOverwrite $authImage $balancerSpec) }}
  {{- end }}
  {{- $clusterSpec = mergeOverwrite (dict "vmselect" $selectSpec) $clusterSpec }}
  {{- if not $clusterSpec.vmselect.enabled -}}
    {{- $_ := unset $clusterSpec "vmselect" -}}
  {{- else -}}
    {{- $_ := unset $clusterSpec.vmselect "enabled" -}}
  {{- end -}}
  {{- if not $clusterSpec.vminsert.enabled -}}
    {{- $_ := unset $clusterSpec "vminsert" -}}
  {{- else -}}
    {{- $_ := unset $clusterSpec.vminsert "enabled" -}}
  {{- end -}}
  {{- tpl (toYaml $clusterSpec) . -}}
{{- end -}}

{{- define "vm.distributed.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $Chart := (.helm).Chart | default .Chart }}
  {{- $selectSpec := include "vm.select.spec" . | fromYaml -}}
  {{- $distributedSpec := deepCopy (($Values.vmdistributed).spec | default dict) -}}
  {{- $clusterSpec := deepCopy ((($distributedSpec.zoneCommon).vmcluster).spec | default dict) -}}
  {{- $clusterSpec = mergeOverwrite (dict "clusterVersion" (printf "%s-cluster" (include "vm.image.tag" .))) $clusterSpec -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $distributedSpec "license" (fromYaml .) -}}
  {{- end -}}
  {{- if ($clusterSpec.requestsLoadBalancer).enabled }}
    {{- $balancerSpec := $clusterSpec.requestsLoadBalancer.spec | default dict }}
    {{- $authImage := dict "image" (dict "tag" (include "vm.image.tag" .)) }}
    {{- $_ := set $clusterSpec.requestsLoadBalancer "spec" (mergeOverwrite $authImage $balancerSpec) }}
  {{- end }}
  {{- $clusterSpec = mergeOverwrite (dict "vmselect" $selectSpec) $clusterSpec }}
  {{- $distributedSpec = mergeOverwrite (dict "zoneCommon" (dict "vmcluster" (dict "spec" $clusterSpec))) $distributedSpec }}

  {{- $agentSpec := deepCopy ((($distributedSpec.zoneCommon).vmagent).spec | default dict) }}
  {{- $image := dict "tag" (include "vm.image.tag" .) }}
  {{- $_ := set $agentSpec "image" $image -}}
  {{- $distributedSpec = mergeOverwrite (dict "zoneCommon" (dict "vmagent" (dict "spec" $agentSpec))) $distributedSpec }}
  {{- tpl (toYaml $distributedSpec) . -}}
{{- end -}}

{{- define "vm.data.source.enabled" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $grafana := $Values.grafana -}}
  {{- $installed := list }}
  {{- range $plugin := ($grafana.plugins | default list) -}}
    {{- $plugin = splitList "@" $plugin | first }}
    {{- $installed = append $installed $plugin }}
  {{- end -}}
  {{- $ds := .ds -}}
  {{- toString (or (not (hasKey $ds "version")) (has $ds.type $installed)) -}}
{{- end -}}

{{- /* Datasources */ -}}
{{- define "vm.data.sources" -}}
  {{- $ctx := . }}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $datasources := $Values.defaultDatasources.extra | default list -}}
  {{- $vmReadEndpoint := include "vm.prometheus.read" $ctx -}}
  {{- $vlReadEndpoint := include "vl.read.endpoint" $ctx -}}
  {{- $vtReadEndpoint := include "vt.read.endpoint" $ctx -}}
  {{- if $vmReadEndpoint -}}
    {{- $readEndpoint := fromYaml $vmReadEndpoint -}}
    {{- $defaultDatasources := list -}}
    {{- range $ds := $Values.defaultDatasources.victoriametrics.datasources }}
      {{- $_ := set $ds "url" $readEndpoint.url -}}
      {{- $defaultDatasources = append $defaultDatasources $ds -}}
    {{- end }}
    {{- $datasources = concat $datasources $defaultDatasources -}}
  {{- end -}}
  {{- if $vlReadEndpoint -}}
    {{- $readEndpoint := fromYaml $vlReadEndpoint -}}
    {{- $defaultDatasources := list -}}
    {{- range $ds := $Values.defaultDatasources.victorialogs.datasources }}
      {{- $_ := set $ds "url" $readEndpoint.url -}}
      {{- $defaultDatasources = append $defaultDatasources $ds -}}
    {{- end }}
    {{- $datasources = concat $datasources $defaultDatasources -}}
  {{- end -}}
  {{- if $vtReadEndpoint -}}
    {{- $readEndpoint := fromYaml $vtReadEndpoint -}}
    {{- $defaultDatasources := list -}}
    {{- range $ds := $Values.defaultDatasources.victoriatraces.datasources }}
      {{- $_ := set $ds "url" (printf "%s/select/jaeger" $readEndpoint.url) -}}
      {{- $defaultDatasources = append $defaultDatasources $ds -}}
    {{- end }}
    {{- $datasources = concat $datasources $defaultDatasources -}}
  {{- end -}}
  {{- if $Values.alertmanager.enabled -}}
    {{- range $ds := $Values.defaultDatasources.alertmanager.datasources }}
      {{- $appSecure := not (empty ((($Values.alertmanager).spec).webConfig).tls_server_config) -}}
      {{- $_ := set $ctx "appKey" (list "alertmanager" "spec") -}}
      {{- $_ := set $ctx "appSecure" $appSecure -}}
      {{- $_ := set $ctx "appRoute" (($Values.alertmanager).spec).routePrefix -}}
      {{- $_ := set $ds "url" (include "vm.url" $ctx) -}}
      {{- $_ := set $ds "type" "alertmanager" -}}
      {{- $datasources = append $datasources $ds -}}
    {{- end }}
  {{- end -}}
  {{- toYaml (dict "datasources" $datasources) -}}
{{- end }}

{{- define "vm-k8s-stack.grafana.addr" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $grafanaAddr := (($Values.external).grafana).host -}}
  {{- if not (or (hasPrefix "http://" $grafanaAddr) (hasPrefix "https://" $grafanaAddr)) -}}
    {{- $grafanaAddr = printf "http://%s" $grafanaAddr -}}
  {{- end -}}
  {{- if and ($Values.grafana).enabled (($Values.grafana).ingress).enabled -}}
    {{- $grafanaScheme := ternary "https" "http" (gt (len (($Values.grafana).ingress).tls) 0) -}}
    {{- $grafanaHosts := (($Values.grafana).ingress).hosts | default list }}
    {{- if eq (len $grafanaHosts) 0 }}
      {{- fail ".Values.grafana.ingress.hosts should not be empty if .Values.grafana.ingress.enabled is true" }}
    {{- end }}
    {{- $grafanaAddr = printf "%s://%s" $grafanaScheme (index $grafanaHosts 0) -}}
  {{- else if and ($Values.grafana).enabled (($Values.grafana).route).main.enabled -}}
    {{- $grafanaScheme := (($Values.grafana).route).main.scheme | default "http" -}}
    {{- $grafanaHosts := (($Values.grafana).route).main.hostnames | default list }}
    {{- if eq (len $grafanaHosts) 0 }}
      {{- fail ".Values.grafana.route.main.hostnames should not be empty if .Values.grafana.route.main.enabled is true" }}
    {{- end }}
    {{- $grafanaAddr = printf "%s://%s" $grafanaScheme (index $grafanaHosts 0) -}}
  {{- end -}}
  {{- $grafanaAddr -}}
{{- end -}}

{{- define "vl.read.endpoint" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $endpoint := dict -}}
  {{- $_ := set . "style" "managed" -}}
  {{- if $Values.vlsingle.enabled -}}
    {{- $_ := set . "appKey" (list "vlsingle" "spec") -}}
    {{- $_ := set $endpoint "url" (include "vm.url" .) -}}
  {{- else if and $Values.vlcluster.enabled $Values.vlcluster.spec.vlselect.enabled -}}
    {{- $_ := set . "appKey" (list "vlcluster" "spec" "vlselect") -}}
    {{- $_ := set $endpoint "url" (include "vm.url" .) -}}
  {{- else if $Values.external.vl.read.url -}}
    {{- $_ := set $endpoint "url" ((($Values.external).vl).read).url -}}
  {{- end -}}
  {{- with $endpoint -}}
    {{- toYaml . -}}
  {{- end -}}
{{- end }}

{{- define "vl.write.endpoint" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $endpoint := dict -}}
  {{- $_ := set . "style" "managed" -}}
  {{- if $Values.vlsingle.enabled -}}
    {{- $_ := set . "appKey" (list "vlsingle" "spec") -}}
    {{- $baseURL := include "vm.url" . -}}
    {{- $_ := set $endpoint "url" (printf "%s/insert/native" $baseURL) -}}
  {{- else if and $Values.vlcluster.enabled $Values.vlcluster.spec.vlinsert.enabled -}}
    {{- $_ := set . "appKey" (list "vlcluster" "spec" "vlinsert") -}}
    {{- $baseURL := include "vm.url" . -}}
    {{- $_ := set $endpoint "url" (printf "%s/insert/native" $baseURL) -}}
  {{- else if $Values.external.vl.write.url -}}
    {{- $endpoint = $Values.external.vl.write -}}
  {{- end -}}
  {{- with $endpoint -}}
    {{- toYaml . -}}
  {{- end -}}
{{- end -}}

{{- /* VLAgent spec */ -}}
{{- define "vl.agent.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $agentValues := $Values.vlagent -}}
  {{- $remoteWrites := $agentValues.additionalRemoteWrites | default list }}
  {{- $rws := $agentValues.spec.remoteWrite | default list }}
  {{- $writeEndpoint := include "vl.write.endpoint" . -}}
  {{- with $writeEndpoint -}}
    {{- if $rws -}}
      {{- $rws = prepend (slice $rws 1) (mergeOverwrite (fromYaml .) (deepCopy (first $rws))) -}}
    {{- else -}}
      {{- $rws = append $rws (fromYaml .) -}}
    {{- end -}}
  {{- end -}}
  {{- $remoteWrites = concat $remoteWrites $rws }}
  {{- $spec := dict "remoteWrite" $remoteWrites -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl (mergeOverwrite (deepCopy $agentValues.spec) (deepCopy $spec) | toYaml) . -}}
{{- end }}

{{- /* VLSingle spec */ -}}
{{- define "vl.single.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $image := dict "tag" (include "vm.image.tag" .) }}
  {{- $extraArgs := dict -}}
  {{- if $Values.vmalert.enabled }}
    {{- $_ := set . "appKey" (list "vmalert" "spec") }}
    {{- $_ := set $extraArgs "vmalert.proxyURL" (include "vm.url" .) -}}
  {{- end -}}
  {{- $spec := dict "extraArgs" $extraArgs "image" $image -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl (deepCopy $Values.vlsingle.spec | mergeOverwrite $spec | toYaml) . -}}
{{- end }}

{{- /* VLCluster select spec */ -}}
{{- define "vl.select.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $extraArgs := dict -}}
  {{- if $Values.vmalert.enabled -}}
    {{- $_ := set . "appKey" (list "vmalert" "spec") -}}
    {{- $_ := set $extraArgs "vmalert.proxyURL" (include "vm.url" .) -}}
  {{- end -}}
  {{- $spec := dict "extraArgs" $extraArgs -}}
  {{- toYaml $spec -}}
{{- end -}}

{{- /* VLCluster spec */ -}}
{{- define "vl.cluster.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $clusterSpec := deepCopy $Values.vlcluster.spec -}}
  {{- $clusterSpec = mergeOverwrite (dict "clusterVersion" (printf "%s-cluster" (include "vm.image.tag" .))) $clusterSpec -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $clusterSpec "license" (fromYaml .) -}}
  {{- end -}}
  {{- if ($clusterSpec.requestsLoadBalancer).enabled }}
    {{- $balancerSpec := $clusterSpec.requestsLoadBalancer.spec | default dict }}
    {{- $authImage := dict "image" (dict "tag" (include "vm.image.tag" .)) }}
    {{- $_ := set $clusterSpec.requestsLoadBalancer "spec" (mergeOverwrite $authImage $balancerSpec) }}
  {{- end }}
  {{- $clusterSpec = mergeOverwrite (dict "vlselect" (include "vl.select.spec" . | fromYaml)) $clusterSpec }}
  {{- if not $clusterSpec.vlselect.enabled -}}
    {{- $_ := unset $clusterSpec "vlselect" -}}
  {{- else -}}
    {{- $_ := unset $clusterSpec.vlselect "enabled" -}}
  {{- end -}}
  {{- if not $clusterSpec.vlinsert.enabled -}}
    {{- $_ := unset $clusterSpec "vlinsert" -}}
  {{- else -}}
    {{- $_ := unset $clusterSpec.vlinsert "enabled" -}}
  {{- end -}}
  {{- tpl (toYaml $clusterSpec) . -}}
{{- end -}}

{{- define "vt.read.endpoint" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $endpoint := dict -}}
  {{- $_ := set . "style" "managed" -}}
  {{- if $Values.vtsingle.enabled -}}
    {{- $_ := set . "appKey" (list "vtsingle" "spec") -}}
    {{- $_ := set $endpoint "url" (include "vm.url" .) -}}
  {{- else if and $Values.vtcluster.enabled $Values.vtcluster.spec.vtselect.enabled -}}
    {{- $_ := set . "appKey" (list "vtcluster" "spec" "vtselect") -}}
    {{- $_ := set $endpoint "url" (include "vm.url" .) -}}
  {{- else if $Values.external.vt.read.url -}}
    {{- $_ := set $endpoint "url" ((($Values.external).vt).read).url -}}
  {{- end -}}
  {{- with $endpoint -}}
    {{- toYaml . -}}
  {{- end -}}
{{- end }}

{{- define "vt.write.endpoint" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $endpoint := dict -}}
  {{- $_ := set . "style" "managed" -}}
  {{- if $Values.vtsingle.enabled -}}
    {{- $_ := set . "appKey" (list "vtsingle" "spec") -}}
    {{- $_ := set $endpoint "url" (include "vm.url" .) -}}
  {{- else if and $Values.vtcluster.enabled $Values.vtcluster.spec.vtinsert.enabled -}}
    {{- $_ := set . "appKey" (list "vtcluster" "spec" "vtinsert") -}}
    {{- $_ := set $endpoint "url" (include "vm.url" .) -}}
  {{- else if $Values.external.vt.write.url -}}
    {{- $endpoint = $Values.external.vt.write -}}
  {{- end -}}
  {{- with $endpoint -}}
    {{- toYaml . -}}
  {{- end -}}
{{- end -}}

{{- /* VTSingle spec */ -}}
{{- define "vt.single.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $image := dict "tag" (include "vm.image.tag" .) }}
  {{- $spec := dict "image" $image -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $spec "license" (fromYaml .) -}}
  {{- end -}}
  {{- tpl (deepCopy $Values.vtsingle.spec | mergeOverwrite $spec | toYaml) . -}}
{{- end }}

{{- /* VTCluster spec */ -}}
{{- define "vt.cluster.spec" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- $clusterSpec := deepCopy $Values.vtcluster.spec -}}
  {{- $clusterSpec = mergeOverwrite (dict "clusterVersion" (printf "%s-cluster" (include "vm.image.tag" .))) $clusterSpec -}}
  {{- with (include "vm.license.global" .) -}}
    {{- $_ := set $clusterSpec "license" (fromYaml .) -}}
  {{- end -}}
  {{- $vtselect := deepCopy ($clusterSpec.vtselect | default dict) -}}
  {{- $_ := unset $clusterSpec "vtselect" -}}
  {{- if $vtselect.enabled -}}
    {{- $_ := unset $vtselect "enabled" -}}
    {{- $_ := set $clusterSpec "select" $vtselect -}}
  {{- end -}}
  {{- $vtinsert := deepCopy ($clusterSpec.vtinsert | default dict) -}}
  {{- $_ := unset $clusterSpec "vtinsert" -}}
  {{- if $vtinsert.enabled -}}
    {{- $_ := unset $vtinsert "enabled" -}}
    {{- $_ := set $clusterSpec "insert" $vtinsert -}}
  {{- end -}}
  {{- $vtstorage := deepCopy ($clusterSpec.vtstorage | default dict) -}}
  {{- $_ := unset $clusterSpec "vtstorage" -}}
  {{- $_ := set $clusterSpec "storage" $vtstorage -}}
  {{- tpl (toYaml $clusterSpec) . -}}
{{- end -}}

{{- /* VMAuth spec for routing vmalert: /select/logsql/.* → VL, everything else → VM */ -}}
{{- define "vm.auth.internal.spec" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- include "vm.auth.context" . -}}
  {{- tpl (deepCopy $Values.internal.vmauth.spec | toYaml) . -}}
{{- end -}}
