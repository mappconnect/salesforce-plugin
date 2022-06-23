trigger membershipDelete on CampaignMember (before delete) {
    for (CampaignMember mbr : Trigger.old) {
        MembershipSaveCallout.deleteMembership(mbr.CampaignId, mbr.ContactId, mbr.LeadId);
    }
}