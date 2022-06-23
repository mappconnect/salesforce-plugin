trigger contactUpdate on Contact (after update) {
    for (Contact ct : Trigger.new) {
        if (String.isNotBlank(ct.Email)) {
            Map<String, String> customFields = CustomFieldsHelper.getCustomContactFields(ct);
            ContactSaveCallout.saveContact(ct.Email, ct.mobilePhone, ct.firstName, ct.lastName, ct.salutation, ct.birthDate, 
                ct.mailingPostalCode, ct.Languages__c, ct.mailingCountry, ct.leadSource, customFields);
        }
    }
}