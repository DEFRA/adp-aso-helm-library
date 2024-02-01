{{/*
A default message string to be used when checking for a required value
*/}}
{{- define "adp-aso-helm-library.default-check-required-msg" -}}
{{- "No value found for '%s' in adp-aso-helm-library template" -}}
{{- end -}}

{{/*
Common Tags for Azure resources
*/}}
{{- define "adp-aso-helm-library.commonTags" -}}
{{- $ := index . 0 }}
{{- $userTags := index . 1 }}
{{- $requiredMsg := include "adp-aso-helm-library.default-check-required-msg" . }}
{{- if $.Values.commonTags }}
Environment: {{ required (printf $requiredMsg "commonTags.environment") $.Values.commonTags.environment | quote }}
ServiceCode: {{ required (printf $requiredMsg "commonTags.serviceCode") $.Values.commonTags.serviceCode | quote }}
ServiceName: {{ required (printf $requiredMsg "commonTags.serviceName") $.Values.commonTags.serviceName | quote }}
ServiceType: {{ $.Values.commonTags.serviceType | default "Dedicated" }}
ManagedBy: AzureServiceOperator
Restriction: AUTOMATED CHANGES ONLY
kubernetes_cluster: {{ required (printf $requiredMsg "commonTags.kubernetes_cluster") $.Values.commonTags.kubernetes_cluster | quote }}
kubernetes_namespace: {{ required (printf $requiredMsg "commonTags.kubernetes_namespace") $.Values.namespace | quote }}
kubernetes_label_ServiceCode: {{ required (printf $requiredMsg "commonTags.kubernetes_label_serviceCode") $.Values.commonTags.kubernetes_label_serviceCode | quote }}
{{- end }}
{{- if $userTags }}
{{ toYaml $userTags }}
{{- end }}
{{- end -}}


{{/*
resource FullName
*/}}
{{- define "resource.fullname" -}}
{{- $ := index . 0 }}
{{- $resourceName := index . 1 }}
{{- $requiredMsg := include "adp-aso-helm-library.default-check-required-msg" . }}
{{- $resourceNamePrefix := (required (printf $requiredMsg "namespace") $.Values.namespace) | lower }}
{{- (printf "%s-%s" $resourceNamePrefix $resourceName) | lower }}
{{- end }}


{{/*
managedidentity Name. Each service will have one managedidentity and it follows standard naming convention which is derived in adp-flux-services
*/}}
{{- define "managedidentity.name" -}}
{{- $requiredMsg := include "adp-aso-helm-library.default-check-required-msg" . }}
{{- $teamMIPrefix := (required (printf $requiredMsg "teamMIPrefix") $.Values.teamMIPrefix) }}
{{- $serviceName := (required (printf $requiredMsg "serviceName") $.Values.serviceName) }}
{{- if (and $teamMIPrefix $serviceName) }}
{{- (printf "%s-%s" $teamMIPrefix $serviceName) | lower }}
{{- else }}
{{- printf "this-condition-is-required-for-linting" }}
{{- end }}
{{- end }}

{{/*
managedidentity ConfigMapName
*/}}
{{- define "managedidentity.configMapName" -}}
{{- $requiredMsg := include "adp-aso-helm-library.default-check-required-msg" . }}
{{- printf "%s-mi-credential" (required (printf $requiredMsg "serviceName") $.Values.serviceName) }}
{{- end }}

{{/*
roleDefinitionId for the roleAssignment
*/}}
{{- define "roleAssignment.roleDefinitionId" -}}
{{- $roleName := . | lower }}
{{- if eq $roleName "queuesender" }}
{{- printf (include "builtInRole.azureServiceBusDataSenderId" .) }}
{{- else if eq $roleName "queuereceiver" }}
{{- printf (include "builtInRole.azureServiceBusDataReceiverId" .) }}
{{- else if eq $roleName "topicsender" }}
{{- printf (include "builtInRole.azureServiceBusDataSenderId" .) }}
{{- else if eq $roleName "topicreceiver" }}
{{- printf (include "builtInRole.azureServiceBusDataReceiverId" .) }}
{{- else if eq $roleName "keyvaultsecretuser" }}
{{- printf (include "builtInRole.keyVaultSecretsUserId" .) }}
{{- else }}
{{- fail (printf "Value for roleName is not as expected. '%s' role is not in the allowed roles." $roleName) }}
{{- end }}
{{- end }}


{{/*
Scope for the roleAssignment
*/}}
{{- define "roleAssignment.scope" -}}
{{- $ := index . 0 }}
{{- $resourceName := index . 1 }}
{{- $resourceType := index . 2 }}
{{- if eq $resourceType "namespaceQueue" }}
{{- printf "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.ServiceBus/namespaces/%s/queues/%s" $.Values.subscriptionId $.Values.serviceBusResourceGroupName $.Values.serviceBusNamespaceName $resourceName }}
{{- else if eq $resourceType "namespaceTopic" }}
{{- printf "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.ServiceBus/namespaces/%s/topics/%s" $.Values.subscriptionId $.Values.serviceBusResourceGroupName $.Values.serviceBusNamespaceName $resourceName }}
{{- else if eq $resourceType "keyVaultSecret" }}
{{- printf "/subscriptions/%s/resourcegroups/%s/providers/Microsoft.KeyVault/vaults/%s/secrets/%s" $.Values.subscriptionId $.Values.keyVaultResourceGroupName $.Values.keyVaultName (printf "%s-%s" $.Values.serviceName $resourceName) }}
{{- end }}
{{- end }}

{{/*
default name for StorageAccountsBlobService, StorageAccountsTableService, StorageAccountsFileService, StorageAccountsQueueService
*/}}
{{- define "storageaccountsService.defaultName" -}}
{{- $storageAccountName := index . 0 }}
{{- (printf "%s-default" $storageAccountName) | lower }}
{{- end }}

{{/*
Storage account blob service container FullName
*/}}
{{- define "storageAccountsBlobServicesContainer.fullname" -}}
{{- $storageAccountName := index . 0 }}
{{- $containerName := index . 1 }}
{{- (printf "%s-%s" (include "storageaccountsService.defaultName" (list $storageAccountName)) $containerName) | lower }}
{{- end }}

{{/*
Storage account Table FullName
*/}}
{{- define "storageAccountsTableServicesTable.fullname" -}}
{{- $storageAccountName := index . 0 }}
{{- $tableName := index . 1 }}
{{- (printf "%s-%s" (include "storageaccountsService.defaultName" (list $storageAccountName)) $tableName) | lower }}
{{- end }}
