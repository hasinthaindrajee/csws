import ballerinax/ai.openai;

// Base URL of the order status MCP service (3.1)
configurable string mcpServiceUrl = "http://localhost:9090/mcp";

// OpenAI credentials. Point openAiServiceUrl at the AI Gateway for scenario 3.3.
configurable string openAiApiKey = ?;
configurable string openAiServiceUrl = "https://api.openai.com/v1";
configurable openai:OPEN_AI_MODEL_NAMES openAiModel = openai:GPT_4O_MINI;

// Port the agent's chat endpoint listens on
configurable int agentPort = 8090;
