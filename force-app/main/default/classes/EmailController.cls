public class EmailController {
    
    public mappmct__engage_integration__c integrationSettings {get; set;}
    public List<SelectOption> messages {get; set;}
    public List<SelectOption> leadFields {get; set;}
    public String selectedMessage {get; set;}
    public String emailType {get; set;}
    public List<CustomParameter> customParameterList {get;set;}
    public List<CustomParameter> leadParameterList {get;set;}
    public Integer customParamCounter {get; set;}
    public Integer leadParamCounter {get; set;}
    public List<MessageHistory> messagesHistory {get; set;}

    private String optionNone = '-- Select --';
    
    public EmailController() {
        customParameterList = new List<CustomParameter>();
        leadParameterList = new List<CustomParameter>();

		List<mappmct__engage_integration__c> settings = [SELECT id, mappmct__api_url__c, mappmct__integration_id__c, mappmct__secret__c, mappmct__lead_group__c, mappmct__connection_status__c FROM mappmct__engage_integration__c];
		integrationSettings = settings.get(0);

        messages = buildMessageList();
        leadFields = buildLeadFieldList();
        messagesHistory = buildMessagesHistory();
    }

    private List<MessageHistory> buildMessagesHistory()
    {
        String leadId = ApexPages.currentPage().getParameters().get('id');

        List<MessageHistory> history = new List<MessageHistory>();
        if (String.isNotBlank(leadId)) {
            Integer numberOfRows = 10;
            Integer offset = 0;
            String query = 'SELECT Email FROM Lead WHERE Id = \'' + leadId + '\'';
            System.debug('Query: ' + query);
            
            Lead[] result = Database.query(query);
            if (result.size() > 0) {
                String leadEmail = result[0].email;
                history = new EngageApiClient().getHistory(leadEmail, numberOfRows, offset);
                for (MessageHistory message : history) {
                    message.prepareForDisplay();
                }
            }
        }
        return history;
    }

    private List<SelectOption> buildMessageList() {
        Map<String, String> messageMap = new EngageApiClient().getMessages();
        List<SelectOption> messages = new List<SelectOption>();
        for (String key : messageMap.keySet()) {
            if (String.isNotBlank(messageMap.get(key))) {
                messages.add(new SelectOption(key, messageMap.get(key)));
            }
        }
        return messages;
    }

    private List<SelectOption> buildLeadFieldList() {
        List<SelectOption> leadFields = new List<SelectOption>();
        leadFields.add(new SelectOption(optionNone, optionNone));
        SObjectType accountType = Schema.getGlobalDescribe().get('Lead');
        Map<String,Schema.SObjectField> leadFieldsMeta = accountType.getDescribe().fields.getMap();
        for (String leadFieldName : leadFieldsMeta.keySet()) {
            if (!leadFieldName.equals('emaill')) {
                leadFields.add(new SelectOption(leadFieldName, leadFieldName));
            }
        }
        return leadFields;
    }

    public void addCustomParam() {
        customParameterList.add(new CustomParameter());
    }

    public void deleteCustomParam() {
        customParameterList.remove(customParamCounter);
    }

    public void addLeadParam() {
       leadParameterList.add(new CustomParameter());
    }

    public void deleteLeadParam() {
        leadParameterList.remove(leadParamCounter);
    }

    public void sendSingle() {

        for (Integer i = leadParameterList.size() - 1; i >= 0; i--) {
            if (leadParameterList.get(i).name.equals(optionNone)) {
                leadParameterList.remove(i);
            }
        }

        String leadParams = '';
        for (CustomParameter lp : leadParameterList) {
            leadParams += ',' + lp.name;
        }

        String query = 'SELECT Email' +  leadParams + ' FROM Lead WHERE Id = \'' + ApexPages.currentPage().getParameters().get('id') + '\'';
        System.debug('Query: ' + query); 

   	    Lead[] result = Database.query(query);
   	
        Lead lead = result[0];
 
        for (CustomParameter lp : leadParameterList) {
            if (String.isNotBlank(lp.name)) {
                lp.value = lead.get(lp.name).toString();
            }
        }

        boolean success = new EngageApiClient().sendSingleEmail(lead.Email, selectedMessage, customParameterList, leadParameterList);
        if (success) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Email sent'));
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Failed to send email'));
        }
    }

    public void sendCampaign() {
        boolean success = new EngageApiClient().sendCampaignEmail(integrationSettings.mappmct__lead_group__c, selectedMessage, customParameterList);
        if (success) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Campaign email sent'));
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Failed to send campaign email'));
        }
    }
}