{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "vault-secrets-integrator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vault-secrets-integrator.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vault-secrets-integrator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "vault-secrets-integrator.labels" -}}
helm.sh/chart: {{ include "vault-secrets-integrator.chart" . }}
{{ include "vault-secrets-integrator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "vault-secrets-integrator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vault-secrets-integrator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "vault-secrets-integrator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "vault-secrets-integrator.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

# Vault annotations: secrets
{{- define "vault.annotations.secrets" -}}
  {{- if .Values.vault.annotations.secrets }}
    {{- range .Values.vault.annotations.secrets }}
            vault.hashicorp.com/agent-inject-secret-{{ .name }}.json: "{{ .path }}"
            vault.hashicorp.com/agent-inject-template-{{ .name }}.json: |-
              {{ "{{- with secret" }} "{{ .path }}" {{ "-}}" }}
              {{ "{" }}
              {{ "  \"apiVersion\": \"v1\"," }}
              {{ "  \"kind\": \"Secret\"," }}
              {{ "  \"metadata\": {" }}
              {{ "    \"name\": \"" }}{{ .name }}{{ "\"," }}
              {{ "  }," }}
              {{ "  \"type\": \"Opaque\"," }}
              {{ "  \"stringData\": {" }}
              {{ "  {{ range $k, $v := .Data.data }}" }}
              {{ "  \"{{ $k }}\": \"{{ $v }}\"," }}
              {{ "  {{ end }}" }}
              {{ "  \"end\": \"NULL\"" }}
              {{ "  }" }}
              {{ "}" }}
              {{ "{{- end }}" }}
    {{- end }}
  {{- end }}
{{- end -}}

# Vault annotations: dockerconfigjson
{{- define "vault.annotations.dockerregistrycred" -}}
  {{- if .Values.vault.annotations.dockerregistrycred }}
    {{- range .Values.vault.annotations.dockerregistrycred }}
            vault.hashicorp.com/agent-inject-secret-{{ .name }}.json: "{{ .path }}"
            vault.hashicorp.com/agent-inject-template-{{ .name }}.json: |-
              {{ "{{- with secret" }} "{{ .path }}" {{ "-}}" }}
              {{ "{" }}
              {{ "  \"apiVersion\": \"v1\"," }}
              {{ "  \"kind\": \"Secret\"," }}
              {{ "  \"metadata\": {" }}
              {{ "    \"name\": \"" }}{{ .name }}{{ "\"," }}
              {{ "  }," }}
              {{ "  \"type\": \"kubernetes.io/dockerconfigjson\"," }}
              {{ "  \"data\": {" }}
              {{ "  \".dockerconfigjson\": {{ .Data.data.dockerconfigjson }}" }}
              {{ "  }" }}
              {{ "}" }}
              {{ "{{- end }}" }}
    {{- end }}
  {{- end }}
{{- end -}}