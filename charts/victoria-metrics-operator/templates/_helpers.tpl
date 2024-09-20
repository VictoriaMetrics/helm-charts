{{/*
Selector labels
*/}}
{{- define "vm-operator.selectorLabels" -}}
{{- $Release := (.helm).Release | default .Release -}}
app.kubernetes.io/name: {{ include "vm.name" . }}
app.kubernetes.io/instance: {{ $Release.Name | trunc 63 | trimSuffix "-" }}
{{- with .extraLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{/*
Create unified labels for vm-operator components
*/}}
{{- define "vm-operator.labels" -}}
{{- include "vm-operator.selectorLabels" . }}
{{- $Release := (.helm).Release | default .Release }}
helm.sh/chart: {{ include "vm.chart" . }}
app.kubernetes.io/managed-by: {{ $Release.Service | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Create unified annotations for vm-operator components
*/}}
{{- define "vm-operator.crds.annotations" -}}
{{- $Release :=(.helm).Release | default .Release -}}
helm.sh/resource-policy: keep
meta.helm.sh/release-namespace: {{ include "vm.namespace" . }}
meta.helm.sh/release-name: {{ $Release.Name }}
{{- end -}}

{{/*
Generate certificates for webhook
*/}}
{{- define "vm-operator.certs" -}}
{{- $Values := (.helm).Values | default .Values }}
{{- $Release := (.helm).Release | default .Release }}
{{- $webhook := $Values.admissionWebhooks -}}
{{- $tls := $webhook.tls -}}
{{- $serviceName := (include "vm.fullname" .) -}}
{{- $secretName := (printf "%s-validation" $serviceName) -}}
{{- $secret := lookup "v1" "Secret" (include "vm.namespace" .) $secretName -}}
{{- if (and $tls.caCert $tls.cert $tls.key) -}}
caCert: {{ $tls.caCert | b64enc }}
clientCert: {{ $tls.cert | b64enc }}
clientKey: {{ $tls.key | b64enc }}
{{- else if and $webhook.keepTLSSecret $secret -}}
caCert: {{ index $secret.data "ca.crt" }}
clientCert: {{ index $secret.data "tls.crt" }}
clientKey: {{ index $secret.data "tls.key" }}
{{- else -}}
{{- $altNames := default list -}}
{{- $namePrefix := (printf "%s.%s" $serviceName (include "vm.namespace" .)) -}}
{{- $altNames = append $altNames $namePrefix -}}
{{- $altNames = append $altNames (printf "%s.svc" $namePrefix) -}}
{{- $altNames = append $altNames (printf "%s.svc.%s" $namePrefix $Values.global.cluster.dnsDomain) -}}
{{- $ca := genCA "vm-operator-ca" 3650 -}}
{{- $cert := genSignedCert $serviceName nil $altNames 3650 $ca -}}
caCert: {{ $ca.Cert | b64enc }}
clientCert: {{ $cert.Cert | b64enc }}
clientKey: {{ $cert.Key | b64enc }}
{{- end -}}
{{- end -}}
