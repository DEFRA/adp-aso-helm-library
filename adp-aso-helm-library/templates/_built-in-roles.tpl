{{/*
Built In Role: Azure Service Bus Data Receiver
*/}}
{{- define "builtInRole.azureServiceBusDataReceiverId" -}}
{{- printf "%s%s" "/subscriptions/00000000-0000-0000-0000-000000000000" "/providers/Microsoft.Authorization/roleDefinitions/4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0" }}
{{- end }}

{{/*
Built In Role: Azure Service Bus Data Sender
*/}}
{{- define "builtInRole.azureServiceBusDataSenderId" -}}
{{- printf "%s%s" "/subscriptions/00000000-0000-0000-0000-000000000000" "/providers/Microsoft.Authorization/roleDefinitions/69a216fc-b8fb-44d8-bc22-1f3c2cd27a39" }}
{{- end }}

{{/*
Built In Role: Key Vault Secrets User
*/}}
{{- define "builtInRole.keyVaultSecretsUserId" -}}
{{- printf "%s%s" "/subscriptions/00000000-0000-0000-0000-000000000000" "/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6" }}
{{- end }}

{{/*
Custom Role: Storage Data Writer
*/}}
{{- define "cutomRole.storageDataWriterId" -}}
{{- printf "%s%s" "/subscriptions/00000000-0000-0000-0000-000000000000" "/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe" }}
{{- end }}

{{/*
Custom Role: Storage Data Reader
*/}}
{{- define "cutomRole.storageDataReaderId" -}}
{{- printf "%s%s" "/subscriptions/00000000-0000-0000-0000-000000000000" "/providers/Microsoft.Authorization/roleDefinitions/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1" }}
{{- end }}
