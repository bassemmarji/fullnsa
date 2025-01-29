public with sharing class AsyncPatientUpdate implements Queueable {

    public Set< String > idSet ;        
    public String checkboxAPIname;


    /**
     * 
     * @param checkboxAPIname 
     */
    public AsyncPatientUpdate(Set< String > idSet,String checkboxAPIname) {
        this.idSet = idSet ;    
        this.checkboxAPIname = checkboxAPIname;
       
    }

    public void execute(QueueableContext context) {
        System.debug('API NAME ==========> '+this.checkboxAPIname);
        List<IntPS__Patient__c> ptist=new List<IntPS__Patient__c> ();
        for(String ptid:idSet){
            IntPS__Patient__c pt=new IntPS__Patient__c();
            pt.id=ptid;
            pt.put(this.checkboxAPIname,true);
            ptist.add(pt);     
        }
        //try {
            if(!ptist.isEmpty()) {
                update ptist;
            }
        //} catch(Exception e) {
        //    IntPS_NSA__NSA_Error_Log__c nsaError = new IntPS_NSA__NSA_Error_Log__c();
        //    nsaError.IntPS_NSA__Error_Message__c = 'Cause: '+e.getCause()+'\n'+'Line Number: '+e.getLineNumber()+'\n'+
        //    'Message: '+e.getMessage()+'\n'+'Type Name: '+e.getTypeName()+'\n'+'Stack Trace: '+e.getStackTraceString();
        //    nsaError.IntPS_NSA__Status__c = 'Failed';
        //    nsaError.IntPS_NSA__Error_Stage__c = 'Count: '+String.valueOf(ptist.size())+'\n'+'Affected Patient Ids: \n'+JSON.serialize(idSet);
        //    insert nsaError;
        //    // String currentUserId = [SELECT CreatedById FROM IntPS_NSA__NSA_Error_Log__c WHERE Id=:nsaError.Id].CreatedById;
        //    Task task = new Task();
        //    task.WhatId = nsaError.Id;
        //    task.Status = 'Not Started';
        //    task.Subject = 'Other';
        //    task.Type = 'Other';
        //    // task.Owner.Id = currentUserId;
        //    insert task;
        //}
    }
}