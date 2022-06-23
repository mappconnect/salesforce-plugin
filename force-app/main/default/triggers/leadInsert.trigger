trigger leadInsert on Lead (after insert) {
	for (Lead ld : Trigger.new) {
        if (String.isNotBlank(ld.Email)) {
            Map<String, String> customFields = CustomFieldsHelper.getCustomLeadFields(ld);
            LeadSaveCallout.saveLead(ld.Email, ld.Id, ld.MobilePhone, ld.FirstName, ld.LastName, ld.Salutation, ld.PostalCode, ld.Country, 
                ld.Company, ld.LeadSource, ld.Status, ld.Rating, customFields);
        }
    }
}