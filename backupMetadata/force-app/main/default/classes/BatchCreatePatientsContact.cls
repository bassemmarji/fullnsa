public class BatchCreatePatientsContact implements Database.Batchable < SObject > , Database.Stateful {
    
    public static final String SELECTED_USER_OPTION = [SELECT Option__c FROM NSA_Trigger_Configuration__mdt WHERE Is_Active__c = True AND DeveloperName ='Data_Upload_Configuration' LIMIT 1].Option__c;
    public static String CREATE_USER = 'Create User';
    public static String CREATE_ACCOUNT_CONTACT = 'Create Account and Contact';
    public static String fieldAPIname = '';
    private static String whereCondition = '';
    public ID plId;
    public BatchCreatePatientsContact(Id plId) {
        this.plId= plId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(getMembers());
    }

    public void execute(Database.BatchableContext BC, List < IntPS__Eligibility__c > scope) {
        if(SELECTED_USER_OPTION == 'None') {
            return;
        }

        System.debug('SELECTED_USER_OPTION ====> '+SELECTED_USER_OPTION);
        if(SELECTED_USER_OPTION == CREATE_USER) {
            // whereCondition+= ' AND IntPS__Patient__r.IntPS__Email__c!=NULL AND IntPS__Patient__r.IntPS__Not_Unique_Member_Id__c!=NULL';
            fieldAPIname = 'Create_User__c';
        } else if(SELECTED_USER_OPTION == CREATE_ACCOUNT_CONTACT){
            // whereCondition+= ' AND IntPS__Patient__r.IntPS__Not_Unique_Member_Id__c!=NULL ';
            fieldAPIname = 'Create_Account_Plan_Member__c';
        }
        System.debug('fieldAPIname ====> '+fieldAPIname);
        UpdatePatients(scope,fieldAPIname);
    }


    public void finish(Database.BatchableContext BC) {

       
    }
    public String getMembers() {
        if(SELECTED_USER_OPTION == CREATE_USER) {
            whereCondition+= ' AND IntPS__Patient__r.IntPS__Email__c!=NULL AND IntPS__Patient__r.IntPS__Not_Unique_Member_Id__c!=NULL';
            // fieldAPIname = 'Create_User__c';
        } else if(SELECTED_USER_OPTION == CREATE_ACCOUNT_CONTACT){
            whereCondition+= ' AND IntPS__Patient__r.IntPS__Not_Unique_Member_Id__c!=NULL ';
            // fieldAPIname = 'Create_Account_Plan_Member__c';
        }

        String query =' SELECT Id, IntPS__Patient__c,'+
        ' IntPS__Processing_Log__c,'+
        'IntPS__Patient__r.Create_Account_Plan_Member__c,'+
        ' IntPS__Patient__r.Create_Portal_Contact_Dependent__c,'+
        ' IntPS__Patient__r.IntPS__Email__c,'+
        ' IntPS__Patient__r.Portal_User__c FROM IntPS__Eligibility__c '+
        'where IntPS__Patient__r.Create_Account_Plan_Member__c=false and IntPS__Patient__r.Create_Portal_Contact_Dependent__c=false and '+
        'IntPS__Patient__r.Portal_User__c=null AND  IntPS__Patient__r.Record_Type_Name__c=\'Plan Member\' and IntPS__Processing_Log__c=\''+plId+'\''+
        whereCondition;
        
        return query;
    }
    public void UpdatePatients(List < IntPS__Eligibility__c > elgList,String fApiName) {
        Set<string> patientSet = new Set<string>();
        Map<String,String> emailSet = new Map<String,String>();
        for (IntPS__Eligibility__c elg : elgList) {
                if(String.isNotBlank(elg.IntPS__Patient__r.IntPS__Email__c) && SELECTED_USER_OPTION == CREATE_USER) {
                    String email = '';
                    email = elg.IntPS__Patient__r.IntPS__Email__c;
                    if(email.length()>40) {
                        email = email.substring(0,40);
                    }
                    emailSet.put(email,elg.IntPS__Patient__c);
                }
               patientSet.add(elg.IntPS__Patient__c);
            }
        if(SELECTED_USER_OPTION == CREATE_USER) {
            List<User> existingUsers = [SELECT CommunityNickname FROM User WHERE CommunityNickname IN:emailSet.keySet()];
            for (User xu : existingUsers) {
                if(emailSet.containsKey(xu.CommunityNickname)) {
                    emailSet.remove(xu.CommunityNickname);
                }
            }
            patientSet = new Set<String>(emailSet.values());
        }
        System.debug('UpdatePatients method-----');
        System.debug('SELECTED_USER_OPTION ====> '+SELECTED_USER_OPTION);
        System.debug('fieldAPIname ====> '+fApiName);
        
        System.enqueueJob(new AsyncPatientUpdate(patientSet,fApiName));
    
    }
}