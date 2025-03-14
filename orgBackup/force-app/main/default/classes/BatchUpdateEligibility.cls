public class BatchUpdateEligibility implements Database.Batchable<SObject>{
    public BatchUpdateEligibility() {

    }
    
    public Database.QueryLocator start(Database.BatchableContext bC){
        Set<string> PatientIdSet=new Set<string>();


        for (AggregateResult ar : [Select IntPS__Patient__c patientID,
        count(ID)
        From IntPS__Eligibility__c
        Where IntPS__Term_Date__c = NULL  
        Group by IntPS__Patient__c Having count(ID)> 1 ]) {
            PatientIdSet.add((string)ar.get('patientID'));

        }


        String query = 'select id,'+
        '(Select ID, NAME, '+
        'IntPS__Begin_Date__c, '+
        'IntPS__Term_Date__c, '+
        'IntPS__Health_Plan__c  '+
        ' From IntPS__Eligibilitys__r '+
        ' where IntPS__Term_Date__c = NULL '+
        ' order by IntPS__Begin_Date__c desc ,createdDate desc )'+
        ' from IntPS__Patient__c where id IN:PatientIdSet';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bC, List<IntPS__Patient__c> patientList){
        
        List<IntPS__Eligibility__c> elgUpdateList=new List<IntPS__Eligibility__c> ();
        for(IntPS__Patient__c p:patientList){
            Integer idx = 0;
            date lastBeginDate ;
            for(IntPS__Eligibility__c elg: p.IntPS__Eligibilitys__r){
            
                if(idx > 0){
                    if(lastBeginDate>elg.IntPS__Begin_Date__c){
                        elg.IntPS__Term_Date__c=lastBeginDate.addDays(-1);
                    }else{
                        elg.IntPS__Term_Date__c=elg.IntPS__Begin_Date__c;
                    }
                
                    elgUpdateList.add(elg);
                }
            lastBeginDate=elg.IntPS__Begin_Date__c;
                idx++;
            }
        
        }
        if(!elgUpdateList.isEmpty()){
            update elgUpdateList;
        }
    }

    public void finish(Database.BatchableContext BC){

    }
}