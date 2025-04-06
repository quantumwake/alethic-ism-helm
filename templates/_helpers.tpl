{{/* ## main helm chart variables ## */}}
{{- define "alethichelm.name" -}}{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}{{- end -}}
{{- define "alethichelm.release" -}}{{- printf "%s" .Release.Name -}}{{- end -}}
{{- define "alethichelm.chart" -}}{{- printf "%s-%s" .Chart.Name .Chart.Version -}}{{- end -}}
{{- define "alethichelm.fullname" -}}{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}{{- end -}}
{{- define "alethichelm.routesSecretName" -}}{{ include "alethichelm.fullname" . }}-routes-secret{{- end -}}

{{/* ## postgres configuration ## */}}
{{- define "alethichelm.postgres.name" -}}{{ include "alethichelm.release" . }}-postgres{{- end -}}
{{- define "alethichelm.postgres.dburl" -}}postgresql://{{ .Values.global.postgres.user }}:{{ .Values.global.postgres.password }}@{{ include "alethichelm.postgres.name" . }}.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.global.postgres.port }}/{{ .Values.global.postgres.database }}{{- end -}}

{{/*{{- define "alethichelm.postgres.dburl" -}}{{- $postgresDBURL := include "alethichelm.postgres.name" . -}}postgresql://{{ .Values.global.postgres.user }}:{{ .Values.global.postgres.password }}@{{ $postgresName }}:{{ .Values.global.postgres.port }}/{{ .Values.global.postgres.database }}{{- end -}}*/}}
{{/*{{- define "alethichelm.postgres.dburl" -}}postgresql://{{ .Values.postgres.user }}:{{ .Values.postgres.password }}@{{ include "alethichelm.postgres.name" . }}:5432/{{ .Values.postgres.database }}{{- end -}}*/}}

