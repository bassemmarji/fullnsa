@IsTest
public with sharing class disclaimerControllerTest {

    @IsTest
    public static void createEOBSuccess() {
        User user1 = new User();  
        user1 = [Select Id, T_C_Acceptance__c,T_C_Acceptance_Date__c from User where id=: userinfo.getUserId()];  
        test.startTest();
        disclaimerController.aknowledgeUser(user1.Id);       
        test.stopTest();
    }
     

}