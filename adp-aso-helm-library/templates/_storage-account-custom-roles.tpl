# DEFRA DEV  - Custom Storage Data Writer Role Id
{{- define "customRole.defradev.storageDataWriterId" -}}
{{- include "customRole.roleId" "007f9e36-e36a-5a8a-ae5f-4b3b290fd666" -}}
{{- end -}}

# DEFRA NON PRD - Custom Storage Data Writer Role Id
{{- define "customRole.defraNonPrd.storageDataWriterId" -}}
{{- include "customRole.roleId" "a763bd63-0a12-5528-b29d-84ffc3be32c5" -}}
{{- end -}}

# DEFRA PRD - Custom Storage Data Writer Role Id
{{- define "customRole.defraPrd.storageDataWriterId" -}}
{{- include "customRole.roleId" "ea76d2b1-c243-5f31-8112-21b92143d6fe" -}}
{{- end -}}

# DEFRA DEV - Custom Storage Data Reader Role Id
{{- define "customRole.defradev.storageDataReaderId" -}}
{{- include "customRole.roleId" "c9c8fc7a-77bc-5910-ba49-5807849602ae" -}}
{{- end -}}

# DEFRA NON PRD - Custom Storage Data Reader Role Id
{{- define "customRole.defraNonPrd.storageDataReaderId" -}}
{{- include "customRole.roleId" "ebdd18c0-21ec-5084-850b-22e68c91bc60" -}}
{{- end -}}

# DEFRA - Custom Storage Data Reader Role Id
{{- define "customRole.defraPrd.storageDataReaderId" -}}
{{- include "customRole.roleId" "9c837a88-0b44-50da-aff1-137c702b861d" -}}
{{- end -}}

# CustomRole -  Storage Data Writer
{{- define "customRole.storageDataWriterId" -}}
{{- printf "%s%s%s" "/subscriptions/00000000-0000-0000-0000-000000000000" "/providers/Microsoft.Authorization/roleDefinitions/" (include "customRole.getRoleId" (dict "tenant" .tenant "environment" .environment "role" "storageDataWriter")) }}
{{- end }}

# CustomRole -  Storage Data Reader
{{- define "customRole.storageDataReaderId" -}}
{{- printf "%s%s%s" "/subscriptions/00000000-0000-0000-0000-000000000000" "/providers/Microsoft.Authorization/roleDefinitions/" (include "customRole.getRoleId" (dict "tenant" .tenant "environment" .environment "role" "storageDataReader")) }}
{{- end }}

{{- define "customRole.roleId" -}}
{{- printf "%s" . -}}
{{- end -}}

{{- define "customRole.getRoleId" -}}
{{- $tenant := .tenant -}}
{{- $env := .environment -}}
{{- $role := .role -}}
{{- if and (eq $env "snd") (eq $tenant "defradev") -}}
{{- include (printf "customRole.defradev.%sId" $role) . }}
{{- else if and (eq $env "snd") (eq $tenant "defra") -}}
{{- include (printf "customRole.defraNonPrd.%sId" $role) . }}
{{- else if eq $env "prd" -}}
{{- include (printf "customRole.defraPrd.%sId" $role) . }}
{{- else -}}
{{- include (printf "customRole.defraNonPrd.%sId" $role) . }}
{{- end -}}
{{- end -}}