{{/* ## main helm chart variables ## */}}
{{- define "alethichelm.name" -}}{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}{{- end -}}
{{- define "alethichelm.release" -}}{{- printf "%s" .Release.Name -}}{{- end -}}
{{- define "alethichelm.chart" -}}{{- printf "%s-%s" .Chart.Name .Chart.Version -}}{{- end -}}
{{- define "alethichelm.fullname" -}}{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}{{- end -}}
{{- define "alethichelm.routesSecretName" -}}{{ include "alethichelm.fullname" . }}-routes-secret{{- end -}}

{{/* ## postgres configuration ## */}}
{{- define "alethichelm.postgres.name" -}}{{ include "alethichelm.release" . }}-postgres{{- end -}}
{{- define "alethichelm.postgres.dburl" -}}postgresql://{{ .Values.global.postgres.user }}:{{ .Values.global.postgres.password }}@{{ include "alethichelm.postgres.name" . }}.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.global.postgres.port }}/{{ .Values.global.postgres.database }}{{- end -}}
{{- define "alethichelm.postgres.dsn" -}}host={{ include "alethichelm.postgres.name" . }}.{{ .Release.Namespace }}.svc.cluster.local port={{ .Values.global.postgres.port }} user={{ .Values.global.postgres.user }} password={{ .Values.global.postgres.password }} dbname={{ .Values.global.postgres.database }} sslmode={{ .Values.global.postgres.sslmode }}{{- end -}}


{{- define "alethichelm.nats.url" -}}nats://{{ .Release.Name }}-nats.{{ .Release.Namespace }}.svc.cluster.local:4222{{- end -}}