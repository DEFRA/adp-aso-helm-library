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
namespace: <string>                       --namespace name
subscriptionId: <string>                  --subscription Id
serviceBusResourceGroupName: <string>     --Name of the service bus resource group
serviceBusNamespaceName: <string>         --Name of the environment specific service bus 
postgresResourceGroupName: <string>       --Name of the Postgres server resource group
postgresServerName: <string>              --Name of the environment specific postgres server
keyVaultResourceGroupName: <string>       --Name of the keyvault resource group
keyVaultName: <string>                    --Name of the environment specific keyVaultName
teamMIPrefix: <string>                    --Prefix used for ManageIdentity/UserAssignedIdentity resource name
serviceName: <string>                     --Service name. Suffix used for ManageIdentity/UserAssignedIdentity resource name
teamResourceGroupName: <string>           --Team ResourceGroup Name where team resources are created.

tags:
  Environment: <string>
  ServiceCode: <string>
  ServiceName: <string>
  ServiceType: <string> (Shared or Dedicated)
  kubernetes_cluster: <string>
  kubernetes_namespace: <string>
  kubernetes_label_ServiceCode: <string>

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

For e.g. TeamA wanted to create a queue called "claim" and add two role assignments, then the template would look like,

```
namespaceQueues:
  name: claim
  roleAssignments:  
    - roleName: QueueSender
    - roleName: QueueReceiver                    
```

If you are creating only role assignments for the queue you do not own, then you should explicitly set the `owner` flag to `no` so that it will only create the role assignments on the existing queue. 

For e.g. TeamB wanted to create one role assignments on TeamA's queue, then the template would look like,

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

For e.g. TeamA wanted to create a Topic called "calculator" and add two role assignments, then the template would look like,

```
namespaceTopics:
  name: calculator
  roleAssignments:  
    - roleName: TopicSender
    - roleName: TopicReceiver                    
```

If you are creating only role assignments for the Topic you do not own, then you should explicitly set the `owner` flag to `no` so that it will only create the role assignments on the existing Topic. 

For e.g. TeamB wanted to create one role assignments on TeamA's Topic, then the template would look like,

```
namespaceTopics:
  name: calculator
  owner: 'no'
  roleAssignments:  
    - roleName: TopicReceiver                   
```

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

For e.g. The below example will create one topic, one subscription, and two subscription rules.

```

namespaceTopics:
- name: demo-topic-01
  topicSubscriptions:
    - name: demo-topic-subscription-01
      topicSubscriptionRules:
        - name: demo-topic-subscription-rule-01
          filterType: SqlFilter
          sqlFilter:
            sqlExpression: "3=3"   
        - name: demo-topic-subscription-rule-02
          filterType: CorrelationFilter
          sqlFilter:
            contentType: "testvalue"             
                    
```
To create `topicSubscriptions` inside already existing topics, set the property `owner` to `no`. By default `owner` is set to `yes` which creates the topic name defined in values.

Below example creates only the topicSubscriptions inside the existing topic named demo-topic-01.

```
namespaceTopics:
- name: demo-topic-01
  owner: "no"
  topicSubscriptions:
    - name: demo-topic-subscription-01
```

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

Below are the minimum values that are required to be set in the parent chart's values.yaml to create a `userAssignedIdentity`, `roleAssignments` and `federatedCreds`.

```
userAssignedIdentity:     
    federatedCreds:                      <Array of Object> 
      - namespace: <string>                    
        serviceAccountName: <string>     

```

For e.g. The below example will create one userAssignedIdentity, two role assignments, and one federated credential.

```

userAssignedIdentity:
  federatedCreds: 
    - namespace: ffc-demo
      serviceAccountName: ffc-demo    
                    
```

### Storage
    In Progress


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

