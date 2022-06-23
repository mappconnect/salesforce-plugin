trigger contactInsert on Contact (after insert) {
    for (Contact ct : Trigger.new) {
        if (String.isNotBlank(ct.Email)) {
            Map<String, String> customFields = CustomFieldsHelper.getCustomContactFields(ct);
            ContactSaveCallout.saveContact(ct.Email, ct.MobilePhone, ct.FirstName, ct.LastName, ct.Salutation, ct.Birthdate, 
                ct.MailingPostalCode, ct.Languages__c, ct.MailingCountry, ct.LeadSource, customFields);
        }
    }
}