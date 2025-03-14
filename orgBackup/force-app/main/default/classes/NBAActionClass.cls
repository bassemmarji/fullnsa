/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class NBAActionClass {
    @InvocableMethod(label='Suggest Providers')
    public static List<Providers> SuggestProvider(List<String> patientId) {
            List<Providers> result=new List<Providers>();
            List<IntPS__EOB__c> existingEOBs=[Select Id,IntPS_NSA__Provider_Billing_City__c,IntPS_NSA__Provider_Name__c,IntPS_NSA__Provider_Network__c,IntPS_NSA__Provider_NPI_Number__c,IntPS_NSA__Provider_Billing_Postal_Code__c,IntPS_NSA__Provider_Billing_State__c,IntPS_NSA__Provider_Billing_Street__c from IntPS__EOB__c where  IntPS_NSA__Patient__c=:patientId[0] ];
            for(IntPS__EOB__c eob:existingEOBs){
                Providers provider=new Providers();
                provider.ProviderName=eob.IntPS_NSA__Provider_Name__c;
                provider.ProviderCity=eob.IntPS_NSA__Provider_Billing_City__c;
                provider.networkOption=eob.IntPS_NSA__Provider_Network__c;
                provider.NPINumber=eob.IntPS_NSA__Provider_NPI_Number__c;
                provider.ProviderPostalCode=eob.IntPS_NSA__Provider_Billing_Postal_Code__c;
                provider.ProviderState=eob.IntPS_NSA__Provider_Billing_State__c;
                provider.ProviderStreet=eob.IntPS_NSA__Provider_Billing_Street__c;
                result.add(provider);
            }
            return result;
        }
        public class Providers {
            @InvocableVariable(
            label = 'Label of my output variable'
            description = 'Tooltip for this output variable'
        )
            public String NPINumber;
            @InvocableVariable(
            label = 'Label of my output variable'
            description = 'Tooltip for this output variable'
        )
            public String ProviderName;
            @InvocableVariable(
                label = 'Label of my output variable'
                description = 'Tooltip for this output variable'
            )
            public String ProviderType;
            @InvocableVariable(
            label = 'Label of my output variable'
            description = 'Tooltip for this output variable'
        )
            public String ProviderCity;
            @InvocableVariable(
            label = 'Label of my output variable'
            description = 'Tooltip for this output variable'
        )
            public String ProviderStreet;
            @InvocableVariable(
            label = 'Label of my output variable'
            description = 'Tooltip for this output variable'
        )
            public String ProviderState;
            @InvocableVariable(
            label = 'Label of my output variable'
            description = 'Tooltip for this output variable'
        )
            public String ProviderPostalCode;
            @InvocableVariable(
            label = 'Label of my output variable'
            description = 'Tooltip for this output variable'
        )
            public String ProviderCountry;
            @InvocableVariable(
            label = 'Label of my output variable'
            description = 'Tooltip for this output variable'
        )
            public String ProviderPhone;
            @InvocableVariable(
            label = 'Label of my output variable'
            description = 'Tooltip for this output variable'
        )
            public String networkOption;
  
        }
    }