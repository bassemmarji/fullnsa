/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-02-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class NSA_EOBEntryFormController {
    //ping server to make sure everything is ok
      //ping server to make sure everything is ok
      @AuraEnabled
      public static Boolean serversHeartbeat() {
          
          try {
              // Checking MRF API server
              if (test.isRunningTest()) {
               Test.setMock(HttpCalloutMock.class, new NSA_MRFPricesMock());
           }
              Boolean result = NSA_WSUtils.pingServer('callout:MRF_API/api/provider/getbyfilter', 'POST', '{"tins":["1164604591"],"TPA_Acronym":"BSi","NTW_Acronym": ["MC"]}', null);   
              if (result) {
                  // Check NPI Registry
                  if (test.isRunningTest()) {
                   Test.setMock(HttpCalloutMock.class, new NSA_ProviderWSMock());
               }
                  result = NSA_WSUtils.pingServer('callout:NPI_Registry', 'GET', null, null);
                  if (result) {
                      // Checking Valenz API
                      if (test.isRunningTest()) {
                       Test.setMock(HttpCalloutMock.class, new NSA_ValenzMock());
                   }
                      result = NSA_WSUtils.pingServer('callout:Valenz_API/Release/hooks/ips/submit.py', 'POST', 'test', System.Label.NSA_ValenzAuth);
                     
                  }
              }
              return result;
          } catch (Exception e) {
              throw new AuraHandledException(e.getMessage());
          }
      }
    
     //check if the patient's employer group is activated for the pricing application
     // we use the is Admin because if an admin/custom support is using the system, they select the patient.
     // THe patient details won't be immediately available like when an actual patient logs in to the system
      @AuraEnabled
     public static Boolean checkEmployerGroup(String patientEmployer,Boolean isAdmin) {
       if(isAdmin){
         IntPS__Patient__c patient = [SELECT Id, Name, IntPS__Email__c,IntPS__Employer__c FROM IntPS__Patient__c WHERE Id=:patientEmployer];
         List<IntPS_NSA__Release__c> nsaReleases=[Select Id,IntPS_NSA__Employee_Group__c from IntPS_NSA__Release__c where IntPS_NSA__Employee_Group__c=:patient.IntPS__Employer__c];
         if(nsaReleases.size()>0){
             return true;
         }
         else{
             return false;
         }
       }
       else{
         List<IntPS_NSA__Release__c> nsaReleases=[Select Id,IntPS_NSA__Employee_Group__c from IntPS_NSA__Release__c where IntPS_NSA__Employee_Group__c=:patientEmployer];
         if(nsaReleases.size()>0){
             return true;
         }
         else{
             return false;
         }
     }
     }
 
     //get the patient details linked to the contact of the user
     // we use the contact id of the logged in User,
     // and we use IntPS__Plan_Member__c is empty because we want the main patient without his dependents
   @AuraEnabled
   public static List<IntPS__Patient__c> getPatient(String contactId) {
     System.debug('contact Id ' + contactId);
 
       List<IntPS__Patient__c> patient = [SELECT Id, Name, IntPS__Email__c,IntPS__Employer__c FROM IntPS__Patient__c WHERE Portal_User__c=:contactId];
       return patient;
   }
   //get all the networks that are available in the health plan of the Patient, the IN and Out of network both
   @AuraEnabled
   public static List < IntPS_NSA__Health_Plan_Content_Network__c > getNetworksDetails(String healthPlanId,String patientId) {
       List < IntPS_NSA__Health_Plan_Content_Network__c > result = new List < IntPS_NSA__Health_Plan_Content_Network__c > ();
 
       try {
           System.debug('healthPlanId ' + healthPlanId);
           result = [Select Id,IntPS_NSA__Services__c,IntPS_NSA__RbP_Percentage__c, IntPS_NSA__Priority__c, IntPS_NSA__Network__r.Name, IntPS_NSA__RbP_Basis__c, IntPS_NSA__RbP__c, IntPS_NSA__Network__r.IntPS_NSA__External_ID__c, IntPS_NSA__Network__c, IntPS_NSA__Health_Plan_Content__c, IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c from IntPS_NSA__Health_Plan_Content_Network__c where IntPS_NSA__Health_Plan_Content__r.IntPS__Health_Plan__c =: healthPlanId and (IntPS_NSA__Patient__c='' or IntPS_NSA__Patient__c=:patientId)];
           System.debug('result ' + result);
 
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
       return result;
   }
   //get all the patients that are dependent from the initial patient logged in
   /*@AuraEnabled
   public static List < IntPS__Patient__c > getPatientDependents(String patientId) {
       List < IntPS__Patient__c > dependents = [Select Id, Name from IntPS__Patient__c where IntPS__Plan_Member__c =: patientId];
       return dependents;
   }*/
 // get Provider Details by NPI Number: Used in PodPlan when using geo Location
 // will be activated when used by podplan
 /*@AuraEnabled
 public static List<Providers> getProviderByNPI(String npi) {
     String query = 'SELECT Physician_Name__c, Id, Account__r.IntPS__NPI_Number__c, City__c, Street__c, State__c, Postal_Code__c, Country__c,Phone__c FROM Active_Office_Location__c WHERE  Id =:npi';
     List<sObject> npiList = Database.query(query);
     System.debug('dbg>>>>>>>'+ npiList);
     List<Providers> providers=new List<Providers>();
 
     for(sObject account : npiList){
       Providers resultFirstName=new Providers();
       resultFirstName.NPINumber= String.valueof(account.getSObject('Account__r').get('IntPS__NPI_Number__c'));
       resultFirstName.ProviderType='Not Defined';
       resultFirstName.ProviderName= String.valueof(account.get('Physician_Name__c'));
       resultFirstName.ProviderCity= String.valueof(account.get('City__c'));
       resultFirstName.ProviderCountry= String.valueof(account.get('Country__c'));
       resultFirstName.ProviderPostalCode= String.valueof(account.get('Postal_Code__c'));
       resultFirstName.ProviderState= String.valueof(account.get('State__c'));
       resultFirstName.ProviderStreet= String.valueof(account.get('Street__c'));
       resultFirstName.ProviderPhone= String.valueof(account.get('Phone__c'));
       resultFirstName.networkOption = 'In-Network';
 
       providers.add(resultFirstName);
     }
     return providers;
 }*/
   // get the pdf version of the advancedEOb VF Page 
   @AuraEnabled
   public static String getPdfFileAsBase64String(String eobId,Boolean isPodPlan) {
     PageReference pdfPage;
 
     if(isPodPlan){
          pdfPage = new PageReference('/apex/nsa_advancedeobpodplan');
 
     }
     else{
          pdfPage = Page.NSA_EstimatedCosts;
 
     }
       pdfPage.getParameters().put('id', eobId);
       Blob pdfBlob;
       if (Test.isRunningTest()) {
           pdfBlob = blob.valueOf('Unit.Test');
       } else {
           pdfBlob = pdfPage.getContent();
       }
       String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
       return pdfPage.getUrl();
   }
  // get the price of each service based on the priority of the networks in the patient's health plan.
  //if the price is not found in the MRF database, and the following priority is for a network with RBP, we call the Fair health of Medicare API
   public static NetworkPrice validateNetworksPricesByPriority(String networkName,List < NSA_MRFToApex > servicesPrices, String procedureCode, String placeOfService) {
       Double price;
       NetworkPrice result = new NetworkPrice();
  System.debug('networkName'+networkName);
           for (NSA_MRFToApex mrf: servicesPrices) {
               System.debug('Current Network in mrf ' + mrf.NTW_Acronym+' '+mrf.procedure_code+' '+procedureCode+'  '+placeOfService);
               if (mrf.procedure_code == procedureCode) {
                 if(mrf.service_code.contains(placeOfService)){ 
                 System.debug('network chosen '+mrf.negotiated_type+' ' + System.Label.NSA_MedicareNegotiatedPriceType + ' ' + mrf.network.reporting_entity_name + ' ' + mrf.service_code + ' ' + mrf.negotiated_rate);
                 if (System.Label.NSA_MedicareNegotiatedPriceType.contains(mrf.negotiated_type)) {
                     System.debug('result '+result);
                     if(result.price==null){
                         System.debug('re inserting the same price');
                         result.price = mrf.negotiated_rate;
                       }
                       else{
                         
                         if(result.price<=mrf.negotiated_rate){
                             System.debug('initial price is lesst then the new');
                             System.debug('initial price '+result.price+' new'+mrf.negotiated_rate);
                             result.price = mrf.negotiated_rate;
     
                           }
                           else{
                             System.debug('initial price is still greater');
                           }
                       }  
                     result.netowrkName = networkName;
                     result.networkSmallName = mrf.NTW_Acronym;
                     result.isRateFound=true;
                       result.isRbp = false;
                       String da = mrf.network.last_updated_on;
                       da = da.replace('/', '-');
                       Date mrfdate = Date.valueOf(da);
                       System.debug(mrfdate);
 
                       result.networkDate = mrfdate;
                   } else {
                     //and also if we don't find a price in this selected network for a specific procedure, we should put a 0 to tell the user
                       result.netowrkName = networkName;
                       result.networkSmallName = mrf.NTW_Acronym;
                       if(result==null){
                         result.price = 0;
                         result.isRateFound=false;
                       }
                       else{
                         result.isRateFound=true;
                       }
                       
                       result.isRbp = false;
                       String da = mrf.network.last_updated_on;
                       da = da.replace('/', '-');
                       Date mrfdate = Date.valueOf(da);
                       System.debug(mrfdate);
 
                       result.networkDate = mrfdate;
                   }
                 }
                 else{
                     if(placeOfService=='21'){
                         // we fill out the price with 0 becuase if no price is found, we should tell the user
                         
                         System.debug('place of service is 21, so we should not select other price if no price is found for this place of service');
                         result.netowrkName = networkName;
                       result.networkSmallName = mrf.NTW_Acronym;
                       if(result==null){
                         result.price = 0;
                         result.isRateFound=false;
                       }
                       else{
                         result.isRateFound=true;
                       }
                       
                       result.isRbp = false;
                       String da = mrf.network.last_updated_on;
                       da = da.replace('/', '-');
                       Date mrfdate = Date.valueOf(da);
                       System.debug(mrfdate);
 
                       result.networkDate = mrfdate;
                     }
                     else{
                         System.debug('checking if any price is found for another place of service');
                         if((mrf.service_code.size()==1 && mrf.service_code[0]=='21')){
                             // we fill out the price with 0 becuase if no price is found, we should tell the user
                             System.debug('price found for only place of service 21, we should not get any price');
                             result.netowrkName = networkName;
                             result.networkSmallName = mrf.NTW_Acronym;
                             if(result==null){
                               result.price = 0;
                               result.isRateFound=false;
                             }
                             else{
                               result.isRateFound=true;
                             }
                             
                             result.isRbp = false;
                             String da = mrf.network.last_updated_on;
                             da = da.replace('/', '-');
                             Date mrfdate = Date.valueOf(da);
                             System.debug(mrfdate);
       
                             result.networkDate = mrfdate;
                         }
                         else{
                             System.debug('network chosen even if no place of service found '+mrf.negotiated_type+' ' + System.Label.NSA_MedicareNegotiatedPriceType + ' ' + mrf.network.reporting_entity_name + ' ' + mrf.service_code + ' ' + mrf.negotiated_rate);
                             if (System.Label.NSA_MedicareNegotiatedPriceType.contains(mrf.negotiated_type)) {
                                 System.debug('result '+result);
                                 if(result.price==null){
                                     System.debug('re inserting the same price');
                                     result.price = mrf.negotiated_rate;
                                   }
                                   else{
                                     
                                     if(result.price<=mrf.negotiated_rate){
                                         System.debug('initial price is lesst then the new');
                                         System.debug('initial price '+result.price+' new'+mrf.negotiated_rate);
                                         result.price = mrf.negotiated_rate;
                 
                                       }
                                       else{
                                         System.debug('initial price is still greater');
                                       }
                                   }  
                                 result.netowrkName = networkName;
                                 result.networkSmallName = mrf.NTW_Acronym;
                                 result.isRateFound=true;
                                   result.isRbp = false;
                                   String da = mrf.network.last_updated_on;
                                   da = da.replace('/', '-');
                                   Date mrfdate = Date.valueOf(da);
                                   System.debug(mrfdate);
             
                                   result.networkDate = mrfdate;
   
                             } else {
                               // we fill out the price with 0 becuase if no price is found, we should tell the user
                               result.netowrkName = networkName;
                               result.networkSmallName = mrf.NTW_Acronym;
                               if(result==null){
                                 result.price = 0;
                                 result.isRateFound=false;
                               }
                               else{
                                 result.isRateFound=true;
                               }
                               
                               result.isRbp = false;
                               String da = mrf.network.last_updated_on;
                               da = da.replace('/', '-');
                               Date mrfdate = Date.valueOf(da);
                               System.debug(mrfdate);
         
                               result.networkDate = mrfdate;
   
                             }
                         }
                     } 
                 }
               }
           }
       
       return result;
   }
   
 
     //check if the user's request should be from a facility or a professional in case of INNRBp should be considered
     @AuraEnabled
     public static String checkServiceTypeforINNRBP(List < Procedures > selectedProcedures) {
      String serviceType;
      String placeOfService=selectedProcedures[0].PlaceOfService;
      String prevPregn=selectedProcedures[0].PreventativeOption;
      switch on prevPregn {
          when 'Preventative Services' {
              serviceType='Professional';
          }
          when 'Prenatal Services'{
              serviceType='Professional';
          }
      
          when 'None of the above'{
              if(placeOfService=='11' || placeOfService=='10'){
                  serviceType='Professional';
              }
              else{
                  serviceType='Institutional';
              }
          }
         
          when else {
             if(prevPregn=='Pregnancy Labor & Delivery - Professional Services'){
                 serviceType='Professional';
             }
             else{
                 serviceType='Institutional';
             }
             
          }
       }
  
    
      return serviceType;
   }
    //check if the user's request should be from a facility or a professional
    @AuraEnabled
    public static String checkServiceType(List < Procedures > selectedProcedures) {
     String serviceType;
     String placeOfService=selectedProcedures[0].PlaceOfService;
     String prevPregn=selectedProcedures[0].PreventativeOption;
     switch on prevPregn {
         when 'Preventative Services' {
             serviceType='Professional';
         }
         when 'Prenatal Services'{
             serviceType='Professional';
         }
         when 'None of the above'{
             if(placeOfService=='11' || placeOfService=='10'){
                 serviceType='Professional';
             }
             else{
                 serviceType='Institutional';
             }
         }
        
         when else {
             serviceType='Institutional';
         }
      }
 
   
     return serviceType;
  }
   //get the needed Health Plan Content Network in case of rbp calculation
   @AuraEnabled
   public static IntPS_NSA__Health_Plan_Content_Network__c getHealthPlanNetwork(List<String> outOfNetworkNames, String serviceType,String networkOption) {
     System.debug('checking hpcNetwork '+outOfNetworkNames+' '+serviceType);
       IntPS_NSA__Health_Plan_Content_Network__c result=new IntPS_NSA__Health_Plan_Content_Network__c();
     List<IntPS_NSA__Health_Plan_Content_Network__c> hpn=[Select IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c,IntPS_NSA__RbP_Basis__c,IntPS_NSA__RbP_Percentage__c from IntPS_NSA__Health_Plan_Content_Network__c where Id in:outOfNetworkNames and IntPS_NSA__Services__c=:serviceType];
     if(hpn.size()>1){
         for(IntPS_NSA__Health_Plan_Content_Network__c hpcrecord:hpn){
            if(hpcrecord.IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c==networkOption) {
             result= hpcrecord;
            }
         }
     }
     else{
         if(hpn.size()>0){ result= hpn[0];}
     }
     return result;
 }
 
 //Check if any of the user's selected CPT COdes is DRG
 @AuraEnabled
   public static Boolean isDRG(List < Procedures > selectedProcedures,String healthPlanId,String networkOption) {
    System.debug('checking isDRG');
     Boolean drg=false;
     for (Integer cc = 0; cc < selectedProcedures.size(); cc++) {
     String codeType = MapProceduresToHPI(selectedProcedures[cc].Code, selectedProcedures[cc].PregnancyOption, selectedProcedures[cc].ProviderType, selectedProcedures[cc].PlaceOfService,healthPlanId,networkOption).codeType;
     if (codeType == 'Procedure Code') {
         drg = false;
     } else {
       if(codeType=='MS-DRG'){
         System.debug('one of the selected cpts is DRG');
           drg=true;
           break;
 
       }
       else {
          drg=false;
      }
     }    
 }
 return drg;
 }
 
   // logic done to prepare the call for the Fair health or the Valenz API
   @AuraEnabled
   public static WebServiceCalloutWrapper rbpCalculation(List<String> outOfNetworkNames, String tpaAcro, String providerZIP, String providerNPI, List < Procedures > selectedProcedures, Date serviceDate,String healthPlanId,String networkOption,IntPS_NSA__Health_Plan_Content_Network__c hpn) {
     WebServiceCalloutWrapper result=new WebServiceCalloutWrapper();  
     //preparing a uuid to use in the request 
       Blob b = Crypto.GenerateAESKey(128);
       String h = EncodingUtil.ConvertTohex(b);
       String myUuidValue = h.SubString(0, 8);
 
       String ProcedureCode;
       String RevenueCode;
       String DRGCode;
       Boolean containsDRG =isDRG(selectedProcedures,healthPlanID,networkOption);
       String claimType = 'O';
      
       //a custom settings that has the mapping of the claim type based on the place of service
       Claim_Type_POS_Mapping__c objGame = Claim_Type_POS_Mapping__c.getValues(selectedProcedures[0].PlaceOfService);
       claimType = objGame.claimType__c;
       if(containsDRG){
         System.debug('one of the selected cpts is DRG so we used claim type I');
 
         claimType='I'; 
       }
       NSA_RbpPricesResponse rbpServicePrices;
       //change the format of the service date to the format accepted in the API
       String dateStr = serviceDate.month() + '/' + serviceDate.day() + '/' + serviceDate.year();
       System.debug('>>>>' + dateStr);
       String request = '{"CLAIM": [{"TransactionControl": {"ClientID": "' + tpaAcro + '","TransactionID": "' + myUuidValue + '","ClaimType": "' + claimType + '"},"ProviderInfo": {"ZIP": "' + providerZIP + '","NPI": "' + providerNPI + '","CCN": ""},"Services": [';
       for (Integer cc = 0; cc < selectedProcedures.size(); cc++) {
           Integer lineNumber = cc + 1;
           ProcedureCode = '';
           RevenueCode = '';
           DRGCode='';
           //checking if the procedure is a revenue code or a procedure code.
           String codeType = MapProceduresToHPI(selectedProcedures[cc].Code, selectedProcedures[cc].PregnancyOption, selectedProcedures[cc].ProviderType, selectedProcedures[cc].PlaceOfService,healthPlanId,networkOption).codeType;
           System.debug('checking codeType ' + codeType);
           if (codeType == 'Procedure Code') {
               ProcedureCode = selectedProcedures[cc].Code;
           } else {
             if(codeType=='MS-DRG'){
                 DRGCode = selectedProcedures[cc].Code;
 
             }
             else {
                 RevenueCode = selectedProcedures[cc].Code;
                 ProcedureCode = selectedProcedures[cc].Code;
 
            }
           }
           if (cc == selectedProcedures.size() - 1) {
               request = request + '{"LineNumber":' + lineNumber + ',"PlaceOfService": "' + selectedProcedures[cc].PlaceOfService + '","ProcedureCode": "' + ProcedureCode + '","RevenueCode": "' + RevenueCode + '","DRG": "'+DRGCode+'","Units": 1,"DatesOfService": {"From": "' + dateStr + '","To": "' + dateStr + '"},"ModifierList": [""],"DiagnosisList": []}] }]}';
           } else {
               request = request + '{"LineNumber":' + lineNumber + ',"PlaceOfService": "' + selectedProcedures[cc].PlaceOfService + '","ProcedureCode": "' + ProcedureCode + '","RevenueCode": "' + RevenueCode + '","DRG": "'+DRGCode+'","Units": 1,"DatesOfService": {"From": "' + dateStr + '","To": "' + dateStr + '"},"ModifierList": [""],"DiagnosisList": []},';
 
           }
       }
       result.request=request;
        if (hpn.IntPS_NSA__RbP_Basis__c == 'Medicare') {
           System.debug('calling valenz api');
           if (test.isRunningTest()) {
               Test.setMock(HttpCalloutMock.class, new NSA_ValenzMock());
           }
           result.response=NSA_WSUtils.doPost('getValenzPrice', request);
           rbpServicePrices = NSA_RbpPricesResponse.parse(result.response);
       } else {
           System.debug('calling Fair health api');
           if (test.isRunningTest()) {
               Test.setMock(HttpCalloutMock.class, new NSA_FairHealthMock());
           }
           result.response=NSA_WSUtils.doPost('getUCRPrice', request);
           rbpServicePrices = NSA_RbpPricesResponse.parse(result.response);
 
       }
       result.rbpResponse=rbpServicePrices;
       return result;
   }
 
   // if an error occured when creating the eob or the eob line item
   // we create a record in NSA Error Log object for troubleshooting
   // we create the eob and its line item with minimal details to troubleshoot
   @AuraEnabled
   public static ErrorWrapper handleSQLError(List < String > networkNames, String providerNumber, String tpaAcro, String procedures, Boolean includeEOB, String fields, String userEmail, String patientId, String errorMessage, Date serviceDate,String healthPlanId,String networkOption,List<String> availableNetworksForProvider,List<String> networkNamesDisplay) {
       System.debug('handleSQLError');
       ErrorWrapper result=new ErrorWrapper();
       String mrfBody = createMRFBody(procedures, providerNumber, tpaAcro, networkNames);
       IntPS_NSA__NSA_Error_Log__c nsaerror = createErrorLogs(null,patientId, '', errorMessage, userEmail, 'When Calling MRF SQL WebService with request ' + mrfBody);
       String claimId;
       if (includeEOB) {
         result.claimId=createEOBDetailsWithNoPrice(fields, userEmail, patientId, nsaerror, procedures, serviceDate,healthPlanId,networkOption,availableNetworksForProvider,networkNamesDisplay);
       }
       result.errorMessage=errorMessage;
       return result;
   }
   // create the MRF API request body
   public static String createMRFBody(String procedures, String providerNumber, String tpaAcro, List < String > networkNames) {
       List < Procedures > selectedProcedures = (List < Procedures > ) JSON.deserialize(procedures, List < Procedures > .class);
       String mrfCallBody = '{"procedure_codes":[';
       for (Integer cc = 0; cc < selectedProcedures.size(); cc++) {
           if (cc == selectedProcedures.size() - 1) {
               mrfCallBody = mrfCallBody + '"' + selectedProcedures[cc].Code + '"';
 
           } else {
               mrfCallBody = mrfCallBody + '"' + selectedProcedures[cc].Code + '",';
 
           }
 
       }
       mrfCallBody = mrfCallBody + '],"tins":["' + providerNumber + '"], "TPA_Acronym":"' + tpaAcro + '", "NTW_Acronym": [';
       for (Integer cc = 0; cc < networkNames.size(); cc++) {
           if (cc == networkNames.size() - 1) {
               mrfCallBody = mrfCallBody + '"' + networkNames[cc] + '"]}';
 
           } else {
               mrfCallBody = mrfCallBody + '"' + networkNames[cc] + '",';
 
           }
 
       }
       return mrfCallBody;
   }
 
   // prepare to call the MRF Database API
   @AuraEnabled
   public static WebServiceCalloutWrapper SQLWSCallout(String fields, String eob, List < IntPS_NSA__Health_Plan_Content_Network__c > networks, List < Procedures > selectedProcedures, String providerNumber, String tpaAcro, List < String > networkNames, String userEmail, String patientId) {
     WebServiceCalloutWrapper result=new WebServiceCalloutWrapper();
       String mrfCallBody = '{"procedure_codes":[';
       for (Integer cc = 0; cc < selectedProcedures.size(); cc++) {
           if (cc == selectedProcedures.size() - 1) {
               mrfCallBody = mrfCallBody + '"' + selectedProcedures[cc].Code + '"';
 
           } else {
               mrfCallBody = mrfCallBody + '"' + selectedProcedures[cc].Code + '",';
 
           }
 
       }
       mrfCallBody = mrfCallBody + '],"tins":["' + providerNumber + '"], "TPA_Acronym":"' + tpaAcro + '", "NTW_Acronym": [';
       for (Integer cc = 0; cc < networkNames.size(); cc++) {
           if (cc == networkNames.size() - 1) {
               mrfCallBody = mrfCallBody + '"' + networkNames[cc] + '"]}';
 
           } else {
               mrfCallBody = mrfCallBody + '"' + networkNames[cc] + '",';
 
           }
 
       }
       System.debug('mrfCallBody ' + mrfCallBody);
       result.request=mrfCallBody;
       String servicePrices;
       try {
           if (test.isRunningTest()) {
               Test.setMock(HttpCalloutMock.class, new NSA_MRFPricesMock());
           }
           servicePrices = NSA_WSUtils.doPost('getServicePrice', mrfCallBody);
       } catch (Exception e) {
           System.debug('SQL WS Error');
 
           throw new AuraHandledException(e.getMessage());
       }
       result.response=servicePrices;
       return result;
   }
 
   //create a record of the NSA Error Log object
   @AuraEnabled
   public static IntPS_NSA__NSA_Error_Log__c createErrorLogs(IntPS__EOB__c eobAdded,String patientId, String eob, String errorMessage, String patientEmail, String errorStage) {
       IntPS_NSA__NSA_Error_Log__c nsaerror = new IntPS_NSA__NSA_Error_Log__c();
       nsaerror.IntPS_NSA__Error_Message__c = errorMessage;
       nsaerror.IntPS_NSA__Patient_Email__c = patientEmail;
       nsaerror.IntPS_NSA__Error_Stage__c = errorStage;
       System.debug('createErrorLogs');
       if (eob == '') {} else {
           nsaerror.IntPS_NSA__Explanation_of_Benefits_EOB__c = eob;
       }
       nsaerror.IntPS_NSA__Log_File__c = 'To Be provided';
       nsaerror.IntPS_NSA__Status__c = 'Failed';
       nsaerror.IntPS_NSA__Patient__c = patientId;
       try {
           System.debug('nsaerror ' + nsaerror);
           insert nsaerror;
           System.debug('nsaerror added ' + nsaerror);
           String summary;
          return nsaerror;
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
   }
 
   // check if the first priority network is RBP
   @AuraEnabled
   public static Boolean isFirstPriorityRBP(Map < Integer, IntPS_NSA__Health_Plan_Content_Network__c > networkContentByPriority) {
       System.debug('checking if first priority is rbp or not');
 
       Double price;
       List < Integer > aList = new List < Integer > ();
       aList.addAll(networkContentByPriority.keySet());
       aList.sort();
       System.debug('first prio ' + aList[0]);
       IntPS_NSA__Health_Plan_Content_Network__c network = networkContentByPriority.get(aList[0]);
       System.debug('first prio network ' + network);
       System.debug('is rbp ' + network.IntPS_NSA__RbP__c);
 
       return network.IntPS_NSA__RbP__c;
   }
 
   // create a jira ticket containing with error or even without errors for validation reasons
   @AuraEnabled
   public static Boolean createJiraTicket(String claimId,String errorMessage, Boolean withError) {
     IntPS__EOB__c eobAdded = [Select Id,Name, IntPS_NSA__MRF_Date__c, IntPS_NSA__MRF_Network__c from IntPS__EOB__c where Id =: claimId];
     String summary=eobAdded.Name;
     String body;
     if(!withError){ 
          body='{"fields":{"summary":"'+summary+'","issuetype":{"id":"'+System.label.NSA_JiraIssueType+'"},"project":{"key":"'+System.label.NSA_JiraProject+'"},"description":{"type":"doc","version":1,"content":[{"type":"paragraph","content":[{"text":"You can access the eob using :'+System.label.NSA_EOBUrl+eobAdded.Id+'/view. Error Message : '+errorMessage.remove('"')+'","type":"text"}]}]}}}';
     }
     else{
               body='{"fields":{"summary":"'+summary+'", "assignee": {"accountId": "62f66ec096eb272011ab000b"},"issuetype":{"id":"'+System.label.NSA_JiraIssueType+'"},"project":{"key":"'+System.label.NSA_JiraProject+'"},"description":{"type":"doc","version":1,"content":[{"type":"paragraph","content":[{"text":"You can access the eob using :'+System.label.NSA_EOBUrl+eobAdded.Id+'/view. Error Message : '+errorMessage.remove('"')+'","type":"text"}]}]}}}';
    }
     System.debug('jira api request '+body);
     if (test.isRunningTest()) {
         Test.setMock(HttpCalloutMock.class, new NSA_JiraAPIWrapperMock());
     }
     NSA_WSUtils.createJiraTicket(System.label.NSA_JiraAPIUrl,body);
    // eobAdded.Jira_Ticket__c=System.label.NSA_JiraUrl+jiraresponse.key;
     return true;
   }
 
   // get tpa acronym from custom settings
   @AuraEnabled
   public static string getTPAAcro(String companyName) {
       String tpaAcro;
       String test = '';
       Date currentDate = date.today();
       List < NSA_Configuration__c > configs = NSA_WSUtils.getOrgDetails(companyName);
       for (NSA_Configuration__c config: configs) {
           System.debug('in config ' + config.API_End_Date__c + ' ' + config.API_Start_Date__c + ' ' + currentDate);
           if (currentDate > config.API_Start_Date__c && (config.API_End_Date__c == null)) {
 
               tpaAcro = config.TPA_Acronym__c;
               System.debug('tpaAcro ' + tpaAcro);
               break;
           } else {
               System.debug('in else');
           }
 
       }
       return tpaAcro;
   }
 
   // create eob and eob line items without calling any api and without putting any price. THis is used for troubleshooting in case of error in the pricing
   @AuraEnabled
   public static String createEOBDetailsWithNoPrice(String fields, String userEmail, String patientId, IntPS_NSA__NSA_Error_Log__c nsaerror, String procedures, Date serviceDate,String healthPlanId,String networkOption,List<String> availableNetworksForProvider,List<String> networkNamesDisplay) {
       List < SaveResultWrapper > srwList = new List < SaveResultWrapper > ();
       ClaimSaveResultWrapper csrw = new ClaimSaveResultWrapper();
       List < Procedures > selectedProcedures = (List < Procedures > ) JSON.deserialize(procedures, List < Procedures > .class);
     String networkOptionSelected;
       String claimId;
       Savepoint sp;
       if(!Test.isRunningTest())
       {
         sp = Database.setSavepoint();  
       }
       WebServiceCalloutWrapper wsWrapper=new WebServiceCalloutWrapper();
       wsWrapper.request='';
       wsWrapper.response='';
      //creating eob with no details
       List < SaveResultWrapper > claimResult = claimInsert(fields, 'From Create WS Error', userEmail, patientId,wsWrapper,'',0,networkOption,availableNetworksForProvider,networkNamesDisplay);
       csrw.claimSWRList = claimResult;
       Boolean hasError = true;
       for (SaveResultWrapper swr: claimResult) {
           if (swr.isSucces) {
               System.debug('swr ' + swr);
               claimId = swr.Id;
               hasError = false;
               nsaerror.IntPS_NSA__Explanation_of_Benefits_EOB__c = claimId;
               System.debug('nsa error before update ID ' + nsaerror.ID);
               System.debug('nsa error before update ' + nsaerror);
               Database.SaveResult srList = Database.update(nsaerror, false);
 
               System.debug('sr update nsaerror' + srList);
 
 
               System.debug('nsa error after update ' + nsaerror);
               Boolean allLineInsered = true;
               //eob created successfully, we start creating the eob line items with no pricing
               List < IntPS__EOB_Line_Item__c > slList = new List < IntPS__EOB_Line_Item__c > ();
               Integer counter = 1;
           
               for (Integer cc = 0; cc < selectedProcedures.size(); cc++) {
                   IntPS__EOB_Line_Item__c lineItem = new IntPS__EOB_Line_Item__c();
                   lineItem.IntPS__L2110_Procedure_Code__c = selectedProcedures[cc].Code;
                   lineItem.IntPS__L2110_Procedure_Code_Description__c = selectedProcedures[cc].Description;
                   lineItem.IntPS_NSA__Line_Number__c = cc + 1;
                   System.debug('eob line item linked to ' + claimId);
                   lineItem.IntPS__EOB__c = claimId;
                   lineItem.IntPS_NSA__Place_Of_Service__c = selectedProcedures[cc].PlaceOfService;
                   lineItem.Provider_Type__c = selectedProcedures[cc].ProviderType;
                   lineItem.PreventativePregn__c = selectedProcedures[cc].PreventativeOption;
                   lineItem.IntPS__L2110_Units_of_Service_Paid_Count__c = selectedProcedures[cc].Quantity;
                   lineItem.IntPS__L2110_Service_Date__c = serviceDate;
                   lineItem.IntPS__L2110_Service_End_Date__c = serviceDate;
                   lineItem.IntPS__L2110_Service_Start_Date__c = serviceDate;
                   ProceduresMappedWithHP procHPI= MapProceduresToHPI(selectedProcedures[cc].Code, selectedProcedures[cc].PregnancyOption, selectedProcedures[cc].ProviderType, selectedProcedures[cc].PlaceOfService,healthPlanId,networkOption);
                   lineItem.IntPS_NSA__Health_Plan_Item__c = procHPI.healthPlanItemID;
                   lineItem.IntPS_NSA__Child_Procedure_Code_Name__c=procHPI.procedureCode;
                   lineItem.IntPS_NSA__NSA_Clasification_Name__c=procHPI.nsaClassificationName;
                   networkOptionSelected=procHPI.providerNetworkOption;
 
                   System.debug('lineItem.IntPS_NSA__Health_Plan_Item__c ' + lineItem.IntPS_NSA__Health_Plan_Item__c);
 
                   slList.add(lineItem);
               }
               List < Database.SaveResult > srList2 = new List < Database.SaveResult > ();
               if (!slList.isEmpty()) {
                   srList2 = Database.insert(slList, false);
                   for (Database.SaveResult sr: srList2) {
                       SaveResultWrapper srw = new SaveResultWrapper();
                       srw.isSucces = sr.isSuccess();
 
                       if (sr.isSuccess()) {
                           srw.Id = sr.getId();
                       } else {
                           allLineInsered = false;
                           // Operation failed, so get all errors
                           List < String > customErrorMessageList = new List < String > ();
                           for (Database.Error err: sr.getErrors()) {
                               customErrorMessageList.add(err.getStatusCode() + ': ' + err.getMessage());
                           }
                           srw.handleErrorList = customErrorMessageList;
                       }
                       srwList.add(srw);
                   }
               }
               IntPS__EOB__c eobAdded = [Select Id,Name, IntPS_NSA__MRF_Date__c, IntPS_NSA__MRF_Network__c from IntPS__EOB__c where Id =: claimId];
            
               eobAdded.IntPS_NSA__Provider_Network__c=networkOptionSelected;
               try {
                   update(eobAdded);
                   System.debug('eob updated' + eobAdded);
               } catch (Exception e) {
                   IntPS_NSA__NSA_Error_Log__c nsaerror2 = createErrorLogs(eobAdded,patientId, claimId, e.getMessage(), userEmail, 'When updating eob with provider network ');
                   throw new AuraHandledException(e.getMessage());
         
               }
               if (!allLineInsered) {
                   Database.rollback(sp);
               }
           }
       }
       return claimId;
   }
 //check if the list of networks has a member specific network. Usually they have a null priority.So we put it as 0 to indicate that it has the first priority now
   @AuraEnabled
   public static List<IntPS_NSA__Health_Plan_Content_Network__c> checkForMemberSpecificHPC(List<IntPS_NSA__Health_Plan_Content_Network__c> networks){
     Boolean hasMemberSpecific=false;
     System.debug('before'+networks);
 
     try {
         for(IntPS_NSA__Health_Plan_Content_Network__c network:networks){
             if(network.IntPS_NSA__Priority__c==null && network.IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c=='In-Network'){
                 System.debug('has member specific '+network);
                 hasMemberSpecific=true;
                 network.IntPS_NSA__Priority__c=0;
             }
      }
         System.debug('after'+networks);
     } catch (Exception e) {
         throw new AuraHandledException(e.getMessage());
     }
     return networks;
 
   }
 
   //get the health plan content of the chosen network
   @AuraEnabled
   public static IntPS_NSA__Health_Plan_Content_Network__c getHealthPlanContentFromNetwork(String network,Map < Integer, String > networkByPriority,Map < Integer, IntPS_NSA__Health_Plan_Content_Network__c > networkContentByPriority){
     Integer priority;
     System.debug('networkContentByPriority '+networkContentByPriority);
     System.debug('network '+network);
     System.debug('networkByPriority '+networkByPriority);
 
     IntPS_NSA__Health_Plan_Content_Network__c result=new IntPS_NSA__Health_Plan_Content_Network__c(); 
     try {
         
         for(Integer key : networkByPriority.keySet()){
             
             if(networkByPriority.get(key)!=null){
             if(networkByPriority.get(key).toLowerCase() == network.toLowerCase()){
                 priority= key;
             }
           }}
           result= networkContentByPriority.get(priority);
 
     } catch (Exception e) {
         throw new AuraHandledException(e.getMessage());
     }
     return result;
   }
   @AuraEnabled
   public static String getNetworkNames(List<String> availableNetworksForProvider){
     String result='';
     Integer i=0;
     try {
       List<Account> networks  =[Select IntPS__External_ID__c,Name FROM Account where IntPS__External_ID__c in : availableNetworksForProvider];
     for(Account network :networks){
         if(i==0){
             result=network.Name; 
         }
         else{
           
                 result=result+','+network.Name;
          }
          i++;
     }
     } catch (Exception e) {
         throw new AuraHandledException(e.getMessage());
     }
     return result;
   }
   // main function for the eob and eob line item creation
   @AuraEnabled
   public static String serviceLineInsert(String claimFields, String procedures, String providerNumber, Date serviceDate, List < IntPS_NSA__Health_Plan_Content_Network__c > networks, String networkOption, String tpaAcro, List < String > networkNames, String userEmail, String patientId, List<String> outOfNetworkNames, String providerZIP,String healthPlanId,List<String> availableNetworksForProvider,List<String> networkNamesDisplay) {
       System.debug('1 entering service line insert having all the fields and values of the EOB,the procedures selected,the provider details, the network details including the in networks or the out networks'+availableNetworksForProvider);
       Boolean checkIfSplitAvailable=[Select IntPS_NSA__Split_Provider_Pricing__c from IntPS__Health_Plan__c  where Id=:healthPlanId].IntPS_NSA__Split_Provider_Pricing__c;
       String networkNameSelected;
       List < Procedures > selectedProcedures = (List < Procedures > ) JSON.deserialize(procedures, List < Procedures > .class);
       String serviceType;
       Boolean INNRbp=false;
       if(checkIfSplitAvailable){
         serviceType= checkServiceTypeforINNRBP(selectedProcedures);
       if(serviceType=='Institutional'){
           INNRbp=true;
           networkOption='In-Network';
       }
       else{
           INNRbp=false; 
       }
     }
     else{
         serviceType= checkServiceType(selectedProcedures);
     }
       Boolean lineItemWithNoRate=false;
       Boolean atLeastOneServiceWithPrice=false;
       IntPS__RemarkCode__c noRateRM=new IntPS__RemarkCode__c();
       IntPS__RemarkCode__c noNetworkRateRM=new IntPS__RemarkCode__c();
       String networkOptionSelected;
       NetworkPrice priceResult;
       String networkUsed;
       String networkUsedSmallName;
       Date networkDateUsed;
       WebServiceCalloutWrapper wsWrapper=new WebServiceCalloutWrapper();
       List < NSA_MRFToApex > servicesPrices = new List < NSA_MRFToApex > ();
       String servicePrices;
       System.debug('2 variables prepared');
       List < String > procedureCodeList = new List < String > ();
       System.debug('3');
 
       Map < Integer, String > networkByPriority = new Map < Integer, String > ();
       Map < Integer, IntPS_NSA__Health_Plan_Content_Network__c > networkContentByPriority = new Map < Integer, IntPS_NSA__Health_Plan_Content_Network__c > ();
       Map < Integer, IntPS_NSA__Health_Plan_Content_Network__c > networkContentByPriorityTier2 = new Map < Integer, IntPS_NSA__Health_Plan_Content_Network__c > ();
       Map < Integer, IntPS_NSA__Health_Plan_Content_Network__c > networkContentByPriorityTier3 = new Map < Integer, IntPS_NSA__Health_Plan_Content_Network__c > ();
 
       NSA_RbpPricesResponse rbpPriceByProcedure;
       System.debug('4 sorting networks by priority their priority');
       //fix the empty priorities that are on the member specific hpc networks to be first in priority
     networks=checkForMemberSpecificHPC(networks);
       for (IntPS_NSA__Health_Plan_Content_Network__c network: networks) {
           if (network.IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c == networkOption) {
             System.debug('entering if provider network is purely in network or out of network');
              networkByPriority.put(Integer.valueOf(network.IntPS_NSA__Priority__c), network.IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
               networkContentByPriority.put(Integer.valueOf(network.IntPS_NSA__Priority__c), network);
             
           }
           else{
             if(network.IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c.contains('1')){
                 System.debug('entering if provider network contains 1, We will have multi tiers hpc');
               networkByPriority.put(Integer.valueOf(network.IntPS_NSA__Priority__c), network.IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
               networkContentByPriority.put(Integer.valueOf(network.IntPS_NSA__Priority__c), network);
           }
           else{
             if(network.IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c.contains('2')){
             System.debug('entering if provider network contains 2, We will have multi tiers hpc');
             networkContentByPriorityTier2.put(Integer.valueOf(network.IntPS_NSA__Priority__c), network);
             }
             else{
                 if(network.IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c.contains('3')){
                     System.debug('entering if provider network contains 3');
                     networkContentByPriorityTier3.put(Integer.valueOf(network.IntPS_NSA__Priority__c), network);
             }
             
           }
           }
       }
     }
     System.debug('networkByPriority '+networkByPriority);
       List < Integer > aList = new List < Integer > ();
       aList.addAll(networkByPriority.keySet());
       aList.sort();
       Integer maxValue=aList.size();
       System.debug('max value is '+maxValue);
       for (Integer key : networkContentByPriorityTier2.keySet()) {
         networkByPriority.put(maxValue+Integer.valueOf(networkContentByPriorityTier2.get(key).IntPS_NSA__Priority__c), networkContentByPriorityTier2.get(key).IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
         networkContentByPriority.put(maxValue+Integer.valueOf(networkContentByPriorityTier2.get(key).IntPS_NSA__Priority__c), networkContentByPriorityTier2.get(key));
 
     }
     List < Integer > aListTier2 = new List < Integer > ();
     aListTier2.addAll(networkByPriority.keySet());
     aListTier2.sort();
       Integer maxValueTier2=aListTier2.size();
       System.debug('max value tier 2 is '+maxValueTier2);
     for (Integer key : networkContentByPriorityTier3.keySet()) {
         networkByPriority.put(maxValueTier2+Integer.valueOf(networkContentByPriorityTier3.get(key).IntPS_NSA__Priority__c), networkContentByPriorityTier3.get(key).IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
         networkContentByPriority.put(maxValueTier2+Integer.valueOf(networkContentByPriorityTier3.get(key).IntPS_NSA__Priority__c), networkContentByPriorityTier3.get(key));
 
     }
       System.debug('5' + networkContentByPriority);
       System.debug('5 v2 '+networkByPriority);
       Boolean isRBP=false;
       if(INNRbp){isRBP=true; }
       System.debug('checking from where we are getting the prices');
       IntPS_NSA__Health_Plan_Content_Network__c hon=getHealthPlanNetwork(outOfNetworkNames,serviceType,networkOption);
      
     Boolean healthplanField=true;
     
     
 
       if (networkOption == 'Out-Of-Network') {
         if(INNRbp){
             networkOption='In-Network';
         }
           System.debug('out of network, so only rbp, so we will now check if we will use medicare or fair health');
           wsWrapper=rbpCalculation(outOfNetworkNames, tpaAcro, providerZIP, providerNumber, selectedProcedures, serviceDate,healthPlanId,networkOption,hon);
           rbpPriceByProcedure = wsWrapper.rbpResponse;
       } else {
           System.debug('this is in network, so we check if the most priority is rbp or else');
 
           if (isRBP) {
               System.debug('first priority is rbp,  so we will now check if we will use medicare or fair health');
               wsWrapper=rbpCalculation(outOfNetworkNames, tpaAcro, providerZIP, providerNumber, selectedProcedures, serviceDate,healthPlanId,networkOption,hon);
               rbpPriceByProcedure = wsWrapper.rbpResponse;
           } else {
               System.debug('first priority is not rbp, so we do a sql callout for validation, and also we will use rbp calculation if it exists at least on hpc network having rbp');
               List<IntPS_NSA__Health_Plan_Content_Network__c> hpn=[Select IntPS_NSA__RbP_Basis__c,IntPS_NSA__RbP_Percentage__c from IntPS_NSA__Health_Plan_Content_Network__c where IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c='In-Network' and IntPS_NSA__RbP__c=true];
               if(hpn.size()>0){
                 rbpPriceByProcedure=rbpCalculation(outOfNetworkNames, tpaAcro, providerZIP, providerNumber, selectedProcedures, serviceDate,healthPlanId,networkOption,hon).rbpResponse;
 
               }
 
               wsWrapper = SQLWSCallout(claimFields, '', networks, selectedProcedures, providerNumber, tpaAcro, networkNames, userEmail, patientId);
               servicePrices=wsWrapper.response;
               servicesPrices = NSA_MRFToApex.parse(servicePrices);
 
           }
       }
       //inserting eob first  
       System.debug('inserting eob first ');
 
       List < SaveResultWrapper > srwList = new List < SaveResultWrapper > ();
       ClaimSaveResultWrapper csrw = new ClaimSaveResultWrapper();
       String claimId;
         Savepoint sp;
       if(!Test.isRunningTest())
       {
         sp = Database.setSavepoint();  
       } 
       List < SaveResultWrapper > claimResult = claimInsert(claimFields, servicePrices, userEmail, patientId,wsWrapper,hon.IntPS_NSA__RbP_Basis__c,hon.IntPS_NSA__RbP_Percentage__c,networkOption,availableNetworksForProvider,networkNamesDisplay);
       csrw.claimSWRList = claimResult;
       Boolean hasError = true;
       for (SaveResultWrapper swr: claimResult) {
           if (swr.isSucces) {
               claimId = swr.Id;
               hasError = false;
           }
       }
       if (!hasError) {
           System.debug('eob inserted ');
 
           Boolean allLineInsered = true;
           List < IntPS__EOB_Line_Item__c > slList = new List < IntPS__EOB_Line_Item__c > ();
           Integer counter = 0;
       
           System.debug('we now prepare to insert eob line items by going through each procedure selected ');
 
           for (Integer cc = 0; cc < selectedProcedures.size(); cc++) {
               System.debug('preparing eob line item number' + cc + ' ' + selectedProcedures[cc].Code);
               IntPS__EOB_Line_Item__c lineItem = new IntPS__EOB_Line_Item__c();
               lineItem.IntPS__L2110_Procedure_Code__c = selectedProcedures[cc].Code;
               lineItem.IntPS__L2110_Procedure_Code_Description__c = selectedProcedures[cc].Description;
               lineItem.IntPS_NSA__Line_Number__c = cc + 1;
               lineItem.IntPS__EOB__c = claimId;
               lineItem.IntPS_NSA__Place_Of_Service__c = selectedProcedures[cc].PlaceOfService;
               lineItem.Provider_Type__c = selectedProcedures[cc].ProviderType;
               lineItem.PreventativePregn__c = selectedProcedures[cc].PreventativeOption;
               lineItem.IntPS__L2110_Units_of_Service_Paid_Count__c = selectedProcedures[cc].Quantity;
               System.debug('checking if rbp or oon, we get the price from the valenz or fair health ws, if In network, we get the price from the mrf ws');
               if (isRBP || networkOption == 'Out-Of-Network' || INNRbp) {
                   System.debug('getting price from rbp WS'+rbpPriceByProcedure);
                   System.debug('getting price from rbp WS '+rbpPriceByProcedure.success);
                   if(!rbpPriceByProcedure.success){
                     lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c=0.0;
                     lineItemWithNoRate=true;
                     lineItem.isRateAvailableInMRF__c=false;
                   }
                   else{
                   for (NSA_RbpPricesResponse.Results results: rbpPriceByProcedure.Data[0].Results) {
                     System.debug('getting price from rbp WSin for loop'+results);
                       if (selectedProcedures[cc].Code == results.ProcedureCode) {
                         System.debug('in if '+results.Allowed);
                         System.debug('in if '+results.Allowed);
                         lineItem.IntPS_NSA__RBP_Initial_Price__c = results != null && results.Allowed != null && results.Allowed!=''  ? Decimal.valueOf(results.Allowed) : null;
                         if(lineItem.IntPS_NSA__RBP_Initial_Price__c!=null){
                             lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c = (Decimal.valueOf(results.Allowed)*hon.IntPS_NSA__RbP_Percentage__c)/100;
                             atLeastOneServiceWithPrice=true;
                             lineItem.isRateAvailableInMRF__c=true;
 
                         }
                         else{
                             lineItemWithNoRate=true;
                             lineItem.isRateAvailableInMRF__c=false;
 
                         }
                        
                           System.debug('lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c ' + lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c);
 
                       }
                   }
                 }
               } else {
                   System.debug('getting price from mrf WS');
                   System.debug('network selected? ' + networkNameSelected);
                     if(priceResult==null ||  !priceResult.isRbp){
                         priceResult = validateNetworksPricesByPriority(networkNames[0], servicesPrices, selectedProcedures[cc].Code, selectedProcedures[cc].PlaceOfService);
                         //calling again to get the maximum price in that selected network
                    
                     }
                     else{
                         if(rbpPriceByProcedure==null){
                             rbpPriceByProcedure = rbpCalculation(outOfNetworkNames, tpaAcro, providerZIP, providerNumber, selectedProcedures, serviceDate,healthPlanId,networkOption,hon).rbpResponse;
 
                         }
 
                     }
                     System.debug('price result '+priceResult);
                  if(priceResult!=null && priceResult.isRbp!=null){
                   if(priceResult.isRbp){
                     INNRbp=true;
                     priceResult=null;
                     System.debug('getting price from rbp WS after checking the mrf prices'+INNRbp+priceResult);
                     System.debug('rbpresponse available? '+rbpPriceByProcedure);
                     if(rbpPriceByProcedure.success){
                     for (NSA_RbpPricesResponse.Results results: rbpPriceByProcedure.Data[0].Results) {
                         if (selectedProcedures[cc].Code == results.ProcedureCode) {
                            
                            lineItem.IntPS_NSA__RBP_Initial_Price__c = results != null && results.Allowed != null && results.Allowed!=''  ? Decimal.valueOf(results.Allowed) : null;
                            if(lineItem.IntPS_NSA__RBP_Initial_Price__c!=null){
                                 lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c = (Decimal.valueOf(results.Allowed)*hon.IntPS_NSA__RbP_Percentage__c)/100;
                                 atLeastOneServiceWithPrice=true;
                                 lineItem.isRateAvailableInMRF__c=true;
     
                             }
                             else{
                                 lineItemWithNoRate=true;
                                 lineItem.isRateAvailableInMRF__c=false;
     
                             }
                             System.debug('lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c ' + lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c);
   
                         }
                     }
                 }
                 else{
                     lineItemWithNoRate=true;
                     lineItem.isRateAvailableInMRF__c=false;
                 }
                   }
                   else{
                     if(priceResult.isRateFound){
                         lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c = priceResult.price;
                         atLeastOneServiceWithPrice=true;
                         lineItem.isRateAvailableInMRF__c=true;
                         networkDateUsed=priceResult.networkDate;
                         networkUsed=priceResult.netowrkName;
                         networkUsedSmallName=priceResult.networkSmallName;
                     }
                     else{
                         lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c =0.0;
                         lineItemWithNoRate=true;
                         lineItem.isRateAvailableInMRF__c=false;
                     }
                     networkNameSelected = priceResult.netowrkName;
 
                 
                  
                   }
                 }
                 else{
                     if(rbpPriceByProcedure!=null){
                         INNRbp=true;
                         priceResult=null;
                         System.debug('getting price from rbp WS after checking the mrf prices'+INNRbp+priceResult);
                         for (NSA_RbpPricesResponse.Results results: rbpPriceByProcedure.Data[0].Results) {
                             if (selectedProcedures[cc].Code == results.ProcedureCode) {
                                lineItem.IntPS_NSA__RBP_Initial_Price__c = results != null && results.Allowed != null && results.Allowed!=''  ? Decimal.valueOf(results.Allowed) : null;
                                if(lineItem.IntPS_NSA__RBP_Initial_Price__c!=null){
                                     lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c = (Decimal.valueOf(results.Allowed)*hon.IntPS_NSA__RbP_Percentage__c)/100;
                                     atLeastOneServiceWithPrice=true;
                                     lineItem.isRateAvailableInMRF__c=true;
         
                                 }
                                 else{
                                     lineItemWithNoRate=true;
                                     lineItem.isRateAvailableInMRF__c=false;
         
                                 }
                                 System.debug('lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c ' + lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c);
       
                             }
                         } 
                     }
                     else{
                         //price not found  
                         lineItemWithNoRate=true;
                         lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c = 0.0;
                         lineItem.isRateAvailableInMRF__c=false;
                     }
                 }
 
 
                   System.debug('lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c ' + lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c);
               }
               System.debug(' lineItem.IntPS_NSA__Place_Of_Service__c ' + lineItem.IntPS_NSA__Place_Of_Service__c);
               if(lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c==null){
                 lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c=0.0;
               }
               lineItem.IntPS__L2110_Service_Line_Allowed_Amount__c = lineItem.IntPS__L2110_Units_of_Service_Paid_Count__c * lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c;
               lineItem.IntPS__L2110_Service_Date__c = serviceDate;
               lineItem.IntPS__L2110_Service_End_Date__c = serviceDate;
               lineItem.IntPS__L2110_Service_Start_Date__c = serviceDate;
               
               ProceduresMappedWithHP procHPI= MapProceduresToHPI(selectedProcedures[cc].Code, selectedProcedures[cc].PregnancyOption, selectedProcedures[cc].ProviderType, selectedProcedures[cc].PlaceOfService,healthPlanId,networkOption);
               if(networkOption=='Out-Of-Network' || networkUsed!=null || procHPI.healthPlanItemID!=null){
                 lineItem.IntPS_NSA__Health_Plan_Item__c = procHPI.healthPlanItemID;
               }
               lineItem.IntPS_NSA__Child_Procedure_Code_Name__c=procHPI.procedureCode;
               lineItem.IntPS_NSA__NSA_Clasification_Name__c=procHPI.nsaClassificationName;
               if(INNRbp){
                 networkOptionSelected=networkOption;
 
               }
               else{
                 networkOptionSelected=procHPI.providerNetworkOption;
 
               }
               System.debug('lineItem.IntPS_NSA__Health_Plan_Item__c ' + lineItem.IntPS_NSA__Health_Plan_Item__c);
               System.debug('counter ' + counter+' networkUsed'+networkUsed +' networkOption '+networkOption);
 
               if(counter!=0){
                 if(slList[counter-1].IntPS_NSA__Health_Plan_Item__c==null && networkUsed!=null && networkOption!='Out-Of-Network'){
                     System.debug('inside if to reconsider hpi');
                     networkOption=getHealthPlanContentFromNetwork(networkUsedSmallName,networkByPriority,networkContentByPriority).IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c;
                     ProceduresMappedWithHP procHPI2= MapProceduresToHPI(selectedProcedures[cc-1].Code, selectedProcedures[cc-1].PregnancyOption, selectedProcedures[cc-1].ProviderType, selectedProcedures[cc-1].PlaceOfService,healthPlanId,networkOption);
                     slList[counter-1].IntPS_NSA__Health_Plan_Item__c = procHPI2.healthPlanItemID;
                     slList[counter-1].IntPS_NSA__Child_Procedure_Code_Name__c=procHPI2.procedureCode;
                     slList[counter-1].IntPS_NSA__NSA_Clasification_Name__c=procHPI2.nsaClassificationName;
                 }
               }
               counter++;
               slList.add(lineItem);
           }
           System.debug('lineItemWithNoRate '+lineItemWithNoRate+ 'atLeastOneServiceWithPrice '+atLeastOneServiceWithPrice);
           // if any line item does not have a rate in the MRF datatabases, we assign the no rate Remark code to it
           if(lineItemWithNoRate){
              noRateRM=[Select Id,IntPS__EOB_Description__c from IntPS__RemarkCode__c where Name=:System.label.NSA_NoRateRemarkCode ];
           
         }
         if(!atLeastOneServiceWithPrice){
             noNetworkRateRM=[Select Id,IntPS__EOB_Description__c from IntPS__RemarkCode__c where Name=:System.label.NSA_NoNetworkRateRemarkCode ];
         }
           for(IntPS__EOB_Line_Item__c eobLine:slList){
             if(eobLine.IntPS_NSA__Service_Line_Allowed_Unit_Price__c==0.0){
                 eobLine.Remark_Code__c=noRateRM.Id;
             }
           
         }
     
           System.debug('inserting eob line items');
           List < Database.SaveResult > srList = new List < Database.SaveResult > ();
           if (!slList.isEmpty()) {
               srList = Database.insert(slList, false);
               for (Database.SaveResult sr: srList) {
                   SaveResultWrapper srw = new SaveResultWrapper();
                   srw.isSucces = sr.isSuccess();
 
                   if (sr.isSuccess()) {
                       srw.Id = sr.getId();
                   } else {
                       allLineInsered = false;
                       // Operation failed, so get all errors
                       List < String > customErrorMessageList = new List < String > ();
                       for (Database.Error err: sr.getErrors()) {
                           customErrorMessageList.add(err.getStatusCode() + ': ' + err.getMessage());
                       }
                       srw.handleErrorList = customErrorMessageList;
                   }
                   srwList.add(srw);
               }
           }
           if (!allLineInsered) {
               Database.rollback(sp);
           }
       } else {
 
           throw new AuraHandledException(claimResult[0].handleErrorList[0]);
 
 
 
 
       }
       csrw.serviceSWRList = srwList;
       System.debug('updating eob with the mrf details');
 
       IntPS__EOB__c eobAdded = [Select Id,Name, IntPS_NSA__MRF_Date__c, IntPS_NSA__MRF_Network__c from IntPS__EOB__c where Id =: claimId];
       System.debug('priceResult is null? ' + priceResult);
       if(!atLeastOneServiceWithPrice){
             eobAdded.IntPS_NSA__MRF_Network__c = noNetworkRateRM.IntPS__EOB_Description__c;
 
       }
       else{
       if (priceResult == null) {
           System.debug('priceResult is null ' + outOfNetworkNames);
           if(INNRbp){
             eobAdded.IntPS_NSA__MRF_Network__c = networkOption;
             for (Integer key : networkContentByPriority.keySet()) {
                if(networkContentByPriority.get(key).IntPS_NSA__RbP__c){
                 String selectednetworkId=networkContentByPriority.get(key).IntPS_NSA__Network__c;
                 if(selectednetworkId!=null){
                    eobAdded.IntPS_NSA__MRF_Network__c = [Select Name from IntPS__Network__c where Id=:selectednetworkId].Name;
                 }
                 else{
                    eobAdded.IntPS_NSA__MRF_Network__c = 'In-Network RBP';
                 }                }
             }
           }
           else{
             if(networkOption=='In-Network'){
                 eobAdded.IntPS_NSA__MRF_Network__c = 'In-Network RBP';
 
             }
             else{
                 eobAdded.IntPS_NSA__MRF_Network__c = 'Out Of Network';
 
             }
 
           }
       } else {
           System.debug('priceResult is not null ' + priceResult);
           System.debug('priceResult is not null ' + networkDateUsed+ ' '+networkUsed);
           eobAdded.IntPS_NSA__MRF_Date__c = networkDateUsed;
           eobAdded.IntPS_NSA__MRF_Network__c = networkUsed;
       }
     }
     
     
        
       eobAdded.IntPS_NSA__Provider_Network__c=networkOptionSelected;
       try {
           update(eobAdded);
           System.debug('eob updated' + eobAdded);
       } catch (Exception e) {
           IntPS_NSA__NSA_Error_Log__c nsaerror = createErrorLogs(eobAdded,patientId, claimId, e.getMessage(), userEmail, 'When doing the mrf date/name update ');
           throw new AuraHandledException(e.getMessage());
 
       }
       System.debug('claimId ' + claimId);
       return claimId;
   }
 
 
   // trigger the calculation of the eob line items using accumulators
   @AuraEnabled
   public static Boolean triggerCalculation(String eobId, String patientId, String userEmail) {
     Boolean atLeastOneServiceWithRate=false;
       IntPS__EOB__c eobAdded = [Select Id, IntPS_NSA__Calculate_TPA__c from IntPS__EOB__c where Id =: eobId];
       eobAdded.IntPS_NSA__Calculate_TPA__c = true;
       List<IntPS__EOB_Line_Item__c> eobItems=[Select isRateAvailableInMRF__c from IntPS__EOB_Line_Item__c where IntPS__EOB__c=:eobId];
       
       try {
           update(eobAdded);
           System.debug('eob updated ');
           List < IntPS__EOB_Line_Item__c > lineItems = [Select isRateAvailableInMRF__c,IntPS__L2110_Service_Line_Allowed_Amount__c,IntPS_NSA__Service_Line_Allowed_Unit_Price__c,IntPS_NSA__Patient_Responsibility__c, IntPS_NSA__Deductible_Amount__c, IntPS_NSA__Copay_Amount__c, IntPS_NSA__Coinsurance_Amount__c, IntPS_NSA__Not_Covered_Amount__c from IntPS__EOB_Line_Item__c where IntPS__EOB__c =: eobId];
           System.debug('getting line items ');
           for (IntPS__EOB_Line_Item__c lineItem: lineItems) {
             System.debug('calculating line items IntPS_NSA__Patient_Responsibility__c ');
               lineItem.IntPS_NSA__Patient_Responsibility__c = lineItem.IntPS_NSA__Deductible_Amount__c + lineItem.IntPS_NSA__Copay_Amount__c + lineItem.IntPS_NSA__Coinsurance_Amount__c + lineItem.IntPS_NSA__Not_Covered_Amount__c;
               System.debug('calculated');
 
               System.debug('checking is rate available '+lineItem.isRateAvailableInMRF__c);
               if(!lineItem.isRateAvailableInMRF__c){
           
             }
             else{
                 atLeastOneServiceWithRate=true;
             }
             }
           
           if(!atLeastOneServiceWithRate){
             eobAdded.AtLeastOneLineItemWithRate__c=false;
             update(eobAdded);
           
           }
           for (IntPS__EOB_Line_Item__c lineItem: lineItems) {
             System.debug('calculating line items IntPS_NSA__Patient_Responsibility__c ');
               lineItem.IntPS_NSA__Patient_Responsibility__c = lineItem.IntPS_NSA__Deductible_Amount__c + lineItem.IntPS_NSA__Copay_Amount__c + lineItem.IntPS_NSA__Coinsurance_Amount__c + lineItem.IntPS_NSA__Not_Covered_Amount__c;
               System.debug('calculated');
 
               System.debug('checking is rate available '+lineItem.isRateAvailableInMRF__c);
               if(!lineItem.isRateAvailableInMRF__c){
                 lineItem.IntPS__L2110_Service_Line_Allowed_Amount__c=null;
                 lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c=null;
                 lineItem.IntPS_NSA__Deductible_Amount__c=null;
                 lineItem.IntPS_NSA__Copay_Amount__c=null;
                 lineItem.IntPS_NSA__Coinsurance_Amount__c=null;
                 lineItem.IntPS_NSA__Not_Covered_Amount__c=null;
                 System.debug('lineItem '+lineItem);
             }
           
             }
             update(lineItems);
           
       } catch (Exception e) {
           IntPS_NSA__NSA_Error_Log__c nsaerror = createErrorLogs(eobAdded,patientId, eobId, e.getMessage(), userEmail, 'When doing the TPA Calculation ');
           throw new AuraHandledException(e.getMessage());
 
       }
       return true;
   }
   // insert eob record
   @AuraEnabled
   public static List < SaveResultWrapper > claimInsert(String fields, String servicePrices, String userEmail, String patientId,WebServiceCalloutWrapper wsWrapper,String basis,Decimal percentage,String networkOption,List<String> availableNetworksForProvider,List<String> networkNamesDisplay) {
 
       List < IntPS__EOB_Line_Item__c > slList = new List < IntPS__EOB_Line_Item__c > ();
        
       List < SaveResultWrapper > srwList = new List < SaveResultWrapper > ();
         Savepoint sp;
       if(!Test.isRunningTest())
       {
         sp = Database.setSavepoint();  
       }      Boolean allLineInsered = true;
       List < IntPS__EOB__c > claimList = new List < IntPS__EOB__c > ();
       IntPS__EOB__c ss = (IntPS__EOB__c) JSON.deserialize(fields, IntPS__EOB__c.class);
       ss.IntPS__L2100_Received_Date__c = date.parse(date.today().format());
       String response1;
       String response2;
       if(wsWrapper.response.length()>130900){
          response1= wsWrapper.response.substring(0, 130900);
          response2= wsWrapper.response.substring(130900, wsWrapper.response.length());
       }
       else{
         response1= wsWrapper.response.substring(0, wsWrapper.response.length());
         response2='';
       }
        
       
       ss.WSErrorLogs__c = response1;
       ss.WS_Response_Part_2__c = response2;
       ss.WS_Request__c=wsWrapper.request;
       ss.IntPS_Eob__Provider_Network__c=ss.IntPS_NSA__Provider_Network__c;
       ss.IntPS_Eob__Patient__c=ss.IntPS_NSA__Patient__c;
       if(System.Label.NSA_NeedsValidation=='true'){
         ss.IntPS__Status__c=System.Label.NSA_Initial_EOB_Status;
       }
       else{
         ss.IntPS__Status__c=System.Label.NSA_EOBNoValidationStatus;
       }  
       if(networkOption == 'Out-Of-Network'){
         ss.IntPS_NSA__RbP_Percentage__c=percentage;
         ss.IntPS_NSA__RbP_Basis__c=basis;
       }
       else{
        String availableNetworks='';
        if(networkNamesDisplay.size()>0){
            for(String network:networkNamesDisplay){
                availableNetworks=availableNetworks+network+' ';
            }
 
        }
        ss.Available_Networks_For_Provider__c=availableNetworks;

      
       }
       
       ss.RecordTypeId=Schema.getGlobalDescribe().get('IntPS__EOB__c').getDescribe().getRecordTypeInfosByName().get('Advanced EOB').getRecordTypeId();
       System.debug('record type '+ss.RecordTypeId+' status '+ss.IntPS__Status__c);
       System.debug('claim fields ' + ss);
 
       claimList.add(ss);
 
       List < Database.SaveResult > srList = new List < Database.SaveResult > ();
       if (!claimList.isEmpty()) {
           srList = Database.insert(claimList, false);
           for (Database.SaveResult sr: srList) {
               SaveResultWrapper srw = new SaveResultWrapper();
               srw.isSucces = sr.isSuccess();
               System.debug('sr inserting eob' + sr);
               if (sr.isSuccess()) {
                   srw.Id = sr.getId();
               } else {
                   createErrorLogs(null,patientId, '', sr.getErrors()[0].getMessage(), userEmail, 'When Creating the EOB itself: ' + claimList);
 
                   allLineInsered = false;
                   // Operation failed, so get all errors
                   List < String > customErrorMessageList = new List < String > ();
                   for (Database.Error err: sr.getErrors()) {
                       customErrorMessageList.add(err.getStatusCode() + ': ' + err.getMessage());
                   }
                   srw.handleErrorList = customErrorMessageList;
               }
               srwList.add(srw);
           }
       }
       if (!allLineInsered) {
           Database.rollback(sp);
       }
 
       return srwList;
   }
   // main function for the eob and eob line item creation in PodPlan
   @AuraEnabled
   public static String serviceLineInsertPodPlan(String claimFields, String procedures, String providerNumber, Date serviceDate, List < IntPS_NSA__Health_Plan_Content_Network__c > networks, String networkOption, String tpaAcro, List < String > networkNames, String userEmail, String patientId, List<String> outOfNetworkNames, String providerZIP,List<String> availableNetworksForProvider,List<String> networkNamesDisplay) {
       List < Procedures > selectedProcedures = (List < Procedures > ) JSON.deserialize(procedures, List < Procedures > .class);
       List < String > procedureCodeList = new List < String > ();
       WebServiceCalloutWrapper wsWrapper=new WebServiceCalloutWrapper();
       wsWrapper.request='';
       wsWrapper.response='';
       //inserting eob first  
       System.debug('inserting eob first ');
 
       List < SaveResultWrapper > srwList = new List < SaveResultWrapper > ();
       ClaimSaveResultWrapper csrw = new ClaimSaveResultWrapper();
       String claimId;
         
         Savepoint sp = Database.setSavepoint();  
        
       List < SaveResultWrapper > claimResult = claimInsert(claimFields, null, userEmail, patientId,wsWrapper,'',0,networkOption,availableNetworksForProvider,networkNamesDisplay);
       csrw.claimSWRList = claimResult;
       Boolean hasError = true;
       for (SaveResultWrapper swr: claimResult) {
           if (swr.isSucces) {
               claimId = swr.Id;
               hasError = false;
           }
       }
       if (!hasError) {
           System.debug('eob inserted ');
 
           Boolean allLineInsered = true;
           List < IntPS__EOB_Line_Item__c > slList = new List < IntPS__EOB_Line_Item__c > ();
           Integer counter = 1;
           /* for(String s : fields) {
              IntPS__EOB_Line_Item__c ss = (IntPS__EOB_Line_Item__c)JSON.deserialize(s,IntPS__EOB_Line_Item__c.class);
              ss.Line_Number__c=counter;
                ss.IntPS__EOB__c = claimId;
                slList.add(ss);
                counter++;
            }*/
           System.debug('we now prepare to insert eob line items by going through each procedure selected ');
 
           for (Integer cc = 0; cc < selectedProcedures.size(); cc++) {
               System.debug('preparing eob line item number' + cc + ' ' + selectedProcedures[cc].Code);
               IntPS__EOB_Line_Item__c lineItem = new IntPS__EOB_Line_Item__c();
               lineItem.IntPS__L2110_Procedure_Code__c = selectedProcedures[cc].Code;
               lineItem.IntPS__L2110_Procedure_Code_Description__c = selectedProcedures[cc].Description;
               lineItem.IntPS_NSA__Line_Number__c = cc + 1;
               lineItem.IntPS__EOB__c = claimId;
               lineItem.IntPS__L2110_Units_of_Service_Paid_Count__c = selectedProcedures[cc].Quantity;
               IntPS__Cpt_Repricing_Table__c pricing=[Select IntPS__Procedure_Code__c,IntPS__Price__c from IntPS__Cpt_Repricing_Table__c where IntPS__Procedure_Code__r.Name=:selectedProcedures[cc].Code LIMIT 1];
 
               lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c = Decimal.valueOf(pricing.IntPS__Price__c);
                 if(lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c!=null){
                     lineItem.IntPS__L2110_Service_Line_Allowed_Amount__c = lineItem.IntPS__L2110_Units_of_Service_Paid_Count__c * lineItem.IntPS_NSA__Service_Line_Allowed_Unit_Price__c;
 
                 }
               lineItem.IntPS__L2110_Service_Date__c = serviceDate;
               lineItem.IntPS__L2110_Service_End_Date__c = serviceDate;
               lineItem.IntPS__L2110_Service_Start_Date__c = serviceDate;
               lineItem.IntPS_NSA__Health_Plan_Item__c = 'a0GDn000000IbhiMAC';
 
               slList.add(lineItem);
           }
           System.debug('inserting eob line items');
           List < Database.SaveResult > srList = new List < Database.SaveResult > ();
           if (!slList.isEmpty()) {
               srList = Database.insert(slList, false);
               for (Database.SaveResult sr: srList) {
                   SaveResultWrapper srw = new SaveResultWrapper();
                   srw.isSucces = sr.isSuccess();
 
                   if (sr.isSuccess()) {
                       srw.Id = sr.getId();
                   } else {
                       allLineInsered = false;
                       // Operation failed, so get all errors
                       List < String > customErrorMessageList = new List < String > ();
                       for (Database.Error err: sr.getErrors()) {
                           customErrorMessageList.add(err.getStatusCode() + ': ' + err.getMessage());
                       }
                       srw.handleErrorList = customErrorMessageList;
                   }
                   srwList.add(srw);
               }
           }
           if (!allLineInsered) {
               Database.rollback(sp);
           }
       } else {
 
           throw new AuraHandledException(claimResult[0].handleErrorList[0]);
 
 
 
 
       }
       csrw.serviceSWRList = srwList;
 
     
       System.debug('claimId ' + claimId);
       return claimId;
   }
 // get patient eligibilities
   @AuraEnabled
   public static Map < String, List < SObject >> getPatientInformation(string patientId, Date serviceDate, String continueWElig) {
       List < SObject > returnList = new List < SObject > ();
       Map < String, List < SObject >> returnMap = new Map < String, List < SObject >> ();
 
           //returnList = [SELECT Id, Name, Status__c, Eligibility__c, IntPS__L2100_Total_Claim_Charge_Amount__c, IntPS__L2100_Total_Claim_Payment_Amount__c, IntPS__L2100_Patient_Responsibility_Amount__c, IntPS__L2100_Adjustment_Amount__c, Service_Date__c, ServiceDate__c, Patient__c FROM IntPS__EOB__c WHERE Patient__c =: patientId AND Eligibility__c != null AND (Service_Date__c =: serviceDate OR ServiceDate__c =: serviceDate)] ;
           //if(returnList.isEmpty()){
           System.debug('patientId ' + patientId);
 
           List < IntPS__Eligibility__c > properEligibilityList = [SELECT Id,Employer_and_TPA_Plan__c,Employer_and_TPA_Plan__r.Pricing_Vendor__c,Employer_and_TPA_Plan__r.Pricing_Vendor__r.Name,Employer_and_TPA_Plan__r.Network_Acronym__c, IntPS__Health_Plan__c,IntPS__Health_Plan__r.Name, IntPS__Payer_Name__c, IntPS__Payer_Name__r.Name, IntPS__Begin_Date__c, IntPS__Term_Date__c,IntPS__Patient__r.IntPS__Employer__c,IntPS__Patient__c,IntPS__Patient__r.IntPS__Employer__r.Name FROM IntPS__Eligibility__c WHERE IntPS__Patient__c =: patientId and (IntPS__Health_Plan__r.IntPS_NSA__Plan_Type__c = 'MEC' or IntPS__Health_Plan__r.Plan_Type__c = 'MEC') ORDER BY IntPS__Begin_Date__c DESC];
 
           List < IntPS__Eligibility__c > returnEligibilityList = new List < IntPS__Eligibility__c > (); 
           for (IntPS__Eligibility__c elg: properEligibilityList) {
               if (elg.IntPS__Begin_Date__c <= serviceDate && (elg.IntPS__Term_Date__c == null || elg.IntPS__Term_Date__c >= serviceDate)) {
                   System.debug('adding elig ' + elg);
                   System.debug('adding IntPS__External_ID__c ' + elg.Employer_and_TPA_Plan__r.Network_Acronym__c);
                   returnEligibilityList.add(elg);
                   System.debug('adding elig ' + returnEligibilityList);
                 break;
               }
           }
           returnMap.put('Eligibility', returnEligibilityList);
           // }else{
           //   returnMap.put('EOB', returnList);
           //   returnMap.put('Eligibility', null);
           // }
           System.debug('dbg--------' + returnMap);
       
 
       return returnMap;
   }
 // get health plan items of a specific Health plan and health plan content
   @AuraEnabled
   public static List < IntPS__Health_Plan_Item__c > getHPIList(String hpId, String hpcId) {
       /*String query = 'Select Id, Name FROM IntPS__Health_Plan_Item__c WHERE IntPS__Health_Plan__c =: hpId AND Name LIKE \'%' + searchKey + '%\'';
       List<SObject> objectList = Database.query(query); */
       List < IntPS__Health_Plan_Item__c > hpiList = [Select Id, Name, NSA_Classification__c, IntPS__Not_Covered__c, IntPS__Maximum_Benefit__c, IntPS__Add_to_Deductible_Amount__c, IntPS__After_Plan_Deductible__c, IntPS__Coinsurance__c, IntPS__Copay__c FROM IntPS__Health_Plan_Item__c WHERE IntPS__Health_Plan__c =: hpId AND IntPS__Health_Plan_Content__c =: hpcId];
       return hpiList;
   }
 //get health contents of a health plan
   @AuraEnabled
   public static List < IntPS__Health_Plan_Content__c > getHPCList(String hpId) {
       List < IntPS__Health_Plan_Content__c > hpcList = [SELECT Id, IntPS__Provider_Network__c, Name FROM IntPS__Health_Plan_Content__c WHERE IntPS__Health_Plan__c =: hpId ORDER BY CreatedDate];
       return hpcList;
   }
 
   //check if a health plan has an OUt of netowrk health plan content
   @AuraEnabled
   public static Boolean hasOutOfNetwork(String healthPlanId) {
       try {
           List < IntPS__Health_Plan_Content__c > result = [Select Id from IntPS__Health_Plan_Content__c where IntPS__Health_Plan__c =: healthPlanId and IntPS__Provider_Network__c = 'Out-of-Network'];
           if (result.size() > 0) {
               return true;
           } else {
               return false;
           }
       } catch (Exception e) {
           return false;
       }
   }
 // search for providers by first checking NPI Registry, and after that checking if the provider is included in the patients health plan or not by calling the MRF API
   @AuraEnabled(cacheable = true)
   public static List < Providers > checkExistingNPI(String searchValue, Boolean searchwithCode, Boolean searchwithName, List < String > networks, String tpaAcro, Boolean hasOON) {
       List < Providers > providers = new List < Providers > ();
       String mrfCallBody = '{"tins":["' + searchValue + '"],"TPA_Acronym":"' + tpaAcro + '","NTW_Acronym": [';
       for (Integer cc = 0; cc < networks.size(); cc++) {
           if (cc == networks.size() - 1) {
               mrfCallBody = mrfCallBody + '"' + networks[cc] + '"]}';
 
           } else {
               mrfCallBody = mrfCallBody + '"' + networks[cc] + '",';
 
           }
 
       }
       System.debug('mrfCallBody ' + mrfCallBody);
       List < NSA_ProvideDetailsWrapper > providerDetails = new List < NSA_ProvideDetailsWrapper > ();
       if(networks.size()!=0){
       try {
           if (test.isRunningTest()) {
               Test.setMock(HttpCalloutMock.class, new NSA_ProviderDetailsMock());
 
           }
           providerDetails = NSA_ProvideDetailsWrapper.parse(NSA_WSUtils.doPost('getProviderDetails', mrfCallBody));
 
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
     }
       Map < String, NSA_ProvideDetailsWrapper > providerDetailsMap = new Map < String, NSA_ProvideDetailsWrapper > ();
       for (NSA_ProvideDetailsWrapper prov: providerDetails) {
           providerDetailsMap.put(String.valueOf(prov.tin), prov);
       }
       if (searchwithName) {
           string searchKeyword = '%' + searchValue + '%';
           List<Account> npiList = [SELECT Name, Id, IntPS__NPI_Number__c, BillingCity, BillingStreet, BillingState, BillingPostalCode, BillingCountry,Phone FROM Account WHERE Type='Provider' and Name Like :searchKeyword];
           System.debug('dbg>>>>>>>'+ npiList);
           for(Account account : npiList){
             Providers resultFirstName=new Providers();
             resultFirstName.NPINumber=account.IntPS__NPI_Number__c;
            
             resultFirstName.ProviderName=account.Name;
             resultFirstName.ProviderCity=account.BillingCity;
             resultFirstName.ProviderCountry=account.BillingCountry;
             resultFirstName.ProviderPostalCode=account.BillingPostalCode;
             resultFirstName.ProviderState=account.BillingState;
             resultFirstName.ProviderStreet=account.BillingStreet;
             resultFirstName.ProviderPhone=account.Phone;
             resultFirstName.networkOption = 'In-Network';
 
             providers.add(resultFirstName);
           }
          /* String searchString='first_name='+searchValue;
            NSA_NPIToApex npiFirstName=new NSA_NPIToApex();
            try{
             if(test.isRunningTest()){
               Test.setMock(HttpCalloutMock.class, new NSA_ProviderWSMock());
             }
             npiFirstName = NSA_NPIToApex.parse(NSA_WSUtils.doPost('NPIAPI',searchString));
            }
            catch (Exception e) {
              throw new AuraHandledException(e.getMessage());
            }
            for(Integer i=0;i<npiFirstName.results.size();i++){
              Providers resultFirstName=new Providers();
              resultFirstName.NPINumber='1234';
              resultFirstName.ProviderName=npiFirstName.results[i].basic.first_name+' '+npiFirstName.results[0].basic.last_name;
              resultFirstName.ProviderCity=npiFirstName.results[i].addresses[0].city;
              resultFirstName.ProviderCountry=npiFirstName.results[i].addresses[0].country_name;
              resultFirstName.ProviderPostalCode=npiFirstName.results[i].addresses[0].postal_code;
              resultFirstName.ProviderState=npiFirstName.results[i].addresses[0].state;
              resultFirstName.ProviderStreet=npiFirstName.results[i].addresses[0].address_1;
              resultFirstName.ProviderPhone=npiFirstName.results[i].addresses[0].telephone_number;
              providers.add(resultFirstName);
            }
 
            searchString='last_name='+searchValue;
            NSA_NPIToApex npiLastName=new NSA_NPIToApex();
            try{
             if(test.isRunningTest()){
               Test.setMock(HttpCalloutMock.class, new NSA_ProviderWSMock());
             }
             npiLastName = NSA_NPIToApex.parse(NSA_WSUtils.doPost('NPIAPI',searchString));
            }
            catch (Exception e) {
              throw new AuraHandledException(e.getMessage());
            }
            for(Integer i=0;i<npiLastName.results.size();i++){
              Providers resultLastByName=new Providers();
              resultLastByName.NPINumber='124';
              resultLastByName.ProviderName=npiLastName.results[i].basic.first_name+' '+npiLastName.results[0].basic.last_name;
              resultLastByName.ProviderCity=npiLastName.results[i].addresses[0].city;
              resultLastByName.ProviderCountry=npiLastName.results[i].addresses[0].country_name;
              resultLastByName.ProviderPostalCode=npiLastName.results[i].addresses[0].postal_code;
              resultLastByName.ProviderState=npiLastName.results[i].addresses[0].state;
              resultLastByName.ProviderStreet=npiLastName.results[i].addresses[0].address_1;
              resultLastByName.ProviderPhone=npiLastName.results[i].addresses[0].telephone_number;
              providers.add(resultLastByName);
            }*/
            
       } else {
           //  npiList = [SELECT Name, Id, IntPS__NPI_Number__c, BillingCity, BillingStreet, BillingState, BillingPostalCode, BillingCountry,is_In_Network__c,Phone FROM Account WHERE Type='Provider' and  IntPS__NPI_Number__c = : searchValue];
 
           String searchString = 'number=' + searchValue;
           NSA_NPIToApex npi = new NSA_NPIToApex();
           try {
               if (test.isRunningTest()) {
                   Test.setMock(HttpCalloutMock.class, new NSA_ProviderWSMock());
               }
               npi = NSA_NPIToApex.parse(NSA_WSUtils.doPost('NPIAPI', searchString));
           } catch (Exception e) {
               throw new AuraHandledException(e.getMessage());
           }
           for (Integer i = 0; i < npi.results.size(); i++) {
               Providers result = new Providers();
               result.NPINumber = searchValue;
               NSA_ProvideDetailsWrapper providerDetailsWrappe = providerDetailsMap.get(searchValue);
               System.debug('hasOON' + hasOON);
               if (providerDetailsWrappe == null && hasOON) {
                   System.debug('OON entered');
                   result.networkOption = 'Out-of-Network';
               } else {
                   if (providerDetailsWrappe == null && !hasOON) {
                     if(networks.size()==0){
                         System.debug('OON error');
                           result.networkOption = 'In-Network';
                       }
                       else{
                       System.debug('OON error');
 
                       throw new AuraHandledException('OON Error');
                       }
                   } else {
                       System.debug('IN entered');
                       result.availableNetworksForProvider=providerDetailsWrappe.networks;
 
                       result.networkOption = 'In-Network';
                   }
               }
               if(npi.results[i].enumeration_type.contains('NPI-2'))
               {
                 result.ProviderType='Institutional';
                 result.ProviderName = npi.results[i].basic.organization_name;
                 for(NSA_NPIToApex.cls_addresses address:npi.results[i].addresses){
                     if(address.address_purpose=='LOCATION'){
                         result.ProviderCity = address.city;
                         result.ProviderCountry = address.country_name;
                         result.ProviderPostalCode = address.postal_code;
                         result.ProviderState = address.state;
                         result.ProviderStreet =address.address_1;
                         result.ProviderPhone = address.telephone_number;
                         break;
                     }
                 }
                 
               }
               else{
                 result.ProviderType='Professional';
                 result.ProviderName = npi.results[i].basic.first_name + ' ' + npi.results[0].basic.last_name;
                 result.ProviderCity = npi.results[i].addresses[0].city;
                 result.ProviderCountry = npi.results[i].addresses[0].country_name;
                 result.ProviderPostalCode = npi.results[i].addresses[0].postal_code;
                 result.ProviderState = npi.results[i].addresses[0].state;
                 result.ProviderStreet = npi.results[i].addresses[0].address_1;
                 result.ProviderPhone = npi.results[i].addresses[0].telephone_number;
               }
               
               providers.add(result);
           }
       }
       System.debug('result length ' + providers.size());
 
       System.debug('result ' + providers);
 
       return providers;
   }
  
 
   public class SaveResultWrapper {
       @AuraEnabled
       public Boolean isSucces;
       @AuraEnabled
       public String Id;
       @AuraEnabled
       public List < String > handleErrorList;
 
   }
 
   public class ClaimSaveResultWrapper {
       @AuraEnabled
       public List < SaveResultWrapper > claimSWRList;
       @AuraEnabled
       public List < SaveResultWrapper > serviceSWRList;
   }
  
 // get the child procedure code based on the place of service/pregnany preventative/provider type
 // get the health plan item of the child procedure code
   @AuraEnabled
   public static ProceduresMappedWithHP MapProceduresToHPI(String parentProcedureCode, String prevPregn, String providerType, String placeOfService,String healthPlanId,String networkOption) {
       ProceduresMappedWithHP result = new ProceduresMappedWithHP();
       System.debug('placeOfService '+placeOfService+' prevPregn '+prevPregn+' providerType '+providerType);
       try {
         if(prevPregn=='Preventative Services'){
             List < IntPS__Procedure_Code__c > prList = [SELECT Id,IntPS__Classification__c,IntPS__Classification__r.Name, IntPS__Code_Type__c, Name, IntPS__Consumer_Description__c FROM IntPS__Procedure_Code__c where IntPS__Parent_Procedure_Code__r.IntPS_NSA__Shoppable_Item__c =true and IntPS__Parent_Procedure_Code__r.Name =:parentProcedureCode and Name like '%Prev'and IntPS__Parent_Procedure_Code__r.IntPS_NSA__Inactive__c =false and IntPS__Parent_Procedure_Code__r.IntPS_NSA__Inactive_F__c =false];
             if(prList.size()>0){
               List<IntPS__Health_Plan_Item__c> HPIs=[Select Id,IntPS__Provider_Network__c,Name,IntPS__Health_Plan_Content__r.IntPS__Provider_Network__c from IntPS__Health_Plan_Item__c where IntPS__Procedure_Code_Classification__c =:prList[0].IntPS__Classification__c and IntPS__Health_Plan__c =:healthPlanId];
               
               for(IntPS__Health_Plan_Item__c hpiitem:HPIs){
                 if(hpiitem.IntPS__Provider_Network__c==null){
                     result.nsaClassificationName=prList[0].IntPS__Classification__r.Name;
                     result.healthPlanItemID = hpiitem.Id;
                     result.codeType = prList[0].IntPS__Code_Type__c;
                     result.Description = prList[0].IntPS__Consumer_Description__c;
                     result.procedureCode = prList[0].Name;
                     result.providerNetworkOption=hpiitem.IntPS__Health_Plan_Content__r.IntPS__Provider_Network__c;
                     System.debug('ProceduresMappedWithHP result '+result);
                     break;
                 }
                 else{
                     if(hpiitem.IntPS__Provider_Network__c==networkOption){
                         result.nsaClassificationName=prList[0].IntPS__Classification__r.Name;
                         result.healthPlanItemID = hpiitem.Id;
                         result.codeType = prList[0].IntPS__Code_Type__c;
                         result.Description = prList[0].IntPS__Consumer_Description__c;
                         result.procedureCode = prList[0].Name;
                         result.providerNetworkOption=hpiitem.IntPS__Health_Plan_Content__r.IntPS__Provider_Network__c;
                         System.debug('ProceduresMappedWithHP result '+result);
                         break;
                     }
                 }
                 
               }
           
               return result;
             }
         }
         else{
             List < IntPS__Procedure_Code__c > prList = [SELECT Id,IntPS__Classification__c,IntPS__Classification__r.Name, IntPS__Code_Type__c, Name, IntPS__Consumer_Description__c FROM IntPS__Procedure_Code__c where IntPS_NSA__Shoppable_Item__c =true and Name =:parentProcedureCode and IntPS_NSA__Inactive__c =false and IntPS_NSA__Inactive_F__c =false];
             if(prList.size()>0){
               List<IntPS__Health_Plan_Item__c> HPIs=[Select Id,IntPS__Provider_Network__c,Name,IntPS__Health_Plan_Content__r.IntPS__Provider_Network__c from IntPS__Health_Plan_Item__c where IntPS__Procedure_Code_Classification__c =:prList[0].IntPS__Classification__c and IntPS__Health_Plan__c =:healthPlanId];
               for(IntPS__Health_Plan_Item__c hpiitem:HPIs){
                 if(hpiitem.IntPS__Provider_Network__c==null){
                     result.nsaClassificationName=prList[0].IntPS__Classification__r.Name;
                     result.healthPlanItemID = hpiitem.Id;
                     result.codeType = prList[0].IntPS__Code_Type__c;
                     result.Description = prList[0].IntPS__Consumer_Description__c;
                     result.procedureCode = prList[0].Name;
                     result.providerNetworkOption=hpiitem.IntPS__Health_Plan_Content__r.IntPS__Provider_Network__c;
                     System.debug('ProceduresMappedWithHP result '+result);
                     break;
                 }
                 else{
                     if(hpiitem.IntPS__Provider_Network__c==networkOption){
                         result.nsaClassificationName=prList[0].IntPS__Classification__r.Name;
                         result.healthPlanItemID = hpiitem.Id;
                         result.codeType = prList[0].IntPS__Code_Type__c;
                         result.Description = prList[0].IntPS__Consumer_Description__c;
                         result.procedureCode = prList[0].Name;
                         result.providerNetworkOption=hpiitem.IntPS__Health_Plan_Content__r.IntPS__Provider_Network__c;
                         System.debug('ProceduresMappedWithHP result '+result);
                         break;
                     }
                 }
                 
               }
           
               return result;
             }
         }
         
           return result;
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
   }
 
   @AuraEnabled
   public static Boolean hasMultiTiers(String healthPlanId){
     List<IntPS__Health_Plan_Content__c> hpc= new List<IntPS__Health_Plan_Content__c>();
     try {
         hpc=[Select Id from IntPS__Health_Plan_Content__c where IntPS__Health_Plan__c=:healthPlanId and IntPS__Provider_Network__c='INN-2'];
         
     } catch (Exception e) {
         throw new AuraHandledException(e.getMessage());
     }
     if(hpc.size()>0){
         return true;
     }
     else{
         return false;
     }
   }
 // search procedure codes based on the code or description, check if they are included in the health plan of the patient
   @AuraEnabled
   public static List < ProceduresFiltered > getProcedureCodes(String searchValue, Boolean searchwithCode, Boolean searchwithDescription, String healthPlanID, String networkOption,Boolean isPodPlan) {
       //getting all procedure codes based on the searched criteria
       System.debug('healthPlanID '+healthPlanID);
     if(isPodPlan){
         string searchKeyword = '%' + searchValue + '%';
       List < IntPS__Cpt_Repricing_Table__c > prList = new List < IntPS__Cpt_Repricing_Table__c > ();
       if (searchwithDescription) {
           try {
               prList = [SELECT IntPS__Procedure_Code__c, IntPS__Procedure_Code__r.Name, IntPS__Procedure_Code__r.IntPS__Consumer_Description__c, IntPS__Procedure_Code__r.IntPS__Code_Type__c FROM IntPS__Cpt_Repricing_Table__c where  IntPS__Procedure_Code__r.IntPS__Parent_Procedure_Code__c = ''
                   AND IntPS__Procedure_Code__r.IntPS__Description__c Like: searchKeyword
               ];
               System.debug('prList' + prList);
           } catch (Exception e) {
               throw new AuraHandledException(e.getMessage());
           }
       } else {
           try {
             prList = [SELECT IntPS__Procedure_Code__c, IntPS__Procedure_Code__r.Name, IntPS__Procedure_Code__r.IntPS__Consumer_Description__c, IntPS__Procedure_Code__r.IntPS__Code_Type__c FROM IntPS__Cpt_Repricing_Table__c where IntPS__Procedure_Code__r.IntPS__Parent_Procedure_Code__c = ''
             and IntPS__Procedure_Code__r.Name Like: searchKeyword
               ];
           } catch (Exception e) {
               throw new AuraHandledException(e.getMessage());
           }
       }
    
       List < ProceduresFiltered > finalProcedures = new List < ProceduresFiltered > ();
       for (IntPS__Cpt_Repricing_Table__c pr: prList) {
           ProceduresFiltered prFiltered = new ProceduresFiltered();
           prFiltered.procId = pr.IntPS__Procedure_Code__r.Id;
           prFiltered.Name = pr.IntPS__Procedure_Code__r.Name;
           prFiltered.Description = pr.IntPS__Procedure_Code__r.IntPS__Consumer_Description__c;
           prFiltered.Status = 'Included in Your Health Plan';
           prFiltered.CodeType = pr.IntPS__Procedure_Code__r.IntPS__Code_Type__c;
           
           
 
 
           finalProcedures.add(prFiltered);
 
       }
       return finalProcedures;
     }
     else{
         string searchKeyword = '%' + searchValue + '%';
         List < IntPS__Procedure_Code__c > prList = new List < IntPS__Procedure_Code__c > ();
         if (searchwithDescription) {
             try {
                 prList = [SELECT Id, Name, IntPS__Consumer_Description__c, IntPS__Code_Type__c FROM IntPS__Procedure_Code__c where IntPS_NSA__Shoppable_Item__c=true and IntPS__Parent_Procedure_Code__c = ''
                     AND IntPS__Description__c Like: searchKeyword and IntPS_NSA__Inactive__c=false
                 ];
                 System.debug('prList' + prList);
             } catch (Exception e) {
                 throw new AuraHandledException(e.getMessage());
             }
         } else {
             try {
                 prList = [SELECT Id, Name, IntPS__Consumer_Description__c, IntPS__Code_Type__c FROM IntPS__Procedure_Code__c where IntPS_NSA__Shoppable_Item__c=true and IntPS__Parent_Procedure_Code__c = ''
                     and name Like: searchKeyword and IntPS_NSA__Inactive__c=false
                 ];
             } catch (Exception e) {
                 throw new AuraHandledException(e.getMessage());
             }
         }
         List<String> prListCodes=new List<String>();
         for(IntPS__Procedure_Code__c c : prList){
           prListCodes.add(c.Name);
         }
       //getting all HPIs that are included in the Patient's Health Plan
       Map < String, String > classificationByHPI = new Map < String, String > ();
       List < IntPS__Health_Plan_Item__c > HPIs = new List < IntPS__Health_Plan_Item__c > ();
       try {
         if(networkOption!='Out-of-Network'){
             System.debug('network option is in network, so we check if it has multi tiers');
             Boolean hasMultiTiers=hasMultiTiers(healthPlanID);
             System.debug('multi tiers? '+hasMultiTiers);
            if(hasMultiTiers){
             System.debug('getting hpi for all multi tiers hpc');
             HPIs = [Select Id, IntPS__Procedure_Code_Classification__c from IntPS__Health_Plan_Item__c where IntPS__Health_Plan__c =: healthPlanID and IntPS__Health_Plan_Content__r.IntPS__Health_Plan__c =: healthPlanID and IntPS__Health_Plan_Content__r.IntPS__Provider_Network__c in ('In-Network','INN-2','INN-3') and IntPS__Procedure_Code_Classification__c!=null and IntPS__Provider_Network__c=:networkOption];
 
            }
            else{
             System.debug('getting hpi for one hpc');
             HPIs = [Select Id, IntPS__Procedure_Code_Classification__c from IntPS__Health_Plan_Item__c where IntPS__Health_Plan__c =: healthPlanID and IntPS__Health_Plan_Content__r.IntPS__Health_Plan__c =: healthPlanID and IntPS__Health_Plan_Content__r.IntPS__Provider_Network__c =: networkOption and IntPS__Procedure_Code_Classification__c!=null  and IntPS__Provider_Network__c=:networkOption];
 
            }
 
         }
         else{
             System.debug('in out of network, no multi tiers');
             HPIs = [Select Id, IntPS__Procedure_Code_Classification__c from IntPS__Health_Plan_Item__c where IntPS__Health_Plan__c =: healthPlanID and IntPS__Health_Plan_Content__r.IntPS__Health_Plan__c =: healthPlanID and IntPS__Health_Plan_Content__r.IntPS__Provider_Network__c =: networkOption and IntPS__Procedure_Code_Classification__c!=null  and IntPS__Provider_Network__c=:networkOption];
 
         }
         
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
       //group health plan items by classification
       Set < String > classifications = new Set < String > ();
       for (IntPS__Health_Plan_Item__c hpi: HPIs) {
           classifications.add(hpi.IntPS__Procedure_Code_Classification__c);
           classificationByHPI.put(hpi.Id, hpi.IntPS__Procedure_Code_Classification__c);
       }
       System.debug('classifications ' + classifications);
       //
       List < IntPS__Procedure_Code__c > proceduresAvailableInHP = new List < IntPS__Procedure_Code__c > ();
       //get all procedure codes that have the classifications of the healh plan of the patient
       try {
           proceduresAvailableInHP = [Select Name, IntPS__Consumer_Description__c, IntPS__Classification__c,IntPS__Parent_Procedure_Code__r.Name from IntPS__Procedure_Code__c where IntPS_NSA__Shoppable_Item__c=true and IntPS__Classification__c in: classifications and IntPS__Classification__c!=null and (IntPS__Parent_Procedure_Code__r.Name in :prListCodes OR Name in:prListCodes)];
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
       System.debug(proceduresAvailableInHP);
 
       //group available procedure codes by their code
       Map < String, IntPS__Procedure_Code__c > objMap1 = new Map < String, IntPS__Procedure_Code__c > ();
       for (IntPS__Procedure_Code__c procedureAvailableInHP: proceduresAvailableInHP) {
           objMap1.put(procedureAvailableInHP.Name, procedureAvailableInHP);
       }
       System.debug('the map '+objMap1);
       List < ProceduresFiltered > finalProcedures = new List < ProceduresFiltered > ();
       for (IntPS__Procedure_Code__c pr: prList) {
           ProceduresFiltered prFiltered = new ProceduresFiltered();
           prFiltered.procId = pr.Id;
           prFiltered.Name = pr.Name;
           prFiltered.Description = pr.IntPS__Consumer_Description__c;
           prFiltered.Status = 'Not Included in Your Health Plan';
           prFiltered.CodeType = pr.IntPS__Code_Type__c;
               if (objMap1.get(pr.Name)!=null) {
                   prFiltered.Status = 'Included in Your Health Plan';
                   System.debug('found ' + pr.Name);
               } 
           
 
 
           finalProcedures.add(prFiltered);
 
       }
       return finalProcedures;
     }
 
 
   }
   public class ProceduresFiltered {
       @AuraEnabled
       public String procId;
       @AuraEnabled
       public String Name;
       @AuraEnabled
       public String Description;
       @AuraEnabled
       public String Status;
       @AuraEnabled
       public String healthPlanItemID;
       @AuraEnabled
       public String CodeType;
   }
   public class ErrorWrapper {
     @AuraEnabled
     public String claimId;
     @AuraEnabled
     public String errorMessage;
    
 }
   public class ProceduresMappedWithHP {
       @AuraEnabled
       public String procedureCode;
       @AuraEnabled
       public String codeType;
       @AuraEnabled
       public String Description;
       @AuraEnabled
       public String healthPlanItemID;
       @AuraEnabled
       public String providerNetworkOption;
       @AuraEnabled
       public String nsaClassificationName;
   }
 
   public class Procedures {
       @AuraEnabled
       public String procId;
       @AuraEnabled
       public String Code;
       @AuraEnabled
       public String Description;
       @AuraEnabled
       public String Rate;
       @AuraEnabled
       public Integer Quantity;
       @AuraEnabled
       public String ProviderType;
       @AuraEnabled
       public String PregnancyOption;
       @AuraEnabled
       public String PreventativeOption;
       @AuraEnabled
       public String PlaceOfService;
       @AuraEnabled
       public String healthPlanItemID;
       @AuraEnabled
       public String CodeType;
   }
   public class NetworkPrice {
       @AuraEnabled
       public String netowrkName;
       @AuraEnabled
       public Double price;
       @AuraEnabled
       public Date networkDate;
       @AuraEnabled
       public Boolean isRbp;
       @AuraEnabled
       public Boolean isRateFound;
       @AuraEnabled
       public String networkSmallName;
       
   }
   public class WebServiceCalloutWrapper {
     @AuraEnabled
     public String request;
     @AuraEnabled
     public String response;
     @AuraEnabled
     public NSA_RbpPricesResponse rbpResponse ;
 
   
 }
   public class Providers {
       @AuraEnabled
       public String NPINumber;
       @AuraEnabled
       public String ProviderName;
       @AuraEnabled
       public String ProviderType;
       @AuraEnabled
       public String ProviderCity;
       @AuraEnabled
       public String ProviderStreet;
       @AuraEnabled
       public String ProviderState;
       @AuraEnabled
       public String ProviderPostalCode;
       @AuraEnabled
       public String ProviderCountry;
       @AuraEnabled
       public String ProviderPhone;
       @AuraEnabled
       public String networkOption;
       @AuraEnabled
       public List<String> availableNetworksForProvider;
   }
 }