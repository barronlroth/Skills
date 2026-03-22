### list_apps
Lists apps in the given project and location.
Read-only: yes
Parameters:
    filter (optional): Optional. Filter to be applied when listing the apps. See https://google.aip.dev
    orderBy (optional): Optional. Field to sort by. Only "name" and "create_time" is supported. See http
    pageSize (optional): Optional. Requested page size. Server may return fewer items than requested. If 
    pageToken (optional): Optional. The next_page_token value returned from a previous list AgentService.L
    parent (required): Required. The resource name of the location to list apps from.

### get_app
Gets details of the specified app.
Read-only: yes
Parameters:
    name (required): Required. The resource name of the app to retrieve.

### create_app
Creates a new app in the given project and location.
Destructive: yes
Parameters:
    app (required): Required. The app to create.
    appId (optional): Optional. The ID to use for the app, which will become the final component of th
    parent (required): Required. The resource name of the location to create an app in.

### update_app
Updates the specified app.
Destructive: yes
Parameters:
    app (required): Required. The app to update.
    updateMask (optional): Optional. Field mask is used to control which fields get updated. If the mask is

### delete_app
Deletes the specified app.
Destructive: yes
Parameters:
    etag (optional): Optional. The current etag of the app. If an etag is not provided, the deletion 
    name (required): Required. The resource name of the app to delete.

### list_agents
Lists agents in the given app.
Read-only: yes
Parameters:
    filter (optional): Optional. Filter to be applied when listing the agents. See https://google.aip.d
    orderBy (optional): Optional. Field to sort by. Only "name" and "create_time" is supported. See http
    pageSize (optional): Optional. Requested page size. Server may return fewer items than requested. If 
    pageToken (optional): Optional. The next_page_token value returned from a previous list AgentService.L
    parent (required): Required. The resource name of the app to list agents from.

### get_agent
Gets details of the specified agent.
Read-only: yes
Parameters:
    name (required): Required. The resource name of the agent to retrieve.

### create_agent
Creates a new agent in the given app.
Destructive: yes
Parameters:
    agent (required): Required. The agent to create.
    agentId (optional): Optional. The ID to use for the agent, which will become the final component of 
    parent (required): Required. The resource name of the app to create an agent in.

### update_agent
Updates the specified agent.
Destructive: yes
Parameters:
    agent (required): Required. The agent to update.
    updateMask (optional): Optional. Field mask is used to control which fields get updated. If the mask is

### delete_agent
Deletes the specified agent.
Destructive: yes
Parameters:
    etag (optional): Optional. The current etag of the agent. If an etag is not provided, the deletio
    force (optional): Optional. Indicates whether to forcefully delete the agent, even if it is still 
    name (required): Required. The resource name of the agent to delete.

### list_examples
Lists examples in the given app.
Read-only: yes
Parameters:
    filter (optional): Optional. Filter to be applied when listing the examples. See https://google.aip
    orderBy (optional): Optional. Field to sort by. Only "name" and "create_time" is supported. See http
    pageSize (optional): Optional. Requested page size. Server may return fewer items than requested. If 
    pageToken (optional): Optional. The next_page_token value returned from a previous list AgentService.L
    parent (required): Required. The resource name of the app to list examples from.

### get_example
Gets details of the specified example.
Read-only: yes
Parameters:
    name (required): Required. The resource name of the example to retrieve.

### create_example
Creates a new example in the given app.
Destructive: yes
Parameters:
    example (required): Required. The example to create.
    exampleId (optional): Optional. The ID to use for the example, which will become the final component o
    parent (required): Required. The resource name of the app to create an example in.

### update_example
Updates the specified example.
Destructive: yes
Parameters:
    example (required): Required. The example to update.
    updateMask (optional): Optional. Field mask is used to control which fields get updated. If the mask is

### delete_example
Deletes the specified example.
Destructive: yes
Parameters:
    etag (optional): Optional. The current etag of the example. If an etag is not provided, the delet
    name (required): Required. The resource name of the example to delete.

### list_tools
Lists tools in the given app.
Read-only: yes
Parameters:
    filter (optional): Optional. Filter to be applied when listing the tools. Use "include_system_tools
    orderBy (optional): Optional. Field to sort by. Only "name" and "create_time" is supported. See http
    pageSize (optional): Optional. Requested page size. Server may return fewer items than requested. If 
    pageToken (optional): Optional. The next_page_token value returned from a previous list AgentService.L
    parent (required): Required. The resource name of the app to list tools from.

### get_tool
Gets details of the specified tool.
Read-only: yes
Parameters:
    name (required): Required. The resource name of the tool to retrieve.

### create_tool
Creates a new tool in the given app.
Destructive: yes
Parameters:
    parent (required): Required. The resource name of the app to create a tool in.
    tool (required): Required. The tool to create.
    toolId (optional): Optional. The ID to use for the tool, which will become the final component of t

### update_tool
Updates the specified tool.
Destructive: yes
Parameters:
    tool (required): Required. The tool to update.
    updateMask (optional): Optional. Field mask is used to control which fields get updated. If the mask is

### delete_tool
Deletes the specified tool.
Destructive: yes
Parameters:
    etag (optional): Optional. The current etag of the tool. If an etag is not provided, the deletion
    force (optional): Optional. Indicates whether to forcefully delete the tool, even if it is still r
    name (required): Required. The resource name of the tool to delete.

### list_guardrails
Lists guardrails in the given app.
Read-only: yes
Parameters:
    filter (optional): Optional. Filter to be applied when listing the guardrails. See https://google.a
    orderBy (optional): Optional. Field to sort by. Only "name" and "create_time" is supported. See http
    pageSize (optional): Optional. Requested page size. Server may return fewer items than requested. If 
    pageToken (optional): Optional. The next_page_token value returned from a previous list AgentService.L
    parent (required): Required. The resource name of the app to list guardrails from.

### get_guardrail
Gets details of the specified guardrail.
Read-only: yes
Parameters:
    name (required): Required. The resource name of the guardrail to retrieve.

### create_guardrail
Creates a new guardrail in the given app.
Destructive: yes
Parameters:
    guardrail (required): Required. The guardrail to create.
    guardrailId (optional): Optional. The ID to use for the guardrail, which will become the final component
    parent (required): Required. The resource name of the app to create a guardrail in.

### update_guardrail
Updates the specified guardrail.
Destructive: yes
Parameters:
    guardrail (required): Required. The guardrail to update.
    updateMask (optional): Optional. Field mask is used to control which fields get updated. If the mask is

### delete_guardrail
Deletes the specified guardrail.
Destructive: yes
Parameters:
    etag (optional): Optional. The current etag of the guardrail. If an etag is not provided, the del
    force (optional): Optional. Indicates whether to forcefully delete the guardrail, even if it is st
    name (required): Required. The resource name of the guardrail to delete.

### list_deployments
Lists deployments in the given app.
Read-only: yes
Parameters:
    orderBy (optional): Optional. Field to sort by. Only "name" and "create_time" is supported. See http
    pageSize (optional): Optional. The maximum number of deployments to return. The service may return fe
    pageToken (optional): Optional. A page token, received from a previous `ListDeployments` call. Provide
    parent (required): Required. The parent app. Format: `projects/{project}/locations/{location}/apps/

### get_deployment
Gets details of the specified deployment.
Read-only: yes
Parameters:
    name (required): Required. The name of the deployment. Format: `projects/{project}/locations/{loc

### create_deployment
Creates a new deployment in the given app.
Destructive: yes
Parameters:
    deployment (required): Required. The deployment to create.
    deploymentId (optional): Optional. The ID to use for the deployment, which will become the final componen
    parent (required): Required. The parent app. Format: `projects/{project}/locations/{location}/apps/

### update_deployment
Updates the specified deployment.
Destructive: yes
Parameters:
    deployment (required): Required. The deployment to update.
    updateMask (optional): Optional. The list of fields to update.

### delete_deployment
Deletes the specified deployment.
Destructive: yes
Parameters:
    etag (optional): Optional. The etag of the deployment. If an etag is provided and does not match 
    name (required): Required. The name of the deployment to delete. Format: `projects/{project}/loca

### list_toolsets
Lists toolsets in the given app.
Read-only: yes
Parameters:
    filter (optional): Optional. Filter to be applied when listing the toolsets. See https://google.aip
    orderBy (optional): Optional. Field to sort by. Only "name" and "create_time" is supported. See http
    pageSize (optional): Optional. Requested page size. Server may return fewer items than requested. If 
    pageToken (optional): Optional. The next_page_token value returned from a previous list AgentService.L
    parent (required): Required. The resource name of the app to list toolsets from.

### get_toolset
Gets details of the specified toolset.
Read-only: yes
Parameters:
    name (required): Required. The resource name of the toolset to retrieve.

### create_toolset
Creates a new toolset in the given app.
Destructive: yes
Parameters:
    parent (required): Required. The resource name of the app to create a toolset in.
    toolset (required): Required. The toolset to create.
    toolsetId (optional): Optional. The ID to use for the toolset, which will become the final component o

### update_toolset
Updates the specified toolset.
Destructive: yes
Parameters:
    toolset (required): Required. The toolset to update.
    updateMask (optional): Optional. Field mask is used to control which fields get updated. If the mask is

### delete_toolset
Deletes the specified toolset.
Destructive: yes
Parameters:
    etag (optional): Optional. The current etag of the toolset. If an etag is not provided, the delet
    force (optional): Optional. Indicates whether to forcefully delete the toolset, even if it is stil
    name (required): Required. The resource name of the toolset to delete.

### list_app_versions
Lists all app versions in the given app.
Read-only: yes
Parameters:
    filter (optional): Optional. Filter to be applied when listing the app versions. See https://google
    orderBy (optional): Optional. Field to sort by. Only "name" and "create_time" is supported. See http
    pageSize (optional): Optional. Requested page size. Server may return fewer items than requested. If 
    pageToken (optional): Optional. The next_page_token value returned from a previous list AgentService.L
    parent (required): Required. The resource name of the app to list app versions from.

### get_app_version
Gets details of the specified app version.
Read-only: yes
Parameters:
    name (required): Required. The resource name of the app version to retrieve.

### create_app_version
Creates a new app version in the given app.
Destructive: yes
Parameters:
    appVersion (required): Required. The app version to create.
    appVersionId (optional): Optional. The ID to use for the app version, which will become the final compone
    parent (required): Required. The resource name of the app to create an app version in.

### delete_app_version
Deletes the specified app version.
Destructive: yes
Parameters:
    etag (optional): Optional. The current etag of the app version. If an etag is not provided, the d
    name (required): Required. The resource name of the app version to delete.

### restore_app_version
Restores the specified app version.
Destructive: yes
Parameters:
    name (required): Required. The resource name of the app version to restore.

### list_changelogs
Lists changelogs in the given app.
Read-only: yes
Parameters:
    filter (optional): Optional. Filter to be applied when listing the changelogs. See https://google.a
    orderBy (optional): Optional. Field to sort by. Only "name" and "create_time" is supported. See http
    pageSize (optional): Optional. Requested page size. Server may return fewer items than requested. If 
    pageToken (optional): Optional. The next_page_token value returned from a previous list AgentService.L
    parent (required): Required. The resource name of the app to list changelogs from.

### get_changelog
Gets details of the specified changelog.
Read-only: yes
Parameters:
    name (required): Required. The resource name of the changelog to retrieve.

### start_export_app
Starts to export a CES app
Parameters:
    appId (optional): The app id of the app to export.
    locationId (optional): The location id of the app to export.
    projectId (optional): The project id of the app to export.

### start_import_app
Starts to import a CES app
Destructive: yes
Parameters:
    appId (optional): The app id of the app to import.
    content (optional): The bytes of the zip file of the compressed app import, which is a folder contai
    locationId (optional): The location id of the app to import.
    projectId (optional): The project id of the app to import.

### run_evaluation
Runs an evaluation for a CES app
Parameters:
    app (optional): The resource name of the app to run the evaluation for. Format: projects/{projec
    appVersion (optional): The app version to use for the evaluation run.
    displayName (optional): The display name of the evaluation run.
    evaluationDataset (optional): The evaluation dataset id to use for the run.
    evaluations (optional): The list of evaluation ids to run.

### create_evaluation
Creates a new evaluation.
Parameters:
    evaluation (required): Required. The evaluation to create.
    evaluationId (optional): Optional. The ID to use for the evaluation, which will become the final componen
    parent (required): Required. The app to create the evaluation for. Format: `projects/{project}/loca

### create_evaluation_dataset
Creates a new evaluation dataset.
Parameters:
    evaluationDataset (required): Required. The evaluation dataset to create.
    evaluationDatasetId (optional): Optional. The ID to use for the evaluation dataset, which will become the final 
    parent (required): Required. The app to create the evaluation for. Format: `projects/{project}/loca

### delete_evaluation
Deletes the specified evaluation.
Destructive: yes
Parameters:
    etag (optional): Optional. The current etag of the evaluation. If an etag is not provided, the de
    force (optional): Optional. Indicates whether to forcefully delete the evaluation, even if it is s
    name (required): Required. The resource name of the evaluation to delete.

### delete_evaluation_dataset
Deletes the specified evaluation dataset.
Destructive: yes
Parameters:
    etag (optional): Optional. The current etag of the evaluation dataset. If an etag is not provided
    name (required): Required. The resource name of the evaluation dataset to delete.

### generate_evaluation_from_conversation
Generates an evaluation from a conversation.
Parameters:
    conversation (required): Required. The conversation to create the golden evaluation for. Format: `project
    source (optional): Optional. Indicate the source of the conversation. If not set, all sources will 

### get_evaluation
Gets details of the specified evaluation.
Read-only: yes
Parameters:
    name (required): Required. The resource name of the evaluation to retrieve.

### get_evaluation_dataset
Gets details of the specified evaluation dataset.
Read-only: yes
Parameters:
    name (required): Required. The resource name of the evaluation dataset to retrieve.

### get_evaluation_result
Gets details of the specified evaluation result.
Read-only: yes
Parameters:
    name (required): Required. The resource name of the evaluation result to retrieve.

### get_evaluation_run
Gets details of the specified evaluation run.
Read-only: yes
Parameters:
    name (required): Required. The resource name of the evaluation run to retrieve.

### list_evaluation_datasets
Lists evaluation datasets.
Read-only: yes
Parameters:
    filter (optional): Optional. Filter to be applied when listing the evaluation datasets. See https:/
    orderBy (optional): Optional. Field to sort by. Only "name" and "create_time", and "update_time" are
    pageSize (optional): Optional. Requested page size. Server may return fewer items than requested. If 
    pageToken (optional): Optional. The next_page_token value returned from a previous list EvaluationServ
    parent (required): Required. The resource name of the app to list evaluation datasets from.

### list_evaluation_results
Lists evaluation results.
Read-only: yes
Parameters:
    filter (optional): Optional. Filter to be applied when listing the evaluation results. See https://
    orderBy (optional): Optional. Field to sort by. Only "name" and "create_time", and "update_time" are
    pageSize (optional): Optional. Requested page size. Server may return fewer items than requested. If 
    pageToken (optional): Optional. The next_page_token value returned from a previous list EvaluationServ
    parent (required): Required. The resource name of the evaluation to list evaluation results from. T

### list_evaluation_runs
Lists evaluation runs.
Read-only: yes
Parameters:
    filter (optional): Optional. Filter to be applied when listing the evaluation runs. See https://goo
    orderBy (optional): Optional. Field to sort by. Only "name" and "create_time", and "update_time" are
    pageSize (optional): Optional. Requested page size. Server may return fewer items than requested. If 
    pageToken (optional): Optional. The next_page_token value returned from a previous list EvaluationServ
    parent (required): Required. The resource name of the app to list evaluation runs from.

### list_evaluations
Lists evaluations.
Read-only: yes
Parameters:
    filter (optional): Optional. Filter to be applied when listing the evaluations. See https://google.
    lastTenResults (optional): Optional. Whether to include the last 10 evaluation results for each evaluation 
    orderBy (optional): Optional. Field to sort by. Only "name" and "create_time", and "update_time" are
    pageSize (optional): Optional. Requested page size. Server may return fewer items than requested. If 
    pageToken (optional): Optional. The next_page_token value returned from a previous list EvaluationServ
    parent (required): Required. The resource name of the app to list evaluations from.

### update_evaluation
Updates the specified evaluation.
Parameters:
    evaluation (required): Required. The evaluation to update.
    updateMask (optional): Optional. Field mask is used to control which fields get updated. If the mask is

### update_evaluation_dataset
Updates the specified evaluation dataset.
Parameters:
    evaluationDataset (required): Required. The evaluation dataset to update.
    updateMask (optional): Optional. Field mask is used to control which fields get updated. If the mask is

### delete_evaluation_result
Deletes the specified evaluation result.
Destructive: yes
Parameters:
    name (required): Required. The resource name of the evaluation result to delete.

### delete_evaluation_run
Deletes the specified evaluation run.
Destructive: yes
Parameters:
    name (required): Required. The resource name of the evaluation run to delete.

### get_conversation
Gets details of the specified conversation.
Read-only: yes
Parameters:
    name (required): Required. The resource name of the conversation to retrieve.
    source (optional): Optional. Indicate the source of the conversation. If not set, all source will b

### list_conversations
Lists conversations.
Read-only: yes
Parameters:
    filter (optional): Optional. Filter to be applied when listing the conversations. See https://googl
    pageSize (optional): Optional. Requested page size. Server may return fewer items than requested. If 
    pageToken (optional): Optional. The next_page_token value returned from a previous list AgentService.L
    parent (required): Required. The resource name of the app to list conversations from.
    source (optional): Optional. Indicate the source of the conversation. If not set, Source.Live will 
    sources (optional): Optional. Indicate the sources of the conversations. If not set, all available s

### get_operation
Gets the status of a long-running operation.

***Usage***
Some tools (for example, `run_evaluation`) return a long-running operation.
You can use this tool to get the status of the operation. It can be called repeatedly to
poll the status of a long running operation

**Parameters**
*   `name`: The name of the operation to get.
    * `name` should be the name returned by the tool that initiated the operation.
    * `name` should be in the format of `projects/{project}/locations/{location}/operations/{operation}`.

Read-only: yes
Parameters:
    name (optional): The name of the operation resource.

