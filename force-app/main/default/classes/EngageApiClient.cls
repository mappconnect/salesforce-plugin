public class EngageApiClient {

    public mappmct__engage_integration__c integrationSettings {get; set;}
    
    public EngageApiClient() {
		List<mappmct__engage_integration__c> settings = [select id, mappmct__api_url__c, mappmct__integration_id__c, mappmct__secret__c, mappmct__lead_group__c from mappmct__engage_integration__c];
        if (settings.size() > 0) {
		    integrationSettings = settings.get(0);
        } else {
            integrationSettings = new mappmct__engage_integration__c();
        }
    }
    
    public Map<String, String> getGroups() {       
        URL url = new URL(integrationSettings.mappmct__api_url__c + '/integration/' + integrationSettings.mappmct__integration_id__c + '/group');         
        HttpResponse response = executeRequest(url, 'GET', null);

        if (response.getStatusCode() == 200) {
            String groupResponse = response.getBody();
            Map<String, String> groups = (Map<String, String>)JSON.deserialize(groupResponse, Map<String, String>.class);
            return groups;
        } else {
            System.debug('Response: ' + response.getBody());
            System.debug('Response: ' + response.getStatusCode());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Failed to get groups. Check your config.'));
            return new Map<String, String>();
        }
    }

    public List<MessageHistory> getHistory(String leadEmail, Integer numberOfRows, Integer offset)
    {
        URL url = new URL(integrationSettings.mappmct__api_url__c + '/integration/' + integrationSettings.mappmct__integration_id__c + '/message/history?userEmail=' + leadEmail + '&numberOfRows=' + numberOfRows + '&offset=' + offset);
        HttpResponse response = executeRequest(url, 'GET', null);
        if (response.getStatusCode() == 200) {
            String messageResponse = response.getBody();
            Map<String, List<MessageHistory>> bodyResponse = (Map<String, List<MessageHistory>>) JSON.deserialize(messageResponse, Map<String, List<MessageHistory>>.class);
            return bodyResponse.get('historyItems');
        } else {
            System.debug('Response: ' + response.getBody());
            System.debug('Response: ' + response.getStatusCode());
            return new List<MessageHistory>();
        }
    }

    public Map<String, String> getMessages() {       
        URL url = new URL(integrationSettings.mappmct__api_url__c + '/integration/' + integrationSettings.mappmct__integration_id__c + '/message');         
        HttpResponse response = executeRequest(url, 'GET', null);
        String messageResponse = response.getBody();
		Map<String, String> messages = (Map<String, String>)JSON.deserialize(messageResponse, Map<String,String>.class);
        return messages;
    }
    
    public boolean sendSingleEmail(String email, String messageId, List<CustomParameter> customParameters, List<CustomParameter> leadParameters) {
        String customParametersSerialized = serializeCustomAndLeadParameters(customParameters, leadParameters);

        String body = '{"email":"' + email +'","messageId":"' + messageId + '"' + customParametersSerialized + '}';   
        System.debug('Single Message Body: ' + body);     

        URL url = new URL(integrationSettings.mappmct__api_url__c + '/integration/' + integrationSettings.mappmct__integration_id__c + '/event?subtype=email');         
        HttpResponse response = executeRequest(url, 'POST', body);

        if (response.getStatusCode() == 200) {
            return true;
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Failed to send email. Check your config.'));
            return false;
        }
    }

    private String serializeCustomAndLeadParameters(List<CustomParameter> customParameters, List<CustomParameter> leadParameters) {
        String customParametersSerialized = serializeParameters(customParameters) + serializeParameters(leadParameters);
        return customParametersSerialized;
    }

    private String serializeParameters(List<CustomParameter> customParameters) {
        String customParametersSerialized = '';
        for (CustomParameter cp : customParameters) {
            if (String.isNotBlank(cp.name) && String.isNotBlank(cp.value)) {
                customParametersSerialized = customParametersSerialized + ',"' + cp.name + '":"' + cp.value + '"';
            }
        }
        return customParametersSerialized;
    }

    public boolean sendCampaignEmail(String groupId, String messageId, List<CustomParameter> customParameters) {
        String customParametersSerialized = serializeParameters(customParameters);

        String body = '{"group":"' + groupId +'","messageId":"' + messageId + '"' + customParametersSerialized + '}';   
        System.debug('Group Message Body: ' + body);

        URL url = new URL(integrationSettings.mappmct__api_url__c + '/integration/' + integrationSettings.mappmct__integration_id__c + '/event?subtype=email');         
        HttpResponse response = executeRequest(url, 'POST', body);

        if (response.getStatusCode() == 200) {
            return true;
        } else {
            return false;
        }
    }

    public void saveContact(EntityType entityType, String leadId, String email, String mobilePhone, String firstName, String lastName, String salutation, Date birthDate,
            String postalCode, String languages, String country, String company, String leadSource, String status, String rating, Map<String, String> customFields) {

        System.debug('Custom params: ' + customFields);

        EngageContact engageContact = new EngageContact(entityType, email, leadId, mobilePhone, firstName, lastName, salutation, birthDate,
            postalCode, languages, country, company, leadSource, status, rating, integrationSettings.mappmct__lead_group__c);
        String engageContactJson = JSON.serialize(engageContact, true).replaceAll('"groupId":', '"group":');

        if (customFields.size() > 0) {
            Map<String, Object> contact = (Map<String, Object>) JSON.deserializeUntyped(engageContactJson);
            for (String customField : customFields.keySet()) {
                contact.put(customField, customFields.get(customField));
                engageContactJson = JSON.serialize(contact, true);
                System.debug('Serialized with custom params: ' + engageContactJson);
            }
        }
        
        
        URL url = new URL(integrationSettings.mappmct__api_url__c + '/integration/' + integrationSettings.mappmct__integration_id__c + '/event?subtype=user');     
        System.debug('Contact: ' + engageContactJson);    
        HttpResponse response = executeRequest(url, 'POST', engageContactJson);
    }

    public void saveContact(String email, String groupId) {
        String body = '{"email":"' + email +'","group":"' + groupId +'"}';        
        URL url = new URL(integrationSettings.mappmct__api_url__c + '/integration/' + integrationSettings.mappmct__integration_id__c + '/event?subtype=user');         
        HttpResponse response = executeRequest(url, 'POST', body);
    }

    public void unsubscribeContact(String email, String groupId) {
        String body = '{"email":"' + email +'","group":"' + groupId +'","unsubscribe":"true"}';        
        URL url = new URL(integrationSettings.mappmct__api_url__c + '/integration/' + integrationSettings.mappmct__integration_id__c + '/event?subtype=user');         
        HttpResponse response = executeRequest(url, 'POST', body);
    }

    public void saveContact(String email) {
        saveContact(email, integrationSettings.mappmct__lead_group__c);
    }

    public ConnectionInfo connect(String groupToBeCreated, String apiUrl, String integrationId, String secret) {
        if (String.isNotBlank(apiUrl)) {
            integrationSettings.mappmct__api_url__c = apiUrl;
        }
        if (String.isNotBlank(integrationId)) {
            integrationSettings.mappmct__integration_id__c = integrationId;
        }
        if (String.isNotBlank(secret)) {
            integrationSettings.mappmct__secret__c = secret;
        }

        String body = '{"createDefaultGroups":"' + false +'","groupNamesToBeCreated":["' + groupToBeCreated + '"]}';  
        URL url = new URL(integrationSettings.mappmct__api_url__c + '/integration/' + integrationSettings.mappmct__integration_id__c + '/connect');
        HttpResponse response = executeRequest(url, 'POST', body);

        if (response.getStatusCode() == 200) {
            System.debug('Connect response: ' + response.getBody());
            ConnectionInfo connectionInfo = (ConnectionInfo)JSON.deserialize(response.getBody(), ConnectionInfo.class);
            connectionInfo.error = false;
            return connectionInfo;
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Failed to connect. Check your config.'));
            ConnectionInfo connectionInfo = new ConnectionInfo();
            connectionInfo.error = true;
            return connectionInfo;
        }
    }

    public Long createGroup(String name) {
        String body = '{"groupNames":["' + name + '"]}';
        URL url = new URL(integrationSettings.mappmct__api_url__c + '/integration/' + integrationSettings.mappmct__integration_id__c + '/genericgroup');         
        HttpResponse response = executeRequest(url, 'POST', body);

        if (response.getStatusCode() == 200) {
            GroupInfo groupInfo = (GroupInfo)JSON.deserialize(response.getBody(), GroupInfo.class);
            if (groupInfo.groupNamesAndIds.size() == 1) {
                return groupInfo.groupNamesAndIds.get(name);
            }
        }
        return null;
    }
    
    private HttpResponse executeRequest(URL url, String method, String body) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('auth-token', getAuthToken(url, body)); 
        request.setEndpoint(url.toExternalForm());
        request.setMethod(method);
        request.setTimeout(30000);
        if (String.isNotBlank(body)) {
            request.setBody(body);
        }
        request.setHeader('content-type', 'application/json'); 
        HttpResponse response = http.send(request);
        return response;
    }
    
    private String getAuthToken(URL url, String body) {       
        String requestHash = getRequestHash(url, body);
        
        JWT jwt = new JWT('HS256');
        jwt.privateKey = integrationSettings.mappmct__secret__c;
        Map<String,String> claims = new  Map<String,String>();
        claims.put('request-hash', requestHash);
        jwt.claims = claims;        
        String token = jwt.issue();  
        
        System.debug('TOKEN: ' + token);
        
        return token;
    }
    
    private String getRequestHash(URL url, String body) {
        String requestData = getUrlPathPart(url);
        if (String.isNotBlank(body)) {
            requestData += '|' + body;
        }
        if (String.isNotBlank(url.getQuery())) {
            requestData += '|' + url.getQuery();
        }
        System.debug('Setting: ' + integrationSettings.mappmct__api_url__c);
        System.debug('Token req data:' + requestData);
        String hash = EncodingUtil.convertToHex(Crypto.generateDigest('SHA1', Blob.valueOf(requestData)));
        return hash;
    }

    private String getUrlPathPart(URL url) {
        if (String.isNotBlank(url.toExternalForm()) && url.toExternalForm().indexOf('/api/v1') > 0) {
            if (url.toExternalForm().indexOf('?') > 0) {
                return url.toExternalForm().substring(url.toExternalForm().indexOf('/api/v1'), url.toExternalForm().indexOf('?'));
            } else {
                return url.toExternalForm().substring(url.toExternalForm().indexOf('/api/v1'));
            }
        } else {
            return url.toExternalForm();
        }
    }
}