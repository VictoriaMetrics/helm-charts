{{- define "vlagent.args" -}}
  {{- $Values := (.helm).Values | default .Values }}
  {{- if empty $Values.remoteWrite }}
    {{- fail "at least one remoteWrite configuration must be provided" }}
  {{- end }}

  {{- $args := dict "tmpDataPath" "/vlagent-data" }}
  {{- $_ := set $args "remoteWrite.maxDiskUsagePerURL" $Values.maxDiskUsagePerURL -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.license.flag" .)) -}}
  {{- $rwItems := list -}}
  {{- range $i, $rw := $Values.remoteWrite -}}
    {{- if not $rw.url -}}
      {{- fail (printf "remoteWrite[%d].url parameter is not set" $i) -}}
    {{- end -}}
    {{- $item := dict -}}
    {{- range $rwKey, $rwValue := $rw -}}
      {{- $value := $rwValue -}}
      {{- if eq $rwKey "url" -}}
        {{- $url := urlParse $rwValue -}}
        {{- $isEmptyPath := empty (trimPrefix "/" $url.path) -}}
        {{- $isNativeFormat := or (empty $rw.format) (eq $rw.format "native") -}}
        {{- $_ = set $url "path" (ternary "/insert/native" $url.path (and $isEmptyPath $isNativeFormat)) -}}
        {{- $value = urlJoin $url -}}
      {{- else if eq $rwKey "headers" -}}
        {{- $headers := list -}}
        {{- range $hk, $hv := $rwValue -}}
          {{- $vs := "" -}}
          {{- if kindIs "slice" $hv -}}
            {{- $vs = join "," $hv -}}
          {{- else if kindIs "map" $hv -}}
            {{- $pairs := list -}}
            {{- range $k, $v := $hv -}}
              {{- $pairs = append $pairs (printf "%s=%s" $k $v) -}}
            {{- end -}}
            {{- $vs = join "," $pairs -}}
          {{- else -}}
            {{- $vs = toString $hv -}}
          {{- end -}}
          {{- $headers = append $headers (printf "%s:%s" $hk $vs) -}}
        {{- end -}}
        {{- $value = quote (join "^^" $headers) -}}
      {{- end -}}
      {{- $_ := set $item (printf "remoteWrite.%s" $rwKey) $value -}}
    {{- end -}}
    {{- $rwItems = append $rwItems $item -}}
  {{- end -}}
  {{- $args = mergeOverwrite $args (fromYaml (include "vm.args.positional" $rwItems)) -}}
  {{- $extraArgs := $Values.extraArgs | default dict }}
  {{- $args = mergeOverwrite $args $extraArgs -}}
  {{- if empty $extraArgs.httpListenAddr -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vm.http.args" $Values.http)) -}}
  {{- end -}}
  {{- if and (empty (index $extraArgs "syslog.listenAddr.tcp")) (empty (index $extraArgs "syslog.listenAddr.udp")) -}}
    {{- $args = mergeOverwrite $args (fromYaml (include "vl.syslog.args" $Values.syslog)) -}}
  {{- end -}}
  {{- toYaml (fromYaml (include "vm.args" $args)).args -}}
{{- end }}

{{- define "vlagent.cr.spec" -}}
  {{- $Values := (.helm).Values | default .Values -}}
  {{- $spec := include "vm.cr.component.spec" (dict "comp" $Values) | fromYaml -}}
  {{- with $Values.remoteWrite }}{{- $_ := set $spec "remoteWrite" . }}{{- end -}}
  {{- if ($Values.persistentVolume).enabled }}
    {{- $pvc := $Values.persistentVolume -}}
    {{- $pvcSpec := dict "resources" (dict "requests" (dict "storage" $pvc.size)) -}}
    {{- with $pvc.accessModes }}{{- $_ := set $pvcSpec "accessModes" . }}{{- end -}}
    {{- with $pvc.storageClassName }}{{- $_ := set $pvcSpec "storageClassName" . }}{{- end -}}
    {{- $_ := set $spec "storage" (dict "volumeClaimTemplate" (dict "spec" $pvcSpec)) -}}
  {{- end -}}
  {{- if $Values.useLegacyNaming }}{{- $_ := set $spec "useLegacyNaming" true }}{{- end -}}
  {{- toYaml (mergeOverwrite $spec ($Values.spec | default dict)) -}}
{{- end -}}
