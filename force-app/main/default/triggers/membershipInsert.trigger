trigger membershipInsert on CampaignMember (after insert) {
    for (CampaignMember mbr : Trigger.new) {
        MembershipSaveCallout.saveMembership(mbr.CampaignId, mbr.ContactId, mbr.LeadId);
    }
}