@IsTest(SeeAllData=true)
public class ExperienceTest {
    @isTest
    static void testCommunityUser(){
           User u = [SELECT Id FROM User WHERE Id ='005Qy00000ABzs1IAD'];
           System.debug('User='+u.Id);
           
        
           System.runAs(u) {
            System.debug('Before');
            System.debug('UserName='+UserInfo.getUserName());
            System.debug('User Profile='+UserInfo.getProfileId());
               
            if (Schema.SobjectType.IntPS__Eligibility__c.isaccessible()){
                System.debug('User has permission to query Eligibility Records');
            }
               
            if (Schema.SobjectType.IntPS__Health_Plan__c.fields.IntPS_NSA__Plan_Type__c.isAccessible()){
                System.debug('User has permission to IntPS__Health_Plan__c.IntPS_NSA__Plan_Type__c');
            }   

            if (Schema.SobjectType.IntPS__Health_Plan__c.fields.Plan_Type__c.isAccessible()){
                System.debug('User has permission to IntPS__Health_Plan__c.Plan_Type__c');
            }   
               
            List <Contact> contactList = [Select Id from Contact];
            System.debug('contactList=' + contactList);

            List <IntPS_NSA__Release__c> releasedList = [Select Id, Name from IntPS_NSA__Release__c];
            System.debug('releasedList=' + releasedList);
               
            List <PicklistValueInfo> res = [SELECT Label,Value FROM PicklistValueInfo WHERE EntityParticle.EntityDefinition.QualifiedApiName = 'IntPS__EOB_Line_Item__c' 
                AND EntityParticle.QualifiedApiName = 'Provider_Type__c' and isActive = true LIMIT 1000];
            System.debug('res=' + res);   
            
               
            System.debug('11111');
            try
            {   
            	Http http = new Http();
            	HttpRequest request = new HttpRequest();
            	request.setEndpoint('/services/data/v62.0/ui-api/object-info/IntPS__EOB_Line_Item__c/picklist-values/012000000000000AAA/Provider_Type__c');
            	request.setMethod('Get');
            	HttpResponse response = http.send(request);
            	System.debug('response=');
            	System.debug('response=' + response.getStatusCode());
            	System.debug('response=' + response.getBody());
            } catch (Exception ex){
              System.debug('Error='+ex.getMessage());  
            }
            System.debug('22222');   
               
            List < IntPS__Patient__c > patientList = [Select Id, Name from IntPS__Patient__c];
            System.debug('patientList=' + patientList);   
            //aboutSalesforce.com 2019 10 field-level-security-in-apex-with
            SObjectAccessDecision   strippedRecords;
            strippedRecords = Security.stripInaccessible(AccessType.READABLE, [Select Id, Name From IntPS__Health_Plan__c]); 
            System.debug( 'strippedRecords ='+ (List<IntPS__Health_Plan__c>)strippedRecords.getRecords() );
            
            try{
			   List < IntPS__Eligibility__c > properEligibilityList = [SELECT Id
                                                                    , IntPS__Health_Plan__c
                                                                    , IntPS__Health_Plan__r.Name
                                                                    , IntPS__Health_Plan__r.IntPS_NSA__Plan_Type__c
                                                                    , IntPS__Health_Plan__r.Plan_Type__c
                                                                    , IntPS__Payer_Name__c
                                                                    , IntPS__Payer_Name__r.Name
                                                                    , IntPS__Begin_Date__c
                                                                    , IntPS__Term_Date__c
                                                                    ,IntPS__Patient__r.IntPS__Employer__c
                                                                    ,IntPS__Patient__c
                                                                    ,IntPS__Patient__r.IntPS__Employer__r.Name 
                                                                    FROM IntPS__Eligibility__c 
                                                                   WHERE IntPS__Patient__c in ('a0QQy00000EKUEUMA5')
                                                                     //and IntPS__Health_Plan__r.IntPS_NSA__Plan_Type__c = 'Medical' 
                                                                      //or IntPS__Health_Plan__r.Plan_Type__c = 'Medical'
                                                                    //ORDER BY IntPS__Begin_Date__c DESC
                                                                    WITH SECURITY_ENFORCED
                                                                    ];
              System.debug('properEligibilityList=' + properEligibilityList);
            } catch (Exception ex){
              System.debug('Error='+ex.getMessage());  
            }
               
            List < IntPS_NSA__Health_Plan_Content_Network__c > result = new List < IntPS_NSA__Health_Plan_Content_Network__c > ();
       
            try {
          
               ///----------------------
               result = [Select Id,IntPS_NSA__Services__c,IntPS_NSA__RbP_Percentage__c, IntPS_NSA__Priority__c
                     , IntPS_NSA__Network__r.Name, IntPS_NSA__RbP_Basis__c, IntPS_NSA__RbP__c
                     , IntPS_NSA__Network__r.IntPS_NSA__External_ID__c, IntPS_NSA__Network__c
                     , IntPS_NSA__Health_Plan_Content__c
                     , IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c 
                     from IntPS_NSA__Health_Plan_Content_Network__c 
                     where IntPS_NSA__Health_Plan_Content__r.IntPS__Health_Plan__c = 'a0HQy000003OKYbMAO'
                     //and (IntPS_NSA__Patient__c='' or IntPS_NSA__Patient__c='a0QQy00000EKUEUMA5' )
                     ];
               System.debug('result ' + result);
 
            } catch (Exception ex) {
               System.debug('Error='+ex.getMessage());  
            }
			
            String objectName = 'IntPS__EOB_Line_Item__c';
            String fieldName ='Provider_Type__c';
  
			Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName) ;
			Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
			Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
			Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry pickListVal : ple){
    			System.debug(pickListVal.getLabel() +' '+pickListVal.getValue() + ' '+pickListVal.isActive());
			}   
             
            System.debug('After');
       }
    }
}