/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-11-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class NSATestToolTest {
    
    public static testMethod void startTest(){
        Service_Tool_End_Points__c setting = MainUtilities.createServiceToolEndPoints('MRFDetails Test','http://35.80.161.201/v1/api/Statistic/GetByTPAAcronym?isTest=1');
        String procedureCodes = '';
        String tins = '';
        String tpaAcronym = '';
        String networkAcronyms = '';
        String requestType = 'MRFDetails';
        String zips = '';
        String claimType = '10';
        date myDate = date.today();
        date weekStart = myDate.toStartofWeek();
        weekStart.addDays(7);
        String fromDate = String.valueOf(myDate);
        String toDate = String.valueOf(weekStart);
        Boolean revCodeCheckBox = false;
        String quantity = '';
        Claim_Type_POS_Mapping__c ctposmap = new Claim_Type_POS_Mapping__c();
        ctposmap.Name = '10';
        ctposmap.claimType__c = 'P';
        insert ctposmap;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NSATestMock()); 

        String makeRequestReturn=NSATestToolController.makeRequest(procedureCodes, tins, tpaAcronym, networkAcronyms, requestType,zips,true);
        String medicareRequestReturn=NSATestToolController.medicareRequest(procedureCodes, tins, tpaAcronym);
        String retrieveMRFDetailsReturn=NSATestToolController.retrieveMRFDetails(tpaAcronym,true);
        List<NSATestToolController.ReturnOutOfNewtork> fairHealthRequestReturn=NSATestToolController.fairHealthRequest(procedureCodes, tins, tpaAcronym, networkAcronyms, claimType, zips, fromDate, toDate, revCodeCheckBox, quantity,false);
        System.debug('makeRequestReturn=='+makeRequestReturn);
        System.debug('medicareRequestReturn=='+medicareRequestReturn);
        System.debug('retrieveMRFDetailsReturn=='+retrieveMRFDetailsReturn);
        System.debug('fairHealthRequestReturn=='+fairHealthRequestReturn);
        Test.stopTest();
    }
}