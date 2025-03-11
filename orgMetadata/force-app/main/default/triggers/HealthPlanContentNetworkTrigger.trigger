trigger HealthPlanContentNetworkTrigger  on IntPS_NSA__Health_Plan_Content_Network__c (before update,before insert) {

HealthPlanContentNetworkTriggerHandler.populateHPContent();

}