public class SettingsController {

    public static final String SF_GROUP_NAME = 'Salesforce';

    public mappmct__engage_integration__c integrationSettings {get; set;}
    public mappmct__EngageCustomFields__c customFieldSettings {get; set;}
    public List<SelectOption> groups {get; set;}
    public List<CustomParameter> leadFieldsList {get;set;}
    public List<SelectOption> leadFields {get; set;}
    
    public List<CustomParameter> contactFieldsList {get;set;}
    public List<SelectOption> contactFields {get; set;}

    private String optionNone = '-- Select --';

    private List<String> defaultLeadFields;
    private List<String> defaultContactFields;

    public Integer contactFieldCounter {get; set;}
    public Integer leadFieldCounter {get; set;}
    
    public SettingsController() {
		integrationSettings = getIntegrationSettings();
        groups = new List<SelectOption>();
        loadGroups();
        
        if (String.isBlank(integrationSettings.mappmct__connection_status__c)) {
            integrationSettings.mappmct__connection_status__c = ConnectionStatus.DISCONNECTED.name();
        }
        leadFieldsList = new List<CustomParameter>();
        contactFieldsList = new List<CustomParameter>();

        defaultLeadFields = new List<String>{'id', 'email', 'mobilephone', 'firstname', 'lastname', 'salutation', 'postalcode', 'country', 'company', 'leadsource', 'status', 'rating'};
        defaultContactFields = new List<String>{'email', 'mobilephone', 'firstname', 'lastname', 'salutation', 'birthdate', 'postalcode', 'languages', 'country', 'leadsource'};

        leadFields = buildFieldsList('Lead', defaultLeadFields);
        contactFields = buildFieldsList('Contact', defaultContactFields);

        mappmct__EngageCustomFields__c[] fields = [SELECT Name, mappmct__FieldType__c FROM mappmct__EngageCustomFields__c];
        for (mappmct__EngageCustomFields__c field : fields) {
            if (field.mappmct__FieldType__c == 'Lead') {
                leadFieldsList.add(new CustomParameter(field.name));
            } else if (field.mappmct__FieldType__c == 'Contact') {
                contactFieldsList.add(new CustomParameter(field.name));
            }
        }
    }

    public void addLeadField() {
        leadFieldsList.add(new CustomParameter());
    }

     public void deleteLeadField() {
        leadFieldsList.remove(leadFieldCounter);
    }

    public void addContactField() {
        contactFieldsList.add(new CustomParameter());
    }
    
    public void deleteContactField() {
        contactFieldsList.remove(contactFieldCounter);
    }

    private List<SelectOption> buildFieldsList(String objectName, List<String> defaultFields) {
        List<SelectOption> fields = new List<SelectOption>();
        fields.add(new SelectOption('-- Select --', '-- Select --'));
        SObjectType accountType = Schema.getGlobalDescribe().get(objectName);
        Map<String,Schema.SObjectField> fieldsMeta = accountType.getDescribe().fields.getMap();
        for (String fieldName : fieldsMeta.keySet()) {
            if (!defaultFields.contains(fieldName)) {
                fields.add(new SelectOption(fieldName, fieldName));
            }
        }
        return fields;
    }

    public static mappmct__engage_integration__c getIntegrationSettings() {
        List<mappmct__engage_integration__c> settings = [SELECT id, mappmct__api_url__c, mappmct__integration_id__c, mappmct__secret__c, mappmct__lead_group__c, mappmct__connection_status__c FROM mappmct__engage_integration__c];
        if (settings.size() > 0) {
		    return settings.get(0);
        } else {
            return new mappmct__engage_integration__c();
        }
    }
    
    public PageReference save() {
        removeEmptyFields(leadFieldsList);
        removeEmptyFields(contactFieldsList);
        
        Boolean setupValid = isSetupValid();
        if (!setupValid) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Can\'t delete fields from active integration'));
            return null;
        }

        if (String.isNotBlank(integrationSettings.mappmct__api_url__c) && String.isNotBlank(integrationSettings.mappmct__integration_id__c) && String.isNotBlank(integrationSettings.mappmct__secret__c)) {            
            connect();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Settings updated'));
        }
		saveIntegrationSettings();
        saveFieldsSettings();

        PageReference thisPage = ApexPages.currentPage();
        thisPage.setRedirect(true);
        return thisPage;
    }

    private void removeEmptyFields(List<CustomParameter> fields) {
        for (Integer i = fields.size() - 1; i >= 0; i--) {
            if (fields.get(i).name.equals(optionNone)) {
                fields.remove(i);
            }
        }
    }

    private boolean integrationParamsChanged() {
        mappmct__engage_integration__c integrationSettingsFromDb = getIntegrationSettings();
        return (integrationSettingsFromDb.mappmct__integration_id__c != integrationSettings.mappmct__integration_id__c) ||
            (integrationSettingsFromDb.mappmct__secret__c != integrationSettings.mappmct__secret__c) || (integrationSettingsFromDb.mappmct__api_url__c != integrationSettings.mappmct__api_url__c);
    }

    private void saveIntegrationSettings() {
        if (integrationSettings.id == null) {                   
			upsert integrationSettings;
        } else {
			update integrationSettings;
        }
    }

    private void saveFieldsSettings() {
        mappmct__EngageCustomFields__c[] fields = [SELECT Name FROM mappmct__EngageCustomFields__c];
        delete fields;

        insertFields(leadFieldsList, 'Lead');
        insertFields(contactFieldsList, 'Contact');
    }

    private void insertFields(List<CustomParameter> fields, String type) {
        for (CustomParameter fieldData : fields) {
            mappmct__EngageCustomFields__c field = new mappmct__EngageCustomFields__c(Name = fieldData.name, mappmct__FieldType__c = type);
            insert field;
        }
    }

    public void connect() {
        ConnectionInfo connectionInfo = new EngageApiClient().connect(SF_GROUP_NAME, integrationSettings.mappmct__api_url__c, integrationSettings.mappmct__integration_id__c, integrationSettings.mappmct__secret__c);
        if (connectionInfo.error) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Connection attempt failed'));
        } else {
            if (connectionInfo.connectionStatus != null) {
                integrationSettings.mappmct__connection_status__c = connectionInfo.connectionStatus.name();
                Long createdGroupId = connectionInfo.groupNamesAndIds.get(SF_GROUP_NAME);
                integrationSettings.mappmct__lead_group__c = String.valueOf(createdGroupId);
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Connection successful'));
        }
    }

    private void loadGroups() {
        if (String.isNotBlank(integrationSettings.mappmct__integration_id__c)) {
            Map<String, String> groupMap = new EngageApiClient().getGroups();
            System.debug('GROUPS RETRIEVED');
            for (String key : groupMap.keySet()) {
                groups.add(new SelectOption(key, groupMap.get(key)));
            }
        }
    }

    private Boolean isSetupValid() {
        if (integrationSettings.mappmct__connection_status__c == ConnectionStatus.CONNECTED.name()) {
            if (String.isBlank(integrationSettings.mappmct__api_url__c) || String.isBlank(integrationSettings.mappmct__integration_id__c) || String.isBlank(integrationSettings.mappmct__secret__c)) {
                return false;
            }
        }
        return true;
    }
}