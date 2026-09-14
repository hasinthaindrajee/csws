import ballerina/ai;
import ballerinax/ai.openai;

// Imports the order status MCP tools so the agent can call them.
// Connects at startup: the MCP service must be running or init fails.
final ai:McpToolKit orderStatusToolKit = check new (
    serverUrl = mcpServiceUrl,
    permittedTools = ["getOrderDetails", "listOrders"],
    info = {name: "OrderAgentMcpClient", version: "1.0.0"}
);

// LLM used by the agent. Route through the AI Gateway by setting openAiServiceUrl.
final openai:ModelProvider openAiModelProvider = check new (
    apiKey = openAiApiKey,
    modelType = openAiModel,
    serviceUrl = openAiServiceUrl
);
