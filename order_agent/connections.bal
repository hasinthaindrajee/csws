import ballerina/ai;
import ballerina/http;
import ballerinax/ai.openai;

// MCP toolkit that authenticates every call to the order status MCP service
// using the pre-configured bearer token.
final ai:McpToolKit orderStatusToolKit = check new (
    serverUrl = mcpServiceUrl,
    permittedTools = ["getOrderDetails", "listOrders"],
    info = {name: "OrderAgentMcpClient", version: "1.0.0"},
    auth = <http:BearerTokenConfig>{token: mcpAccessToken}
);

// LLM used by the agent. Route through the AI Gateway by setting openAiServiceUrl.
final openai:ModelProvider openAiModelProvider = check new (
    apiKey = openAiApiKey,
    modelType = openAiModel,
    serviceUrl = openAiServiceUrl
);
