/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-09-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
global class NSA_ProviderDetailsMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
       
        
         // Create a fake response
         StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'NSA_ProviderDetailsMockResponse' LIMIT 1];
         String responseElement=sr.Body.toString();
         
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(responseElement);
        res.setStatusCode(200);
        return res;
    }
    
 }