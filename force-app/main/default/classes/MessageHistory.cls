public class MessageHistory {
    public String messageName {get; set;}
    public String sendoutDate {get; set;}
    public String clickDate {get; set;}
    public String openDate {get; set;}

    public MessageHistory(String messageName, String sendoutDate, String clickDate, String openDate) {
        this.messageName = messageName;
        this.sendoutDate = sendoutDate;
        this.clickDate = clickDate;
        this.openDate = openDate;
    }

    public void prepareForDisplay() {
        sendoutDate = sendoutDate == null ? '' : Datetime.newInstance(Long.valueOf(sendoutDate)).format('MM/dd/yyyy');
        clickDate = clickDate == null ? 'No' : 'Yes - ' + Datetime.newInstance(Long.valueOf(clickDate)).format('MM/dd/yyyy');
        openDate = openDate == null ? 'No' : 'Yes - ' + Datetime.newInstance(Long.valueOf(openDate)).format('MM/dd/yyyy');
    }
}