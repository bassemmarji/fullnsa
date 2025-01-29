@RestResource(urlMapping='/ProcedureCodes/*')
global class ProcedureCodeWebService {
	@HttpGet
    global static List<IntPS__Procedure_Code__c> getProcedureCodes() {
           List<IntPS__Procedure_Code__c> result = [SELECT Id, Name From IntPS__Procedure_Code__c Limit 1];
           return result;    
    }
}