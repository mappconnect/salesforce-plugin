public class CustomFieldsHelper {
    
    public static Map<String, String> getCustomLeadFields(Lead ld) {
        Map<String, String> customFields = new Map<String, String>();
        mappmct__EngageCustomFields__c[] fields = [SELECT Name FROM mappmct__EngageCustomFields__c WHERE mappmct__FieldType__c = 'Lead'];
        for (mappmct__EngageCustomFields__c field : fields) {
            if (ld.get(field.Name) != null) {
                customFields.put(field.Name, ld.get(field.Name).toString());
            }
        }
        return customFields;
    }

    public static Map<String, String> getCustomContactFields(Contact ct) {
        Map<String, String> customFields = new Map<String, String>();
        mappmct__EngageCustomFields__c[] fields = [SELECT Name FROM mappmct__EngageCustomFields__c WHERE mappmct__FieldType__c = 'Contact'];
        for (mappmct__EngageCustomFields__c field : fields) {
            if (ct.get(field.Name) != null) {
                customFields.put(field.Name, ct.get(field.Name).toString());
            }
        }
        return customFields;
    }
}
