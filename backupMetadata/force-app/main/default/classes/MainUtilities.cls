/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-19-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class MainUtilities {
     @AuraEnabled
   public static Service_Tool_End_Points__c createServiceToolEndPoints(String Name,String endpoint){
    Service_Tool_End_Points__c setting = new Service_Tool_End_Points__c();
    try {
        
		setting.Name = Name;
		setting.EndPoint__c = endpoint;
        setting.Is_Test__c = true;
		insert setting;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return setting;
   }
   @AuraEnabled
   public static Claim_Type_POS_Mapping__c createClaimTypeRecord(String placeOfService,String claimType){
    Claim_Type_POS_Mapping__c setting = new Claim_Type_POS_Mapping__c();
    try {
        
		setting.Name = placeOfService;
		setting.claimType__c = claimType;
		insert setting;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return setting;
   }
   @AuraEnabled
   public static NSA_Configuration__c createNSAConfigRecord(String Name,Date apiStartDate,String endpoint,Decimal period,String instanceType,String orgName,String tpaAcro,String valenzUrl){
    NSA_Configuration__c nsaconfig = new NSA_Configuration__c();
    try {
        
		nsaconfig.Name = 'BSI Companies';
		nsaconfig.API_Start_Date__c =apiStartDate;
        nsaconfig.Endpoint_URL__c = endpoint;
        nsaconfig.Holding_Period_By_Hour__c = period;
        nsaconfig.Instance_Type__c =instanceType;
        nsaconfig.NSA_Org_Name__c = orgName;
        nsaconfig.TPA_Acronym__c = tpaAcro;
        nsaconfig.Valenz_Endpoint_URL__c = valenzUrl;
		insert nsaconfig;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return nsaconfig;
   }

   @AuraEnabled
   public static Account createMainAccount(String name,String npiNumber,String type,String city,String country,String street,String state,String postalCode,String phone){
    Account b= new Account();
    try {
        b.Name=name;
        b.Type=type;
        b.BillingCity=city;
        b.BillingCountry=country;
        b.IntPS__NPI_Number__c=npiNumber;
        b.BillingStreet=street;
        b.BillingState=state;
        b.BillingPostalCode=postalCode;
        b.Phone=phone;
        insert b;
   
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return b;
   }
   @AuraEnabled
   public static Contact createContact(String accountId,String street,String city,String state,String postalCode,String country,String lastName,String firstName){
    Contact con1=new Contact();
    try {
      
        con1.AccountId=accountId;
        con1.MailingStreet=street;
        con1.MailingCity=city;
        con1.MailingState=state;
        con1.MailingPostalCode=postalCode;
        con1.MailingCountry=country;
        con1.LastName=lastName;
        con1.FirstName=firstName;
        insert con1;
   
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return con1;
   }

   @AuraEnabled
   public static IntPS__Patient__c createPatient(String name,String firstName,String lastName,String relationship,String accountId,String street,String street1,String state,String zipCode,String city,String country,String employer,String planMember,String portalContact){
    IntPS__Patient__c pa1=new IntPS__Patient__c();
    try {
      
       
        pa1.Name=name;
        pa1.IntPS__First_Name__c=firstName;
        pa1.IntPS__Last_Name__c=lastName;
        pa1.IntPS__Relationship_Code__c=relationship;
        pa1.Account__c= accountId;
        pa1.IntPS__Street__c=street;
        pa1.IntPS__Street1__c=street1;
        pa1.IntPS__State__c=state;
        pa1.IntPS__Zip_Code__c=zipCode;
        pa1.IntPS__City__c=city;
        pa1.IntPS__Country__c=country;
        pa1.IntPS__Employer__c=employer;
        pa1.IntPS__Plan_Member__c=planMember;
        pa1.Portal_User__c=portalContact;
        insert pa1;
   
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return pa1;
   }
   @AuraEnabled
   public static IntPS__Health_Plan__c createHealthPlan(String name,String dedCalculation,String oopCalculation,Decimal oopMaxFam,Decimal oopMaxInd,Decimal deducFamily,Decimal deducInd,String planType){
    IntPS__Health_Plan__c hp = new IntPS__Health_Plan__c();    
    try {
      
       
       
        hp.Name = name;
        hp.IntPS__Deductible_Calculation_Type__c = dedCalculation; 
        hp.IntPS__Out_Of_Pocket_Calculation_Type__c = oopCalculation; 
        hp.IntPS__Out_of_Pocket_Max_Family__c = oopMaxFam;    
        hp.IntPS__Out_of_Pocket_Max_Individual__c = oopMaxInd; 
        hp.IntPS__Plan_Deductible_Family__c = deducFamily;      
        hp.IntPS__Plan_Deductible_Individual__c = deducInd;
        hp.Plan_Type__c=planType; 
        insert hp;
   
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return hp;
   }
   @AuraEnabled
   public static IntPS__Eligibility__c createEligibility(String patient,String healthplan,Date startDate,Date endDate){
    IntPS__Eligibility__c eligibility = new IntPS__Eligibility__c();
        try {
       
        eligibility.IntPS__Patient__c = patient;
        eligibility.IntPS__Health_Plan__c=healthplan;
        eligibility.IntPS__Begin_Date__c=startDate;
        eligibility.IntPS__Term_Date__c=endDate;
        insert eligibility;
   
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return eligibility;
   }
   @AuraEnabled
   public static IntPS__Health_Plan_Content__c createHealthPlanContent(String providerNetwork,String claimType,Boolean crossAccum,String healthPlan){
    IntPS__Health_Plan_Content__c hpc = new IntPS__Health_Plan_Content__c();
      try {
       
    hpc.IntPS__Provider_Network__c = providerNetwork;
    hpc.IntPS__Claim_Type__c = claimType;
    hpc.IntPS__Cross_Accumulate__c =crossAccum;
    hpc.IntPS__Health_Plan__c = healthPlan;
    insert hpc;
   
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return hpc;
   }
   @AuraEnabled
   public static IntPS__Network__c createNetwork(String name,String externalId){
    IntPS__Network__c network=new IntPS__Network__c(); 
         try {
        
        network.Name=name;
        network.IntPS_NSA__External_ID__c=externalId;
        insert network;
   
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return network;
   }
   @AuraEnabled
   public static IntPS_NSA__Health_Plan_Content_Network__c createHealthPlanContentNetwork(Integer priority,String healthPlanContent,String network,String service,Boolean rbp,String rbpBasis,Decimal rbpCurrency){
    IntPS_NSA__Health_Plan_Content_Network__c hpcn=new IntPS_NSA__Health_Plan_Content_Network__c();
    try {
            hpcn.IntPS_NSA__Priority__c=priority;
            hpcn.IntPS_NSA__Health_Plan_Content__c=healthPlanContent;
            hpcn.IntPS_NSA__Network__c=network;
            hpcn.IntPS_NSA__Services__c=service;
            hpcn.IntPS_NSA__RbP__c=rbp;
            hpcn.IntPS_NSA__RbP_Basis__c=rbpBasis;
            hpcn.IntPS_NSA__RbP_Percentage__c=rbpCurrency;

            insert hpcn;
   
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return hpcn;
   }
   @AuraEnabled
   public static IntPS__Procedure_Code__c createProcedureCodes(String name,String externalId,String description,String codeType,String parentProcedure,String placeOfService,String providerType,String preventative,String classification){
    IntPS__Procedure_Code__c prchild=new IntPS__Procedure_Code__c();  
       try {
          prchild.Name=name;
        prchild.IntPS__ExternalID__c=externalId;
        prchild.IntPS__Description__c=description;
        prchild.IntPS__Long_Description__c=description;
        prchild.IntPS__Consumer_Description__c=description;
        prchild.IntPS__Code_Type__c=codeType;
        prchild.IntPS__Parent_Procedure_Code__c=parentProcedure;
        prchild.Place_Of_Service__c=placeOfService;
        prchild.Preventatitive_Pregnancy__c=preventative;
        prchild.NSA_Classification__c=classification;
        prchild.IntPS_NSA__Shoppable_Item__c =true;
        prchild.Provider_Type__c=providerType;

        insert prchild;
   
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return prchild;
   }
}