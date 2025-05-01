public with sharing class IPS_ReportController {
    
    @AuraEnabled(cacheable=true)
    public static List<Report> getReportsByFolder(String folderName) {
     try {
        return [
            SELECT Id, Name, Description
            FROM Report
            WHERE FolderName = :folderName
            WITH SECURITY_ENFORCED
            ORDER BY Name
        ];
    	} catch (SecurityException e) {
        throw new AuraHandledException('Insufficient permissions to access reports');
    	} catch (Exception e) {
        throw new AuraHandledException('Error fetching reports: ' + e.getMessage());
    	}
    }

    public static Blob extractReport(String reportId) {
		//Get Instance URL
        String instanceUrl = URL.getOrgDomainUrl().toExternalForm();        
        // Build the PrintableViewDownloadServlet URL
        //https://fullnsa-dev-ed.develop.my.salesforce.com/00OQy00000DtTZ3MAN?isdtp=p1&csv=1
        
        //String reportUrl = instanceUrl + '/servlet/PrintableViewDownloadServlet?isdtp=p1&csv=1&reportId=' + reportId;
        String reportUrl = instanceUrl + '/' + reportId +'?isdtp=p1&csv=1';
        //String reportUrl = 'https://fullnsa-dev-ed.develop.my.salesforce.com/servlet/PrintableViewDownloadServlet?isdtp=p1&reportId=' + reportId;
        
        System.Debug('Report Url >>' + reportUrl);   
        
        // Fetch report content as a Blob
        PageReference reportPage = new PageReference(reportUrl);
        Blob reportBlob;
        try {
          reportBlob = reportPage.getContent();
          System.Debug('Report Page  >>' + reportPage.getContent());    
          System.Debug('Report BLOB  >>' + reportBlob.size());   
        } catch (Exception e) {
          throw new AuraHandledException('Error generating report: ' + e.getMessage());
        }
        System.Debug('Returning Results >>' + reportBlob.toString());
        return reportBlob;
    }
    
 
/**
 * Sends an email with the extracted report attached.
 * @param reportId The ID of the report to attach.
 * @param userId The ID of the recipient user.
 * @return Integer indicating success (1) or failure (0).
 */
  @AuraEnabled(cacheable=false)
  public static Integer emailReport(String reportId, String userId) {
    try 
    {
        /*
        // Fetch report name based on reportId
        Report report = [
            SELECT Name
            FROM Report
            WHERE Id = :reportId
            LIMIT 1
        ];

        String reportName = report.Name;

        // Fetch recipient email based on userId
        User recipient = [
            SELECT Email
            FROM User
            WHERE Id = :userId
            LIMIT 1
        ];
        String recipientEmail = recipient.Email;
        String recipientName = recipient.Name;
		
        //IPS_ReportController.emailReport('00OQy00000DtTZ3MAN','005Qy00000ABzs1IAD');
        String recipientEmail = 'bmarji@integratedpayorsolutions.com';
        String recipientName =  'Bassem Marji';    
        String reportName = 'List Of Reports';
        
        // Extract the report as a Blob
        Blob reportBlob = extractReport(reportId);

        // Create email attachment
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(reportName + '.xlsx');
        attachment.setBody(reportBlob);
        attachment.setContentType('application/vnd.ms-excel');

        // Prepare email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

        // Set recipient details
        email.setToAddresses(new String[] { recipientEmail });
        
        // Set email properties
        email.setSenderDisplayName(recipientName);
        email.setSubject('Report: ' + reportName);
        email.setHtmlBody(
            'Hello ' + recipientName + ',<br/><br/>Attached is the requested report: ' + reportName + '<br/><br/>Thank you.'
        );
        
        // Send the email
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        
        System.debug('Email sent successfully: ' + results);
		*/
        // Enqueue email job (runs in system context)
        //System.enqueueJob(new EmailQueueable(reportId,userId));
        sendEmailFuture(reportId,userId);
        return 1; // Success
    } catch (SecurityException e) {
        System.debug('Error SecurityException: ' + e.getMessage());
        throw new AuraHandledException(e.getMessage());
    } catch (Exception e) {
        System.debug('Error sending email: ' + e.getMessage());
        throw new AuraHandledException(e.getMessage());
    }
  }
    
	@Future(callout=true)
    private static void sendEmailFuture(String reportId, String userId) {
        /*
        // Fetch report name based on reportId
        Report report = [
            SELECT Name
            FROM Report
            WHERE Id = :reportId
            LIMIT 1
        ];

        String reportName = report.Name;
		System.Debug('reportName >> '+ reportName);
        // Fetch recipient email based on userId
        User recipient = [
            SELECT Email
            FROM User
            WHERE Id = :userId
            LIMIT 1
        ];
        String recipientEmail = recipient.Email;
        String recipientName = recipient.Name;
		*/
        
        //IPS_ReportController.emailReport('00OQy00000DtTZ3MAN','005Qy00000ABzs1IAD');
        String recipientEmail = 'bmarji@integratedpayorsolutions.com';
        String recipientName =  'Bassem Marji';    
        String reportName = 'List Of Reports';
		System.Debug('recipientEmail >> '+ recipientEmail);
        System.Debug('recipientName >> '+ recipientName);
        
        // Extract the report as a Blob
        Blob reportBlob = extractReport(reportId);
        System.Debug('reportBlob >> '+ reportBlob.size());

        // Create email attachment
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(reportName + '.xlsx');
        attachment.setBody(reportBlob);
        attachment.setContentType('application/vnd.ms-excel');

        // Prepare email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

        // Set recipient details
        email.setToAddresses(new String[] { recipientEmail });
        
        // Set email properties
        email.setSenderDisplayName(recipientName);
        email.setSubject('Report: ' + reportName);
        email.setHtmlBody(
            'Hello ' + recipientName + ',<br/><br/>Attached is the requested report: ' + reportName + '<br/><br/>Thank you.'
        );
        
        // Send the email
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        System.debug('results >> ' + results);
   }   
}