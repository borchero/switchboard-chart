{{ define "config" }}
{{- $cfg := .Values.config -}}
apiVersion: controller-runtime.sigs.k8s.io/v1alpha1
kind: ControllerManagerConfig
health:
  healthProbeBindAddress: :8081
leaderElection:
  leaderElect: {{ gt .Values.replicas 1.0 }}
  resourceName: {{ .Release.Name }}.switchboard.borchero.com
  resourceNamespace: {{ .Release.Namespace }}

{{ if .Values.metrics.enabled }}
metrics:
  bindAddress: :{{ .Values.metrics.port }}
{{ end }}

{{ if .Values.selector.ingressClass }}
selector:
  ingressClass: {{ .Values.selector.ingressClass }}
{{ end }}

{{- $certManager := .Values.integrations.certManager -}}
{{- $externalDNS := .Values.integrations.externalDNS -}}
{{ if or $certManager.enabled $externalDNS.enabled }}
integrations:
  {{ if $certManager.enabled }}
  certManager:
    {{ if and $certManager.issuer.kind $certManager.issuer.name }}
    issuer:
      {{ toYaml $certManager.issuer | nindent 6 }}
    {{ else if .Values.certificateIssuer.create }}
    issuer:
      kind: ClusterIssuer
      name: {{ .Release.Name }}-letsencrypt-issuer
    {{ else }}
      {{ fail "certificate issuer is not provided and none is created by this chart" }}
    {{ end }}
  {{ end }}
  {{ if $externalDNS.enabled }}
  externalDNS:
    target:
      name: {{ $externalDNS.target.name | required "target name required" }}
      namespace: {{ $externalDNS.target.namespace | required "target namespace required" }}
  {{ end }}
{{ end }}

{{ end }}