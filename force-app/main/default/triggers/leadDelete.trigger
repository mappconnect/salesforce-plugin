trigger leadDelete on Lead (before delete) {
    for (Lead ld : Trigger.old) {
        LeadSaveCallout.deleteLead(ld.Email);
    }
}