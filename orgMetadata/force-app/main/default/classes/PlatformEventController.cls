public with sharing class PlatformEventController {
       @AuraEnabled(cacheable=false)
	   public static String publishPlatformEvent(String reportId, String userId) {
              try 
    		  {
                System.debug('>>> publishPlatformEvent >>> reportId='+reportId+' - userId=' + userId);
                  
                // Generate a unique EventUuid
                //String eventId = String.valueOf(Crypto.generateDigest('SHA-256', Blob.valueOf(String.valueOf(Datetime.now()))));
                Blob hash = Crypto.generateDigest('SHA-256', Blob.valueOf(String.valueOf(Datetime.now())));
				String eventId = EncodingUtil.convertToHex(hash);
                  
                Email_Request__e event = new Email_Request__e(Event_ID__c =eventId,Report_ID__c=reportId,User_ID__c=userId);  
                // Publish the event
        		EventBus.publish(event);
                System.debug('>>> publishPlatformEvent >>> eventId='+eventId + ' - reportId='+reportId+' - userId=' + userId);
                return eventId;
                  
  				/*
				List<Email_Request__e> emailRequestListEvent = new List<Email_Request__e>();
                emailRequestListEvent.add(new Email_Request__e(Report_ID__c=reportId,User_ID__c=userId));
                List<Database.SaveResult> srList = EventBus.publish(emailRequestListEvent);
                  
                for (Database.SaveResult srItem:srList){
                    if (srItem.isSuccess()){
                        System.debug('publishPlatformEvent >>> Platform Event Published Successfully...');
                    }
                    else {
                        List <Database.Error> errList = srItem.getErrors();
                        for (Database.error errorDetail:errList) {
                             System.debug('Error Detail = ' + errorDetail.getMessage());
                        }
                    }
                }   
				*/
               } catch (SecurityException e) {
        		 System.debug('publishPlatformEvent >>> Error SecurityException: ' + e.getMessage());
        		 throw new AuraHandledException(e.getMessage());
    		   } catch (Exception e) {
        		 System.debug('publishPlatformEvent >>>  Error: ' + e.getMessage());
        		 throw new AuraHandledException(e.getMessage());
    		   }
			
       }
    
       @AuraEnabled(cacheable=true)
       public static String getEventStatus(String eventId) {
         try { 
        	// Query UserFiles__c for a matching EventUuid
        	List<UserFiles__c> userFiles = [SELECT Id 
                                              FROM UserFiles__c 
                                             WHERE Event_ID__c = :eventId 
                                             LIMIT 1];
            if (userFiles.isEmpty()){
               return 'Pending'; // Default status if no record exists
            }
            return 'Completed';
         } catch (Exception e) {
           // Log the error and return a default status
           System.debug('Error fetching event status: ' + e.getMessage());
           return 'Failed'; // Optionally return an error status
    	 }   
       }
    
     @AuraEnabled(cacheable=true)
     public static List<Map<String, Object>> getEventAttachedFiles(String eventId) {
        // Step 1: Query the UserFiles__c record by EventUuid
        UserFiles__c userFile = [SELECT Id FROM UserFiles__c WHERE Event_ID__c = :eventId LIMIT 1];

        if (userFile == null) {
            throw new AuraHandledException('No UserFiles__c record found for the given EventUuid');
        }

        // Step 2: Query ContentDocumentLink records linked to the UserFiles__c record
        List<ContentDocumentLink> contentLinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :userFile.Id
        ];

        if (contentLinks.isEmpty()) {
            return new List<Map<String, Object>>(); // Return an empty list if no files are attached
        }

        // Step 3: Extract ContentDocumentIds from ContentDocumentLink
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : contentLinks) {
            contentDocumentIds.add(link.ContentDocumentId);
        }

        // Step 4: Query ContentVersion records to get file details
        List<ContentVersion> contentVersions = [
            SELECT Title, FileExtension, ContentUrl, VersionData
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds AND IsLatest = true
        ];

        // Step 5: Format the results as a list of maps
        List<Map<String, Object>> files = new List<Map<String, Object>>();
        for (ContentVersion cv : contentVersions) {
            Map<String, Object> fileDetails = new Map<String, Object>{
                'Title' => cv.Title,
                'FileExtension' => cv.FileExtension,
                'ContentUrl' => '/sfc/servlet.shepherd/version/download/' + cv.Id // URL to download the file
            };
            files.add(fileDetails);
        }

        return files;
    }
}