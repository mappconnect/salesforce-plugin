public class LeadSaveCallout {

	@future(callout=true)
    public static void saveLead(String email, String id, String mobilePhone, String firstName, String lastName, String salutation, String postalCode, 
            String country, String company, String leadSource, String status, String rating, Map<String, String> customFields) {

        new EngageApiClient().saveContact(EntityType.LEAD, id, email, mobilePhone, firstName, lastName, salutation, null, postalCode, null, country,
            company, leadSource, status, rating, customFields);
    }

    @future(callout=true)
    public static void deleteLead(String email) {
        EngageApiClient engageApiClient = new EngageApiClient();

        mappmct__engage_integration__c integrationSettingsFrom = SettingsController.getIntegrationSettings();
        engageApiClient.unsubscribeContact(email, integrationSettingsFrom.mappmct__lead_group__c);

        List<mappmct__EngageGroupMapping__c> engageGroupMappings = [SELECT mappmct__EngageGroupId__c FROM mappmct__EngageGroupMapping__c];
        for (mappmct__EngageGroupMapping__c engageGroupMapping : engageGroupMappings) {
            engageApiClient.unsubscribeContact(email, String.valueOf(engageGroupMapping.mappmct__EngageGroupId__c));
        }
    }
}