@isTest
public class EmailControllerTest {
    
    @TestSetup static void setup() {
        mappmct__engage_integration__c intc = new mappmct__engage_integration__c(mappmct__api_url__c = 'http://engage.com', 
            mappmct__integration_id__c = 'intid', mappmct__secret__c = 'sec', mappmct__connection_status__c = ConnectionStatus.DISCONNECTED.name());
        insert intc;
    }

    @isTest static void testInstantiation() {
        Lead lead = new Lead(email = Datetime.now().millisecond() + 'lid@xx.xx', LastName = 'zdzich', Company = 'XXX');
        insert lead;

        Test.setMock(HttpCalloutMock.class, new EngageApiClientCalloutMock());        
        
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', lead.Id);

        EmailController emailController = new EmailController();
        System.assert(emailController.messages.size() == 2);

        Test.stopTest();
    }

    @isTest static void testSendSingle() {

        Lead lead = new Lead(email = Datetime.now().millisecond() + 'lid@xx.xx', LastName = 'zdzich', Company = 'XXX');
        insert lead;

        Test.setMock(HttpCalloutMock.class, new EngageApiClientCalloutMock());        
        
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', lead.Id);

        EmailController emailController = new EmailController();
        emailController.sendSingle();

        Test.stopTest();
    }

    @isTest static void testSendCampaign() {
        Lead lead = new Lead(email = Datetime.now().millisecond() + 'lid@xx.xx', LastName = 'zdzich', Company = 'XXX');
        insert lead;

        Test.setMock(HttpCalloutMock.class, new EngageApiClientCalloutMock());        
        
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', lead.Id);
        
        EmailController emailController = new EmailController();
        emailController.sendCampaign();

        Test.stopTest();
    }
}
