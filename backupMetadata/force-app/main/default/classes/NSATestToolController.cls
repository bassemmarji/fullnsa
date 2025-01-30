public with sharing class NSATestToolController {


    
    @AuraEnabled
    public static String makeRequest(String procedureCodes,String tins,String tpaAcronym, String networkAcronyms, String requestType,String zips,Boolean isTest){
        

        
        Long beforeRequest = System.now().getTime();

        String jsonString = '{"procedure_codes":'+procedureCodes+',"tins":'+tins+', "TPA_Acronym":"'+tpaAcronym+'", "NTW_Acronym": '+networkAcronyms+'}'; //create json string
        System.debug('jsonString debug');
        System.debug(jsonString);
        HttpRequest req = new HttpRequest(); //create request
        String tenpName='%'+requestType+'%';
        Service_Tool_End_Points__c customSetting=[SELECT id,name,EndPoint__c,Is_Test__c FROM Service_Tool_End_Points__c WHERE name like :tenpName and Is_Test__c=:isTest];
        req.setEndpoint(customSetting.EndPoint__c); //set endpoint
        req.setMethod('POST'); //set method
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setBody(jsonString); //set body
        Http http = new Http(); //create http
        HttpResponse resp = http.send(req); //send request
        System.debug('respone');
        System.debug(resp.getBody()); //print response
        
        Long afterRequest = System.now().getTime();
        System.debug('TIME DIFF');
        System.debug(afterRequest-beforeRequest);
        return resp.getBody();
        
    }

    @AuraEnabled
    public static string medicareRequest(String procedureCodes,String tins,String tpaAcronym){
        String today = getToday();
        String jsonString = '{"CLAIM":[{"TransactionControl":{"ClientID":"'+tpaAcronym+'","TransactionID":"ea6bbed2","ClaimType":"P"},"ProviderInfo":{"ZIP":"381168243","NPI":'+tins+',"CCN":""},"Services":[{"LineNumber":1,"PlaceOfService":"11","ProcedureCode":'+procedureCodes+',"RevenueCode":"","DRG":"","Units":1,"DatesOfService":{"From":"'+today+'","To":"'+today+'"},"ModifierList":[""],"DiagnosisList":[]}]}]}';
        HttpRequest req = new HttpRequest(); //create request
        req.setEndpoint('callout:Valenz_API/Release/hooks/ips/submit.py'); //set endpoint
        req.setMethod('POST'); //set method
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // req.setHeader('Authorization', 'Basic aXBzOkdYQmEkQTcyYGonOX4xanU=');
        req.setBody(jsonString); //set body
        Http http = new Http(); //create http
        HttpResponse resp = http.send(req); //send request
        System.debug(resp.getBody()); //print response
        return resp.getBody();
    }

    @AuraEnabled
    public static List<ReturnOutOfNewtork> fairHealthRequest(String procedureCodes,String tins,String tpaAcronym,String networkAcronyms,String claimType,String zips,String fromDate, String toDate,Boolean revCodeCheckBox,String quantity, Boolean drgCodeCheckBox){
        
        String TempclaimType= getClaimType(claimType);
        System.debug('TempclaimType=='+TempclaimType);
        if (quantity==null || quantity=='') {
            quantity='1';
        }
        if (drgCodeCheckBox) {
            TempclaimType='I';
        }
        //tins=tins.remove('"');
        tins=tins.remove('[');
        tins=tins.remove(']');
        date fromDateReBuild;
        fromDateReBuild=date.newInstance(integer.valueOf(fromDate.split('-')[0]), integer.valueOf(fromDate.split('-')[1]),integer.valueOf(fromDate.split('-')[2]) );
        date toDateReBuild;
        toDateReBuild=date.newInstance(integer.valueOf(toDate.split('-')[0]), integer.valueOf(toDate.split('-')[1]),integer.valueOf(toDate.split('-')[2]) );
        System.debug('fromDateReBuild=='+fromDateReBuild);
        System.debug('toDateReBuild=='+toDateReBuild);

        zips=zips.removeStart('[');
        zips=zips.removeEnd(']');
        System.debug('networkAcronyms=='+networkAcronyms);
        List<String> zipList=zips.split(',');
        String jsonString='{"CLAIM": [';
        String tempjsonString='';
        System.debug('zipList=='+zipList);
        for (String zip : zipList) {
            List<String> codeList = new List<String>();
            System.debug('procedureCodes=='+procedureCodes);
            if (procedureCodes.contains(',')) {
                procedureCodes=procedureCodes.removeEnd(']');
                procedureCodes=procedureCodes.removeStart('[');
                codeList=procedureCodes.split(',');
            }else {
                String tempcode=procedureCodes.removeEnd(']');
                tempcode=tempcode.removeStart('[');
                codeList.add(tempcode);
            }
            System.debug('zip=='+zip);
            //String today = getToday();
            zip=zip.removeEnd('"');
            zip=zip.removeStart('"');
            String tempjsonString1 = '{"TransactionControl": {"ClientID": "'+tpaAcronym+'","TransactionID": "'+zip+String.valueOf(Datetime.now().getTime())+'","ClaimType": "'+TempclaimType+'"},"ProviderInfo": {"ZIP": "'+zip+'","NPI":'+tins+',"CCN": ""},"Services": [';
            //String tempjsonString1 = '{"TransactionControl": {"ClientID": "'+tpaAcronym+'","TransactionID": "'+zip+'","ClaimType": "'+TempclaimType+'"},"ProviderInfo": {"ZIP": '+zip+',"NPI":"","CCN": ""},"Services": [';
            String tempServices='';
            integer count=1;
            System.debug('codeList=='+codeList);
            if (!codeList.isEmpty()) {
                for (String code : codeList) {
                    System.debug('code=='+code);
                    String tempS;
                    if (revCodeCheckBox) {
                        tempS='{"LineNumber":'+count+',"PlaceOfService": "'+claimType+'","ProcedureCode": "","RevenueCode": '+code+',"DRG": "","Units": '+quantity+',"DatesOfService": {"From": "'+String.valueOf(fromDateReBuild.month())+'/'+String.valueOf(fromDateReBuild.day())+'/'+String.valueOf(fromDateReBuild.year())+'","To": "'+String.valueOf(toDateReBuild.month())+'/'+String.valueOf(toDateReBuild.day())+'/'+String.valueOf(toDateReBuild.year())+'"},"ModifierList": [""],"DiagnosisList": []},';
                        // if (drgCodeCheckBox) {
                        //     tempS='{"LineNumber":'+count+',"PlaceOfService": "'+claimType+'","ProcedureCode": "","RevenueCode": '+code+',"DRG": '+code+',"Units": '+quantity+',"DatesOfService": {"From": "'+String.valueOf(fromDateReBuild.month())+'/'+String.valueOf(fromDateReBuild.day())+'/'+String.valueOf(fromDateReBuild.year())+'","To": "'+String.valueOf(toDateReBuild.month())+'/'+String.valueOf(toDateReBuild.day())+'/'+String.valueOf(toDateReBuild.year())+'"},"ModifierList": [""],"DiagnosisList": []},';
                        // }
                    }else if (drgCodeCheckBox) {
                        tempS='{"LineNumber":'+count+',"PlaceOfService": "'+claimType+'","ProcedureCode": "","RevenueCode": "","DRG":'+code+',"Units":'+quantity+',"DatesOfService": {"From": "'+String.valueOf(fromDateReBuild.month())+'/'+String.valueOf(fromDateReBuild.day())+'/'+String.valueOf(fromDateReBuild.year())+'","To": "'+String.valueOf(toDateReBuild.month())+'/'+String.valueOf(toDateReBuild.day())+'/'+String.valueOf(toDateReBuild.year())+'"},"ModifierList": [""],"DiagnosisList": []},';
                    } else {
                        tempS='{"LineNumber":'+count+',"PlaceOfService": "'+claimType+'","ProcedureCode": '+code+',"RevenueCode": "","DRG": "","Units":'+quantity+',"DatesOfService": {"From": "'+String.valueOf(fromDateReBuild.month())+'/'+String.valueOf(fromDateReBuild.day())+'/'+String.valueOf(fromDateReBuild.year())+'","To": "'+String.valueOf(toDateReBuild.month())+'/'+String.valueOf(toDateReBuild.day())+'/'+String.valueOf(toDateReBuild.year())+'"},"ModifierList": [""],"DiagnosisList": []},';
                        // if (drgCodeCheckBox) {
                        //     tempS='{"LineNumber":'+count+',"PlaceOfService": "'+claimType+'","ProcedureCode": '+code+',"RevenueCode": "","DRG": '+code+',"Units":'+quantity+',"DatesOfService": {"From": "'+String.valueOf(fromDateReBuild.month())+'/'+String.valueOf(fromDateReBuild.day())+'/'+String.valueOf(fromDateReBuild.year())+'","To": "'+String.valueOf(toDateReBuild.month())+'/'+String.valueOf(toDateReBuild.day())+'/'+String.valueOf(toDateReBuild.year())+'"},"ModifierList": [""],"DiagnosisList": []},';
                        // }
                    }
                    System.debug('tempS=='+tempS);
                    
                    tempServices=tempServices+tempS;
                    count++;
                }
                if (tempServices!='') {
                    System.debug('test');
                    tempServices=tempServices.removeEnd(',');
                }
                
            }else {
                tempServices='{"LineNumber":null,"PlaceOfService": null,"ProcedureCode": null,"RevenueCode": "","DRG": "","Units": null,"DatesOfService": {"From": null,"To": null},"ModifierList": [""],"DiagnosisList": []}';
            }
            
            
            tempjsonString=tempjsonString+tempjsonString1+tempServices+'] },';
        }
        System.debug('tempjsonString=='+tempjsonString);
        if (tempjsonString!='') {
            tempjsonString=tempjsonString.removeEnd(',');
        }
        jsonString=jsonString+tempjsonString+']}';
        //jsonString='{"CLAIM": [{"TransactionControl": {"ClientID": "BSi","TransactionID": "94306f7a","ClaimType": "I"},"ProviderInfo": {"ZIP": "943052200","NPI":"1194742064","CCN": ""},"Services": [{"LineNumber":1,"PlaceOfService": "11","ProcedureCode": null,"RevenueCode": "","DRG":"460","Units":1,"DatesOfService": {"From": "6/7/2023","To": "6/7/2023"},"ModifierList": [""],"DiagnosisList": []}] }]}';
        System.debug('jsonString=='+jsonString);
        
        System.debug('networkAcronyms=='+networkAcronyms);
        networkAcronyms=networkAcronyms.removeStart('[');
        networkAcronyms=networkAcronyms.removeEnd(']');
        List<String> networkAcronymsList=networkAcronyms.split(',');
        List<ReturnOutOfNewtork> returnValueList = new List<ReturnOutOfNewtork>();
        for (String Acronym : networkAcronymsList) {
            ReturnOutOfNewtork returnvalue= new ReturnOutOfNewtork();
            System.debug('Acronym=='+Acronym);
            String method='POST';
            String boyd=jsonString;
            String header1;
            String header2;
            String endpoint;
            String tempAcronym;
            if (Acronym=='"fh"') {
                endpoint='callout:MRF_API/fhtest/api/FH/GetByFilter';
                if(Test.isRunningTest()) {
                    endpoint='http://35.80.161.201/fhtest/api/FH/GetByFilter';
                }
                tempAcronym='Fair Health';
                returnvalue.returnValue=sentRequest(endpoint,method,boyd).getBody();
            } else {
                endpoint='callout:Valenz_API';
                // if(Test.isRunningTest()) {
                //     endpoint='https://pricer.zebuservices.com';
                // }
                tempAcronym='Medicare(Valenz)';
                if(!Test.isRunningTest()) {
                    returnvalue.returnValue=WSUtils.getValenzPrice(endpoint, boyd);
                }
            }
            
            
            returnvalue.networkAcronyms=tempAcronym;
            returnValueList.add(returnvalue);
        }
        System.debug('returnValueList=='+returnValueList);
        return returnValueList;
    }
    @AuraEnabled
    public static string getClaimType(String claimType){
        System.debug('claimType=='+claimType);
        Claim_Type_POS_Mapping__c claimMapping = Claim_Type_POS_Mapping__c.getValues(claimType);
        String TempclaimType= claimMapping.claimType__c;
        System.debug('TempclaimType=='+TempclaimType);
        return TempclaimType;
    }

    public static String getToday(){
        Date today = System.today();
        Integer day = today.day();
        Integer month = today.month();
        Integer year = today.year();
        return String.valueOf(day)+'/'+String.valueOf(month)+'/'+String.valueOf(year);
    }

    public static HttpResponse sentRequest(String endpoint,String method, String body){
        HttpRequest req = new HttpRequest(); //create request
        req.setEndpoint(endpoint); //set endpoint
        req.setMethod(method); //set method
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');

        req.setBody(body); //set body
        Http http = new Http(); //create http
        HttpResponse resp = http.send(req); //send request
        System.debug('response body'+resp.getBody()); //print response
        return resp;
    }

    
    @AuraEnabled
    public static String retrieveMRFDetails(String tpaAcronym,Boolean isTest ) {
        String jsonRequest='{"TPA_Acronym": "'+tpaAcronym+'" }';
        System.debug('jsonRequest=='+jsonRequest);
        String tenpName='%'+'MRFDetails'+'%';
        Service_Tool_End_Points__c customSetting=[SELECT id,name,EndPoint__c,Is_Test__c FROM Service_Tool_End_Points__c WHERE name like :tenpName and Is_Test__c=:isTest];
        System.debug('customSetting.EndPoint__c='+customSetting.EndPoint__c);
        String endpoint=customSetting.EndPoint__c;
        String method='POST';
        return sentRequest(endpoint,method,jsonRequest).getBody();
    }
    
    @AuraEnabled
    public static List <TPANetwork__mdt> retrieveNetwork(String tpaAcronym){
        String acronym = '%' + tpaAcronym + '%';
        List <TPANetwork__mdt> networksMDT = [SELECT Id, MasterLabel, DeveloperName, Network__c, Acronym__c FROM TPANetwork__mdt WHERE TPA__c LIKE: acronym];
        return networksMDT;
    }

    public class ReturnOutOfNewtork{
        @AuraEnabled public String networkAcronyms { get; set; }
        @AuraEnabled public String returnValue { get; set; }
    }
}