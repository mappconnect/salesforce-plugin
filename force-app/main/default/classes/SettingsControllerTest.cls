@isTest
public class SettingsControllerTest {

    @TestSetup static void setup() {
        mappmct__engage_integration__c intc = new mappmct__engage_integration__c(mappmct__api_url__c = 'http://engage.com', 
            mappmct__integration_id__c = 'intid', mappmct__secret__c = 'sec', mappmct__connection_status__c = ConnectionStatus.DISCONNECTED.name());
        insert intc;
    }

    @isTest static void testSaveAndConnect() {
        Test.setMock(HttpCalloutMock.class, new EngageApiClientCalloutMock());        
        
        Test.startTest();

        ConnectionInfo connectionInfo = new ConnectionInfo();
        connectionInfo.connectionStatus = ConnectionStatus.DISCONNECTED;
        connectionInfo.error = false;
        connectionInfo.groupNamesAndIds = new Map<String, Long>();
        
        SettingsController settingsController = new SettingsController();
        settingsController.save();
       
        Test.stopTest();
        List<mappmct__engage_integration__c> settings = [SELECT id, mappmct__api_url__c, mappmct__integration_id__c, mappmct__secret__c, mappmct__lead_group__c, mappmct__connection_status__c FROM mappmct__engage_integration__c];
		mappmct__engage_integration__c integrationSettings = settings.get(0);
        System.assert(settings.size() == 1);     
    }
}