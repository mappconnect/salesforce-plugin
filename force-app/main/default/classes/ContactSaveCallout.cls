public class ContactSaveCallout {

    @future(callout=true)
    public static void saveContact(String email, String mobilePhone, String firstName, String lastName, String salutation, Date birthDate, String postalCode, 
            String languages, String country, String leadSource, Map<String, String> customFields) {

        new EngageApiClient().saveContact(EntityType.CONTACT, null, email, mobilePhone, firstName, lastName, salutation, birthDate, postalCode, languages, country,
            null, leadSource, null, null, customFields);
    }

    @future(callout=true)
    public static void deleteContact(String email) {
        EngageApiClient engageApiClient = new EngageApiClient();

        mappmct__engage_integration__c integrationSettingsFrom = SettingsController.getIntegrationSettings();
        engageApiClient.unsubscribeContact(email, integrationSettingsFrom.mappmct__lead_group__c);

        List<mappmct__EngageGroupMapping__c> engageGroupMappings = [SELECT mappmct__EngageGroupId__c FROM mappmct__EngageGroupMapping__c];
        for (mappmct__EngageGroupMapping__c engageGroupMapping : engageGroupMappings) {
            engageApiClient.unsubscribeContact(email, String.valueOf(engageGroupMapping.mappmct__EngageGroupId__c));
        }
    }
}