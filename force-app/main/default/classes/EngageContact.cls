public class EngageContact {

    public String entityType {get; set;}
    public String email {get; set;}
    public String leadId {get; set;}
    public String mobilePhone {get; set;}
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String salutation {get; set;}
    public String birthDate {get; set;}
    public String postalCode {get; set;}
    public String languages {get; set;}
    public String country {get; set;}
    public String company {get; set;}
    public String leadSource {get; set;}
    public String status {get; set;}
    public String rating {get; set;}
    public String groupId {get; set;}

    public EngageContact(EntityType entityType, String email, String leadId, String mobilePhone, String firstName, String lastName, String salutation, Date birthDate,
            String postalCode, String languages, String country, String company, String leadSource, String status, String rating, String groupId) {
        
        this.entityType = entityType.name();
        this.email = email;
        this.leadId = leadId;
        this.mobilePhone = mobilePhone;
        this.firstName = firstName;
        this.lastName = lastName;
        this.salutation = salutation;
        if (birthDate != null) {
            this.birthDate = String.valueOf(birthDate);
        }
        this.postalCode = postalCode;
        this.languages = languages;
        this.country = country;
        this.company = company;
        this.leadSource = leadSource;
        this.status = status;
        this.rating = rating;
        this.groupId = groupId;
    }
}
