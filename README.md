#  ADP Platform Azure Service Operator Helm Library Chart
A Helm chart library that captures general configuration for Azure Service Operator (ASO) resources. It can be used by any microservice Helm chart to import AzureServiceOperator K8s object templates configured to run on the ADP platform.


## Including the library chart

In your microservice Helm chart:
  * Update `Chart.yaml` to `apiVersion: v2`.
  * Add the library chart under `dependencies` and choose the version you want (example below). Version number can include `~` or `^` to pick up latest PATCH and MINOR versions respectively.
  * Issue the following commands to add the repo that contains the library chart, update the repo, then update dependencies in your Helm chart:

```
helm repo add adp https://raw.githubusercontent.com/defra/adp-helm-repository/main/adp-aso-helm-library
helm repo update
helm dependency update <helm_chart_location>
```

An example Demo microservice `Chart.yaml`:

```
apiVersion: v2
description: A Helm chart to deploy a microservice to the ADP Kubernetes platform
name: demo-microservice
version: 1.0.0
dependencies:
- name: adp-aso-helm-library
  version: ^1.0.0
  repository: https://raw.githubusercontent.com/defra/adp-helm-repository/main/adp-aso-helm-library
```

NOTE: We will use ACR where ASO Helm Library Chart can be published. So above dependencies will be changed to import library from ACR (In Progress).

## Using the K8s object templates

First, follow [the instructions](#including-the-library-chart) for including the ASO Helm library chart.

The ASO Helm library chart has been configured using the conventions described in the [Helm library chart documentation](https://helm.sh/docs/topics/library_charts/). The K8s object templates provide settings shared by all objects of that type, which can be augmented with extra settings from the parent (Demo microservice) chart. The library object templates will merge the library and parent templates. In the case where settings are defined in both the library and parent chart, the parent chart settings will take precedence, so library chart settings can be overridden. The library object templates will expect values to be set in the parent `.values.yaml`. Any required values (defined for each template below) that are not provided will result in an error message when processing the template (`helm install`, `helm upgrade`, `helm template`).

The general strategy for using one of the library templates in the parent microservice Helm chart is to create a template for the K8s object formateted as so:

```
{{- include "adp-aso-helm-library.namespace-queue" . -}}

```

### All template required values

All the K8s object templates in the library require the following values to be set in the parent microservice Helm chart's `values.yaml`:

```
namespace: <string>
```

### Environment specific Default values 

The below values are used by the ASO templates internally, and their values are set using `platform variables` in `adp-flux-services` repository.

for e.g. NameSpace Queues will get created inside `serviceBusNamespaceName` namespace and postgres database will get created inside `postgresServerName` server.

Whilst the Platform orchestration will manage the 'platform' level variables, they can be optionally supplied in some circumstances. Examples include in sandpit/development when testing against team-specific infrastructure (that isn't Platform shared). So, if you have a dedicated Service Bus or Database Server instance, you can point to those to ensure you apps works as expected. Otherwise, don't supply the Platform level variables as these will be automatically managed and orchestrated throughout all the environments appropriately against core shared infrastructure. You (as a Platform Tenant) just supply your team-specific/instance specific infrastructure config' (i.e. Queues, Storage Accounts, Databases).

```
namespace: <string>                                     --namespace name
environment: <string>                                   --environment name
fluxConfigNamespace: <string>                           --fluxConfig namespace name
subscriptionId: <string>                                --subscription Id
serviceBusResourceGroupName: <string>                   --Name of the service bus resource group
serviceBusNamespaceName: <string>                       --Name of the environment specific service bus 
postgresResourceGroupName: <string>                     --Name of the Postgres server resource group
postgresServerName: <string>                            --Name of the environment specific postgres server
keyVaultResourceGroupName: <string>                     --Name of the keyvault resource group
keyVaultName: <string>                                  --Name of the environment specific keyVaultName
teamMIPrefix: <string>                                  --The prefix used for the ManageIdentity/UserAssignedIdentity resource name
serviceName: <string>                                   --Service name. Suffix used for ManageIdentity/UserAssignedIdentity resource name
teamResourceGroupName: <string>                         --Team ResourceGroup Name where team resources are created
virtualNetworkResourceGroupName: <string>               --Virtual Network resource group
virtualNetworkName: <string>                            --Virtual Network name
storageAccountPrefix: <string>                          --The prefix used for the storage account resource name
privateEndpointSubnetName: <string>                     --The name of the subnet for the service's private endpoint
privateEndpointPrefix: <string>                         --The prefix used for the private endpoint resource name
azrMSTPrivateLinkDNSUKSouthResourceGroupName: <string>  --NOT USED. We need to discuss this further
azrMSTPrivateLinkDNSUKWestResourceGroupName: <string>   --NOT USED. We need to discuss this further
azrMSTPrivateLinkDNSSubscriptionID: <string>            --NOT USED. We need to discuss this further


commonTags:
  environment: <string>
  serviceCode: <string>
  serviceName: <string>
  serviceType: <string> (Shared or Dedicated)
  kubernetes_cluster: <string>
  kubernetes_namespace: <string>
  kubernetes_label_serviceCode: <string>

```

### NameSpace Queue

* Template file: `_namespace-queue.yaml`
* Template name: `adp-aso-helm-library.namespace-queue`

An ASO `NamespacesQueue` object to create a Microsoft.ServiceBus/namespaces/queues resource.

A basic usage of this object template would involve the creation of `templates/namespace-queue.yaml` in the parent Helm chart (e.g. `adp-microservice`) containing:

```
{{- include "adp-aso-helm-library.namespace-queue" . -}}

```

#### Required values

The following values need to be set in the parent chart's `values.yaml` in addition to the globally required values [listed above](#all-template-required-values).

Note that `namespaceQueues` is an array of objects that can be used to create more than one queue.

Please note that the queue name is prefixed with the `namespace` internally. 
For example, if the namespace name is "adp-demo" and you have provided the queue name as "queue1", then in the service bus, it creates a queue with the `adp-demo-queue1` name.

```
namespaceQueues:      
  - name: <string>     
  - name: <string>
```

#### Optional values

The following values can optionally be set in the parent chart's `values.yaml` to set the other properties for servicebus queues:

`owner` property is used to control the ownership of the queue. The default value is `yes` and you don't need to provide it if you are creating and owning the queue.
If you are creating only role assignments for the queue you do not own, then you should explicitly set the `owner` flag to `no` so that it will only create the role assignments on the existing queue.

```
namespaceQueues:
  - name: <string>
    owner: <string>                                    --Default yes    (Accepted values = yes, no)
    deadLetteringOnMessageExpiration: <bool>           --Default false
    defaultMessageTimeToLive: <string>                 --Default P14D
    duplicateDetectionHistoryTimeWindow: <string>      --Default PT10M
    enableBatchedOperations: <bool>                    --Default true
    enableExpress: <bool>                              --Default false
    enablePartitioning: <bool>                         --Default false
    lockDuration: <string>                             --Default PT1M
    maxDeliveryCount: <int>                            --Default 10
    maxMessageSizeInKilobytes: <int>                   --Default 1024
    maxSizeInMegabytes: <int>                          --Default 1024
    requiresDuplicateDetection: <bool>                 --Default false
    requiresSession: <bool>                            --Default false
    roleAssignments:
      - roleName: <string>                             --<RoleName. for e.g QueueSender>
```

#### NameSpace Queue: RoleAssignments

This template also optionally allows you to create `Role Assignments` by providing `roleAssignments` properties in the namespaceQueues object.

Below are the minimum values that are required to be set in the parent chart's values.yaml to create a `roleAssignments`.

```
namespaceQueues:      
  - name: <string>     
    roleAssignments:                                    <Array of Object> 
      - roleName: <string>                              <RoleName. for e.g QueueSender>  (Allowed values QueueSender', 'QueueReceiver')
      - roleName: <string> 
```

If you are creating only role assignments for the queue you do not own, then you should explicitly set the `owner` flag to `no` so that it will only create the role assignments on the existing queue. 

#### Usage examples
The following section provides usage examples for the Namespace Queues template.

##### Example 1 : ServiceA in TeamA creates queue with 2 role assignments

```
namespaceQueues:
  name: claim
  roleAssignments:  
    - roleName: QueueSender
    - roleName: QueueReceiver   
```

##### Example 2 : ServiceB in TeamA needs to receive messages from existing `claim` queue. Note that `owner` is set to `no`.

```
namespaceQueues:
  name: claim
  owner: 'no'
  roleAssignments:  
    - roleName: QueueReceiver     
```

### NameSpace Topic

* Template file: `_namespace-topic.yaml`
* Template name: `adp-aso-helm-library.namespace-topic`

An ASO `NamespacesTopic` object to create a Microsoft.ServiceBus/namespaces/topics resource.

A basic usage of this object template would involve the creation of `templates/namespace-topic.yaml` in the parent Helm chart (e.g. `adp-microservice`) containing:

```
{{- include "adp-aso-helm-library.namespace-topic" . -}}

```

#### Required values

The following values need to be set in the parent chart's `values.yaml` in addition to the globally required values [listed above](#all-template-required-values).

Note that `namespaceTopics` is an array of objects that can be used to create more than one topic.

Please note that the topic name is prefixed with the `namespace` internally. 
For example, if the namespace name is "adp-demo" and you have provided the topic name as "topic1," then in the service bus, it creates a topic with the "adp-demo-topic1" name.

```
namespaceTopics:          <Array of Object>
  - name: <string>     
  - name: <string>
```

#### Optional values

The following values can optionally be set in the parent chart's `values.yaml` to set the other properties for `namespaceTopics`:

`owner` property is used to control the ownership of the topic. The default value is `yes` and you don't need to provide it if you are creating and owning the topic.
If you are only creating role assignments for the topic you do not own, then you should explicitly set the `owner` flag to `no` so that it will only create the role assignments on the existing topic.

```
namespaceTopics:
  - name: <string>
    owner: <string>                                    --Default yes     (Accepted values = yes, no)
    defaultMessageTimeToLive: <string>                 --Default P14D
    duplicateDetectionHistoryTimeWindow: <string>      --Default PT10M
    enableBatchedOperations: <bool>                    --Default true
    enableExpress: <bool>                              --Default false
    enablePartitioning: <bool>                         --Default false
    maxMessageSizeInKilobytes: <int>                   --Default 1024
    maxSizeInMegabytes: <int>                          --Default 1024
    requiresDuplicateDetection: <bool>                 --Default false
    supportOrdering: <bool>                            --Default true
    roleAssignments:
      - roleName: <string>                             --<RoleName. for e.g TopicSender>
```

#### NameSpace Topic: RoleAssignments

This template also optionally allows you to create `Role Assignments` by providing `roleAssignments` properties in the namespaceTopics object.

Below are the minimum values that are required to be set in the parent chart's values.yaml to create a `roleAssignments`.

```
namespaceTopics:      
  - name: <string>     
    roleAssignments:                                    <Array of Object> 
      - roleName: <string>                              <RoleName. for e.g TopicSender>  (Allowed values TopicSender', 'TopicReceiver')
      - roleName: <string> 
```

If you are creating only role assignments for the Topic you do not own, then you should explicitly set the `owner` flag to `no` so that it will only create the role assignments on the existing Topic (See Example 2 in Usage examples section). 

#### NameSpace Topic: Subscriptions, SubscriptionRules

This template also optionally allows you to create `Topic Subscriptions` and `Topic Subscriptions Rules` for a given topic by providing Subscriptions and SubscriptionRules properties in the topic object.

Below are the minimum values that are required to be set in the parent chart's `values.yaml` to create a `NamespacesTopic`, `NamespacesTopicsSubscription` and `NamespacesTopicsSubscriptionsRule`

```
namespaceTopics:      
  - name: <string>     
    topicSubscriptions:                     <Array of Object>  refer "Optional values for `topicSubscriptions`" section for topicSubscriptions optional properties
      - name: <string>
        topicSubscriptionRules:             <Array of Object>  refer "Optional values for `topicSubscriptionRules`" section for topicSubscriptionRules properties
        - name: <string>                    
          filterType: <string>              Accepted values : 'CorrelationFilter' or 'SqlFilter'
          correlationFilter: <Object>       refer "Optional values for `topicSubscriptionRules`" section for correlationFilter properties
          sqlFilter: <Object>               refer "Optional values for `topicSubscriptionRules`" section for sqlFilter properties

```

To create `topicSubscriptions` inside already existing topics, set the property `owner` to `no`. By default `owner` is set to `yes` which creates the topic name defined in values (See Example 4 in Usage examples section).

#### Optional values for `topicSubscriptions`

The following values can optionally be set in the parent chart's `values.yaml` to set the other properties for `topicSubscriptions`:

```
topicSubscriptions:
  - name: <string>
    deadLetteringOnFilterEvaluationExceptions: <bool>       --Default false
    deadLetteringOnMessageExpiration: <bool>                --Default false
    defaultMessageTimeToLive: <string>                      --Default P14D
    duplicateDetectionHistoryTimeWindow: <string>           --Default P10M
    enableBatchedOperations: <bool>                         --Default true
    forwardTo: <string>                                                 
    isClientAffine: <bool>                                  --Default false
    lockDuration: <string>                                  --Default PT1M
    maxDeliveryCount: <int>                                 --Default 10
    requiresSession: <bool>                                 --Default false
```

#### Optional values for `topicSubscriptionRules`

The following values can optionally be set in the parent chart's `values.yaml` to set the other properties for `topicSubscriptionRules`:

```
topicSubscriptionRules:
  - name: <string>
    correlationFilter:
      contentType: <string>
      correlationId: <string>
      label: <string>
      messageId: <string>
      replyTo: <string>                                     
      replyToSessionId: <string>
      sessionId: <string> 
      to: <string> 
    sqlFilter:
      sqlExpression: <string>  
```

#### Usage examples
The following section provides usage examples for the Namespace Topic template.

##### Example 1 : ServiceA in TeamA creates Topic with 1 role assignment

```
namespaceTopics:
  name: claim-notify
  roleAssignments:  
    - roleName: TopicSender 
```

##### Example 2 : ServiceB in TeamA needs to receive messages from existing `claim-notify` Topic. Note that `owner` is set to `no`.

```
namespaceTopics:
  name: claim-notify
  owner: 'no'
  roleAssignments:  
    - roleName: TopicReceiver     
```

##### Example 3 : ServiceA in TeamA creates Topic with 1 role assignment, Topic Subscription and Topic Subscription Rule.

```
namespaceTopics:
  name: claim-notify
  roleAssignments:  
    - roleName: TopicSender 
  topicSubscriptions:
    - name: claim-notify-subscription-01
      topicSubscriptionRules:
        - name: claim-notify-subscription-rule-01
          filterType: SqlFilter
          sqlFilter:
            sqlExpression: "3=3"   
        - name: claim-notify-subscription-rule-02
          filterType: CorrelationFilter
          sqlFilter:
            contentType: "testvalue"      
```

##### Example 4: ServiceB in TeamA creates Topic Subscription in existing Topic.

```
namespaceTopics:
  name: claim-notify
  owner: "no"
  roleAssignments:  
    - roleName: TopicReceiver
  topicSubscriptions:
    - name: claim-notify-subscription-03   
```

### Database for Postgres Flexible server template

* Template file: `_flexible-servers-db.yaml`
* Template name: `adp-aso-helm-library.flexible-servers-db`

An ASO `FlexibleServersDatabase` object.

A basic usage of this object template would involve the creation of `templates/flexible-servers-db.yaml` in the parent Helm chart (e.g. `adp-microservice`) containing:

```
{{- include "adp-aso-helm-library.flexible-servers-db" (list . "adp-microservice.postgres-flexible-db") -}}
{{- define "adp-microservice.postgres-flexible-db" -}}
# Microservice specific configuration in here
{{- end -}}
```

#### Required values

The following values need to be set in the parent chart's `values.yaml` in addition to the globally required values [listed above](#all-template-required-values):
```
postgres:
  db:
    name: <string> 
    charset: <string>  
    collation: <string> 
```
Please note that the postgres DB name is prefixed with `namespace` internally. For example, if the namespace name is "adp-microservice" and you have provided the DB name as "demo-db," then in the postgres server, it creates a database with the name "adp-microservice-demo-db".

#### Usage examples
The following section provides usage examples for the Flexible-Servers-Db template.

##### Example 1 : ServiceA in TeamA creates `payment` database

```
postgres:
  db:
    name: payment 
    charset: UTF8
    collation: en_US.utf8
```

### UserAssignedIdentity

* Template file: `_userassignedidentity.yaml`
* Template name: `adp-aso-helm-library.userassignedidentity`

An ASO `UserAssignedIdentity` object to create a Microsoft.ManagedIdentity/userAssignedIdentities resource.

A basic usage of this object template would involve the creation of `templates/userassignedidentity.yaml` in the parent Helm chart (e.g. `adp-microservice`) containing:

```
{{- include "adp-aso-helm-library.userassignedidentity" . -}}

```

This template uses the below values, whose values are set using platform variables in the `adp-flux-services` repository as a part of the service's ASO helmrelease value configuration, and you don't need to set them explicitly in the values.yaml file.

- teamMIPrefix
- serviceName
- teamResourceGroupName
- clusterOIDCIssuerUrl


UserAssignedIdentity Name is derived internally, and it is set to = `{TEAM_MI_PREFIX}-{SERVICE_NAME}`

For e.g. In SND1 if the `TEAM_MI_PREFIX` value is set to "sndadpinfmid1401" and `SERVICE_NAME` value is set to "adp-demo-service", then `UserAssignedIdentity` value will be : "sndadpinfmid1401-adp-demo-service".

#### Optional values

The following values can optionally be set in the parent chart's `values.yaml` to set the other properties for servicebus queues:

```
userAssignedIdentity:      
  location: <string>

```

This template also optionally allows you to create `Federated credentials` for a given User Assigned Identity by providing `federatedCreds` properties in the userAssignedIdentity object.

Below are the minimum values that are required to be set in the parent chart's values.yaml to create a `userAssignedIdentity` and `federatedCreds`.

```
userAssignedIdentity:     
    federatedCreds:                      <Array of Object> 
      - namespace: <string>                    
        serviceAccountName: <string>     

```
#### Usage examples
The following section provides usage examples for the UserAssignedIdentity template.

##### Example 1 : The below example will create userAssignedIdentity with one federated credential.

```
userAssignedIdentity:
  federatedCreds: 
    - namespace: ffc-demo
      serviceAccountName: ffc-demo 
```


### Storage Account
* Template file: `_storage-account.yaml`
* Template name: `adp-aso-helm-library.storage-account.yaml`


> **Version 2.0.0 and above**
>
> Starting from version 2.0.1, the Storage Account has been enhanced with role assignments. These data role assignments are now scoped at the storage account level, introducing two new data roles: DataWriter and DataReader.
>
> The DataWriter role grants applications the ability to both read and write data in the blob container, tables, and files. Conversely, the DataReader role provides applications with read-only access to data in the blob container, tables, and files.


An ASO `StorageAccount` object to create a Microsoft.Storage/storageAccounts resource and optionally sub resources Blob Containers and Tables.

| :memo: By default, private endpoints are always enabled on storage accounts and `publicNetworkAccess` is disabled. Optionally, you can also configure `ipRules` in scenarios where you want to limit access to your storage account to requests originating from specified IP addresses. |
|:----------|

| :memo: Please be aware that this template only includes A records in the central DNS zone for the Dev, Tst, Pre, and Prd environments. For Sandpit environments snd1, snd2, and snd3, it currently only generates a private endpoint without adding an A record to the DNS zone. You will need to separately add this entry via PowerShell script. |
|:----------|

With this template, you can create the below resources.
  - Storage Accounts
  - Blob containers and RoleAssignments
  - Tables and RoleAssignments

A basic usage of this object template would involve the creation of `templates/storage-account.yaml` in the parent Helm chart (e.g. `adp-microservice`) containing:

```
{{- include "adp-aso-helm-library.storage-account" . -}}

```
#### Default values for Storage account

Below are the default values used by the the storage account template internally, and they cannot be overridden by the user from the `values.yaml` file.

```
kind: "StorageV2"             -- The type of storage account will always be "StorageV2"
dnsEndpointType: "Standard"   -- The type of endpoint
minimumTlsVersion: "TLS1_2"
allowBlobPublicAccess: "false"
sku: "Standard_LRS"           -- This is the sku for Sandpit environments (snd1, snd2, snd3)
sku: "Standard_RAGRS"         -- This is the sku for production environments (dev, test, pre, prd)
```

#### Required values (Only Storage Account)

The following values need to be set in the parent chart's `values.yaml` in addition to the globally required values [listed above](#all-template-required-values).

Note that `storageAccounts` is an array of objects that can be used to create more than one Storage Accounts.

Please note that the storage account name must be unique across Azure.
storage account name is internally prefixed with the `storageAccountPrefix`.  
For instance, in the Dev environment, the storageAccountPrefix is configured as `devadpinfst2401`. If you input "claim" as the storage account name, the final storage account name will be `devadpinfst2401claim`.

```
storageAccounts:          <Array of Object>
  - name: <string>        --Storage account name. Name should be Lowercase letters and numbers and Maximum character limit is `9`
  - name: <string>
```

#### Required values (Storage Account with BlobContainers, Tables and FileShare)

The following values need to be set in the parent chart's `values.yaml` in addition to the globally required values [listed above](#all-template-required-values).


```
Version 2.0.0 and above

storageAccounts:           <Array of Object>
  - name: <string>         --Storage account name. Name should be lowercase letters and numbers and Maximum character limit is `9`
    roleAssignments:
       roleName: <string>    --RoleAssignment Name (Accepted values = "DataWriter", "DataReader")
  - name: <string>
    blobContainers:
      - name: <string>            --Blob container name. Name should be lowercase and can contain only letters, numbers, and the hyphen/minus (-) character. Character limit: 3-63
      - name: <string>
    tables: 
      - name: <string>            --Table name. Name should be lowercase and may contain only alphanumeric characters. and Character limit: 3-63
      - name: <string>
    fileShares:
      - name: <string>            --File Share name. Name should be lowercase and may contain only alphanumeric characters. and Character limit: 3-63
      - name: <string>            --File Share name. Name should be lowercase and may contain only alphanumeric characters. and Character limit: 3-63
        accessTier: <string>      --Access Tier. Allowed values are TransactionOptimized, Hot, Cold. Default is TransactionOptimized
        shareQuota: <int>         --Storage Quota. Share Quota is defined in GiB. Default is 10
```

```
Version 1.0.* 

storageAccounts:           <Array of Object>
  - name: <string>         --Storage account name. Name should be lowercase letters and numbers and Maximum character limit is `9`
  - name: <string>
    blobContainers:
      - name: <string>            --Blob container name. Name should be lowercase and can contain only letters, numbers, and the hyphen/minus (-) character. Character limit: 3-63
        roleAssignments:
          - roleName: <string>    --RoleAssignment Name (Accepted values = "BlobDataContributor", "BlobDataReader")
      - name: <string>
        roleAssignments:
          - roleName: <string>
    tables: 
      - name: <string>            --Table name. Name should be lowercase and may contain only alphanumeric characters. and Character limit: 3-63
        roleAssignments:
          - roleName: <string>    --RoleAssignment Name (Accepted values = "TableDataContributor", "TableDataReader")
      - name: <string>
        roleAssignments:
          - roleName: <string>
    fileShares:
      - name: <string>            --File Share name. Name should be lowercase and may contain only alphanumeric characters. and Character limit: 3-63
      - name: <string>            --File Share name. Name should be lowercase and may contain only alphanumeric characters. and Character limit: 3-63
        accessTier: <string>      --Access Tier. Allowed values are TransactionOptimized, Hot, Cold. Default is TransactionOptimized
        shareQuota: <int>         --Storage Quota. Share Quota is defined in GiB. Default is 10
```

#### Optional values

The following values can optionally be set in the parent chart's `values.yaml` to set the other properties for `storageAccounts`:

For detailed description of each property [see here](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep)

`owner` property is used to control the ownership of the storage account. The default value is `yes` and you don't need to provide it if you are creating and owning the storage account.
If you are creating Blob containers or Tables on the existing storage account that you do not own, then you should explicitly set the `owner` flag to `no` so that it will only create Blob containers or Tables on the existing storage account.

```
storageAccounts:
  - name: <string>
    owner: <string>                                     --Default "yes"     (Accepted values = "yes", "no")
    location: <string>                                  --Default "uksouth"
    accessTier: <string>                                --Default "Hot"     (Accepted values = "Hot", "Cool")
    allowCrossTenantReplication: <bool>                 --Default false
    allowSharedKeyAccess: <bool>                        --Default false
    defaultToOAuthAuthentication: <string>              --Default true    (Accepted values = "true", "false")
    networkAcls:
      ipRules: <array>                                    --Storage Firewall: Sets the IP ACL rules
    storageAccountsBlobService:                         --Confugure properties for the blob service
      changeFeed:                                         --The blob service properties for change feed events
        enabled: <bool>                                       --Default false
        retentionInDays: <int>                                --Applies when changeFeed.enabled is set to true
      containerDeleteRetentionPolicy:                     --The blob service properties for container soft delete
        enabled: <bool>                                       --Default true  
        days: <int>                                           --Applies when containerDeleteRetentionPolicy.enabled is set to true. Default is 7 days       
      deleteRetentionPolicy:                              --The blob service properties for blob soft delete
        enabled: <bool>                                       --Default true                          
        days: <int>                                           --Applies when deleteRetentionPolicy.enabled is set to true. Default is 7 days
        allowPermanentDelete: <bool>                          --Default false 
      isVersioningEnabled: <bool>                         --Default false. Versioning is enabled if set to true
      restorePolicy:                                      --The blob service properties for blob restore policy 
        enabled: <bool>                                       --Default false
        days: <int>                                           --Applies when restorePolicy.enabled is set to true
    storageAccountsFileService:                         --Confugure properties for the blob service
      deleteRetentionPolicy:                              --The blob service properties for blob soft delete
        enabled: <bool>                                       --Default true                          
        days: <int>                                           --Applies when deleteRetentionPolicy.enabled is set to true. Default is 7 days
    blobContainers:                                       --List of Blob containers and roleassignments
      - name: <string>                                        --Blob container name
        roleAssignments:                                      --List of roleAssignments scope to the blob container
          - roleName: <string>                                --RoleAssignment Name (Accepted values = "BlobDataContributor", "BlobDataReader")    
    tables:                                               --List of Tables and roleassignments
      - name: <string>                                        --Table name
        roleAssignments:                                      --List of roleAssignments scope to the table
          - roleName: <string>                                --RoleAssignment Name (Accepted values = "TableDataContributor", "TableDataReader")
```
#### Usage examples
The following section provides usage examples for the storage account template.

##### Example 1 : Create 2 storage accounts

```
storageAccounts:
  - name: storage01
  - name: storage02

```

##### Example 2 : Create 1 storage account using large parameter set and storage firewall

```
storageAccounts:
  - name: storage01
    accessTier: Hot
    location: uksouth
    allowCrossTenantReplication: false
    allowSharedKeyAccess: true
    defaultToOAuthAuthentication: "false"
    networkAcls:
      ipRules:
      - 82.13.86.001
      - 82.13.86.002
```

##### Example 3 : Create 1 storage account and configure properties for the Storage Account BlobService

```
storageAccounts:
  - name: storage01
    storageAccountsBlobService:
      changeFeed:
        enabled: true
        retentionInDays: 14
      containerDeleteRetentionPolicy:
        days: 14
        enabled: true
      deleteRetentionPolicy:
        allowPermanentDelete: true
        days: 20
        enabled: false
      isVersioningEnabled: true
      restorePolicy:
        enabled: true
        days: 40

```

##### Example 4 : Create 1 storage account with 2 blob containers and 1 table with roleassignments (Version 1.0.*)

```
storageAccounts:
  - name: storage01
    blobContainers:  
      - name: container-01
        roleAssignments:
          - roleName: 'BlobDataContributor' 
      - name: container-02
        roleAssignments:
          - roleName: 'BlobDataReader'   
    tables:  
      - name: table01  
        roleAssignments:
          - roleName: 'TableDataContributor' 

```

##### Example 5 : Create 1 blob containers and 2 tables for the existing storage account in your team.

```
storageAccounts:
  - name: storage01
    owner: "No"               --Note owner is set to 'No' to indicate storage account already exists and is owned by a different service in the team
    blobContainers:  
      - name: container-01
    tables:  
      - name: table01  
      - name: table02

```
##### Example 6 : Create 1 storage account and configure properties for the Storage Account FileService

```
storageAccounts:
  - name: storage01
    storageAccountsFileService:
      deleteRetentionPolicy:
        enabled: true
        days: 20
```
##### Example 7 : Create 2 file share, one with default properties other one with specific properties

```
storageAccounts:
  - name: storage01
    owner: "No"               --Note owner is set to 'No' to indicate storage account already exists and is owned by a different service in the team
    fileShares:
      - name: share-01
      - name: share-02
        accessTier: Hot
        shareQuota: 50
```

##### Example 8 : Create 1 storage account with 2 blob containers and roleassignments scoped to storage account  (Version 2.0.*)

```
storageAccounts:
  - name: storage01
    roleAssignments:
      - roleName: 'DataWriter'
    blobContainers:  
      - name: container-01
      - name: container-02

```

##### Example 9 : Create roleassignments for existing storage account in the team  (Version 2.0.*)

```
storageAccounts:
  - name: storage01
    owner: 'no'
    roleAssignments:
      - roleName: 'DataReader'
```

### **Reference Table for Resource Names in Azure and Kubernetes**

The table below shows the Azure Service Operator (ASO) resource naming convention in Azure and Kubernetes: 

In the example below, the following platform values are used for demonstration purposes: 
- namespace = 'ffc-demo'
- serviceName = 'ffc-demo-web'
- teamMIPrefix = 'sndadpinfmi1401'
- storageAccountPrefix = 'sndadpinfst1401'
- privateEndpointPrefix = 'sndadpinfpe1401'
- postgresServerName = 'sndadpdbsps1401'
- userassignedidentityName = 'sndadpinfmi1401-ffc-demo-web'

And the following user input values are used for demonstration purposes: 

- QueueName = 'queue01'
- TopicName = 'topic01'
- TopicSubName = 'topicSub01'
- DatabaseName = 'claim'
- StorageAccountName = 'demo'

| Resource Type | Resource Name Format in `Azure` | Resource Name Example in `Azure` | Resource Name Format in `Kubernetes` | Resource Name Example in `Kubernetes`
| -------- | ------------------ | -------- | ------------------ |------------------ |
| NamespacesQueue | {namespace}-{QueueName} | ffc-demo-queue01 |	{namespace}-{QueueName} | ffc-demo-queue01 |
| Queue RoleAssignment | NA | NA |	{userassignedidentityName}-{QueueName}-{RoleName}-rbac-{index} | sndadpinfmi1401-ffc-demo-web-ffc-demo-queue01-queuereceiver-rbac-0 |
| NamespacesTopic | {namespace}-{TopicName} | ffc-demo-topic01 |	{namespace}-{TopicName} | ffc-demo-topic01 |
| NamespacesTopicsSubscription | {namespace}-{TopicSubName} | ffc-demo-topicSub01 |	{namespace}-{TopicName}-{TopicSubName}-subscription | ffc-demo-topic01-topicsub01-subscription |
| Topic RoleAssignment | NA | NA |	{userassignedidentityName}-{TopicName}-{RoleName}-rbac-{index} | sndadpinfmi1401-ffc-demo-web-ffc-demo-topic01-topicreceiver-rbac-0 |
| Postgres Database | {namespace}-{DatabaseName} | ffc-demo-claim | {postgresServerName}-{namespace}-{DatabaseName} | sndadpdbsps1401-ffc-demo-claim |
| Manage Idenitty | {teamMIPrefix}-{serviceName} | sndadpinfmi1401-ffc-demo-web |	{teamMIPrefix}-{serviceName} | sndadpinfmi1401-ffc-demo-web |
| StorageAccount | {storageAccountPrefix}{StorageAccountName} | sndadpinfst1401demo |	{serviceName}-{StorageAccountName} | ffc-demo-web-sndadpinfst1401demo |
| StorageAccountsBlobService | default | default |	{serviceName}-{StorageAccountName}-default | ffc-demo-web-sndadpinfst1401demo-default |
| StorageAccountsBlobServicesContainer | {ContainerName} | container-01 |	{serviceName}-{StorageAccountName}-default-{ContainerName} | ffc-demo-web-sndadpinfst1401demo-default-container-01 |
| StorageAccountsTableServicesTable | {TableName} | table01 |	{serviceName}-{StorageAccountName}-default-{TableName} | ffc-demo-web-sndadpinfst1401demo-default-table01 |
| PrivateEndpoint | {privateEndpointPrefix}-{ResourceName}-{SubResource} | sndadpinfpe1401-sndadpinfst1401demo-blob | {privateEndpointPrefix}-{ResourceName}-{SubResource} | sndadpinfpe1401-sndadpinfst1401demo-blob |
| PrivateEndpointsPrivateDnsZoneGroup | default | default |	{PrivateEndpointName}-default | sndadpinfpe1401-sndadpinfst1401demo-blob-default |

## Helper templates

In addition to the K8s object templates described above, a number of helper templates are defined in `_helpers.tpl` that are both used within the library chart and available to use within a consuming parent chart.

### Default check required message

* Template name: `adp-aso-helm-library.default-check-required-msg`
* Usage: `{{- include "adp-aso-helm-library.default-check-required-msg" . }}`

A template defining the default message to print when checking for a required value within the library. This is not designed to be used outside of the library.

### Tags

* Template name: `adp-aso-helm-library.commonTags`
* Usage: `{{- include "adp-aso-helm-library.commonTags" $ | nindent 4 }}` (`$` is mapped to the root scope)

Common tags to apply to `tags` of all ASO resource objects on the ADP K8s platform. This template relies on the globally required values [listed above](#environment-specific-default-values).

### Labels 
    In Progress.

### Annotations 

For the Azure Service Operator to not delete the resources created in Azure on the deletion of the kubernetes resource manifest files, the below section can be added to `Values.yaml` in the parent helm chart. 

This specifies the reconcile policy to be used and can be set to `manage`, `skip` or `detach-on-delete`. More info over [here](https://azure.github.io/azure-service-operator/guide/annotations/).

```
asoAnnotations:
  serviceoperator.azure.com/reconcile-policy: detach-on-delete
```

## Licence

THIS INFORMATION IS LICENSED UNDER THE CONDITIONS OF THE OPEN GOVERNMENT LICENCE found at:

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

The following attribution statement MUST be cited in your products and applications when using this information.

>Contains public sector information licensed under the Open Government license v3

### About the licence

The Open Government Licence (OGL) was developed by the Controller of Her Majesty's Stationery Office (HMSO) to enable information providers in the public sector to license the use and re-use of their information under a common open licence.

It is designed to encourage use and re-use of information freely and flexibly, with only a few conditions.

