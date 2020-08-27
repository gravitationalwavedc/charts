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

# Vault engine annotations
{{- define "vault.engine.annotations" -}}
  {{- if .Values.vault.engine.annotations }}
    {{- range .Values.vault.engine.annotations }}
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
      {{ "}" }}
      {{ "{{- end }}" }}
    {{- end }}
    {{ "vault.hashicorp.com/role:" }} {{ .Values.vault.engine.role }}
  {{- end }}
{{- end -}}

# Docker private repository
{{- define "docker.registry.annotations" -}}
  {{- if .Values.docker.registry.annotations }}
    {{- range .Values.docker.registry.annotations }}
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
      {{ "}" }}
      {{ "{{- end }}" }}
    {{- end }}
    {{ "vault.hashicorp.com/role:" }} {{ .Values.vault.engine.role }}
  {{- end }}
{{- end -}}
