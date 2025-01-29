/**
 * @author Kemal Tekin
 * @date 02.22.2023
 *
 * @description
 * 
 */
public with sharing class HealthPlanContentNetworkTriggerHandler {
    public static void populateHPContent() {
       // Map < Id, IntPS_NSA__Health_Plan_Content_Network__c > oldMap = Trigger.oldMap;
        Set<Id> HPIDSet=new Set<Id>();
        
        for (IntPS_NSA__Health_Plan_Content_Network__c nt: (List<IntPS_NSA__Health_Plan_Content_Network__c >)Trigger.new) {
            if (nt.Is_Addt_Primary_Network__c==true && nt.IntPS_NSA__Health_Plan_Content__c==null && nt.Health_Plan__c!=null ) {
                HPIDSet.add(nt.Health_Plan__c);
            }
        }
        List<IntPS__Health_Plan_Content__c > dbHPList=[SELECT Id, IntPS__Provider_Network__c, IntPS__Health_Plan__c FROM 
        IntPS__Health_Plan_Content__c where IntPS__Provider_Network__c='In-Network'];
        Map<string, string> HpIdToHpcontentID = new Map<string, string>();
        for (IntPS__Health_Plan_Content__c hpc : dbHPList) {
            if(!HpIdToHpcontentID.containsKey(hpc.IntPS__Health_Plan__c)){
                HpIdToHpcontentID.put(hpc.IntPS__Health_Plan__c,hpc.Id);
            }
            
        }
        for (IntPS_NSA__Health_Plan_Content_Network__c nt: (List<IntPS_NSA__Health_Plan_Content_Network__c >)Trigger.new) {
            if (nt.Is_Addt_Primary_Network__c==true && nt.IntPS_NSA__Health_Plan_Content__c==null && nt.Health_Plan__c!=null ) {
               if (HpIdToHpcontentID.containsKey(nt.Health_Plan__c)) {
                nt.IntPS_NSA__Health_Plan_Content__c=HpIdToHpcontentID.get(nt.Health_Plan__c);
               }
                
            }
        }
    }

}