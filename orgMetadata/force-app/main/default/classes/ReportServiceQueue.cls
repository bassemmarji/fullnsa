public class ReportServiceQueue implements Queueable {
    String eventId;
    String reportId;
    String userId;

    public ReportServiceQueue(String eventId, String reportId, String userId) {
        this.eventId = eventId;
        this.reportId = reportId;
        this.userId = userId;
    }

    public void execute(QueueableContext context) {
        // Safe to call report API or access content here
        ReportService.sendReportToUser(eventId, userId, reportId);
    }
}