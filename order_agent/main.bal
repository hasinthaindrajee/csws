import ballerina/ai;
import ballerina/http;
import ballerina/log;

listener ai:Listener agentListener = new (agentPort);

service /orderAgent on agentListener {

    # Answers a natural-language order status question.
    #
    # + request - Chat message with the user's question and a session ID
    # + return - The agent's answer
    resource function post chat(@http:Payload ai:ChatReqMessage request)
            returns ai:ChatRespMessage|error {
        string|ai:Error answer = orderStatusAgent.run(request.message, request.sessionId);
        if answer is ai:Error {
            log:printError("Agent failed to answer", answer, sessionId = request.sessionId);
            return {message: "Sorry, I could not look that up right now. Please try again."};
        }
        return {message: answer};
    }
}
