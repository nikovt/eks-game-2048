{{/*
Expand the name of the chart.
*/}}
{{- define "game-2048.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "game-2048.fullname" -}}
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
{{- define "game-2048.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "game-2048.labels" -}}
helm.sh/chart: {{ include "game-2048.chart" . }}
{{ include "game-2048.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Get game id
*/}}
{{- define "game-2048.id" -}}
{{ (split "-" .Chart.Name)._1 }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "game-2048.selectorLabels" -}}
app.kubernetes.io/name: app-{{ include "game-2048.id" . }}
{{- end }}

{{/*
Get deployment name
*/}}
{{- define "game-2048.deploymentName" -}}
deployment-{{ include "game-2048.id" . }}
{{- end }}

{{/*
Get service name
*/}}
{{- define "game-2048.serviceName" -}}
service-{{ include "game-2048.id" . }}
{{- end }}

{{/*
Get ingress name
*/}}
{{- define "game-2048.ingressName" -}}
ingress-{{ include "game-2048.id" . }}
{{- end }}