public class MembershipSaveCallout {
    
    @future(callout=true)
    public static void saveMembership(String campaignId, String contactId, String leadId) {
        String email = getContactOrLeadEmail(contactId, leadId);

        mappmct__EngageGroupMapping__c engageGroupMapping = [SELECT mappmct__EngageGroupId__c FROM mappmct__EngageGroupMapping__c WHERE mappmct__CampaignId__c = :campaignId];
        if (engageGroupMapping != null) {
            new EngageApiClient().saveContact(email, String.valueOf(engageGroupMapping.mappmct__EngageGroupId__c));
        }
    }

    @future(callout=true)
    public static void deleteMembership(String campaignId, String contactId, String leadId) {
        String email = getContactOrLeadEmail(contactId, leadId);

        mappmct__EngageGroupMapping__c engageGroupMapping = [SELECT mappmct__EngageGroupId__c FROM mappmct__EngageGroupMapping__c WHERE mappmct__CampaignId__c = :campaignId];
        if (engageGroupMapping != null) {
            new EngageApiClient().unsubscribeContact(email, String.valueOf(engageGroupMapping.mappmct__EngageGroupId__c));
        }
    }

    private static String getContactOrLeadEmail(String contactId, String leadId) {
        String email = null;
        if (String.isNotBlank(contactId)) {
            Contact contact = [SELECT Email FROM Contact WHERE id = :contactId];
            email = contact.Email;
        } else if (String.isNotBlank(leadId)) {
            Lead lead = [SELECT Email FROM Lead WHERE id = :leadId];
            email = lead.Email;
        }
        return email;
    }
}