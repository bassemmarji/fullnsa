public class PickListController {
    public static void createRecords(){
           Employer_and_TPA_Plans__c etp = new Employer_and_TPA_Plans__c();
           etp.Group__c       = '001Qy00000hdWQhIAM';
           etp.TPA__c         = '001Qy00000hliHnIAI';
           etp.Health_Plan__c = 'a0HQy000003PtMAMA0';
           etp.EHIM__c        = '50003163-01';
           etp.EHIM_RX_Plan_Code__c	= 'EHI3163G02';
           etp.To_HMA_834__c           = false;
           etp.To_EHIM_834__c          = true;
           etp.To_EHIM_Accumulator__c  = true;
           //etp.Health_Plan_Type__c	   = 'Major Medical';
           etp.To_Breckpoint_834__c    = false;
           insert etp;
               
    }
    
    public static void createReleasedRec(){
		   IntPS_NSA__Release__c rec = new IntPS_NSA__Release__c();
           rec.IntPS_NSA__Employee_Group__c = [Select Id from Account Where IntPS__External_ID__c = 'HOSRMP'].id;
           rec.IntPS_NSA__Release_Date__c   = Date.newInstance(2024,12,01);
           insert rec;
    }
    
    public static void initializePlanType(){
		   IntPS__Health_Plan__c rec = [Select Id , IntPS_NSA__Plan_Type__c 
                                          From IntPS__Health_Plan__c 
                                         Where IntPS__ExternalID__c  = 'Hmp001MM'];
           rec.IntPS_NSA__Plan_Type__c      = 'MEC';
           update rec;
           rec = [Select Id , IntPS_NSA__Plan_Type__c 
                                          From IntPS__Health_Plan__c 
                                         Where IntPS__ExternalID__c  = 'Hmp002MM'];
           rec.IntPS_NSA__Plan_Type__c      = 'MEC';
           update rec;
    }
    
    
    public static void create_HPI_OON(){
            
    }
    
    
    //Update Procedure Code IntPS__Classification__c
    public static void updatePrcCode_Classification(){
           List<IntPS__Procedure_Code__c> procs = new List<IntPS__Procedure_Code__c>();
           for (IntPS__Procedure_Code__c proc :[Select Id
                                                     , Name
                                                     , IntPS__Classification__c
                                                  From IntPS__Procedure_Code__c 
                                                 Where IntPS_NSA__Shoppable_Item__c=true    
                                                   And IntPS__Classification__c = Null
                                                   And Name in ('0544T','J0702')
                                               ]){
                                                   
                proc.IntPS__Classification__c = 'a0VQy000007waOKMAY';
				procs.add(proc);                                   
           }
           update procs;
    }
  
    public static void updateHPINSAClassification(){
           List<IntPS__Health_Plan_Item__c> hpis = new List<IntPS__Health_Plan_Item__c>();
           for (IntPS__Health_Plan_Item__c hpi : [Select Id
                                                       , NSA_Classification__c
                                                       , IntPS__Procedure_Code_Classification__c
                                                    from IntPS__Health_Plan_Item__c 
                                                   where IntPS__Health_Plan__c in ('a0HQy000003PtMAMA0','a0HQy000003PtM9MAK')
                                                     And NSA_Classification__c =null
                                                     And IntPS__Procedure_Code_Classification__c !=null
                                                 ]){
           		hpi.NSA_Classification__c = hpi.IntPS__Procedure_Code_Classification__c;
				hpis.add(hpi);
           }
		   
           update hpis;
    }
    
    public static void updatePortalUser(){
        IntPS__Patient__c rec = [SELECT Id, Name, IntPS__Email__c, IntPS__Employer__c, IntPS__Member_Id__c
                                     , IntPS__Not_Unique_Member_Id__c,IntPS__DateOfBirth__c,  IntPS__Patient_Unique_ID__c 
                                     , RecordTypeId, RecordType.Name	
                                     , Portal_User__c
                                  FROM IntPS__Patient__c 							
                                 WHERE IntPS__Employer__r.IntPS__External_ID__c = 'HOSRMP'
                                   And Name = 'ALBERT  BORSCH'];
        rec.IntPS__Email__c = 'bmarji@integratedpayorsolutions.com';
        rec.Portal_User__c  = [Select Id From Contact where Name = 'Bassem Marji'].Id;
        update rec;
    }
    
    
    public static void add_HPCN(){
        List<IntPS_NSA__Health_Plan_Content_Network__c> hpcns = new List<IntPS_NSA__Health_Plan_Content_Network__c>();
        for (IntPS_NSA__Health_Plan_Content_Network__c hpcn : [Select IntPS_NSA__External_ID__c
                                                                    , IntPS_NSA__Health_Plan_Content__c	
                                                                    , IntPS_NSA__Network__c	
                                                                    , IntPS_NSA__Patient__c	
                                                                    , IntPS_NSA__Priority__c	
                                                                    , IntPS_NSA__RbP_Basis__c	
                                                                    , IntPS_NSA__RbP_Percentage__c	
                                                                    , IntPS_NSA__RbP__c	
                                                                    , IntPS_NSA__Services__c	
                                                                    , IntPS_NSA__Health_Plan_Name__c	
                                                                    , IntPS_NSA__Network_External_ID__c	
                                                                    , Health_Plan__c	
                                                                    , Is_Addt_Primary_Network__c
                                                    from IntPS_NSA__Health_Plan_Content_Network__c  
                                                   where Health_Plan__c = 'a0HQy000003OKYbMAO'
                                                     And IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c Like 'IN%'
                                                 ]){
                IntPS_NSA__Health_Plan_Content_Network__c hpcn1 = new IntPS_NSA__Health_Plan_Content_Network__c();                                       
                hpcn1.IntPS_NSA__Health_Plan_Content__c  = [Select Id 
                                                             from IntPS__Health_Plan_Content__c 
                                                            Where Name = 'Hmp002 (Out-of-Network)'].Id;                                    
           		hpcn1.Health_Plan__c                     = 'a0HQy000003PtMAMA0';
                hpcn1.IntPS_NSA__External_ID__c          = hpcn.IntPS_NSA__External_ID__c;
                hpcn1.IntPS_NSA__Network__c	             = hpcn.IntPS_NSA__Network__c;
                hpcn1.IntPS_NSA__Patient__c	             = hpcn.IntPS_NSA__Patient__c;
                hpcn1.IntPS_NSA__Priority__c	         = hpcn.IntPS_NSA__Priority__c;
                hpcn1.IntPS_NSA__RbP_Basis__c	         = hpcn.IntPS_NSA__RbP_Basis__c;
                hpcn1.IntPS_NSA__RbP_Percentage__c	     = hpcn.IntPS_NSA__RbP_Percentage__c;
                hpcn1.IntPS_NSA__RbP__c	                 = hpcn.IntPS_NSA__RbP__c;
                hpcn1.IntPS_NSA__Services__c	         = hpcn.IntPS_NSA__Services__c;
                hpcn1.Is_Addt_Primary_Network__c         = hpcn.Is_Addt_Primary_Network__c;                             
                                                     
				hpcns.add(hpcn1);
           }
           insert(hpcns);
    }
    
    
    public static List<Map<String,String>> getPickListValues(String objectName,String fieldName) {
           //String objectName = 'IntPS__EOB_Line_Item__c';
           //String fieldName  = 'IntPS_NSA__Place_Of_Service__c';
           Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
           Schema.DescribeSObjectResult r = s.getDescribe();
           
           Map<String, Schema.SObjectField> fields = r.fields.getMap();
           Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        
           List<Schema.PickListEntry> entries = fieldResult.getPickListValues();
           List<Map<String,String>>   values  = new List<Map<String,String>>();
           for (Schema.PickListEntry entry:entries){
               if (entry.isActive()){
                   Map<String,String> valueMap = new Map<String,String>();
                   valueMap.put('label', entry.getLabel());
                   valueMap.put('value', entry.getValue());
                   values.add(valueMap);
               }
           }
           System.debug('Values='+values);
           return values;
    }
        
    //glyntalksSalesforce.blogspot.com
    public static Map<Object,List<Schema.PicklistEntry>> getDependentPicklistValues( Schema.sObjectField dependToken )
    {
        //Confirm that the field is a dependent picklist
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if ( controlToken == null ) return null;
        
        //If the controlling field is a checkbox the controlEntries field is set to Null
        //If the controlling field is not a checkbox, the controlEntries field gets the list of Schema.PickListEntry objects.
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
        (   control.getType() == Schema.DisplayType.Boolean
        ?   null
        :   control.getPicklistValues()
        );
     	
        if (controlEntries.isEmpty()){
            System.debug('This field does not have a controlling field');
        }
        
        //The base64map string will be used to decode the characters of the validFor fields.
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object,List<Schema.PicklistEntry>> dependentPicklistValues = new Map<Object,List<Schema.PicklistEntry>>();
        
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars =
                String.valueOf
                (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                ).split( '' );
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                Object controlValue =
                (   controlEntries == null
                ?   (Object) (index == 1)
                :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
                );
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                if  (   controlValue == null
                    ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
                    ) continue;
                if ( !dependentPicklistValues.containsKey( controlValue ) )
                {
                    dependentPicklistValues.put( controlValue, new List<Schema.PicklistEntry>() );
                }
                dependentPicklistValues.get( controlValue ).add( entry );
            }
        }
        System.debug('Dependent Picklist Values='+dependentPicklistValues);
        return dependentPicklistValues;
    }
    
    public static Map<Object,List<Schema.PicklistEntry>> getDependentPicklistValues( String sObjectName, String fieldName )
    {
      //fieldName is the Dependent Picklist
      return getDependentPicklistValues( 
              Schema.getGlobalDescribe().get(SObjectName).getDescribe().fields.getMap().get(fieldName)
             );
    }
}