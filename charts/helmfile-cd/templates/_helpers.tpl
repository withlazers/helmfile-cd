{{/*
Expand the name of the chart.
*/}}
{{- define "helmfile-cd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "helmfile-cd.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "helmfile-cd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "helmfile-cd.labels" -}}
helm.sh/chart: {{ include "helmfile-cd.chart" . }}
{{ include "helmfile-cd.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helmfile-cd.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helmfile-cd.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "helmfile-cd.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "helmfile-cd.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of ssh secret to use
*/}}
{{- define "helmfile-cd.gitSecretName" -}}
{{- .Values.git.authentication.existingSecret | default (include "helmfile-cd.fullname" .) }}
{{- end }}

{{/*
Create the name of pvc to use
*/}}
{{- define "helmfile-cd.pvcName" -}}
{{- .Values.persistence.existingClaim | default (printf "%s-cache" (include "helmfile-cd.fullname" .)) }}
{{- end }}
