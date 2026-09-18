import ballerina/ai;
import ballerina/http;
import ballerina/log;
import ballerina/mcp;

// MCP toolkit that recovers from a server-expired session.
//
// ballerina/mcp 1.1.0 caches the session id for the life of the client and never
// refreshes it. Once the server forgets the session, every tools/call returns
// -32600 "Invalid session ID" and the client stays broken until the process
// restarts. On failure this toolkit closes the session (which clears the cached
// id), re-initializes, and retries the call once.
public isolated class ResilientMcpToolKit {
    *ai:McpBaseToolKit;
    private final mcp:StreamableHttpClient mcpClient;
    private final readonly & mcp:Implementation info;
    private final ai:ToolConfig[] & readonly tools;

    public isolated function init(string serverUrl, string[]? permittedTools = (),
            mcp:Implementation info = {name: "MCP Client", version: "1.0.0"},
            *ai:StreamableHttpClientTransportConfig config) returns ai:Error? {
        ai:StreamableHttpClientTransportConfig {auth, ...configs} = config;
        mcp:StreamableHttpClientTransportConfig mcpConfig = {...configs};
        if auth is http:ClientAuthConfig {
            mcpConfig.auth = auth;
        }

        mcp:StreamableHttpClient|mcp:ClientError mcpClient = new (serverUrl, mcpConfig);
        if mcpClient is error {
            return error ai:Error("Failed to initialize the MCP client", mcpClient);
        }
        self.mcpClient = mcpClient;
        self.info = info.cloneReadOnly();

        mcp:ClientError? initializeRes = self.mcpClient->initialize(info);
        if initializeRes is error {
            return error ai:Error("Failed to initialize the MCP client", initializeRes);
        }

        mcp:ListToolsResult|error listTools = self.mcpClient->listTools();
        if listTools is error {
            return error ai:Error("Failed to get tools from the MCP server", listTools);
        }
        mcp:ToolDefinition[] filtered = filterPermittedTools(listTools.tools, permittedTools);

        isolated function caller = self.callTool;
        self.tools = from mcp:ToolDefinition tool in filtered
            select {
                name: tool.name,
                description: tool.description ?: "",
                parameters: check getInputSchemaValues(tool).cloneReadOnly(),
                caller
            };
    }

    public isolated function callTool(mcp:CallToolParams params) returns mcp:CallToolResult|error {
        mcp:CallToolResult|mcp:ClientError result = self.mcpClient->callTool(params);
        if result !is mcp:ClientError {
            return result;
        }

        // The session may have been dropped server-side. Clear it and retry once.
        log:printWarn("MCP tool call failed; re-establishing session and retrying",
                toolName = params.name, cause = result.message());

        mcp:ClientError? closeRes = self.mcpClient->close();
        if closeRes is error {
            log:printDebug("Ignoring error while closing the stale MCP session",
                    cause = closeRes.message());
        }

        mcp:ClientError? reinit = self.mcpClient->initialize(self.info);
        if reinit is error {
            log:printError("Failed to re-initialize the MCP session", reinit);
            return result;
        }

        return self.mcpClient->callTool(params);
    }

    public isolated function getTools() returns ai:ToolConfig[] => self.tools;
}

isolated function filterPermittedTools(mcp:ToolDefinition[] tools, string[]? permittedTools)
        returns mcp:ToolDefinition[] {
    if permittedTools is () {
        return tools;
    }
    return from mcp:ToolDefinition tool in tools
        where permittedTools.indexOf(tool.name) is int
        select tool;
}

isolated function getInputSchemaValues(mcp:ToolDefinition tool) returns map<json>|ai:Error {
    map<json>|error inputSchema = tool.inputSchema.cloneWithType();
    if inputSchema is error {
        return error ai:Error(
                string `Failed to get the input schema for the tool: ${tool.name}`, inputSchema);
    }
    return inputSchema;
}
