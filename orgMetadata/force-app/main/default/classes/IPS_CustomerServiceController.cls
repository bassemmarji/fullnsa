public class IPS_CustomerServiceController {
	@AuraEnabled
    public static void sendEmail(String emailSubject, String emailBody) {
        
        String emailAddresses = System.Label.IPS_TroubleshootingTeam;
        List<String> toAddresses = new List<String>();
        
        // Split and trim collected email addresses
        for (String email : emailAddresses.split(',')) {
            toAddresses.add(email.trim());
        }
        
        // Ensure we have at least one valid email address
        if (toAddresses.isEmpty()) {
            System.debug('No valid email addresses found in custom label IPS_TroubleshootingTeam');
            return;
        }
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses);
        email.setSubject(emailSubject);
        email.setPlainTextBody(emailBody);
        
        try 
        {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            System.debug('Email sent successfully to: ' + String.join(toAddresses, ', '));
        } catch (Exception e) {
            System.debug('Failed to send email: ' + e.getMessage());
        }
    }

}