@isTest
public class TriggersTest {

    @TestSetup static void setup() {
        mappmct__engage_integration__c intc = new mappmct__engage_integration__c(mappmct__api_url__c = 'http://engage.com', 
            mappmct__integration_id__c = 'intid', mappmct__secret__c = 'sec', mappmct__connection_status__c = ConnectionStatus.DISCONNECTED.name());
        insert intc;  
    }

    @isTest static void testCampaignInsert() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EngageApiClientCalloutMock());

        Campaign campaign = new Campaign(name = 'MeinKampanien', type = 'Mapp Engage');
        insert campaign;
        
        Test.stopTest();
        
        mappmct__EngageGroupMapping__c engageGroupMapping = [SELECT mappmct__EngageGroupId__c FROM mappmct__EngageGroupMapping__c WHERE mappmct__CampaignId__c = :campaign.id];
        System.assertEquals(678, engageGroupMapping.mappmct__EngageGroupId__c);
    }

    @isTest static void testContactInsertUpdateDelete() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EngageApiClientCalloutMock());

        Contact contact = new Contact(email = 'dziobak@xx.xx', LastName = 'pandziobak');        
        insert contact;

        contact.LastName = 'pepe';
        update contact;
 
        delete contact;
        
        Test.stopTest();
    }

    @isTest static void testLeadInsertUpdateDelete() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EngageApiClientCalloutMock());

        Lead lead = new Lead(email = 'dziobak@xx.xx', company = 'mcdonalds', LastName = 'pandziobak');        
        insert lead;

        lead.lastName = 'pepe';
        update lead;

        delete lead;
        
        Test.stopTest();
    }

    @isTest static void testLeadMemberInsert() {
        Campaign campaign = new Campaign(name = 'MeinKampanien' + Datetime.now().millisecond(), type = 'Mapp Engage');
        insert campaign;      

        Lead lead = new Lead(email =  Datetime.now().millisecond() + 'doofenschmirtz@xx.xx', company = 'dei', LastName = 'heinz');        
        insert lead;

        mappmct__EngageGroupMapping__c engageGroupMapping = new mappmct__EngageGroupMapping__c(mappmct__CampaignId__c = campaign.id, mappmct__EngageGroupId__c = 1234);
        insert engageGroupMapping;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EngageApiClientCalloutMock());

        CampaignMember cm = new CampaignMember(CampaignId = campaign.id, LeadId = lead.id);
        insert cm;
        
        Test.stopTest();
    }

    @isTest static void testContactMemberInsert() {
        Campaign campaign = new Campaign(name = 'MeinKampanien' + Datetime.now().millisecond(), type = 'Mapp Engage');
        insert campaign;      

        Contact contact = new Contact(email =  Datetime.now().millisecond() + 'doofenschmirtz@xx.xx', LastName = 'heinz');        
        insert contact;

        mappmct__EngageGroupMapping__c engageGroupMapping = new mappmct__EngageGroupMapping__c(mappmct__CampaignId__c = campaign.id, mappmct__EngageGroupId__c = 1234);
        insert engageGroupMapping;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EngageApiClientCalloutMock());

        CampaignMember cm = new CampaignMember(CampaignId = campaign.id, ContactId = contact.id);
        insert cm;

        delete cm;
        
        Test.stopTest();
    }
}