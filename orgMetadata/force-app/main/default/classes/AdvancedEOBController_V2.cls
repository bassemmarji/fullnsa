/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-26-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class AdvancedEOBController_V2 {

    private List<String> availableStatus = new List<String>{'Mailed – Paper','Reviewed – Paper','Reviewed – Portal','Emailed – Paper','Auto Sent - Portal'};
    private Boolean showPDF = false; // flag to track availability of PDF
    private final List<IntPS__EOB__c> eob;
    private final IntPS__Health_Plan_Content__c healthPlan;
    private final String serviceDate;
    private final decimal RemainingPatientResponsability;
    private final Map<String,String> remarkCodes=new Map<String,String>();
    public AdvancedEOBController_V2() {
        String availableStatusLabel = System.Label.NSA_Available_Status;
        if(availableStatusLabel.contains(',')) {
            availableStatus.clear();
            availableStatusLabel = availableStatusLabel.replaceAll('\r\n|\n|\r', '');
            availableStatus = availableStatusLabel.split(',');
            System.debug('availableStatus-----------==============');
            System.debug(availableStatus);
        }
        else {
            availableStatus.clear();
            availableStatus.add(availableStatusLabel);
        }
        Apexpages.currentPage().getHeaders().put('content-disposition', 'filename=Estimated_Costs_V2.pdf');
        String eobIds=ApexPages.currentPage().getParameters().get('id');
        System.debug(eobIds);
        List<String> listofEOBIDs = eobIds.split(',');
        System.debug('eobs '+listofEOBIDs);
        eob = [SELECT Name,
        IntPS__Status__c,
        IntPS_NSA__Service_Date__c,
        IntPS_NSA__MRF_Date__c,
        AtLeastOneLineItemWithRate__c,
        IntPS_NSA__MRF_Network__c,
        IntPS_NSA__Eligibility__r.IntPS__Begin_Date__c,
        IntPS_NSA__Eligibility__r.IntPS__Term_Date__c,
        IntPS_NSA__Eligibility__r.IntPS__Health_Plan__r.Name,
        IntPS_NSA__Eligibility__r.IntPS__Health_Plan__r.IntPS__ExternalID__c,
        IntPS_NSA__Eligibility__r.IntPS__Health_Plan__r.IntPS_NSA__Disclaimer__c,
        IntPS_NSA__Client__r.IntPS__External_ID__c,
        IntPS_NSA__Provider_Billing_City__c,
        IntPS_NSA__Provider_Name__c,
        IntPS_NSA__Eligibility__r.IntPS__Health_Plan__c,
        IntPS_NSA__Provider_NPI_Number__c,
        IntPS_NSA__Total_Coinsurance_Amount_F__c,
        IntPS_NSA__Total_Copay_Amount_F__c,
        IntPS_NSA__Total_Deductible_Paid_Amount__c,
        IntPS_NSA__Total_Deductible_Paid_Amount_by_Family__c,
        IntPS_NSA__Total_Out_Of_Pocket_Amount__c,
        IntPS_NSA__Total_Out_Of_Pocket_Amount_by_Family__c,
        IntPS_NSA__Total_Deductible_Amount_F__c,
        IntPS_NSA__Total_Non_Covered_Amount_F__c,
        IntPS_NSA__Provider_Billing_Postal_Code__c,
        IntPS_NSA__Provider_Billing_Street__c,
        IntPS_NSA__Provider_Billing_State__c,
        IntPS_NSA__Patient__r.IntPS__First_Name__c,
        IntPS_NSA__Patient__r.IntPS__Last_Name__c,
        IntPS_NSA__Patient__r.IntPS__Address_Full__c,
        IntPS_NSA__Patient__r.IntPS__Street__c,
        IntPS_NSA__Patient__r.IntPS__Street1__c,
        IntPS_NSA__Patient__r.IntPS__City__c,
        IntPS_NSA__Patient__r.IntPS__State__c,
        IntPS_NSA__Patient__r.IntPS__Zip_Code__c,
        IntPS_NSA__Patient__r.IntPS__Employer__r.Name,
        IntPS_NSA__Patient__r.IntPS__Not_Unique_Member_Id__c,
        IntPS__L2100_Received_Date__c,
        Available_Networks_For_Provider__c,
        IntPS_NSA__Total_Allowed_Amount_F__c,
        IntPS_NSA__Provider_Network__c,
        CreatedDate,
        IntPS_NSA__Total_Patient_Responsibility_F__c,
        IntPS_NSA__Total_Plan_Responsibility_F__c,
        (SELECT Remark_Code__c,Remark_Code__r.IntPS__Code__c,Remark_Code__r.IntPS__EOB_Description__c,IntPS_NSA__Patient_Responsibility__c,IntPS_NSA__Health_Plan_Item__r.Remark_Code__c,IntPS_NSA__Health_Plan_Item__r.Remark_Code__r.IntPS__Code__c,IntPS_NSA__Health_Plan_Item__r.Remark_Code__r.IntPS__EOB_Description__c,toLabel(IntPS_NSA__Place_Of_Service__c),Provider_Type__c,PreventativePregn__c, IntPS__L2110_Units_of_Service_Paid_Count__c,IntPS_NSA__Plan_Responsibility__c,IntPS__L2110_Procedure_Code__c,IntPS__L2110_Procedure_Code_Description__c,IntPS__L2110_Service_Start_Date__c, name, IntPS_NSA__Service_Line_Allowed_Unit_Price__c,IntPS_NSA__Coinsurance_Amount__c, IntPS__L2110_Adjustment_Amount__c, IntPS__L2110_Service_Line_Allowed_Amount__c, IntPS_NSA__Not_Covered_Amount__c, IntPS_NSA__Deductible_Amount__c, IntPS_NSA__Copay_Amount__c from IntPS__EOB_Line_Items__r) from IntPS__EOB__c
        WHERE Id in :listofEOBIDs]; 
        healthPlan=[Select IntPS__Plan_Deductible_Individual__c,IntPS__Plan_Deductible_Family__c,IntPS__Out_of_Pocket_Max_Individual__c,IntPS__Out_of_Pocket_Max_Family__c,(Select LastModifiedDate from IntPS__TPA_Accumulators__r) from IntPS__Health_Plan_Content__c where IntPS__Health_Plan__c=:eob[0].IntPS_NSA__Eligibility__r.IntPS__Health_Plan__c and IntPS__Provider_Network__c=:eob[0].IntPS_NSA__Provider_Network__c];
        Date sDate=eob[0].IntPS_NSA__Service_Date__c;
        serviceDate = sDate.month()+'-'+sDate.day()+'-'+sDate.year();
        System.debug('>>>>' + serviceDate);
        System.debug('patient name'+eob[0].IntPS_NSA__Patient__r.IntPS__First_Name__c);
        for(IntPS__EOB_Line_Item__c item  :eob[0].IntPS__EOB_Line_Items__r){
            System.debug(item.IntPS_NSA__Health_Plan_Item__r.Remark_Code__c);
            if(item.IntPS_NSA__Health_Plan_Item__r.Remark_Code__c!=null){
                remarkCodes.put(item.IntPS_NSA__Health_Plan_Item__r.Remark_Code__r.IntPS__Code__c,item.IntPS_NSA__Health_Plan_Item__r.Remark_Code__r.IntPS__EOB_Description__c);
            }
            if(item.Remark_Code__c!=null){
                remarkCodes.put(item.Remark_Code__r.IntPS__Code__c,item.Remark_Code__r.IntPS__EOB_Description__c);
 
            }
        }

        
        Profile pf = [SELECT Name FROM Profile WHERE Id=:UserInfo.getProfileId()];
        System.debug('availableStatus ' +availableStatus+'  System.Label.NSA_NeedsValidation '+System.Label.NSA_NeedsValidation);
        if(availableStatus.contains(eob[0].IntPS__Status__c) || pf.Name == 'System Administrator' || System.Label.NSA_NeedsValidation=='false') { // added by Mert Cenk Kilic to determine availability
            showPDF = true;
        }
 
    }

    public List<IntPS__EOB__c> getEOB() {
        return eob;
    }
    public IntPS__Health_Plan_Content__c getHealthPlan() {
        return healthPlan;
    }
    public String getServiceDate() {
        return serviceDate;
    }
    public Map<String,String> getremarkCodes() {
        return remarkCodes;
    }
    public Boolean getShowPDF(){
        return showPDF;
    }
  
}