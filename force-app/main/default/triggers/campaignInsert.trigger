trigger campaignInsert on Campaign (after insert) {
    for (Campaign cmpgn : Trigger.new) {
        if (cmpgn.Type == 'Mapp Engage') {
            CampaignSaveCallout.saveCampaign(cmpgn.id, cmpgn.Name);
        }
    }
}