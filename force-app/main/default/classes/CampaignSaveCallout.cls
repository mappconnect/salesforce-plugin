public class CampaignSaveCallout {
    @future(callout=true)
    public static void saveCampaign(String id, String name) {
        Long engageGroupId = new EngageApiClient().createGroup(name);
        if (engageGroupId != null) {
            mappmct__EngageGroupMapping__c engageGroupMapping = new mappmct__EngageGroupMapping__c(mappmct__CampaignId__c = id, mappmct__EngageGroupId__c = engageGroupId, name = id + '-' + String.valueOf(engageGroupId));
            insert engageGroupMapping;
        }
    }
}