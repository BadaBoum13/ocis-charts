{{/* vim: set filetype=mustache: */}}
{{/*
OIDC issuer / web client ID env value definitions.

Both take the scope as the first and only parameter, and render the
`value:` or `valueFrom:` portion of an env entry (indentation is left to the
caller, e.g. `{{- include "ocis.oidcIssuerEnvValue" . | nindent 14 }}`).

Resolution order:
  1. Internal IDP (features.externalUserManagement.enabled == false): fixed
     value derived from externalDomain.
  2. External IDP with secretRefs.oidcSecretRef set: read from that Secret.
  3. External IDP without secretRefs.oidcSecretRef: plain value from
     features.externalUserManagement.oidc / services.web.config.oidc.
*/}}
{{- define "ocis.oidcIssuerEnvValue" -}}
{{- if not .Values.features.externalUserManagement.enabled -}}
value: "https://{{ .Values.externalDomain }}"
{{- else if .Values.secretRefs.oidcSecretRef -}}
valueFrom:
  secretKeyRef:
    name: {{ include "secrets.oidcSecret" . }}
    key: issuer-uri
{{- else -}}
value: {{ required "features.externalUserManagement.oidc.issuerURI must be set when features.externalUserManagement.enabled is set to true and secretRefs.oidcSecretRef is not set" .Values.features.externalUserManagement.oidc.issuerURI | quote }}
{{- end -}}
{{- end -}}

{{- define "ocis.oidcWebClientIDEnvValue" -}}
{{- if and .Values.features.externalUserManagement.enabled .Values.secretRefs.oidcSecretRef -}}
valueFrom:
  secretKeyRef:
    name: {{ include "secrets.oidcSecret" . }}
    key: client-id
{{- else -}}
value: {{ .Values.services.web.config.oidc.webClientID | quote }}
{{- end -}}
{{- end -}}
