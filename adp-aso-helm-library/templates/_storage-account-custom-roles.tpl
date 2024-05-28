{{- define "defradev.storageDataWriterId" -}}
{{- include "roleId" "007f9e36-e36a-5a8a-ae5f-4b3b290fd666" -}}
{{- end -}}

{{- define "defra.nonPrd.storageDataWriterId" -}}
{{- include "roleId" "" -}}
{{- end -}}

{{- define "defra.prd.storageDataWriterId" -}}
{{- include "roleId" "" -}}
{{- end -}}

{{- define "defradev.storageDataReaderId" -}}
{{- include "roleId" "c9c8fc7a-77bc-5910-ba49-5807849602ae" -}}
{{- end -}}

{{- define "defra.nonPrd.storageDataReaderId" -}}
{{- include "roleId" "" -}}
{{- end -}}

{{- define "defra.prd.storageDataReaderId" -}}
{{- include "roleId" "" -}}
{{- end -}}

{{- define "roleId" -}}
{{- printf "%s" . -}}
{{- end -}}

{{- define "getRoleId" -}}
{{- $env := .environment -}}
{{- $role := .role -}}
{{- if eq $env "snd" -}}
{{- include (printf "defradev.%sId" $role) . }}
{{- else if eq $env "prd" -}}
{{- include (printf "defra.prd.%sId" $role) . }}
{{- else -}}
{{- include (printf "defra.nonPrd.%sId" $role) . }}
{{- end -}}
{{- end -}}

{{- define "customRole.storageDataWriterId" -}}
{{- printf "%s%s%s" "/subscriptions/00000000-0000-0000-0000-000000000000" "/providers/Microsoft.Authorization/roleDefinitions/" (include "getRoleId" (dict "environment" .environment "role" "storageDataWriter")) }}
{{- end }}

{{- define "customRole.storageDataReaderId" -}}
{{- printf "%s%s%s" "/subscriptions/00000000-0000-0000-0000-000000000000" "/providers/Microsoft.Authorization/roleDefinitions/" (include "getRoleId" (dict "environment" .environment "role" "storageDataReader")) }}
{{- end }}