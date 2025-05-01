public without sharing class ReportService {

    public static String generateReport(String reportId) {
        String instanceUrl = URL.getOrgDomainUrl().toExternalForm();
        String reportUrl = instanceUrl + '/' + reportId + '?isdtp=p1&csv=1';
        System.debug('ReportService - generateReport - reportUrl ='+reportUrl);
        
        PageReference reportPage = new PageReference(reportUrl);
        Blob reportBlob;
        try {
            reportBlob = reportPage.getContent();
        } catch (Exception e) {
            throw new AuraHandledException('Error generating report: ' + e.getMessage());
        }
        return reportBlob.toString();
    }
    
    
    public static ContentVersion saveGeneratedReport(BLOB reportBlob) {
           System.debug('saveGeneratedReport >>> reportBlob='+reportBlob);

           ContentVersion cv = new ContentVersion(
    	   	Title = 'Report.csv',
    	   	PathOnClient = 'Report.csv',
    	   	VersionData = reportBlob
		   );
		   insert cv;
			        
           System.debug('saveGeneratedReport >>> cv.Id='+cv.Id);
           return cv;
    }
    
    public static UserFiles__c saveUserArtifact(String eventId, String userId, String reportId) {
           UserFiles__c uf = new UserFiles__c(
               Event_ID__c  = eventId
              ,User_ID__c   = userId 
              ,Report_ID__c = reportId
              ,Status__c    = 'Successful'
              ,Message__c   = 'Report Generated'
           );
           Insert uf;
           return uf;
    }
    
    public static void attachFileToRecord(Id recordId, Id contentVersionId) {
        // Check if the ContentVersion exists
        ContentVersion cv = [
            SELECT Id, Title, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contentVersionId 
            LIMIT 1
        ];

        // Create ContentDocumentLink to associate file with record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = recordId; // Your UserFiles__c record ID
        cdl.ShareType = 'V'; // V = Viewer permission
        cdl.Visibility = 'AllUsers'; // or 'InternalUsers' based on your needs
        
        insert cdl;
    }
    
    @future(callout=true)
    public static void sendReportToUser(String eventId, String userId, String reportId) {
        try {
            // Run the report
            //Reports.ReportResults results = Reports.ReportManager.runReport(reportId, true);

            // Build CSV
            String csvBody = generateReport(reportId); //buildCSV(results);
			System.debug('sendReportToUser >>> csvBody='+csvBody);
            
            // Get user's email
            User user = [SELECT Email FROM User WHERE Id = :userId LIMIT 1];
            System.debug('sendReportToUser >>> user.Email='+user.Email);
            
			UserFiles__c uf = saveUserArtifact(eventId, userId, reportId);
            System.debug('Output Saved to UserFile >>> ='+uf.Id);
            
            ContentVersion cv = saveGeneratedReport(Blob.ValueOf(csvBody));
            System.debug('Output Saved to ContentVersion >>> ='+cv.Id);
            
            attachFileToRecord(uf.Id, cv.Id); 
            System.debug('ContentVersion Record ='+cv.Id + ' Is attached To UserFile Recodrd=' + uf.Id);
            
            // Create email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { user.Email });
            email.setSubject('Your Requested Report');
            email.setPlainTextBody('Please find your requested report attached.');
            
            // Add attachment
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('report.csv');
            attachment.setBody(Blob.valueOf(csvBody));
            attachment.setContentType('text/csv');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

            // Send email
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            System.debug('Email Successfully Sent '+results);
            
        } catch (Exception e) {
            System.debug('Error sending report: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
	public static List<Map<String, String>> getReports() {
        
        if (!Schema.sObjectType.Report.fields.Id.isAccessible()) {    
    		// Log or notify that the user has insufficient field access
    		System.debug('>>> Field ID is not accessible');
		}
        
        if (!Schema.sObjectType.Report.fields.Name.isAccessible()) {    
    		// Log or notify that the user has insufficient field access
    		System.debug('>>> Field Name is not accessible');
		}   
        
        if (!Schema.sObjectType.Report.fields.FolderName.isAccessible()) {    
    		// Log or notify that the user has insufficient field access
    		System.debug('>>> Field FolderName is not accessible');
		}
        
    	List<Map<String, String>> reportList = new List<Map<String, String>>();

    	try {
        	// Query the Report object for Id and Name (Label)
        	List<Report_Metadata__c> reports = [SELECT Report_Id__c, Report_Name__c FROM Report_Metadata__c];

        	// Format the results as a list of maps
        	for (Report_Metadata__c rpt : reports) {
            	Map<String, String> reportDetails = new Map<String, String>{
                	'Id' => rpt.Report_Id__c,
                	'Name' => rpt.Report_Name__c
            	};
            	reportList.add(reportDetails);
        	}
    	} 
    	catch (SecurityException e) {
        	// Handle security-related exceptions (e.g., field or object access issues)
        	System.debug(LoggingLevel.ERROR, 'SecurityException: ' + e.getMessage());
    	}
    	catch (QueryException e) {
        	// Handle SOQL-specific exceptions
        	System.debug(LoggingLevel.ERROR, 'QueryException: ' + e.getMessage());
    	}
    	catch (Exception e) {
        	// Handle all other exceptions
        	System.debug(LoggingLevel.ERROR, 'General Exception: ' + e.getMessage());
    	}

    	return reportList;
   	}
}