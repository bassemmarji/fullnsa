/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-30-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class WSUtils {
  @AuraEnabled
  public static Boolean pingServer(String endpoint, String method, String body, String auth) {
      try {
          HttpRequest request = new HttpRequest();
          request.setEndpoint(endpoint);
          request.setMethod(method);
          request.setHeader('Content-Type', 'application/json');

          if (body != null) {
              request.setBody(body);
          }
          if (auth != null) {
              request.setHeader('Authorization', 'Basic ' + auth);
          }
          request.setTimeout(5000); // Set a timeout of 5 seconds
  
          HttpResponse response = new Http().send(request);
  
          // Check if the response status code is in the 200 range
          if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
              // Server is up and running
              System.debug('Server is up!');
              return true;
          } else {
              // Server is not responding or is down
              System.debug('Server is down!');
              return false;
          }
      } catch (Exception e) {
          throw new AuraHandledException(e.getMessage());
      }
  }
  @future(callout=true)
  public static void createJiraTicket(String endpoint,String body){
    HttpRequest request = new HttpRequest();
    request.setEndpoint(endpoint+'/rest/api/3/issue');
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
    request.setHeader('Authorization', 'Basic '+System.label.NSA_JiraToken);
    request.setHeader('Accept', 'application/json');

    request.setTimeout(Integer.valueOf(System.Label.NSA_MRF_Webservice_Timeout));
    request.setBody(body);
    Http http = new Http();
    HttpResponse res=new HttpResponse();
    try{
     
      res = http.send(request);

      
    }
    catch (System.CalloutException e) {
      System.debug('error in ws '+e.getMessage());
        throw new System.CalloutException(e.getMessage());
      }
    String responseBody=res.getBody();
    if(res.getStatusCode()!=201){
      System.debug('error in ws '+res);
        throw new System.CalloutException('Valenz Error');
    }
    system.debug('DEBUGGING RESPOSE: ' + res.getStatusCode() + ' > ' + res.getStatus() + '  >  ' + res.getBody());
    JiraAPIWrapper.parse(responseBody);
  } 
     public static String NPIAPI(string body,String endpoint){
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:NPI_Registry/?'+body+'&version=2.1&limit='+System.Label.NSA_NPIRegResultLimit+'&use_first_name_alias=false');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout(Integer.valueOf(System.Label.NSA_MRF_Webservice_Timeout));
        Http http = new Http();
        HttpResponse res =new HttpResponse();
        try{
          
          res = http.send(request);

        }
        catch (System.CalloutException e) {
            throw new System.CalloutException(e.getMessage());
          }
        String responseBody=res.getBody();
        system.debug('DEBUGGING RESPOSE: ' + res.getStatusCode() + ' > ' + res.getStatus() + '  >  ' + res.getBody());
        System.debug('responseBody '+responseBody);
        return responseBody;
    }

    public static String getUCRPrice(String endpoint,String body){
      HttpRequest request = new HttpRequest();
      request.setEndpoint('callout:MRF_API/fhtest/api/FH/GetByFilter');
      request.setMethod('POST');
      request.setHeader('Content-Type', 'application/json;charset=UTF-8');
      request.setTimeout(Integer.valueOf(System.Label.NSA_MRF_Webservice_Timeout));
      request.setBody(body);
      Http http = new Http();
      HttpResponse res=new HttpResponse();
      try{
       
        res = http.send(request);

        
      }
      catch (System.CalloutException e) {
        System.debug('error in ws '+e.getMessage());
          throw new System.CalloutException(e.getMessage());
        }
      String responseBody=res.getBody();
      if(res.getStatusCode()!=200){
        System.debug('error in ws '+res);
          throw new System.CalloutException('Valenz Error');
      }
      system.debug('DEBUGGING RESPOSE: ' + res.getStatusCode() + ' > ' + res.getStatus() + '  >  ' + res.getBody());
      return responseBody;
    }
    public static String getValenzPrice(String endpoint,String body){
      HttpRequest request = new HttpRequest();
      request.setEndpoint('callout:Valenz_API/Release/hooks/ips/submit.py');
      request.setMethod('POST');
      request.setHeader('Content-Type', 'application/json');
      request.setTimeout(Integer.valueOf(System.Label.NSA_MRF_Webservice_Timeout));
      request.setBody(body);
      Http http = new Http();
      HttpResponse res=new HttpResponse();
      try{
       
        res = http.send(request);
      }
      catch (System.CalloutException e) {
        System.debug('error in ws '+e.getMessage());
          throw new System.CalloutException(e.getMessage());
        }
      String responseBody=res.getBody();
      if(res.getStatusCode()!=200){
        System.debug('error in ws '+res);
          throw new System.CalloutException('Valenz Error');
      }
      system.debug('DEBUGGING RESPOSE: ' + res.getStatusCode() + ' > ' + res.getStatus() + '  >  ' + res.getBody());
      return responseBody;
    }

    public static String getServicePrice(string endpoint,String body){
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:MRF_API/v2/price/getbyfilter');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout(Integer.valueOf(System.Label.NSA_MRF_Webservice_Timeout));
        request.setBody(body);
        Http http = new Http();
        HttpResponse res=new HttpResponse();
        try{
          
          res = http.send(request);
        }
        catch (System.CalloutException e) {
          System.debug('error in ws '+e.getMessage());
            throw new System.CalloutException(e.getMessage());
          }
        String responseBody=res.getBody();
        if(res.getStatusCode()!=200){
          System.debug('error in ws '+res);
            throw new System.CalloutException('test');
        }
        system.debug('DEBUGGING RESPOSE: ' + res.getStatusCode() + ' > ' + res.getStatus() + '  >  ' + res.getBody());
        return responseBody;
    }
    public static String getProviderDetails(String body,String endpoint){
        System.debug('inside getProviderDetails '+endpoint);
        System.debug('inside getProviderDetails '+body);

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:MRF_API/v2/provider/getbyfilter');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout(Integer.valueOf(System.Label.NSA_MRF_Webservice_Timeout));
        request.setBody(body);
        Http http = new Http();
        HttpResponse res=new HttpResponse();
        try{
          
         
            res = http.send(request);

          
        }
        catch (System.CalloutException e) {
            throw new System.CalloutException(e.getMessage());
          }
        String responseBody=res.getBody();
        system.debug('DEBUGGING RESPOSE: ' + res.getStatusCode() + ' > ' + res.getStatus() + '  >  ' + res.getBody());
       
        return responseBody;
    }
    public static String doPost(String action,String body){
        List<NSA_Configuration__c> configs=getOrgDetails(System.label.NSA_OrgName);
        Date currentDate=date.today();
        String url;
        String valenzurl;
        for(NSA_Configuration__c config:configs){
            System.debug('in config API_End_Date__c '+config.API_End_Date__c+'  API_Start_Date__c '+config.API_Start_Date__c+'  currentDate '+currentDate+' Endpoint_URL__c '+config.Endpoint_URL__c);
        if(currentDate>config.API_Start_Date__c &&(config.API_End_Date__c==null)){
           System.debug('fetna if');
            url=config.Endpoint_URL__c;
            valenzurl=config.Valenz_Endpoint_URL__c;
            System.debug('url '+url); 
             break;
        }
        else{
            System.debug('in else'); 
        }
    }
        String responseBody;
        if(action=='getProviderDetails'){
            System.debug('calling getProviderDetails');
            responseBody=getProviderDetails(body,url);
        }
        if(action=='NPIAPI'){
            responseBody= NPIAPI(body,'https://npiregistry.cms.hhs.gov/api');
        }
        if(action=='getServicePrice'){
          System.debug('url '+url+' body '+body);
            responseBody=getServicePrice(url,body);
        }
        if(action=='getValenzPrice'){
          
          System.debug('url '+valenzurl+' body '+body);
          responseBody=getValenzPrice(valenzurl,body);
        }
        if(action=='getUCRPrice'){
          System.debug('url '+url+' body '+body);
          responseBody=getUCRPrice(url,body);
        }
        return responseBody;

    }
    public static List<NSA_Configuration__c> getOrgDetails(String orgName){
    
      List<NSA_Configuration__c> result=new List<NSA_Configuration__c>();

      NSA_Configuration__c config=new NSA_Configuration__c();
      try {
        List<NSA_Configuration__c> mcs = NSA_Configuration__c.getall().values();
        for(NSA_Configuration__c nsaconfig : mcs){
          if (nsaconfig.NSA_Org_Name__c == orgName) {
            config=nsaconfig;
            result.add(config);
           }
        }
      } catch (System.CalloutException e) {
        throw new System.CalloutException(e.getMessage());
      }
      return result;
    }
}