{{/*
Generate a full name for resources.
*/}}
{{- define "demo.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate the name of the chart.
*/}}
{{- define "demo.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate a name for the service account.
*/}}
{{- define "demo.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "demo.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}
