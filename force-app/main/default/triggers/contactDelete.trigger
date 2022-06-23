trigger contactDelete on Contact (before delete) {
    for (Contact ct : Trigger.old) {
        ContactSaveCallout.deleteContact(ct.Email);
    }
}