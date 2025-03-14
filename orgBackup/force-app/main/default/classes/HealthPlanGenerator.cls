/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-19-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class HealthPlanGenerator {
    @AuraEnabled
    public static List <IntPS__Health_Plan_Item__c> getHpi(String healthPlanContentId) {
        System.debug('------------------healthPlanContentId'+healthPlanContentId);
        if (healthPlanContentId!=null) {
            List <IntPS__Health_Plan_Item__c> hpItemList= [SELECT ID, Name From IntPS__Health_Plan_Item__c Where IntPS__Health_Plan_Content__c =: healthPlanContentId];       
        return hpItemList; 
        }else {
            return null;
        }
    }

    @AuraEnabled
    public static List<IntPS__Health_Plan_Item__c> getCloneHpiStructure(String healthPlanItemId){
        IntPS__Health_Plan_Item__c hpi = [SELECT ID, 
        
                                                Name, 
                                                IntPS__Add_to_Deductible_Amount__c, 
                                                IntPS__After_Plan_Deductible__c, 
                                                IntPS__Benefit_Step__c, 
                                                IntPS__Coinsurance__c, 
                                                IntPS__Copay__c, 
                                                IntPS__Description__c, 
                                                IntPS__Health_Plan__c, 
                                                IntPS__Health_Plan_Content__c, 
                                                IntPS__Maximum_Benefit__c, 
                                                IntPS__Maximum_Number_Per_Admission__c, 
                                                IntPS__Maximum_Number_Per_Year__c, 
                                                IntPS__Maximum_Paid_Amount__c, 
                                                IntPS__Not_Covered__c,
                                                IntPS__Procedure_Code_Classification__c, 
                                                NSA_Classification__c,
                                                IntPS__Provider_Network__c From IntPS__Health_Plan_Item__c Where Id =: healthPlanItemId];
        List<IntPS__Health_Plan_Item__c> hpiClone = new List<IntPS__Health_Plan_Item__c>();
        hpiClone.add(hpi.clone(false,false,false,false));
        return hpiClone;
    }

    @AuraEnabled
    public static List <IntPS__Health_Plan_Item__c> getHpiStructure(String healthPlanContentId) {
        System.debug('------------------healthPlanContentId'+healthPlanContentId);
        List <IntPS__Health_Plan_Item__c> hpiListClone=new  List <IntPS__Health_Plan_Item__c>();
        if (healthPlanContentId!=null) {
            List <IntPS__Health_Plan_Item__c> hpiList= [SELECT ID, 
                                                               Name, 
                                                               IntPS__Add_to_Deductible_Amount__c, 
                                                               IntPS__After_Plan_Deductible__c, 
                                                               IntPS__Benefit_Step__c, 
                                                               IntPS__Coinsurance__c, 
                                                               IntPS__Copay__c, 
                                                               IntPS__Description__c, 
                                                               IntPS__Health_Plan__c, 
                                                               IntPS__Health_Plan_Content__c, 
                                                               IntPS__Maximum_Benefit__c, 
                                                               IntPS__Maximum_Number_Per_Admission__c, 
                                                               IntPS__Maximum_Number_Per_Year__c, 
                                                               IntPS__Maximum_Paid_Amount__c, 
                                                               IntPS__Not_Covered__c,
                                                               IntPS__Procedure_Code_Classification__c,
                                                               NSA_Classification__c,
                                                               IntPS__Provider_Network__c From IntPS__Health_Plan_Item__c Where IntPS__Health_Plan_Content__c =: healthPlanContentId ]; 
            
            String HPCid = hpiList[0].IntPS__Health_Plan_Content__c;
            System.debug('------------------HPCid'+HPCid);
                for(IntPS__Health_Plan_Item__c hpi:hpiList){
                    //if(HPCid == hpi.IntPS__Health_Plan_Content__c){
                        IntPS__Health_Plan_Item__c hpiClone = hpi.clone(false,false,false,false);
                        IntPS__Health_Plan_Item__c hpiLast = new IntPS__Health_Plan_Item__c();
                       // insert hpiLast;
                        System.debug('------------------hpiLast'+ hpiLast);
                        hpiLast.Name = hpi.Name;
                        hpiLast.IntPS__Add_to_Deductible_Amount__c = hpi.IntPS__Add_to_Deductible_Amount__c;
                        hpiLast.IntPS__After_Plan_Deductible__c = hpi.IntPS__After_Plan_Deductible__c;
                        hpiLast.IntPS__Benefit_Step__c = hpi.IntPS__Benefit_Step__c;
                        hpiLast.IntPS__Coinsurance__c = hpi.IntPS__Coinsurance__c;
                        hpiLast.IntPS__Copay__c = hpi.IntPS__Copay__c;
                        hpiLast.IntPS__Description__c = hpi.IntPS__Description__c;
                        hpiLast.IntPS__Health_Plan__c = hpi.IntPS__Health_Plan__c;
                        hpiLast.IntPS__Health_Plan_Content__c = hpi.IntPS__Health_Plan_Content__c;
                        hpiLast.IntPS__Maximum_Benefit__c = hpi.IntPS__Maximum_Benefit__c;
                        hpiLast.IntPS__Maximum_Number_Per_Admission__c = hpi.IntPS__Maximum_Number_Per_Admission__c;
                        hpiLast.IntPS__Maximum_Number_Per_Year__c = hpi.IntPS__Maximum_Number_Per_Year__c;
                        hpiLast.IntPS__Maximum_Paid_Amount__c = hpi.IntPS__Maximum_Paid_Amount__c;
                        hpiLast.IntPS__Not_Covered__c = hpi.IntPS__Not_Covered__c;
                        hpiLast.IntPS__Procedure_Code_Classification__c = hpi.IntPS__Procedure_Code_Classification__c;
                        hpiLast.NSA_Classification__c=hpi.NSA_Classification__c;
                        hpiLast.IntPS__Provider_Network__c = hpi.IntPS__Provider_Network__c;
                        hpiListClone.add(hpiLast);
                   // }
                }
                //insert hpiListClone;
        System.debug('------------------hpiListClone'+hpiListClone);
        System.debug('------------------hpiListClone.size()'+hpiListClone.size());
        return hpiListClone; 
        }else {
            return null;
        }
    }

    @AuraEnabled
    public static List<IntPS__Health_Plan_Content__c> getSingleHPC(String healthPlanContentId) {
        System.debug('------------------healthPlanContentId'+healthPlanContentId);
        List <IntPS__Health_Plan_Content__c> hpcListClone=new  List <IntPS__Health_Plan_Content__c>();
        if (healthPlanContentId!=null) {
            List<IntPS__Health_Plan_Content__c> hpcList= [SELECT ID, Name, IntPS__Cross_Accumulate__c, IntPS__Claim_Type__c, IntPS__Deductible_Calculation_Type__c, IntPS__Health_Plan__c, IntPS__Out_Of_Pocket_Calculation_Type__c, IntPS__Out_of_Pocket_Max_Family__c, IntPS__Out_of_Pocket_Max_Individual__c, IntPS__Plan_Deductible_Family__c, IntPS__Plan_Deductible_Individual__c, IntPS__Provider_Network__c  From IntPS__Health_Plan_Content__c Where Id =: healthPlanContentId];    
            for(IntPS__Health_Plan_Content__c hpc:hpcList){   
            IntPS__Health_Plan_Content__c hpcClone = hpc.clone(false,false,false,false);
            IntPS__Health_Plan_Content__c hpcLast = new IntPS__Health_Plan_Content__c();
            hpcLast.Name = hpcClone.Name;
            hpcLast.IntPS__Deductible_Calculation_Type__c = hpcClone.IntPS__Deductible_Calculation_Type__c;
            hpcLast.IntPS__Health_Plan__c = hpcClone.IntPS__Health_Plan__c;
            hpcLast.IntPS__Out_Of_Pocket_Calculation_Type__c = hpcClone.IntPS__Out_Of_Pocket_Calculation_Type__c;
            hpcLast.IntPS__Out_of_Pocket_Max_Family__c = hpcClone.IntPS__Out_of_Pocket_Max_Family__c;
            hpcLast.IntPS__Out_of_Pocket_Max_Individual__c = hpcClone.IntPS__Out_of_Pocket_Max_Individual__c;
            hpcLast.IntPS__Plan_Deductible_Family__c = hpcClone.IntPS__Plan_Deductible_Family__c;
            hpcLast.IntPS__Plan_Deductible_Individual__c = hpcClone.IntPS__Plan_Deductible_Individual__c;
            hpcLast.IntPS__Provider_Network__c = hpcClone.IntPS__Provider_Network__c;
            hpcLast.IntPS__Cross_Accumulate__c = hpcClone.IntPS__Cross_Accumulate__c;
            hpcLast.IntPS__Claim_Type__c = hpcClone.IntPS__Claim_Type__c;
            hpcListClone.add(hpcLast);
            }
        return hpcListClone; 
        }else {
            return null;
        }
    }

    @AuraEnabled
    public static Lıst <IntPS__Health_Plan_Content__c> getHpContent(String healthPlanId) {
        System.debug('------------------healthPlanId'+healthPlanId);
        if (healthPlanId!=null) {
            List <IntPS__Health_Plan_Content__c> hpcList= [SELECT ID, Name From IntPS__Health_Plan_Content__c Where IntPS__Health_Plan__c =: healthPlanId];  
            System.debug('------------------hpcList'+hpcList);     
        return hpcList; 
        }else {
            System.debug('------------------null');     
            return null;
        }
    }

    @AuraEnabled
    public static void deleteListData(List<SObject> hpItemList) {
        System.debug('------------------hpItemList'+hpItemList);
          delete hpItemList; 
    }

    @AuraEnabled
    public static void deleteHPC(List<Id> hpcIdList) {
        System.debug('------------------hpcIdList'+hpcIdList);
          delete [SELECT Id From IntPS__Health_Plan_Item__c Where IntPS__Health_Plan_Content__c IN : hpcIdList]; 
          delete  [SELECT Id From IntPS__Health_Plan_Content__c Where Id IN : hpcIdList];
    }

    @AuraEnabled
    public static void deleteHP(List<Id> hpIdList) {
        System.debug('------------------hpIdList'+hpIdList);
        Map <Id,IntPS__Health_Plan_Content__c> hpcList = new Map <Id,IntPS__Health_Plan_Content__c> ([SELECT Id FROM IntPS__Health_Plan_Content__c WHERE IntPS__Health_Plan__c IN:hpIdList]);
        List<Id> idList = new List<Id>();
        idList.addAll(hpcList.keySet());
        deleteHPC(idList);
        delete [SELECT Id From IntPS__Health_Plan__c Where Id IN : hpIdList];
    }

    @AuraEnabled
    public static CloneStructureResponse deepCloneStructureMethod(String healthPlanId){
        System.debug('------------------geldim');
        List<IntPS__Health_Plan_Content__c> hpcCloneList = new  List<IntPS__Health_Plan_Content__c>();
        List<IntPS__Health_Plan__c> hpCloneList = new List<IntPS__Health_Plan__c>();
        CloneStructureResponse response = new CloneStructureResponse();
        if (healthPlanId != null) {
            IntPS__Health_Plan__c hpMainRecord = [SELECT Id, 
                                                  Name,
                                                  IntPS__Deductible_Calculation_Type__c, 
                                                  IntPS__Out_Of_Pocket_Calculation_Type__c, 
                                                  IntPS__Out_of_Pocket_Max_Family__c, 
                                                  IntPS__Out_of_Pocket_Max_Individual__c, 
                                                  IntPS__ExternalID__c,
                                                  IntPS__Employer__c,
                                                  IntPS__Begin_Date__c,
                                                  IntPS_NSA__Disclaimer__c,
                                                  IntPS__Plan_Deductible_Family__c, 
                                                  IntPS__Plan_Deductible_Individual__c FROM IntPS__Health_Plan__c WHERE Id =: healthPlanId];

            List <IntPS__Health_Plan_Content__c> hpcMainRecordList = [SELECT Id,
                                                                      Name, 
                                                                      IntPS__Claim_Type__c, 
                                                                      IntPS__Cross_Accumulate__c, 
                                                                      IntPS__Deductible_Calculation_Type__c, 
                                                                      IntPS__Health_Plan__c, 
                                                                      IntPS__Out_Of_Pocket_Calculation_Type__c, 
                                                                      IntPS__Out_of_Pocket_Max_Family__c, 
                                                                      IntPS__Out_of_Pocket_Max_Individual__c, 
                                                                      IntPS__Plan_Deductible_Family__c, 
                                                                      IntPS__Plan_Deductible_Individual__c, 
                                                                      IntPS__Provider_Network__c,
                                                                      Cloned_Content_Id__c FROM IntPS__Health_Plan_Content__c WHERE IntPS__Health_Plan__c =: healthPlanId];             
            
            hpCloneList.add(hpMainRecord.clone(false,false,false,false));
            for(IntPS__Health_Plan_Content__c hpc : hpcMainRecordList){
                IntPS__Health_Plan_Content__c hpcClone = hpc.clone(false,false,false,false);
                hpcClone.Cloned_Content_Id__c = hpc.Id;
                hpcCloneList.add(hpcClone);
            }
            response.hpClone = hpCloneList;
            response.hpcCloneList = hpcCloneList;

            System.debug('------------------hpCloneList'+hpCloneList);
            System.debug('------------------hpcCloneList'+hpcCloneList);
        }
            return response; 
    }

    @AuraEnabled
    public static String deepCloneInsertHPItemsMethod(String originalHPCId, String clonedHPCId, String clonedHPId){
        List <IntPS__Health_Plan_Item__c> hpiCloneList = new  List <IntPS__Health_Plan_Item__c>();
        String error = '';
        if (originalHPCId != null || clonedHPCId != null) {
            List <IntPS__Health_Plan_Item__c> hpiList= [SELECT ID, 
                                                        Name, 
                                                        IntPS__Add_to_Deductible_Amount__c, 
                                                        IntPS__After_Plan_Deductible__c, 
                                                        IntPS__Benefit_Step__c, 
                                                        IntPS__Coinsurance__c, 
                                                        IntPS__Copay__c, 
                                                        IntPS__Description__c, 
                                                        IntPS__Health_Plan__c, 
                                                        IntPS__Health_Plan_Content__c, 
                                                        IntPS__Maximum_Benefit__c, 
                                                        IntPS__Maximum_Number_Per_Admission__c, 
                                                        IntPS__Maximum_Number_Per_Year__c, 
                                                        IntPS__Maximum_Paid_Amount__c, 
                                                        IntPS__Not_Covered__c,
                                                        IntPS__Procedure_Code_Classification__c,
                                                        NSA_Classification__c,
                                                        IntPS__Provider_Network__c,
                                                        Remark_Code__c,
                                                        Is_Exceptional_Case__c From IntPS__Health_Plan_Item__c Where IntPS__Health_Plan_Content__c =: originalHPCId ]; 
            for(IntPS__Health_Plan_Item__c hpi : hpiList){
                IntPS__Health_Plan_Item__c hpiClone = hpi.clone(false,false,false,false);
                hpiClone.IntPS__Health_Plan_Content__c = clonedHPCId;
                hpiClone.IntPS__Health_Plan__c = clonedHPId;
                hpiCloneList.add(hpiClone);
            }
            
        }
        try{
            insert hpiCloneList;
        }
        catch(Exception e){
            error = e.getMessage(); 
        }

        if(!String.isBlank(error)){
            return error;
        }else{
            return null;
        }
    }

    @AuraEnabled
    public static DataTableResponse getAllCriterias(){
        DataTableResponse response = new DataTableResponse();
        List<DataTableField> fieldList = new List<DataTableField>();
        List<IntPS__Criteria__c> criteriaList = [SELECT Id, 
                                                 Name,
                                                 IntPS__Condition__c, 
                                                 IntPS__Default_Result__c, 
                                                 IntPS__Description__c, 
                                                 IntPS__Entity_Type__c, 
                                                 IntPS__Field__c, 
                                                 IntPS__Friendly_Name__c, 
                                                 IntPS__Index__c, 
                                                 IntPS__Value__c  FROM IntPS__Criteria__c WHERE IntPS__Entity_Type__c = 'CMS1500_ServiceLine__c'];

        Map<String, Schema.SObjectField> fieldsLists = Schema.SObjectType.IntPS__Criteria__c.fields.getMap();
        System.debug('fieldsLists-------------' + fieldsLists);
        for(Schema.SObjectField field : fieldsLists.values()){
            String apiName = String.valueOf(field.getDescribe().getName());
            if(String.valueOf(field.getDescribe().getName()).contains('__c') || String.valueOf(field.getDescribe().getName()) == 'Name'){
                DataTableField datafields = new DataTableField( String.valueOf(field.getDescribe().getLabel()),
                                                                String.valueOf(field.getDescribe().getName()), 
                                                                String.valueOf(field.getDescribe().getType()).toLowerCase());
                fieldList.add(datafields);
            }
        } 
        
        System.debug('criteriaList-------------' + criteriaList);
        System.debug('fieldList-------------' + fieldList);
        response.lstDataTableData = criteriaList;
        response.lstDataTableFields = fieldList;
        return response;
    }

    @AuraEnabled
    public static DataTableResponse getAllMatchingRule(String healthPlanItemId){
        DataTableResponse response = new DataTableResponse();
        List<DataTableField> fieldList = new List<DataTableField>();
        List<IntPS__Matching_Rule__c> matchingRuleList = [SELECT Id, Name, IntPS__Entity_Type__c, IntPS__Logic__c,IntPS__Health_Plan_Item__c,  IntPS__Ignore__c,  IntPS__Parent_Rule__c FROM IntPS__Matching_Rule__c WHERE IntPS__Health_Plan_Item__c =: healthPlanItemId];
        
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>();
        Schema.DescribeFieldResult F = IntPS__Matching_Rule__c.Name.getDescribe();
        Schema.sObjectField T = F.getSObjectField();
        fields.add(T);

        Schema.DescribeFieldResult F1 = IntPS__Matching_Rule__c.IntPS__Entity_Type__c.getDescribe();
        Schema.sObjectField T1 = F1.getSObjectField();
        fields.add(T1);

        Schema.DescribeFieldResult F2 = IntPS__Matching_Rule__c.IntPS__Logic__c.getDescribe();
        Schema.sObjectField T2 = F2.getSObjectField();
        fields.add(T2);

        Schema.DescribeFieldResult F3 = IntPS__Matching_Rule__c.IntPS__Ignore__c.getDescribe();
        Schema.sObjectField T3 = F3.getSObjectField();
        fields.add(T3);

        Schema.DescribeFieldResult F4 = IntPS__Matching_Rule__c.IntPS__Parent_Rule__c.getDescribe();
        Schema.sObjectField T4 = F4.getSObjectField();
        fields.add(T4);

        //Map<String, Schema.SObjectField> fieldsLists = Schema.SObjectType.IntPS__Matching_Rule__c.fields.getMap();
        //System.debug('fieldsLists-------------' + fieldsLists);
        for(Schema.SObjectField field : fields){
            String apiName = String.valueOf(field.getDescribe().getName());
            if(String.valueOf(field.getDescribe().getName()).contains('__c') || String.valueOf(field.getDescribe().getName()) == 'Name'){
                DataTableField datafields = new DataTableField( String.valueOf(field.getDescribe().getLabel()),
                                                                String.valueOf(field.getDescribe().getName()), 
                                                                String.valueOf(field.getDescribe().getType()).toLowerCase());
                fieldList.add(datafields);
            }
        } 
        
        System.debug('matchingRuleList-------------' + matchingRuleList);
        System.debug('fieldList-------------' + fieldList);
        response.lstDataTableData = matchingRuleList;
        response.lstDataTableFields = fieldList;
        return response;
    }

    @AuraEnabled
    public static void createMatchingRule(String matchingRuleLogic, String healthPlanItemId){
        //belki lwc tarafında yaratılabilinir.
        System.debug('matchingRuleLogic-------------' + matchingRuleLogic);
        System.debug('healthPlanItemId-------------' + healthPlanItemId);
        IntPS__Matching_Rule__c mRule = new IntPS__Matching_Rule__c();
        mRule.IntPS__Logic__c = matchingRuleLogic;
        mRule.IntPS__Health_Plan_Item__c = healthPlanItemId;
        mRule.IntPS__Entity_Type__c = 'CMS1500_ServiceLine__c';
        insert mRule;
        //List<IntPS__Matching_Rule__c> mRuleList = [SELECT Id, IntPS__Logic__c, IntPS__Health_Plan_Item__c FROM IntPS__Matching_Rule__c];
    }

    @AuraEnabled
    public static List<IntPS__Health_Plan_Content__c> getHPContentSummaryStructure(String healthPlanId){
        List<IntPS__Health_Plan_Content__c> hpcList = [SELECT Id, 
                                                              IntPS__Deductible_Calculation_TypeF__c, 
                                                              IntPS__Out_Of_Pocket_Calculation_TypeF__c,  
                                                              IntPS__Plan_Deductible_IndividualF__c, 
                                                              IntPS__Plan_Deductible_FamilyF__c, 
                                                              IntPS__Out_of_Pocket_Max_IndividualF__c, 
                                                              IntPS__Out_of_Pocket_Max_FamilyF__c,
                                                              IntPS__Provider_Network__c, 
                                                              IntPS__Health_Plan__c, 
                                                              IntPS__Claim_Type__c FROM IntPS__Health_Plan_Content__c WHERE  IntPS__Health_Plan__c =: healthPlanId AND IntPS__Claim_Type__c = 'Medical' ]; //AND IntPS__Claim_Type__c = 'Medical'
        return hpcList;
    }

    @AuraEnabled
    public static Map<String, Map<String,IntPS__Health_Plan_Item__c>> getHplanSummaryStructure(String healthPlanId){
        List <IntPS__Health_Plan_Item__c> hpiList= [SELECT ID, 
                                                            Name, 
                                                            IntPS__Add_to_Deductible_Amount__c, 
                                                            IntPS__After_Plan_Deductible__c, 
                                                            IntPS__Benefit_Step__c, 
                                                            IntPS__Coinsurance__c, 
                                                            Summary__c,
                                                            IntPS__Copay__c, 
                                                            IntPS__Description__c, 
                                                            IntPS__Health_Plan__c, 
                                                            IntPS__Health_Plan_Content__c,
                                                            IntPS__Health_Plan_Content__r.IntPS__Claim_Type__c ,
                                                            IntPS__Health_Plan_Content__r.IntPS__Out_Of_Pocket_Calculation_TypeF__c,
                                                            IntPS__Health_Plan_Content__r.IntPS__Deductible_Calculation_TypeF__c,
                                                            IntPS__Health_Plan_Content__r.IntPS__Out_of_Pocket_Max_IndividualF__c,
                                                            IntPS__Health_Plan_Content__r.IntPS__Out_of_Pocket_Max_FamilyF__c,
                                                            IntPS__Health_Plan_Content__r.IntPS__Plan_Deductible_IndividualF__c,
                                                            IntPS__Health_Plan_Content__r.IntPS__Plan_Deductible_FamilyF__c,
                                                            IntPS__Health_Plan_Content__r.IntPS__Provider_Network__c,
                                                            IntPS__Maximum_Benefit__c, 
                                                            IntPS__Maximum_Number_Per_Admission__c, 
                                                            IntPS__Maximum_Number_Per_Year__c, 
                                                            IntPS__Maximum_Paid_Amount__c, 
                                                            IntPS__Not_Covered__c,
                                                            IntPS__Procedure_Code_Classification__r.Name, 
                                                            IntPS__Provider_Network__c,
                                                            Is_Exceptional_Case__c From IntPS__Health_Plan_Item__c Where IntPS__Health_Plan__c =: healthPlanId ORDER BY Name]; //AND IntPS__Health_Plan_Content__r.IntPS__Claim_Type__c = 'Medical'
   
    Map<String, Map<String,IntPS__Health_Plan_Item__c>> classificationMap = new Map<String,Map<String,IntPS__Health_Plan_Item__c>>();
    for(IntPS__Health_Plan_Item__c hpi : hpiList){
        if(hpi.Name != null){
            //hpi.IntPS__Coinsurance__c = 100 - hpi.IntPS__Coinsurance__c;
            Map<String,IntPS__Health_Plan_Item__c> providerList = new Map<String,IntPS__Health_Plan_Item__c>();
            String codeClassificitaionId = hpi.Name; //external id ile controle et
            if(classificationMap.containsKey(codeClassificitaionId)){
                providerList = classificationMap.get(codeClassificitaionId);
            }
            providerList.put(hpi.IntPS__Health_Plan_Content__r.IntPS__Provider_Network__c,hpi);
            classificationMap.put(hpi.Name,providerList);
        }
    }
    return classificationMap;
    }

    public with sharing class DataTableResponse {
        @AuraEnabled
        public List<DataTableField> lstDataTableFields {get;set;}
        @AuraEnabled
        public List<sObject> lstDataTableData {get;set;}                
        
        public DataTableResponse(){
            lstDataTableFields = new List<DataTableField>();
            lstDataTableData = new List<sObject>();
        }
    }

    public with sharing class DataTableField {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}

        public DataTableField(String label, String fieldName, String type){
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;         
        }
    }
    
    public with sharing class CloneStructureResponse {
        @AuraEnabled
        public List<IntPS__Health_Plan__c> hpClone {get;set;}
        @AuraEnabled
        public List<IntPS__Health_Plan_Content__c> hpcCloneList {get;set;}   
        
        public CloneStructureResponse(){
            hpClone = new List<IntPS__Health_Plan__c>();
            hpcCloneList = new List<IntPS__Health_Plan_Content__c>();
        }
    }
    
}