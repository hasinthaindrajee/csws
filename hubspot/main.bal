import ballerina/log;
import ballerinax/hubspot.crm.obj.contacts;

public function main() returns error? {
    log:printInfo("Checking for HubSpot contacts updated in the last minute...");

    string? afterCursor = ();
    int totalSynced = 0;

    boolean hasMore = true;
    while hasMore {
        contacts:CollectionResponseWithTotalSimplePublicObjectForwardPaging response =
            check fetchRecentlyUpdatedContacts(afterCursor);

        contacts:SimplePublicObject[] contactList = response.results;
        foreach contacts:SimplePublicObject hubspotContact in contactList {
            ContactProperties contactProps = mapToContactProperties(hubspotContact);
            logContactProperties(contactProps);
            check upsertContact(contactProps);
            totalSynced += 1;
        }

        // Check for next page
        contacts:ForwardPaging? paging = response.paging;
        if paging is contacts:ForwardPaging {
            contacts:NextPage? nextPage = paging.next;
            if nextPage is contacts:NextPage {
                afterCursor = nextPage.after;
            } else {
                hasMore = false;
            }
        } else {
            hasMore = false;
        }
    }

    log:printInfo(string `Done. Contacts updated in the last minute: ${totalSynced}`);
}
