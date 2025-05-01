trigger EmailEventTrigger on Email_Request__e (after insert) {
	for (Email_Request__e event : Trigger.New) {
        System.debug('EmailEventTrigger >>> ID ='+ event.Event_ID__c + '- User ID='+event.User_ID__c + '- Report ID='+event.Report_ID__c);
        //ReportService.sendReportToUser(event.User_ID__c, event.Report_ID__c);
        System.enqueueJob(new ReportServiceQueue(event.Event_ID__c, event.Report_ID__c, event.User_ID__c));
    }
}