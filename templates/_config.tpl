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
ingressConfig:
  targetService:
    name: {{ $cfg.targetService.name | required "target service name must be provided "}}
    namespace: {{ $cfg.targetService.namespace | default .Release.Namespace }}
  {{ if and $cfg.selector $cfg.selector.ingressClass }}
  selector:
    ingressClass: {{ $cfg.selector.ingressClass }}
  {{ end }}
  {{ if and $cfg.certificateIssuer.name $cfg.certificateIssuer.kind }}
  certificateIssuer:
    name: {{ $cfg.certificateIssuer.name | required "certificate issuer name must be provided" }}
    kind: {{ $cfg.certificateIssuer.kind | required "certificate issuer kind must be provided" }}
  {{ else if .Values.certificateIssuer.create }}
  certificateIssuer:
    name: {{ .Release.Name }}-letsencrypt-issuer
    kind: ClusterIssuer
  {{ else }}
    {{ fail "certificate issuer is not provided and none is created by this chart" }}
  {{ end }}
{{ end }}
