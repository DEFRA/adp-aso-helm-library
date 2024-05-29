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
Storage Account roleDefinitionId for the roleAssignment
*/}}
{{- define "roleAssignment.saRoleDefinitionId" -}}
{{- $roleName := .roleName | lower }}
{{- if eq $roleName "datawriter" }}
{{- printf (include "customRole.storageDataWriterId" (dict "tenant" .tenant "environment" .environment)) }}
{{- else if eq $roleName "datareader" }}
{{- printf (include "customRole.storageDataReaderId" (dict "tenant" .tenant "environment" .environment)) }}
{{- else }}
{{- fail (printf "The provided role name for the storage account, '%s', is not valid. It does not match any of the allowed roles." $roleName) }}
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
{{- else }}
{{- fail (printf "Value for resourceType is not as expected. '%s' is not in the allowed scope." $resourceType) }}
{{- end }}
{{- end }}

{{/*
Scope for the Storage account roleAssignment
*/}}
{{- define "storage.roleAssignment.scope" -}}
{{- $ := index . 0 }}
{{- $storageAccountName := index . 1 }}
{{- printf "/subscriptions/%s/resourcegroups/%s/providers/Microsoft.Storage/storageAccounts/%s" $.Values.subscriptionId $.Values.teamResourceGroupName $storageAccountName }}
{{- end }}

{{/*
Storage account FullName in Azure
*/}}
{{- define "storageAccount.fullname" -}}
{{- $ := index . 0 }}
{{- $storageAccountName := index . 1 }}
{{- $requiredMsg := include "adp-aso-helm-library.default-check-required-msg" $ }}
{{- $storageAccountPrefix := (required (printf $requiredMsg "storageAccountPrefix") $.Values.storageAccountPrefix) }}
{{- if le (len $storageAccountName) 9 }}
{{- if $storageAccountPrefix }}
{{- (printf "%s%s" $storageAccountPrefix $storageAccountName) | lower }}
{{- else }}
{{- printf "this-condition-is-required-for-linting" }}
{{- end }}
{{- else }}
{{- fail (printf "The storage account name '%s' is longer than the permitted 9 characters." $storageAccountName) }}
{{- end }}

{{- end }}

{{/*
Storage account metadata FullName
*/}}
{{- define "storageAccount.metadata.fullname" -}}
{{- $ := index . 0 }}
{{- $storageAccountName := index . 1 }}
{{- $requiredMsg := include "adp-aso-helm-library.default-check-required-msg" $ }}
{{- $serviceName := (required (printf $requiredMsg "serviceName") $.Values.serviceName) }}
{{- if $serviceName }}
{{- (printf "%s-%s" $serviceName $storageAccountName) | lower }}
{{- else }}
{{- printf "this-condition-is-required-for-linting" }}
{{- end }}
{{- end }}


{{/*
default name for StorageAccountsBlobService, StorageAccountsTableService, StorageAccountsFileService, StorageAccountsQueueService
*/}}
{{- define "storageaccountsService.metadata.defaultName" -}}
{{- $ := index . 0 }}
{{- $storageAccountName := index . 1 }}
{{- $requiredMsg := include "adp-aso-helm-library.default-check-required-msg" $ }}
{{- $serviceName := (required (printf $requiredMsg "serviceName") $.Values.serviceName) }}
{{- if $serviceName }}
{{- (printf "%s-%s-default" $serviceName $storageAccountName) | lower }}
{{- else }}
{{- printf "this-condition-is-required-for-linting" }}
{{- end }}
{{- end }}

{{/*
Storage account blob service container metadata FullName
*/}}
{{- define "storageAccountsBlobServicesContainer.metadata.fullname" -}}
{{- $ := index . 0 }}
{{- $storageAccountName := index . 1 }}
{{- $containerName := index . 2 }}
{{- (printf "%s-%s" (include "storageaccountsService.metadata.defaultName" (list $ $storageAccountName)) $containerName) | lower }}
{{- end }}

{{/*
Storage account Table metadata FullName
*/}}
{{- define "storageAccountsTableServicesTable.metadata.fullname" -}}
{{- $ := index . 0 }}
{{- $storageAccountName := index . 1 }}
{{- $tableName := index . 2 }}
{{- (printf "%s-%s" (include "storageaccountsService.metadata.defaultName" (list $ $storageAccountName)) $tableName) | lower }}
{{- end }}

{{/*
Storage account file service share metadata FullName
*/}}
{{- define "storageAccountsFileServicesShare.metadata.fullname" -}}
{{- $ := index . 0 }}
{{- $storageAccountName := index . 1 }}
{{- $shareName := index . 2 }}
{{- (printf "%s-%s" (include "storageaccountsService.metadata.defaultName" (list $ $storageAccountName)) $shareName) | lower }}
{{- end }}

{{/*
PrivateEndpoint Name.
*/}}
{{- define "privateEndpoint.name" -}}
{{- $ := index . 0 }}
{{- $ncResource := index . 1 }}
{{- $subResource := index . 2 }}
{{- $requiredMsg := include "adp-aso-helm-library.default-check-required-msg" . }}
{{- $privateEndpointPrefix := (required (printf $requiredMsg "privateEndpointPrefix") $.Values.privateEndpointPrefix) }}
{{- if $privateEndpointPrefix }}
{{- (printf "%s-%s-%s" $privateEndpointPrefix $ncResource $subResource) | lower }}
{{- else }}
{{- printf "this-condition-is-required-for-linting" }}
{{- end }}
{{- end }}

{{/*
Get the Private DNS Zone Id.
*/}}
{{- define "privateDNSZone.resourceId" -}}
{{- $ := index . 0 }}
{{- $env := index . 1 }}
{{- $privateDnsZoneName := index . 2 }}
{{- $location := index . 3 }}
{{- $requiredMsg := include "adp-aso-helm-library.default-check-required-msg" . }}
{{- $azrMSTPrivateLinkDNSSubscriptionID := (required (printf $requiredMsg "azrMSTPrivateLinkDNSSubscriptionID") $.Values.azrMSTPrivateLinkDNSSubscriptionID) }}
{{- $azrMSTPrivateLinkDNSUKSouthResourceGroupName := (required (printf $requiredMsg "azrMSTPrivateLinkDNSUKSouthResourceGroupName") $.Values.azrMSTPrivateLinkDNSUKSouthResourceGroupName) }}
{{- $azrMSTPrivateLinkDNSUKWestResourceGroupName := (required (printf $requiredMsg "azrMSTPrivateLinkDNSUKWestResourceGroupName") $.Values.azrMSTPrivateLinkDNSUKWestResourceGroupName) }}
{{- if eq $location "uksouth" }}
{{- printf "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/privateDnsZones/%s" $azrMSTPrivateLinkDNSSubscriptionID $azrMSTPrivateLinkDNSUKSouthResourceGroupName $privateDnsZoneName }}
{{- else if eq $location "ukwest" }}
{{- printf "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/privateDnsZones/%s" $azrMSTPrivateLinkDNSSubscriptionID $azrMSTPrivateLinkDNSUKWestResourceGroupName $privateDnsZoneName }}
{{- else}}
{{- fail (printf "Value for location is not as expected. '%s' is not in the allowed location." $location) }}
{{- end }}
{{- end }}

{{/*
Get the A record Ip Address if custom resource 'PrivateDnsZonesARecord' exist in cluster
*/}}
{{- define "check.ipAddressFromExistingDnsACustomResource" -}}
{{- $customResourceDnsRecordAName := index . 0 }}
{{- if (lookup "network.azure.com/v1api20200601" "PrivateDnsZonesARecord" "flux-config" $customResourceDnsRecordAName) }}
{{- printf (index (lookup "network.azure.com/v1api20200601" "PrivateDnsZonesARecord" "flux-config" $customResourceDnsRecordAName).spec.aRecords 0).ipv4Address }}
{{- else }}
{{- printf "" }}
{{- end }} 
{{- end }}