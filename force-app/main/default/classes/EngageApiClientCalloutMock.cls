public class EngageApiClientCalloutMock implements HttpCalloutMock {
    public EngageApiClientCalloutMock() {

    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();

       if (req.getEndpoint().contains('/connect')) {
            ConnectionInfo connectionInfo = new ConnectionInfo();
            connectionInfo.groupNamesAndIds = new Map<String, Long>();
            connectionInfo.groupNamesAndIds.put(SettingsController.SF_GROUP_NAME, 666);
            connectionInfo.connectionStatus = ConnectionStatus.CONNECTED;
            res.setBody(JSON.serialize(connectionInfo));
        }

        if (req.getEndpoint().contains('/group')) {
            Map<String, String> groups = new Map<String, String>();
            groups.put('666', SettingsController.SF_GROUP_NAME);
            groups.put('777', 'chlosta');
            res.setBody(JSON.serialize(groups));
        }

        if (req.getEndpoint().contains('/message')) {
            Map<String, String> messages = new Map<String, String>();
            messages.put('66', 'firstmessage');
            messages.put('77', 'secondmessage');
            res.setBody(JSON.serialize(messages));
        }

        if (req.getEndpoint().contains('/genericgroup')) {            
            GroupInfo groupInfo = new GroupInfo();
            groupInfo.groupNamesAndIds = new Map<String, Long>();
            groupInfo.groupNamesAndIds.put('MeinKampanien', 678);
            res.setBody(JSON.serialize(groupInfo));
        }

        if (req.getEndpoint().contains('/message/history')) {
            List<MessageHistory> history = new List<MessageHistory>();
            history.add(new MessageHistory('Message test1', '7857575373553', '7857575373553', null));

            Map<String, List<MessageHistory>> body = new Map<String, List<MessageHistory>>();
            body.put('historyItems', history);
            res.setBody(JSON.serialize(body));
        }

        res.setHeader('Content-Type', 'application/json');        
        res.setStatusCode(200);
        return res;
    }
}