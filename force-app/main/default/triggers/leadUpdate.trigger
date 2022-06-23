trigger leadUpdate on Lead (after update) {
	for (Lead ld : Trigger.new) {
        if (String.isNotBlank(ld.Email)) {
            Map<String, String> customFields = CustomFieldsHelper.getCustomLeadFields(ld);
            LeadSaveCallout.saveLead(ld.Email, ld.Id, ld.mobilePhone, ld.firstName, ld.lastName, ld.salutation, ld.postalCode, ld.country,
                ld.company, ld.leadSource, ld.status, ld.rating, customFields);    
        }
    }
}