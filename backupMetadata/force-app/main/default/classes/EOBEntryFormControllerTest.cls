/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-30-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
public with sharing class EOBEntryFormControllerTest {
    public static void prepareTestdata(Boolean withComplesCPT,Boolean isPodPlan){
        //preparing custom settings
        Claim_Type_POS_Mapping__c setting = MainUtilities.createClaimTypeRecord('11','P');
		setting = MainUtilities.createClaimTypeRecord('22','P');

        NSA_Configuration__c nsaconfig = MainUtilities.createNSAConfigRecord('BSI Companies',Date.newInstance(2021, 12,31),'http://35.80.161.201',6,'Sandbox','BSI Companies','BSi','https://pricer.zebuservices.com');
		IntPS__RemarkCode__c remark=new IntPS__RemarkCode__c();
        remark.Name=System.label.NSA_NoRateRemarkCode;
        remark.IntPS__EOB_Description__c='test';
        insert remark;
        IntPS__RemarkCode__c remark2=new IntPS__RemarkCode__c();
        remark2.Name=System.label.NSA_NoNetworkRateRemarkCode;
        remark2.IntPS__EOB_Description__c='test2';
        insert remark2;
        //prepare Account, contacts, Patient records
        Account a=MainUtilities.createMainAccount('Mario Naharis','123456','Provider','city','USA','sss','IO','NR12443','1244');
        Account b=MainUtilities.createMainAccount('Tania Naharis','124','Provider','city','USA','sss','IO','NR12443','1244');
       
        Contact con1=MainUtilities.createContact(a.Id,'8 Rochefort','Kitchener','FL','1223234','US','Naharis','Mario');
        Contact con2=MainUtilities.createContact(b.Id,'8 Rochefort','Kitchener','FL','1223234','US','Naharis','Tania');

        Account dc=MainUtilities.createMainAccount('DC Risk Solutions',null,null, null,null,null,null,null,null);
   
        IntPS__Patient__c pa1=MainUtilities.createPatient('Mario Naharis','Mario','Naharis','Self',a.Id,'8 Rochefort Street','8 Rochefort Street','FL','n2r1v9','Kitchener','Canada',dc.Id,null,con1.Id);
        IntPS__Patient__c pa2=MainUtilities.createPatient('Tania Naharis','Tania','Naharis','Spouse',b.Id,'8 Rochefort Street','8 Rochefort Street','FL','n2r1v9','Kitchener','Canada',dc.Id,pa1.Id,con1.Id);
    
        IntPS_NSA__Release__c rel=new IntPS_NSA__Release__c();
        rel.IntPS_NSA__Employee_Group__c=pa2.IntPS__Employer__c;
        insert rel;
        //Prepare CPT Codes classifications
        List < IntPS__Procedure_Code_Classification__c > pccList = new List < IntPS__Procedure_Code_Classification__c > (); 
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Adult optical (eyewear)',External_ID__c ='NSA-00031'));
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Adult vision exam (for eye refraction)',External_ID__c ='NSA-00032'));
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Allergy injections',External_ID__c ='NSA-000323')); 
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Ambulance',External_ID__c ='NSA-00034'));
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Certain durable medical equipment (DME) (base only)',External_ID__c ='NSA-0003')); 
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Certain prosthetic and orthotic devices',External_ID__c ='NSA-00036'));  
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'CHEMICAL DEPENDENCY SERVICES In the hospital (detoxification only)',External_ID__c ='NSA-00037')); 
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'CHEMICAL DEPENDENCY SERVICES In the medical office',External_ID__c ='NSA-00038'));    
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Chiropractic and acupuncture',External_ID__c ='NSA-00039')); 
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Emergency Department visits (waived if admitted directly to hospital)',External_ID__c ='NSA-00040'));
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Home health care (up to 100 visits per year)',External_ID__c ='NSA-00041')); 
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Hospice care',External_ID__c ='NSA-00042')); 
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Infertility services',External_ID__c ='NSA-00044'));   
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'MENTAL HEALTH SERVICES In the hospital',External_ID__c ='NSA-00045'));
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'MENTAL HEALTH SERVICES In the medical office',External_ID__c ='NSA-00046')); 
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Most laboratory tests',External_ID__c ='NSA-00047'));    
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Most MRI/CT/PET scans',External_ID__c ='NSA-00048'));
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Most X-rays and diagnostic testing',External_ID__c ='NSA-00049'));   
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Outpatient surgery (per procedure)',External_ID__c ='NSA-00050'));
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Pediatric optical (eyewear)',External_ID__c ='NSA-00051'));    
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Pediatric vision exam',External_ID__c ='NSA-00052'));    
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Physical, occupational, and speech therapy',External_ID__c ='NSA-00053'));    
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Physicians’ services, room and board, tests, medications, supplies, therapies...',External_ID__c ='NSA-00054'));  
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Postpartum care',External_ID__c ='NSA-00055'));      
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Prenatal care',External_ID__c ='NSA-00056'));     
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Preventive exams, vaccines (immunizations)',External_ID__c ='NSA-00057')); 
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Primary care visits',External_ID__c ='NSA-00058'));   
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Skilled nursing facility care (up to 100 days per benefit period)',External_ID__c ='NSA-00059')); 
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Specialty office visits',External_ID__c ='NSA-00060'));    
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Televisits',External_ID__c ='NSA-00061'));    
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Urgent care visits',External_ID__c ='NSA-00062'));    
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = 'Well-child preventive care visits',External_ID__c ='NSA-00063')); 
        pccList.add(new IntPS__Procedure_Code_Classification__c(Name = '32',External_ID__c ='NSA-00064'));    
        insert pccList;
        IntPS__Health_Plan__c hp = MainUtilities.createHealthPlan('SILVER 70 HMO 1000/55* + CHILD DENTAL ALT','Embedded','Embedded',15100,7500,2000,1000,'Medical');    
      
        IntPS__Eligibility__c eligibility =MainUtilities.createEligibility(pa1.Id,hp.Id,Date.newInstance(2021, 12,31),Date.newInstance(2040, 12,31));


    IntPS__Health_Plan_Content__c hpc = MainUtilities.createHealthPlanContent('In-Network','Medical',true,hp.Id);

    IntPS__Health_Plan_Content__c hpcOON = MainUtilities.createHealthPlanContent('Out-of-Network','Medical',true,hp.Id);

	IntPS__Network__c network=MainUtilities.createNetwork('Cigna Health Life Insurance Company','CG');
     IntPS__Network__c networkOOn=MainUtilities.createNetwork('Medicare','Medicare');
 
        IntPS_NSA__Health_Plan_Content_Network__c hpcn=MainUtilities.createHealthPlanContentNetwork(1,hpc.Id,network.Id,'Professional',false,null,null);
     
         IntPS_NSA__Health_Plan_Content_Network__c hpcnOON=MainUtilities.createHealthPlanContentNetwork(1,hpcOON.Id,networkOOn.Id,'Professional',true,'Medicare',120);
 
        IntPS__Procedure_Code__c pr=new IntPS__Procedure_Code__c(); 
List<IntPS__Procedure_Code__c> pcList = new List < IntPS__Procedure_Code__c > (); 
     
          pr=MainUtilities.createProcedureCodes('11730','11730','Simple complete avulsion of single nail plate','Procedure Code',null,null,null,null,pccList[0].Id);   
        IntPS__Procedure_Code__c prchild=MainUtilities.createProcedureCodes('11730-OP','11730-OP','Simple complete avulsion of single nail plate','Procedure Code',pr.Id,'11','A Specialist','Preventative Services',pccList[0].Id);
        IntPS__Procedure_Code__c prchild2=MainUtilities.createProcedureCodes('11730-IP','11730-IP','Simple complete avulsion of single nail plate','Procedure Code',pr.Id,'11','A Specialist','None of the above',pccList[0].Id);
 	    IntPS__Procedure_Code__c prchild3=MainUtilities.createProcedureCodes('11730-LP','11730-LP','Simple complete avulsion of single nail plate','Procedure Code',pr.Id,'11','My Primary Care Physician (PCP)','None of the above',pccList[0].Id);
         IntPS__Procedure_Code__c pr2=MainUtilities.createProcedureCodes('99730','99730','Simple complete avulsion of single nail plate','Procedure Code',null,null,null,null,pccList[0].Id);   
         IntPS__Procedure_Code__c pr2child=MainUtilities.createProcedureCodes('99730-OP','99730-OP','Simple complete avulsion of single nail plate','Procedure Code',pr2.Id,'11','A Specialist','Preventative Services',pccList[0].Id);   
     
         IntPS__Procedure_Code__c   pr3=MainUtilities.createProcedureCodes('33409','33409','Simple complete avulsion of single nail plate','Procedure Code',null,null,null,null,pccList[0].Id);   
         IntPS__Procedure_Code__c pr3child=MainUtilities.createProcedureCodes('33409-OP','33409-OP','Simple complete avulsion of single nail plate','Procedure Code',pr3.Id,'11','A Specialist','Preventative Services',pccList[0].Id);
         IntPS__Procedure_Code__c pr3child2=MainUtilities.createProcedureCodes('33409-IP','33409-IP','Simple complete avulsion of single nail plate','Procedure Code',pr3.Id,'22','A Specialist','None of the above',pccList[0].Id);
          IntPS__Procedure_Code__c pr3child3=MainUtilities.createProcedureCodes('33409-LP','33409-LP','Simple complete avulsion of single nail plate','Procedure Code',pr3.Id,'11','My Primary Care Physician (PCP)','None of the above',pccList[0].Id);
         IntPS__Procedure_Code__c pr3child4=MainUtilities.createProcedureCodes('33409-LD','33409-LD','Simple complete avulsion of single nail plate','Procedure Code',pr3.Id,'11','A Specialist','None of the above',pccList[0].Id); 
        IntPS__Procedure_Code__c   pr4=MainUtilities.createProcedureCodes('33408','33408','Simple complete avulsion of single nail plate','Procedure Code',null,null,null,null,pccList[0].Id);   
          IntPS__Procedure_Code__c pr4child=MainUtilities.createProcedureCodes('33408-OP','33408-OP','Simple complete avulsion of single nail plate','Procedure Code',pr4.Id,'11','A Specialist','Preventative Services',pccList[0].Id);
          IntPS__Procedure_Code__c pr4child2=MainUtilities.createProcedureCodes('33408-IP','33408-IP','Simple complete avulsion of single nail plate','Procedure Code',pr4.Id,'24','A Specialist','None of the above',pccList[0].Id);
           IntPS__Procedure_Code__c pr4child3=MainUtilities.createProcedureCodes('33408-LP','33408-LP','Simple complete avulsion of single nail plate','Procedure Code',pr4.Id,'25','My Primary Care Physician (PCP)','None of the above',pccList[0].Id);
         IntPS__Procedure_Code__c   pr5=MainUtilities.createProcedureCodes('0410','0410','Simple complete avulsion of single nail plate','MS-DRG',null,null,null,null,pccList[0].Id);   
          IntPS__Procedure_Code__c pr5child=MainUtilities.createProcedureCodes('0410-OP','0410-OP','Simple complete avulsion of single nail plate','MS-DRG',pr5.Id,'11','A Specialist','Preventative Services',pccList[0].Id);
          IntPS__Procedure_Code__c pr5child2=MainUtilities.createProcedureCodes('0410-IP','0410-IP','Simple complete avulsion of single nail plate','MS-DRG',pr5.Id,'24','A Specialist','None of the above',pccList[0].Id);
           IntPS__Procedure_Code__c pr5child3=MainUtilities.createProcedureCodes('0410-LP','0410-LP','Simple complete avulsion of single nail plate','MS-DRG',pr5.Id,'25','My Primary Care Physician (PCP)','None of the above',pccList[0].Id);
      

        List <IntPS__Health_Plan_Item__c> hpItemList= new List < IntPS__Health_Plan_Item__c > ();

hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = true, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Adult optical (eyewear)'));        hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Adult vision exam (for eye refraction)'));        hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 5.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Allergy injections'));        hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = true, IntPS__Coinsurance__c = 35, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = true, Name = 'Ambulance'));        hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 35, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Certain durable medical equipment (DME) (base only)'));

    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Certain prosthetic and orthotic devices'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = true, IntPS__Coinsurance__c = 35, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = true, Name = 'CHEMICAL DEPENDENCY SERVICES In the hospital (detoxification only)'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 55.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'CHEMICAL DEPENDENCY SERVICES In the medical office'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 15.00, IntPS__Maximum_Number_Per_Year__c = 20, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Chiropractic and acupuncture'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = true, IntPS__Coinsurance__c = 35, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = true, Name = 'Emergency Department visits (waived if admitted directly to hospital)'));

    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Home health care (up to 100 visits per year)'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Hospice care'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = true, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Infertility services'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = true, IntPS__Coinsurance__c = 35, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = true, Name = 'MENTAL HEALTH SERVICES In the hospital'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 55.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'MENTAL HEALTH SERVICES In the medical office'));

    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 50.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Most laboratory tests'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = true, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 350.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = true, Name = 'Most MRI/CT/PET scans'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 70.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Most X-rays and diagnostic testing'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = true, IntPS__Coinsurance__c = 35, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = true, Name = 'Outpatient surgery (per procedure)'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 0.00, IntPS__Maximum_Number_Per_Year__c = 1, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Pediatric optical (eyewear)'));

    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Pediatric vision exam'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 65.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Physical, occupational, and speech therapy'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = true, IntPS__Coinsurance__c = 35, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Physicians’ services, room and board, tests, medications, supplies, therapies...'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Postpartum care'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Prenatal care'));

    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Preventive exams, vaccines (immunizations)'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 55.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Primary care visits'));

    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = true, IntPS__Coinsurance__c = 50, IntPS__Copay__c = 0.00, IntPS__Maximum_Number_Per_Year__c = 10, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = true, Name = 'Skilled nursing facility care (up to 100 days per benefit period)'));

    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 75.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Specialty office visits'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Televisits'));

    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 55.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Urgent care visits'));
    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = false, IntPS__Coinsurance__c = 0, IntPS__Copay__c = 0.00, IntPS__Not_Covered__c = false, IntPS__Add_to_Deductible_Amount__c = false, Name = 'Well-child preventive care visits'));


    hpItemList.add(new IntPS__Health_Plan_Item__c(IntPS__After_Plan_Deductible__c = true,
        IntPS__Coinsurance__c = 0,
        IntPS__Copay__c = 100.00,
        IntPS__Maximum_Number_Per_Year__c = 20,
        IntPS__Not_Covered__c = false,
        IntPS__Add_to_Deductible_Amount__c = true,
        IntPS__Maximum_Paid_Amount_Per_Claim__c=10000,
        Name = 'Skilled nursing facility care (up to 100 days per benefit period)',
        IntPS__Maximum_Number_Per_Admission__c = 10));

    List < IntPS__Matching_Rule__c > matchingRuleList = new List < IntPS__Matching_Rule__c > ();

    Integer i = 0;
    for (IntPS__Health_Plan_Item__c hpi: hpItemList) {
        hpi.IntPS__Provider_Network__c = 'In-Network';
       // hpi.IntPS__Procedure_Code_Classification__c = pccList[i].Id;
        hpi.IntPS__Health_Plan__c = hp.Id;
        hpi.IntPS__Health_Plan_Content__c = hpc.Id;
        hpi.NSA_Classification__c=pccList[0].Id;
       // i++;
    }
    hpItemList[0].IntPS__Provider_Network__c = 'Out-Of-Network';
	hpItemList[0].IntPS__Health_Plan_Content__c=hpcOON.Id;
    insert hpItemList;
    IntPS__Cpt_Repricing_Table__c pricingtable=new IntPS__Cpt_Repricing_Table__c();
    pricingtable.IntPS__Price__c='78';
    pricingtable.IntPS__Procedure_Code__c=pr.Id;
    insert pricingtable;
        if(isPodPlan){
        sObject officeLocation = Schema.getGlobalDescribe().get('Active_Office_Location__c').newSObject() ;
 		officeLocation.put('Physician_Name__c','test');
        officeLocation.put('Account__c',a.Id);
        officeLocation.put('City__c','City');
        officeLocation.put('Street__c','street');
        officeLocation.put('State__c','street');
        officeLocation.put('Postal_Code__c','street');
        officeLocation.put('Country__c','USA');
        officeLocation.put('Phone__c','123456');
        insert officeLocation;
        }

  /*  IntPS__Criteria__c criteria1 = new IntPS__Criteria__c();
    criteria1.IntPS__Index__c = 1;
    //criteria1.IntPS__Entity_Type__c = 'EOB__c';
    criteria1.IntPS__Field__c = 'IntPS_NSA__Calculate_TPA__c';
    criteria1.IntPS__Value__c = 'false';
    criteria1.IntPS__Condition__c = '==';
    criteria1.IntPS__Description__c = 'Test Description';

    IntPS__Criteria__c criteria2 = new IntPS__Criteria__c();
    criteria2.IntPS__Index__c = 2;
   // criteria2.IntPS__Entity_Type__c = 'EOB__c';
    criteria2.IntPS__Field__c = 'IntPS_NSA__Calculation_Status__c';
    criteria2.IntPS__Value__c = 'test';
    criteria2.IntPS__Condition__c = '==';
    criteria2.IntPS__Description__c = 'Test Description';

    insert new List < IntPS__Criteria__c > {
        criteria1,
        criteria2
    };*/

    i = 0;
   /* for (IntPS__Health_Plan_Item__c hpi: hpItemList) {
        IntPS__Matching_Rule__c matchingRule = new IntPS__Matching_Rule__c();
        matchingRule.IntPS__Logic__c = '1';
       // matchingRule.IntPS__Entity_Type__c = 'EOB__c';
        matchingRule.IntPS__Type__c = 'TPA';

        matchingRule.IntPS__Health_Plan_Item__c = hpItemList[i].Id;
        matchingRuleList.add(matchingRule);
        i++;
    }
    insert matchingRuleList;
*/
    }
    @IsTest
    public static void createEOBSuccessPodPlan() {
		prepareTestdata(false,false);
        Contact cont=[Select Id from Contact where Name='Mario Naharis' LIMIT 1];
          test.startTest();
        List<IntPS__Patient__c> patient=EOBEntryFormController.getPatient(cont.Id);
         Boolean checkEmp1=EOBEntryFormController.checkEmployerGroup(patient[0].Id,true);
        Boolean checkEmp=EOBEntryFormController.checkEmployerGroup(patient[0].Id,false);
       // List<IntPS__Patient__c> dependents=EOBEntryFormController.getPatientDependents(patient.Id);
        String tpaAcro=EOBEntryFormController.getTPAAcro('BSI Companies');
        List<String> patientIds=new List<String>();
        patientIds.add(patient[0].Id);
        Map<String,List<IntPS__Eligibility__c>> patientInfo=EOBEntryFormController.getPatientInformation(patientIds,Date.newInstance(2022, 12,27),false);
        List<IntPS_NSA__Health_Plan_Content_Network__c> networks=EOBEntryFormController.getNetworksDetails(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,patient[0].Id);
        Boolean hasOutOfNetwork=EOBEntryFormController.hasOutOfNetwork(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);
        List<String>networkNames = new List<String>();
        List<String> outOfNetworkNames=new List<String>();
        for(IntPS_NSA__Health_Plan_Content_Network__c hpc:networks){
            networkNames.add(hpc.IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
             if(hpc.IntPS_NSA__RbP__c){
                outOfNetworkNames.add(hpc.Id);
            }
        }
        List<IntPS__Health_Plan_Content__c> hpcs=EOBEntryFormController.getHPCList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);

		List<IntPS__Health_Plan_Item__c> hpis=EOBEntryFormController.getHPIList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, hpcs[0].Id);
       // String query = 'SELECT Id  FROM Active_Office_Location__c LIMIT 1';
       // sObject location = Database.query(query);
        //List<EOBEntryFormController.Providers> providers=EOBEntryFormController.getProviderByNPI(String.valueOf(location.get('Id')));
        List<EOBEntryFormController.ProceduresFiltered> procedureCodes=EOBEntryFormController.getProcedureCodes('11730', true, false, patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, 'In-Network',true,'2.0');
        String claimFields='{"aServiceDate__c":"a","Provider_Network__c":"In-Network","Provider_Account_Name__c":"ROBERT SPRAGUE","Patient__c":"'+patient[0].Id+'","Guarantor__c":"a","IntPS_NSA__Service_Date__c":"2023-01-04","IntPS_NSA__Patient__c":"'+patient[0].Id+'","IntPS_NSA__Provider_Name__c":"ROBERT SPRAGUE","IntPS_NSA__Provider_NPI_Number__c":"1164604591","IntPS_NSA__Provider_Billing_Street__c":"703 RIVERWAY PL","IntPS_NSA__Provider_Billing_City__c":"BEDFORD","IntPS_NSA__Provider_Billing_State__c":"NH","IntPS_NSA__Provider_Billing_Postal_Code__c":"031106768","IntPS_NSA__Provider_Network__c":"In-Network","IntPS_NSA__Eligibility__c":"'+patientInfo.get('Eligibility')[0].Id+'"}';
        String procedures='[{"serviceDate":"2023-01-04","Code":"11730","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"Preventative Services","PreventativeOption":"Preventative Services","PlaceOfService":"11"},{"Code":"11730","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"Preventative Services","PreventativeOption":"Preventative Services","PlaceOfService":"11"}]';
        String result=EOBEntryFormController.serviceLineInsertPodPlan(claimFields, procedures, '1164604591', Date.newInstance(2022, 12,27), networks, 'In-Network', tpaAcro, networkNames, 'aazzi@integratedpayorsolutions.com', patient[0].Id, outOfNetworkNames, '031106768',networkNames);
		

        test.stopTest();
    }
//------------------------------------------------------------------------
//Added By Bassem 08-09-2024    
    @IsTest
    static void setupMultimock() {
             //Test.startTest();
             // if (test.isRunningTest()) {
                  MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
				  // Checking MRF API server
        		  multimock.setStaticResource('callout:MRF_API/api/provider/getbyfilter'      , 'NSA_MRFPricesMockResponse' );
                  // Check NPI Registry
				  multimock.setStaticResource('callout:NPI_Registry'                          , 'NSA_ProviderWSMockResponse');
		   		  // Checking Valenz API - getValenzPrice
				  multimock.setStaticResource('callout:Valenz_API/Release/hooks/ips/submit.py', 'NSA_ValenzMockResponse' );
		   		  // Checking UCR API - getUCRPrice
				  multimock.setStaticResource('callout:MRF_API/fhtest/api/FH/GetByFilter'     , 'NSA_FairHealthMockResponse' );
                  //getServicePrice
                  multimock.setStaticResource('callout:MRF_API/v2/price/getbyfilter'          , 'NSA_MRFPricesMockResponse');
                  //createJiraTicket
                  //multimock.setStaticResource(System.label.NSA_JiraAPIUrl+'/rest/api/3/issue' , 'NSA_JiraAPIMockResponse');
                  //getProviderDetails
                  multimock.setStaticResource('callout:MRF_API/v2/provider/getbyfilter' , 'NSA_ProviderDetailsMockResponse');
                  //NPIAPI
                  //'https://npiregistry.cms.hhs.gov/api'    
        		  //multimock.setStatusCode(200);
        		  //multimock.setHeader( 'Content-Type' , 'application/json' );
		          Test.setMock(HttpCalloutMock.class , multimock);
              //}   
              //Test.stopTest();
    }

    @IsTest
    static void test_HeartBeat(){
        Boolean heartbeat=false;
        try {
        	heartbeat=EOBEntryFormController.serversHeartbeat();
        } catch (Exception e) {
            
        }
   
        setupMultimock();
        heartbeat=EOBEntryFormController.serversHeartbeat();
    }
    
	@IsTest
    static void test_rbpCalculation() {
        
        prepareTestdata(false,false);
        Contact cont=[Select Id from Contact where Name='Mario Naharis' LIMIT 1];
        
        List<IntPS__Patient__c> patient=EOBEntryFormController.getPatient(cont.Id);
         Boolean checkEmp1=EOBEntryFormController.checkEmployerGroup(patient[0].Id,true);
        Boolean checkEmp=EOBEntryFormController.checkEmployerGroup(patient[0].Id,false);
       // List<IntPS__Patient__c> dependents=EOBEntryFormController.getPatientDependents(patient.Id);
        String tpaAcro=EOBEntryFormController.getTPAAcro('BSI Companies');
        List<String> patientIds=new List<String>();
        patientIds.add(patient[0].Id);
        Map<String,List<IntPS__Eligibility__c>> patientInfo=EOBEntryFormController.getPatientInformation(patientIds,Date.newInstance(2022, 12,27),false);
        List<IntPS_NSA__Health_Plan_Content_Network__c> networks=EOBEntryFormController.getNetworksDetails(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,patient[0].Id);
        Boolean hasOutOfNetwork=EOBEntryFormController.hasOutOfNetwork(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);
        List<String>networkNames = new List<String>();
        List<String> outOfNetworkNames=new List<String>();
        for(IntPS_NSA__Health_Plan_Content_Network__c hpc:networks){
            networkNames.add(hpc.IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
             if(hpc.IntPS_NSA__RbP__c){
                outOfNetworkNames.add(hpc.Id);
            }
        }
        List<IntPS__Health_Plan_Content__c> hpcs=EOBEntryFormController.getHPCList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);

		//List<IntPS__Health_Plan_Item__c> hpis=EOBEntryFormController.getHPIList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, hpcs[0].Id);
       // String query = 'SELECT Id  FROM Active_Office_Location__c LIMIT 1';
       // sObject location = Database.query(query);
        //List<EOBEntryFormController.Providers> providers=EOBEntryFormController.getProviderByNPI(String.valueOf(location.get('Id')));
        List<EOBEntryFormController.ProceduresFiltered> procedureCodes=EOBEntryFormController.getProcedureCodes('11730', true, false, patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, 'In-Network',true,'2.0');
        String claimFields='{"aServiceDate__c":"a","Provider_Network__c":"In-Network","Provider_Account_Name__c":"ROBERT SPRAGUE","Patient__c":"'+patient[0].Id+'","Guarantor__c":"a","IntPS_NSA__Service_Date__c":"2023-01-04","IntPS_NSA__Patient__c":"'+patient[0].Id+'","IntPS_NSA__Provider_Name__c":"ROBERT SPRAGUE","IntPS_NSA__Provider_NPI_Number__c":"1164604591","IntPS_NSA__Provider_Billing_Street__c":"703 RIVERWAY PL","IntPS_NSA__Provider_Billing_City__c":"BEDFORD","IntPS_NSA__Provider_Billing_State__c":"NH","IntPS_NSA__Provider_Billing_Postal_Code__c":"031106768","IntPS_NSA__Provider_Network__c":"In-Network","IntPS_NSA__Eligibility__c":"'+patientInfo.get('Eligibility')[0].Id+'"}';
        String procedures='[{"serviceDate":"2023-01-04","Code":"11730","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"Preventative Services","PreventativeOption":"Preventative Services","PlaceOfService":"11"},{"Code":"11730","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"Preventative Services","PreventativeOption":"Preventative Services","PlaceOfService":"11"}]';

        Claim_Type_POS_Mapping__c claim_Type_POS_Mapping = new Claim_Type_POS_Mapping__c();
		claim_Type_POS_Mapping.Name         = '21';
		claim_Type_POS_Mapping.claimType__c = 'I';
		insert claim_Type_POS_Mapping;
        
        String healthPlanId = [Select Id From IntPS__Health_Plan__c Limit 1].Id;
        List < IntPS__Health_Plan_Item__c > HPIs = [Select Id, NSA_Classification__c
                                                          ,IntPS__Health_Plan_Content__r.IntPS__Provider_Network__c 
                                                      from IntPS__Health_Plan_Item__c
                                                     Where IntPS__Health_Plan__c = :healthPlanId];
        String networkOption = HPIs[0].IntPS__Health_Plan_Content__r.IntPS__Provider_Network__c;   

        String providerZIP = 'Test';
        String providerNPI = 'Test';
        
        EOBEntryFormController.Procedures prEOB = new EOBEntryFormController.Procedures();
        List < IntPS__Procedure_Code__c > prList = [SELECT Id,Name, NSA_Classification__r.Name
                                                     , IntPS__Code_Type__c, IntPS__Consumer_Description__c
                                                     , Preventatitive_Pregnancy__c, Place_Of_Service__c
                                                     , Provider_Type__c, NSA_Classification__c 
                                                      FROM IntPS__Procedure_Code__c 
                                                     where Name = '11730'
                                                     Limit 1
                                                    ];
        for (IntPS__Procedure_Code__c prc:prList){
        	 prEOB.serviceDate        = Date.parse('01/01/2024');
             prEOB.procId             = prc.Id;
             prEOB.Code               = prc.Name;
             prEOB.Description        = prc.IntPS__Consumer_Description__c;
             prEOB.Rate               = '1';
             prEOB.Quantity        	  = 1;
             prEOB.ProviderType   	  = prc.Provider_Type__c;
             prEOB.PregnancyOption 	  = prc.Preventatitive_Pregnancy__c;
             prEOB.PreventativeOption = prc.Preventatitive_Pregnancy__c;
             prEOB.PlaceOfService     = '21';
             prEOB.healthPlanItemID   = HPIs[0].Id;
             prEOB.CodeType           = prc.IntPS__Code_Type__c;
        }
        
        List < EOBEntryFormController.Procedures > selectedProcedures = new List <EOBEntryFormController.Procedures>();
        selectedProcedures.add(prEOB);
        
        IntPS_NSA__Health_Plan_Content_Network__c hpn = [Select Id,IntPS_NSA__RbP_Basis__c 
                                                          from IntPS_NSA__Health_Plan_Content_Network__c 
                                                          Limit 1];
        Date serviceDate = Date.parse('01/01/2024');
        String applicationVersion = '1.0';
        
        setupMultimock();
        test.startTest();
        EOBEntryFormController.WebServiceCalloutWrapper result = new EOBEntryFormController.WebServiceCalloutWrapper();
		result = EOBEntryFormController.rbpCalculation(
              outOfNetworkNames
            , tpaAcro
            , providerZIP
            , providerNPI
            , selectedProcedures
            , serviceDate
            , healthPlanId
            , networkOption
            , hpn
            , applicationVersion
          );
          test.stopTest();
    }
    
    @IsTest
    static void test_returnNoPriceMRF(){
        EOBEntryFormController.NetworkPrice np = EOBEntryFormController.returnNoPriceMRF('Test','Test',true,true);
    }
    
    @IsTest
	static void test_getHealthPlanNetworkINNRBP() {
        prepareTestdata(false,false);
        String serviceType = 'RBP';
        String healthPlanId = [Select Id From IntPS__Health_Plan__c Limit 1].id;
		IntPS_NSA__Health_Plan_Content_Network__c result = EOBEntryFormController.getHealthPlanNetworkINNRBP(serviceType ,healthPlanId );
    }
    
    @IsTest
    static void test_checkServiceType_forINNRBP(){
        prepareTestdata(false,false);
        test.startTest();
        EOBEntryFormController.Procedures prEOB = new EOBEntryFormController.Procedures();
        List < IntPS__Procedure_Code__c > prList = [SELECT Id,Name, NSA_Classification__r.Name
                                                     , IntPS__Code_Type__c, IntPS__Consumer_Description__c
                                                     , Preventatitive_Pregnancy__c, Place_Of_Service__c
                                                     , Provider_Type__c, NSA_Classification__c 
                                                      FROM IntPS__Procedure_Code__c 
                                                     where Name = '11730'
                                                     Limit 1
                                                    ];
        for (IntPS__Procedure_Code__c prc:prList){
        	 prEOB.serviceDate        = Date.parse('01/01/2024');
             prEOB.procId             = prc.Id;
             prEOB.Code               = prc.Name;
             prEOB.Description        = prc.IntPS__Consumer_Description__c;
             prEOB.Rate               = '1';
             prEOB.Quantity        	  = 1;
             prEOB.ProviderType   	  = prc.Provider_Type__c;
             prEOB.PregnancyOption 	  = prc.Preventatitive_Pregnancy__c;
             prEOB.PreventativeOption = 'None of the above';
             prEOB.PlaceOfService     = '21';
             prEOB.healthPlanItemID   = '000';
             prEOB.CodeType           = prc.IntPS__Code_Type__c;
        }
        
        List < EOBEntryFormController.Procedures > selectedProcedures = new List <EOBEntryFormController.Procedures>();
        selectedProcedures.add(prEOB);
        String result = EOBEntryFormController.checkServiceTypeforINNRBP(selectedProcedures);
        result = EOBEntryFormController.checkServiceType(selectedProcedures);
        
        prEOB.PreventativeOption = 'Prenatal Services';
        selectedProcedures = new List <EOBEntryFormController.Procedures>();
        selectedProcedures.add(prEOB);
        result = EOBEntryFormController.checkServiceTypeforINNRBP(selectedProcedures);
        result = EOBEntryFormController.checkServiceType(selectedProcedures);
        
		prEOB.PreventativeOption = 'None of the above';   
        prEOB.PlaceOfService     = '21';
        selectedProcedures = new List <EOBEntryFormController.Procedures>();
        selectedProcedures.add(prEOB);
        result = EOBEntryFormController.checkServiceTypeforINNRBP(selectedProcedures);
        result = EOBEntryFormController.checkServiceType(selectedProcedures);
        
		prEOB.PreventativeOption = 'Pregnancy Labor & Delivery - Professional Services';   
        selectedProcedures = new List <EOBEntryFormController.Procedures>();
        selectedProcedures.add(prEOB);
        result = EOBEntryFormController.checkServiceTypeforINNRBP(selectedProcedures);
		result = EOBEntryFormController.checkServiceType(selectedProcedures);
        
		prEOB.PreventativeOption = 'other';   
        selectedProcedures = new List <EOBEntryFormController.Procedures>();
        selectedProcedures.add(prEOB);
        result = EOBEntryFormController.checkServiceTypeforINNRBP(selectedProcedures);
        result = EOBEntryFormController.checkServiceType(selectedProcedures);
        
        test.stopTest();
    }
    
    @IsTest
    static void test_getHealthPlanNetwork() {
        prepareTestdata(false,false);
        test.startTest();
        String serviceType = 'Professional';
        List<String> outOfNetworkNames = new List<String>();
        for (IntPS_NSA__Health_Plan_Content_Network__c hpcn:[Select Id from IntPS_NSA__Health_Plan_Content_Network__c where IntPS_NSA__Services__c=:serviceType]){
            outOfNetworkNames.add(String.valueOf(hpcn.Id));
        }
        String networkOption = null;
        IntPS_NSA__Health_Plan_Content_Network__c result = EOBEntryFormController.getHealthPlanNetwork(outOfNetworkNames,serviceType,networkOption);
        ///////////////////
        serviceType = 'Institutional';
        outOfNetworkNames = new List<String>();
        for (IntPS_NSA__Health_Plan_Content_Network__c hpcn:[Select Id from IntPS_NSA__Health_Plan_Content_Network__c where IntPS_NSA__Services__c=:serviceType]){
            outOfNetworkNames.add(String.valueOf(hpcn.Id));
        }
        networkOption = null;
        result = EOBEntryFormController.getHealthPlanNetwork(outOfNetworkNames,serviceType,networkOption);
        EOBEntryFormController.throwTestException = true;
        result = EOBEntryFormController.getHealthPlanNetwork(outOfNetworkNames,serviceType,networkOption);
        test.stopTest();
    }
    
    
    @IsTest
    static void test_validateNetworksPricesByPriority() {
        //System.debug('BM= validateNetworksPricesByPriority() - 0');
        prepareTestdata(false,false);
        //System.debug('BM= validateNetworksPricesByPriority() - 1');
        
        test.startTest();
        try
        {
          String networkName;
                       
          Map < Integer, String > map_networkByPriority = new Map < Integer, String >();
          for (IntPS_NSA__Health_Plan_Content_Network__c rec : [select IntPS_NSA__Priority__c , IntPS_NSA__Network__r.Name
                                                                  from IntPS_NSA__Health_Plan_Content_Network__c
                                                                 Where IntPS_NSA__Priority__c != Null
                                                                   And IntPS_NSA__Network__r.Name != Null
                                                               ]) 
          {
              map_networkByPriority.put( Integer.valueOf(rec.IntPS_NSA__Priority__c), rec.IntPS_NSA__Network__r.Name);
          }
          //System.debug('BM= validateNetworksPricesByPriority() - 4');
            
          Map < Integer, IntPS_NSA__Health_Plan_Content_Network__c > map_HPCN = new Map < Integer, IntPS_NSA__Health_Plan_Content_Network__c >();
   		  for (IntPS_NSA__Health_Plan_Content_Network__c rec : [select IntPS_NSA__Priority__c , Id 
                                                                  from IntPS_NSA__Health_Plan_Content_Network__c
                                                                 Where IntPS_NSA__Priority__c != Null
                                                                   And IntPS_NSA__Network__r.Name != Null
                                                               ]) 
          {
              map_HPCN.put( Integer.valueOf(rec.IntPS_NSA__Priority__c), rec);
          }
          IntPS_NSA__Health_Plan_Content_Network__c hpcn = map_HPCN.get( new List<Integer>(map_HPCN.keySet())[0] );
          String jsonData = [SELECT Body FROM StaticResource WHERE Name = 'NSA_MRFPricesMockResponse'].Body.toString(); 

          List <MRFToApex> servicesPrices = MRFToApex.parse(jsonData);
          MRFToApex sp = servicesPrices[0];

          sp.NTW_Acronym = 'MEDICARE'; 
          /////////////
          networkName = null;
          /////////////  
          //System.debug('BM= validateNetworksPricesByPriority() - 5');
          
          
          //Scenario 1
          System.debug('BM= Scenario 1');
          hpcn.IntPS_NSA__RbP__c = true;
          //System.debug('BM= hpcn = '+hpcn);            
          EOBEntryFormController.NetworkPrice result = EOBEntryFormController.validateNetworksPricesByPriority(
             networkName
           , map_networkByPriority
           , servicesPrices
           , map_HPCN
           , '11730'
           , '787878'
          );
            
          //Scenario 2
          System.debug('BM= Scenario 2');
          hpcn.IntPS_NSA__RbP__c = false;
          sp.negotiated_type = 'negotiated';
          result = EOBEntryFormController.validateNetworksPricesByPriority(
             networkName
           , map_networkByPriority
           , servicesPrices
           , map_HPCN
           , '11730'
           , '21' //String placeOfService
          );

          //Scenario 3
          System.debug('BM= Scenario 3');
          hpcn.IntPS_NSA__RbP__c = false;
          sp.negotiated_type = 'Not Available';
          result = EOBEntryFormController.validateNetworksPricesByPriority(
             networkName
           , map_networkByPriority
           , servicesPrices
           , map_HPCN
           , '11730'
           , '21' //String placeOfService
          );

          //Scenario 4
          System.debug('BM= Scenario 4');
          hpcn.IntPS_NSA__RbP__c = false;
          sp.service_code = new List<String>{'01','02'};
          result = EOBEntryFormController.validateNetworksPricesByPriority(
             networkName
           , map_networkByPriority
           , servicesPrices
           , map_HPCN
           , '11730'
           , '21' //String placeOfService
          );

          //Scenario 5
          System.debug('BM= Scenario 5');
          hpcn.IntPS_NSA__RbP__c = false;
          //System.debug('BM= hpcn = '+hpcn);
          sp.service_code = new List<String>{'21'};
          result = EOBEntryFormController.validateNetworksPricesByPriority(
             networkName
           , map_networkByPriority
           , servicesPrices
           , map_HPCN
           , '11730'
           , '221' //String placeOfService
          );
            
          //Scenario 6
          System.debug('BM= Scenario 7');
          hpcn.IntPS_NSA__RbP__c = false;
          sp.negotiated_type = 'negotiated';  
          sp.service_code = new List<String>{'01','02','03'};
          result = EOBEntryFormController.validateNetworksPricesByPriority(
             networkName
           , map_networkByPriority
           , servicesPrices
           , map_HPCN
           , '11730'
           , '221' //String placeOfService
          );

          //Scenario 7
          System.debug('BM= Scenario 7');
          hpcn.IntPS_NSA__RbP__c = false;
          sp.negotiated_type = 'Not Available';    
          sp.service_code = new List<String>{'01','02','03'};
          result = EOBEntryFormController.validateNetworksPricesByPriority(
             networkName
           , map_networkByPriority
           , servicesPrices
           , map_HPCN
           , '11730'
           , '221' //String placeOfService
          );

          //Scenario 8
          System.debug('BM= Scenario 8');
          hpcn.IntPS_NSA__RbP__c = false;
          sp.negotiated_type = 'Not Available';    
          sp.service_code = new List<String>{'01','02','03'};
          result = EOBEntryFormController.validateNetworksPricesByPriority(
             networkName
           , map_networkByPriority
           , servicesPrices
           , map_HPCN
           , '11732'
           , '221' //String placeOfService
          );
            
          networkName = 'CG';
            
          //Scenario 9
          System.debug('BM= Scenario 9');
          hpcn.IntPS_NSA__RbP__c = false;
          sp.network.reporting_entity_name = 'CG';
          sp.negotiated_type = 'negotiated';    
          sp.service_code = new List<String>{'21'};
          result = EOBEntryFormController.validateNetworksPricesByPriority(
             networkName
           , map_networkByPriority
           , servicesPrices
           , map_HPCN
           , '11730'
           , '21' //String placeOfService
          );

          //Scenario 10
          System.debug('BM= Scenario 10');
          hpcn.IntPS_NSA__RbP__c = false;
          sp.network.reporting_entity_name = 'CG';
          sp.negotiated_type = 'Not Available';    
          sp.service_code = new List<String>{'21'};
          result = EOBEntryFormController.validateNetworksPricesByPriority(
             networkName
           , map_networkByPriority
           , servicesPrices
           , map_HPCN
           , '11730'
           , '21' //String placeOfService
          );

          //Scenario 11
          System.debug('BM= Scenario 11');
          hpcn.IntPS_NSA__RbP__c = false;
          sp.network.reporting_entity_name = 'CG';
          sp.negotiated_type = 'Not Available';    
          sp.service_code = new List<String>{'20','22'};
          result = EOBEntryFormController.validateNetworksPricesByPriority(
             networkName
           , map_networkByPriority
           , servicesPrices
           , map_HPCN
           , '11730'
           , '21' //String placeOfService
          );

          //Scenario 12
          System.debug('BM= Scenario 12');
          hpcn.IntPS_NSA__RbP__c = false;
          sp.network.reporting_entity_name = 'CG';
          sp.negotiated_type = 'Not Available';    
          sp.service_code = new List<String>{'21'};
          result = EOBEntryFormController.validateNetworksPricesByPriority(
             networkName
           , map_networkByPriority
           , servicesPrices
           , map_HPCN
           , '11730'
           , '22' //String placeOfService
          );

          //Scenario 13
          System.debug('BM= Scenario 13');
          hpcn.IntPS_NSA__RbP__c = false;
          sp.network.reporting_entity_name = 'CG';
          sp.negotiated_type = 'negotiated';    
          sp.service_code = new List<String>{'21','23'};
          result = EOBEntryFormController.validateNetworksPricesByPriority(
             networkName
           , map_networkByPriority
           , servicesPrices
           , map_HPCN
           , '11730'
           , '22' //String placeOfService
          );

          //Scenario 14
          System.debug('BM= Scenario 14');
          hpcn.IntPS_NSA__RbP__c = false;
          sp.network.reporting_entity_name = 'CG';
          sp.negotiated_type = 'Not Available';    
          sp.service_code = new List<String>{'21','23'};
          result = EOBEntryFormController.validateNetworksPricesByPriority(
             networkName
           , map_networkByPriority
           , servicesPrices
           , map_HPCN
           , '11730'
           , '22' //String placeOfService
          );

        } catch (Exception e) {
            
        }
		test.stopTest();
    }
    
    @IsTest
    static void test_serviceLineInsert(){
        String result = null;
        prepareTestdata(false,false);        
        test.startTest();
            
        String claimFields    = '{"aServiceDate__c":"a","Provider_Network__c":"Out-Of-Network","Provider_Account_Name__c":"ROBERT SPRAGUE","Patient__c":"a0OEa000002auDrMAI","Guarantor__c":"a","IntPS_NSA__Service_Date__c":"2023-01-04","IntPS_NSA__Patient__c":"a0OEa000002auDrMAI","IntPS_NSA__Provider_Name__c":"ROBERT"}';
           
        EOBEntryFormController.Procedures prEOB = new EOBEntryFormController.Procedures();
        List < IntPS__Procedure_Code__c > prList = [SELECT Id,Name, NSA_Classification__r.Name
                                                            , IntPS__Code_Type__c, IntPS__Consumer_Description__c
                                                            , Preventatitive_Pregnancy__c, Place_Of_Service__c
                                                            , Provider_Type__c, NSA_Classification__c 
                                                         FROM IntPS__Procedure_Code__c 
                                                        where Name = '11730'
                                                        Limit 1
                                                      ];
        for (IntPS__Procedure_Code__c prc:prList){
        		 prEOB.serviceDate        = Date.parse('01/01/2024');
            	 prEOB.procId             = prc.Id;
                 prEOB.Code               = prc.Name;
             	 prEOB.Description        = prc.IntPS__Consumer_Description__c;
             	 prEOB.Rate               = '1';
            	 prEOB.Quantity        	  = 1;
             	 prEOB.ProviderType   	  = prc.Provider_Type__c;
             	 prEOB.PregnancyOption 	  = prc.Preventatitive_Pregnancy__c;
                 prEOB.PreventativeOption = 'None of the above';
                 prEOB.PlaceOfService     = '21';
             	 prEOB.healthPlanItemID   = '000';
             	 prEOB.CodeType           = prc.IntPS__Code_Type__c;
           }
           
        List < EOBEntryFormController.Procedures > selectedProcedures = new List <EOBEntryFormController.Procedures>();
       	selectedProcedures.add(prEOB);
           //result = EOBEntryFormController.checkServiceTypeforINNRBP(selectedProcedures);
           //result = EOBEntryFormController.checkServiceType(selectedProcedures);
 
        String procedures     = JSON.Serialize(selectedProcedures);
        String providerNumber = '1164604591';
        Date serviceDate      = Date.newInstance(2022,12,27);
           
        String networkOption  = 'In-Network';
        String jsonData = [SELECT Body FROM StaticResource WHERE Name = 'NSA_MRFPricesMockResponse'].Body.toString(); 
        List <MRFToApex> servicesPrices = MRFToApex.parse(jsonData);
        MRFToApex sp = servicesPrices[0];
        String tpaAcro        = sp.TPA_Acronym;
        List <String> networkNames = new List <String>();
        for (IntPS_NSA__Health_Plan_Content_Network__c rec:[Select IntPS_NSA__Network__r.Name
                                                              From IntPS_NSA__Health_Plan_Content_Network__c
                                                             Where IntPS_NSA__Network__r.Name != null
                    ]) {
                networkNames.add(rec.IntPS_NSA__Network__r.Name);       
        }
        String userEmail = 'aazzi@integratedpayorsolutions.com';
        String patientId = String.valueOf([Select Id From IntPS__Patient__c Limit 1].Id);
            
        List<String> outOfNetworkNames = new List<String>();
        for (IntPS_NSA__Health_Plan_Content_Network__c rec:[Select IntPS_NSA__Network__r.Name
                                                              From IntPS_NSA__Health_Plan_Content_Network__c
                                                             Where IntPS_NSA__Network__r.Name != null             
                    ]){
                    outOfNetworkNames.add(rec.IntPS_NSA__Network__r.Name);    
        }
           
        String providerZIP = '031106768';
        IntPS__Health_Plan__c hp = [Select Id,IntPS_NSA__Split_Provider_Pricing__c From IntPS__Health_Plan__c];
        hp.IntPS_NSA__Split_Provider_Pricing__c = true;
        update hp;
        String healthPlanId = String.valueOf(hp.Id);
           
        List<String> availableNetworksForProvider = new List<String>();
        for (IntPS_NSA__Health_Plan_Content_Network__c rec:[Select IntPS_NSA__Network__r.Name
                                                              From IntPS_NSA__Health_Plan_Content_Network__c
                                                             Where IntPS_NSA__Network__r.Name != null
                    ]) {
                availableNetworksForProvider.add(rec.IntPS_NSA__Network__r.Name);       
        }
        String applicationVersion = '2.0';
        
        System.debug('BM= test_serviceLineInsert');
        List <IntPS_NSA__Health_Plan_Content_Network__c> networks = new List <IntPS_NSA__Health_Plan_Content_Network__c>();
        try 
        {
  		   System.debug('BM= test_serviceLineInsert - 1 - Start');
           networks.clear();
            
           for (IntPS_NSA__Health_Plan_Content_Network__c rec:[Select Id
                                                                    , IntPS_NSA__Priority__c
                                                                    , IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c
                                                                 From IntPS_NSA__Health_Plan_Content_Network__c
                                                                Where IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c != null
                                                              ]){
                rec.IntPS_NSA__Priority__c = null;
                rec.IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c = 'In-Network';
                networks.add(rec);
           }
        
           //Scenario 1
           result = EOBEntryFormController.serviceLineInsert(claimFields
                                                           , procedures
                                                           , providerNumber
                                                           , serviceDate
                                                           , networks
                                                           , networkOption
                                                           , tpaAcro
                                                           , networkNames
                                                           , userEmail
                                                           , patientId
                                                           , outOfNetworkNames
                                                           , providerZIP
                                                           , healthPlanId
                                                           , availableNetworksForProvider
                                                           , applicationVersion
                                                            );
            
          System.debug('BM= test_serviceLineInsert - 1 - End');
        } catch (Exception e) {
               
        } 
        
        try
        {
           //Scenario 2
           networks.clear();
           System.debug('BM= Scenario 2 - serviceLineInsert - Start'); 
           
           for (IntPS_NSA__Health_Plan_Content_Network__c rec:[Select Id
                                                                    , IntPS_NSA__Priority__c
                                                                    , IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c
                                                                 From IntPS_NSA__Health_Plan_Content_Network__c
                                                                Where IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c != null
                                                              ]){
                rec.IntPS_NSA__Priority__c = 1;
                rec.IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c = '1';
                networks.add(rec);                                                                                                            
           }
            
           result = EOBEntryFormController.serviceLineInsert(claimFields
                                                           , procedures
                                                           , providerNumber
                                                           , serviceDate
                                                           , networks
                                                           , networkOption
                                                           , tpaAcro
                                                           , networkNames
                                                           , userEmail
                                                           , patientId
                                                           , outOfNetworkNames
                                                           , providerZIP
                                                           , healthPlanId
                                                           , availableNetworksForProvider
                                                           , applicationVersion
                                                            );
            
          System.debug('BM= Scenario 2 - serviceLineInsert - End'); 
        } catch (Exception e) {
               
        } 
        
        try
        {
           //Scenario 3
           networks.clear();
           System.debug('BM= Scenario 3 - serviceLineInsert - Start'); 
           
           for (IntPS_NSA__Health_Plan_Content_Network__c rec:[Select Id
                                                                    , IntPS_NSA__Priority__c
                                                                    , IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c
                                                                 From IntPS_NSA__Health_Plan_Content_Network__c
                                                                Where IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c != null
                                                              ]){
                rec.IntPS_NSA__Priority__c = 1;
                rec.IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c = '2';
                networks.add(rec);                                                                                                            
           }
            
           result = EOBEntryFormController.serviceLineInsert(claimFields
                                                           , procedures
                                                           , providerNumber
                                                           , serviceDate
                                                           , networks
                                                           , networkOption
                                                           , tpaAcro
                                                           , networkNames
                                                           , userEmail
                                                           , patientId
                                                           , outOfNetworkNames
                                                           , providerZIP
                                                           , healthPlanId
                                                           , availableNetworksForProvider
                                                           , applicationVersion
                                                            );
            
          System.debug('BM= Scenario 3 - serviceLineInsert - End'); 
        } catch (Exception e) {
               
        } 
        
        try
        {
           //Scenario 4
           networks.clear();
           System.debug('BM= Scenario 4 - serviceLineInsert - Start'); 
           
           for (IntPS_NSA__Health_Plan_Content_Network__c rec:[Select Id
                                                                    , IntPS_NSA__Priority__c
                                                                    , IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c
                                                                 From IntPS_NSA__Health_Plan_Content_Network__c
                                                                Where IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c != null
                                                              ]){
                rec.IntPS_NSA__Priority__c = 1;
                rec.IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c = '3';
                networks.add(rec);                                                                                                            
           }
            
           result = EOBEntryFormController.serviceLineInsert(claimFields
                                                           , procedures
                                                           , providerNumber
                                                           , serviceDate
                                                           , networks
                                                           , networkOption
                                                           , tpaAcro
                                                           , networkNames
                                                           , userEmail
                                                           , patientId
                                                           , outOfNetworkNames
                                                           , providerZIP
                                                           , healthPlanId
                                                           , availableNetworksForProvider
                                                           , applicationVersion
                                                            );
            
          System.debug('BM= Scenario 4 - serviceLineInsert - End'); 
        } catch (Exception e) {
               
        } 
		
        test.stopTest();
    }
    
    @IsTest
    static void test_checkForMemberSpecificHPC(){
        prepareTestdata(false,false);
        test.startTest();
        List<IntPS_NSA__Health_Plan_Content_Network__c> networks = new List<IntPS_NSA__Health_Plan_Content_Network__c>(); 
        for(IntPS_NSA__Health_Plan_Content_Network__c net:[Select Id
                                                              , IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c
                                                           from IntPS_NSA__Health_Plan_Content_Network__c]){
                                                               
            net.IntPS_NSA__Priority__c = Null;
            net.IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c='In-Network';  
            networks.add(net);
        }
        update networks;
        List<IntPS_NSA__Health_Plan_Content_Network__c> result = EOBEntryFormController.checkForMemberSpecificHPC(networks);
        test.stopTest();
    }
    
    
	@IsTest
    static void test_getProcedureCodes() {
        prepareTestdata(false,false);
        test.startTest();
        List <EOBEntryFormController.ProceduresFiltered> lpf = EOBEntryFormController.getProcedureCodes(
                'searchValue'
              , false
              , true
              , 'healthPlanID'
              , 'networkOption'
              , true
              , 'applicationVersion'
        );
        
		EOBEntryFormController.throwTestException = true;
        try {
          lpf = EOBEntryFormController.getProcedureCodes(
                'searchValue'
              , false
              , true
              , 'healthPlanID'
              , 'networkOption'
              , true
              , 'applicationVersion'
           );
        } catch (Exception e){
            
        }
        try
        {
           lpf = EOBEntryFormController.getProcedureCodes(
                'searchValue'
              , true
              , false
              , 'healthPlanID'
              , 'networkOption'
              , true
              , 'applicationVersion'
           );
        } catch (Exception e){
            
        }
        test.stopTest();
    }
    
    @IsTest
    static void test_checkExistingNPI(){
        prepareTestdata(false,false);
        test.startTest();           
           String searchValue     = 'test';
           Boolean searchwithCode = true;
           Boolean searchwithName = false;
           List <String> networks = new List<String>();
           //for (IntPS_NSA__Health_Plan_Content_Network__c rec:[Select IntPS_NSA__Network__r.Name
           //                                                   From IntPS_NSA__Health_Plan_Content_Network__c
           //                                                  Where IntPS_NSA__Network__r.Name != null             
           //         ]){
           //         networks.add(rec.IntPS_NSA__Network__r.Name);    
           //}
                                                                  
           String jsonData = [SELECT Body FROM StaticResource WHERE Name = 'NSA_MRFPricesMockResponse'].Body.toString(); 
           List <MRFToApex> servicesPrices = MRFToApex.parse(jsonData);
           MRFToApex sp = servicesPrices[0];
           String tpaAcro        = sp.TPA_Acronym;

           Boolean hasOON = false;
        
           try
           {
             System.debug('BM= ProviderWSMock - 1');  
             List <EOBEntryFormController.Providers> res = EOBEntryFormController.checkExistingNPI(searchValue
                                                                                           , searchwithCode
                                                                                           , searchwithName
                                                                                           , networks
                                                                                           , tpaAcro
                                                                                           , hasOON);
           } catch(Exception ex)
           {}
        
        test.stopTest();
    }
        
    @IsTest
    static void test_misc(){
        //prepareTestdata(false,false);
        EOBEntryFormController.throwTestException = true;
        List<IntPS_NSA__Health_Plan_Content_Network__c> l_hpnc = new List<IntPS_NSA__Health_Plan_Content_Network__c>();
        try
        {    
         EOBEntryFormController.checkForMemberSpecificHPC(null);
        } catch (Exception e) {
            
        }
        
        List<EOBEntryFormController.ProceduresFiltered> l_pf = new List<EOBEntryFormController.ProceduresFiltered>();
        try {  
           l_pf = EOBEntryFormController.getProcedureCodesByHPI(null);
        } catch (Exception e) {
            
        }  
        
		List < IntPS_NSA__Health_Plan_Content_Network__c > l_hpcn = new List < IntPS_NSA__Health_Plan_Content_Network__c >();
        try {
            l_hpcn = EOBEntryFormController.getNetworksDetails(Null,Null);
        }catch (Exception e) {
            
        }  
        
        try {
            IntPS_NSA__NSA_Error_Log__c result = EOBEntryFormController.createErrorLogs(
                 null
                ,'-patientId-'
                ,'eob'
                , null
                , null
                , null);
        }catch (Exception e) {
            
        } 
        
        try {
         String result = EOBEntryFormController.getNetworkNames(null);
        }catch (Exception e) {
            
        }  
        
        try {
            Boolean result = EOBEntryFormController.triggerCalculation(null,null,null);
        }catch (Exception e) {
            
        }    
        
        try {
            Boolean result = EOBEntryFormController.hasOutOfNetwork('-abcdef-');
        }catch (Exception e) {
            
        } 
        
        try {
            List <EOBEntryFormController.Providers> lp = EOBEntryFormController.checkExistingNPI(null
                                                                        , false
                                                                        , false
                                                                        , null
                                                                        , null
                                                                        , false);
        } catch (Exception e) {
            
        }
        
        try {
            EOBEntryFormController.ProceduresMappedWithHP result = EOBEntryFormController.MapProceduresToHPI('-abcdef-'
                                                                                                           , null
                                                                                                           , null
                                                                                                           , null
                                                                                                           , '-abcdef-'
                                                                                                           , null
                                                                                                           , null);
        }catch (Exception e) {
            
        }
        
        try{
            Boolean result = EOBEntryFormController.hasMultiTiers(null);
            result = EOBEntryFormController.hasMultiTiers('-abcdef-'); 
        } catch (Exception e) {
            
        }
        
        try{
            String result = EOBEntryFormController.getPdfFileAsBase64String('eobId',true);
        } catch (Exception e) {
            
        }
    }
//------------------------------------------------------------------------
    @IsTest
    public static void testAFacilityProvider() {
        prepareTestdata(false,false);
		      IntPS__Health_Plan__c hp=[Select IntPS_NSA__Split_Provider_Pricing__c from IntPS__Health_Plan__c  LIMIT 1];
        hp.IntPS_NSA__Split_Provider_Pricing__c=true;
        update hp;
        Contact cont=[Select Id from Contact where Name='Mario Naharis' LIMIT 1];
          test.startTest();
        List<IntPS__Patient__c> patient=EOBEntryFormController.getPatient(cont.Id);
        //List<IntPS__Patient__c> dependents=EOBEntryFormController.getPatientDependents(patient.Id);
        String tpaAcro=EOBEntryFormController.getTPAAcro('BSI Companies');
         List<String> patientIds=new List<String>();
        patientIds.add(patient[0].Id);
        Map<String,List<IntPS__Eligibility__c>> patientInfo=EOBEntryFormController.getPatientInformation(patientIds,Date.newInstance(2022, 12,27),false);
        List<IntPS_NSA__Health_Plan_Content_Network__c> networks=EOBEntryFormController.getNetworksDetails(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,patient[0].Id);
        Boolean hasOutOfNetwork=EOBEntryFormController.hasOutOfNetwork(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);
        List<String>networkNames = new List<String>();
        List<String> outOfNetworkNames=new List<String>();
        for(IntPS_NSA__Health_Plan_Content_Network__c hpc:networks){
            networkNames.add(hpc.IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
             if(hpc.IntPS_NSA__RbP__c){
                outOfNetworkNames.add(hpc.Id);
            }
        }
        List<IntPS__Health_Plan_Content__c> hpcs=EOBEntryFormController.getHPCList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);

		List<IntPS__Health_Plan_Item__c> hpis=EOBEntryFormController.getHPIList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, hpcs[0].Id);
               List<EOBEntryFormController.Providers> providers2=EOBEntryFormController.checkExistingNPI('1073998647', true, false, networkNames, tpaAcro, hasOutOfNetwork);

    }
    @IsTest
    public static void createEOBSuccessWithComplexCPTWithcheckIfSplitAvailable2() {
		prepareTestdata(false,false);
		      IntPS__Health_Plan__c hp=[Select IntPS_NSA__Split_Provider_Pricing__c from IntPS__Health_Plan__c  LIMIT 1];
        hp.IntPS_NSA__Split_Provider_Pricing__c=true;
        update hp;
        Contact cont=[Select Id from Contact where Name='Mario Naharis' LIMIT 1];
          test.startTest();
        List<IntPS__Patient__c> patient=EOBEntryFormController.getPatient(cont.Id);
        //List<IntPS__Patient__c> dependents=EOBEntryFormController.getPatientDependents(patient.Id);
        String tpaAcro=EOBEntryFormController.getTPAAcro('BSI Companies');
        List<String> patientIds=new List<String>();
        patientIds.add(patient[0].Id);
        Map<String,List<IntPS__Eligibility__c>> patientInfo=EOBEntryFormController.getPatientInformation(patientIds,Date.newInstance(2022, 12,27),false);
        List<IntPS_NSA__Health_Plan_Content_Network__c> networks=EOBEntryFormController.getNetworksDetails(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,patient[0].Id);
        Boolean hasOutOfNetwork=EOBEntryFormController.hasOutOfNetwork(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);
        List<String>networkNames = new List<String>();
        List<String> outOfNetworkNames=new List<String>();
        for(IntPS_NSA__Health_Plan_Content_Network__c hpc:networks){
            networkNames.add(hpc.IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
             if(hpc.IntPS_NSA__RbP__c){
                outOfNetworkNames.add(hpc.Id);
            }
        }
        List<IntPS__Health_Plan_Content__c> hpcs=EOBEntryFormController.getHPCList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);

		List<IntPS__Health_Plan_Item__c> hpis=EOBEntryFormController.getHPIList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, hpcs[0].Id);
        List<EOBEntryFormController.Providers> providers= EOBEntryFormController.retriveProviders('number=1194742064',networkNames,tpaAcro, hasOutOfNetwork);
        List <USState__mdt> usstates= EOBEntryFormController.getUSStates();
        List<EOBEntryFormController.Providers> providersWithName=EOBEntryFormController.checkExistingNPI('Tania', false, true, networkNames, tpaAcro, hasOutOfNetwork);
       	List<String> availableNetworks=providers[0].availableNetworksForProvider;
        List<EOBEntryFormController.ProceduresFiltered> procedureCodes=EOBEntryFormController.getProcedureCodes('11730', true, false, patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, 'In-Network',false,'2.0');
        String claimFields='{"aServiceDate__c":"a","Provider_Network__c":"In-Network","Provider_Account_Name__c":"ROBERT SPRAGUE","Patient__c":"'+patient[0].Id+'","Guarantor__c":"a","IntPS_NSA__Service_Date__c":"2023-01-04","IntPS_NSA__Patient__c":"'+patient[0].Id+'","IntPS_NSA__Provider_Name__c":"ROBERT SPRAGUE","IntPS_NSA__Provider_NPI_Number__c":"1164604591","IntPS_NSA__Provider_Billing_Street__c":"703 RIVERWAY PL","IntPS_NSA__Provider_Billing_City__c":"BEDFORD","IntPS_NSA__Provider_Billing_State__c":"NH","IntPS_NSA__Provider_Billing_Postal_Code__c":"031106768","IntPS_NSA__Provider_Network__c":"In-Network","IntPS_NSA__Eligibility__c":"'+patientInfo.get('Eligibility')[0].Id+'"}';
        String procedures='[{"serviceDate":"2023-01-04","Code":"33408","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"Preventative Services","PreventativeOption":"Preventative Services","PlaceOfService":"11"},{"Code":"11730","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"Preventative Services","PreventativeOption":"Preventative Services","PlaceOfService":"11"}]';
        String result=EOBEntryFormController.serviceLineInsert(claimFields, procedures, '1164604591', Date.newInstance(2022, 12,27), networks, 'In-Network', tpaAcro, networkNames, 'aazzi@integratedpayorsolutions.com', patient[0].Id, outOfNetworkNames, '031106768',patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,availableNetworks,'2.0');
		String pdf=EOBEntryFormController.getPdfFileAsBase64String(result,false);
       	Boolean calculation=EOBEntryFormController.triggerCalculation(result, patient[0].Id, 'aazzi@integratedpayorsolutions.com');
        ApexPages.currentPage().getParameters().put('id', result);
		AdvancedEOBController  testAccPlan = new AdvancedEOBController();
		testAccPlan.getEOB();
        testAccPlan.getHealthPlan();

        test.stopTest();
    }
      @IsTest
    public static void createEOBSuccessWithComplexCPTWithcheckIfSplitAvailable() {
		prepareTestdata(false,false);
		      IntPS__Health_Plan__c hp=[Select IntPS_NSA__Split_Provider_Pricing__c from IntPS__Health_Plan__c  LIMIT 1];
        hp.IntPS_NSA__Split_Provider_Pricing__c=true;
        update hp;
        Contact cont=[Select Id from Contact where Name='Mario Naharis' LIMIT 1];
          test.startTest();
        List<IntPS__Patient__c> patient=EOBEntryFormController.getPatient(cont.Id);
        //List<IntPS__Patient__c> dependents=EOBEntryFormController.getPatientDependents(patient.Id);
        String tpaAcro=EOBEntryFormController.getTPAAcro('BSI Companies');
        List<String> patientIds=new List<String>();
        patientIds.add(patient[0].Id);
        Map<String,List<IntPS__Eligibility__c>> patientInfo=EOBEntryFormController.getPatientInformation(patientIds,Date.newInstance(2022, 12,27),false);
        List<IntPS_NSA__Health_Plan_Content_Network__c> networks=EOBEntryFormController.getNetworksDetails(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,patient[0].Id);
        Boolean hasOutOfNetwork=EOBEntryFormController.hasOutOfNetwork(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);
        List<String>networkNames = new List<String>();
        List<String> outOfNetworkNames=new List<String>();
        for(IntPS_NSA__Health_Plan_Content_Network__c hpc:networks){
            networkNames.add(hpc.IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
             if(hpc.IntPS_NSA__RbP__c){
                outOfNetworkNames.add(hpc.Id);
            }
        }
        List<IntPS__Health_Plan_Content__c> hpcs=EOBEntryFormController.getHPCList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);

		List<IntPS__Health_Plan_Item__c> hpis=EOBEntryFormController.getHPIList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, hpcs[0].Id);
        List<EOBEntryFormController.Providers> providers=EOBEntryFormController.checkExistingNPI('1164604591', true, false, networkNames, tpaAcro, hasOutOfNetwork);

        List<EOBEntryFormController.Providers> providersWithName=EOBEntryFormController.checkExistingNPI('Tania', false, true, networkNames, tpaAcro, hasOutOfNetwork);
       	List<String> availableNetworks=providers[0].availableNetworksForProvider;
        List<EOBEntryFormController.ProceduresFiltered> procedureCodes=EOBEntryFormController.getProcedureCodes('11730', true, false, patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, 'In-Network',false,'2.0');
        String claimFields='{"aServiceDate__c":"a","Provider_Network__c":"In-Network","Provider_Account_Name__c":"ROBERT SPRAGUE","Patient__c":"'+patient[0].Id+'","Guarantor__c":"a","IntPS_NSA__Service_Date__c":"2023-01-04","IntPS_NSA__Patient__c":"'+patient[0].Id+'","IntPS_NSA__Provider_Name__c":"ROBERT SPRAGUE","IntPS_NSA__Provider_NPI_Number__c":"1164604591","IntPS_NSA__Provider_Billing_Street__c":"703 RIVERWAY PL","IntPS_NSA__Provider_Billing_City__c":"BEDFORD","IntPS_NSA__Provider_Billing_State__c":"NH","IntPS_NSA__Provider_Billing_Postal_Code__c":"031106768","IntPS_NSA__Provider_Network__c":"In-Network","IntPS_NSA__Eligibility__c":"'+patientInfo.get('Eligibility')[0].Id+'"}';
        String procedures='[{"serviceDate":"2023-01-04","Code":"33408","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"None of the above","PreventativeOption":"None of the above","PlaceOfService":"10"},{"Code":"11730","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"Preventative Services","PreventativeOption":"Preventative Services","PlaceOfService":"11"}]';
        String result=EOBEntryFormController.serviceLineInsert(claimFields, procedures, '1164604591', Date.newInstance(2022, 12,27), networks, 'In-Network', tpaAcro, networkNames, 'aazzi@integratedpayorsolutions.com', patient[0].Id, outOfNetworkNames, '031106768',patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,availableNetworks,'2.0');
		String pdf=EOBEntryFormController.getPdfFileAsBase64String(result,false);
       	Boolean calculation=EOBEntryFormController.triggerCalculation(result, patient[0].Id, 'aazzi@integratedpayorsolutions.com');
        ApexPages.currentPage().getParameters().put('id', result);
		AdvancedEOBController  testAccPlan = new AdvancedEOBController();
		testAccPlan.getEOB();
        testAccPlan.getHealthPlan();

        test.stopTest();
    }
     @IsTest
    public static void createEOBSuccessWithComplexCPT() {
		prepareTestdata(false,false);

        Contact cont=[Select Id from Contact where Name='Mario Naharis' LIMIT 1];
          test.startTest();
        List<IntPS__Patient__c> patient=EOBEntryFormController.getPatient(cont.Id);
        //List<IntPS__Patient__c> dependents=EOBEntryFormController.getPatientDependents(patient.Id);
        String tpaAcro=EOBEntryFormController.getTPAAcro('BSI Companies');
        List<String> patientIds=new List<String>();
        patientIds.add(patient[0].Id);
        Map<String,List<IntPS__Eligibility__c>> patientInfo=EOBEntryFormController.getPatientInformation(patientIds,Date.newInstance(2022, 12,27),true);
        List<IntPS_NSA__Health_Plan_Content_Network__c> networks=EOBEntryFormController.getNetworksDetails(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,patient[0].Id);
        Boolean hasOutOfNetwork=EOBEntryFormController.hasOutOfNetwork(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);
        List<String>networkNames = new List<String>();
        List<String> outOfNetworkNames=new List<String>();
        for(IntPS_NSA__Health_Plan_Content_Network__c hpc:networks){
            networkNames.add(hpc.IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
             if(hpc.IntPS_NSA__RbP__c){
                outOfNetworkNames.add(hpc.Id);
            }
        }
        List<IntPS__Health_Plan_Content__c> hpcs=EOBEntryFormController.getHPCList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);

		List<IntPS__Health_Plan_Item__c> hpis=EOBEntryFormController.getHPIList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, hpcs[0].Id);
        List<EOBEntryFormController.Providers> providers=EOBEntryFormController.checkExistingNPI('1164604591', true, false, networkNames, tpaAcro, hasOutOfNetwork);
        List<EOBEntryFormController.Providers> providersWithName=EOBEntryFormController.checkExistingNPI('Tania', false, true, networkNames, tpaAcro, hasOutOfNetwork);
       	List<String> availableNetworks=providers[0].availableNetworksForProvider;
        List<EOBEntryFormController.ProceduresFiltered> procedureCodes=EOBEntryFormController.getProcedureCodes('11730', true, false, patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, 'In-Network',false,'2.0');
        String claimFields='{"aServiceDate__c":"a","Provider_Network__c":"In-Network","Provider_Account_Name__c":"ROBERT SPRAGUE","Patient__c":"'+patient[0].Id+'","Guarantor__c":"a","IntPS_NSA__Service_Date__c":"2023-01-04","IntPS_NSA__Patient__c":"'+patient[0].Id+'","IntPS_NSA__Provider_Name__c":"ROBERT SPRAGUE","IntPS_NSA__Provider_NPI_Number__c":"1164604591","IntPS_NSA__Provider_Billing_Street__c":"703 RIVERWAY PL","IntPS_NSA__Provider_Billing_City__c":"BEDFORD","IntPS_NSA__Provider_Billing_State__c":"NH","IntPS_NSA__Provider_Billing_Postal_Code__c":"031106768","IntPS_NSA__Provider_Network__c":"In-Network","IntPS_NSA__Eligibility__c":"'+patientInfo.get('Eligibility')[0].Id+'"}';
        String procedures='[{"serviceDate":"2023-01-04","Code":"33408","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"None of the above","PreventativeOption":"None of the above","PlaceOfService":"10"},{"Code":"11730","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"Preventative Services","PreventativeOption":"Preventative Services","PlaceOfService":"11"}]';
        String result=EOBEntryFormController.serviceLineInsert(claimFields, procedures, '1164604591', Date.newInstance(2022, 12,27), networks, 'In-Network', tpaAcro, networkNames, 'aazzi@integratedpayorsolutions.com', patient[0].Id, outOfNetworkNames, '031106768',patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,availableNetworks,'2.0');
		String pdf=EOBEntryFormController.getPdfFileAsBase64String(result,false);
       	Boolean calculation=EOBEntryFormController.triggerCalculation(result, patient[0].Id, 'aazzi@integratedpayorsolutions.com');
        ApexPages.currentPage().getParameters().put('id', result);
		AdvancedEOBController  testAccPlan = new AdvancedEOBController();
		testAccPlan.getEOB();
        testAccPlan.getHealthPlan();
        test.stopTest();
    }
    @IsTest
    public static void createEOBSuccessWithComplexCPT2() {
		prepareTestdata(false,false);
        Contact cont=[Select Id from Contact where Name='Mario Naharis' LIMIT 1];
          test.startTest();
        List<IntPS__Patient__c> patient=EOBEntryFormController.getPatient(cont.Id);
        //List<IntPS__Patient__c> dependents=EOBEntryFormController.getPatientDependents(patient[0].Id);
        String tpaAcro=EOBEntryFormController.getTPAAcro('BSI Companies');
        List<String> patientIds=new List<String>();
        patientIds.add(patient[0].Id);
        Map<String,List<IntPS__Eligibility__c>> patientInfo=EOBEntryFormController.getPatientInformation(patientIds,Date.newInstance(2022, 12,27),false);
        List<IntPS_NSA__Health_Plan_Content_Network__c> networks=EOBEntryFormController.getNetworksDetails(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,patient[0].Id);
        Boolean hasOutOfNetwork=EOBEntryFormController.hasOutOfNetwork(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);
        List<String>networkNames = new List<String>();
        List<String> outOfNetworkNames=new List<String>();
        for(IntPS_NSA__Health_Plan_Content_Network__c hpc:networks){
            networkNames.add(hpc.IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
             if(hpc.IntPS_NSA__RbP__c){
                outOfNetworkNames.add(hpc.Id);
            }
        }
        List<IntPS__Health_Plan_Content__c> hpcs=EOBEntryFormController.getHPCList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);

		List<IntPS__Health_Plan_Item__c> hpis=EOBEntryFormController.getHPIList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, hpcs[0].Id);
        List<EOBEntryFormController.Providers> providers=EOBEntryFormController.checkExistingNPI('1164604591', true, false, networkNames, tpaAcro, hasOutOfNetwork);
        List<EOBEntryFormController.Providers> providersWithName=EOBEntryFormController.checkExistingNPI('Tania', false, true, networkNames, tpaAcro, hasOutOfNetwork);
       	List<String> availableNetworks=providers[0].availableNetworksForProvider;
        List<EOBEntryFormController.ProceduresFiltered> procedureCodes=EOBEntryFormController.getProcedureCodes('11730', true, false, patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, 'In-Network',false,'2.0');
        String claimFields='{"aServiceDate__c":"a","Provider_Network__c":"In-Network","Provider_Account_Name__c":"ROBERT SPRAGUE","Patient__c":"'+patient[0].Id+'","Guarantor__c":"a","IntPS_NSA__Service_Date__c":"2023-01-04","IntPS_NSA__Patient__c":"'+patient[0].Id+'","IntPS_NSA__Provider_Name__c":"ROBERT SPRAGUE","IntPS_NSA__Provider_NPI_Number__c":"1164604591","IntPS_NSA__Provider_Billing_Street__c":"703 RIVERWAY PL","IntPS_NSA__Provider_Billing_City__c":"BEDFORD","IntPS_NSA__Provider_Billing_State__c":"NH","IntPS_NSA__Provider_Billing_Postal_Code__c":"031106768","IntPS_NSA__Provider_Network__c":"In-Network","IntPS_NSA__Eligibility__c":"'+patientInfo.get('Eligibility')[0].Id+'"}';
        String procedures='[{"serviceDate":"2023-01-04","Code":"33409","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"None of the above","PreventativeOption":"None of the above","PlaceOfService":"11"},{"Code":"11730","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"Preventative Services","PreventativeOption":"Preventative Services","PlaceOfService":"11"}]';
        String result=EOBEntryFormController.serviceLineInsert(claimFields, procedures, '1164604591', Date.newInstance(2022, 12,27), networks, 'In-Network', tpaAcro, networkNames, 'aazzi@integratedpayorsolutions.com', patient[0].Id, outOfNetworkNames, '031106768',patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,availableNetworks,'2.0');
		String pdf=EOBEntryFormController.getPdfFileAsBase64String(result,false);
       	Boolean calculation=EOBEntryFormController.triggerCalculation(result, patient[0].Id, 'aazzi@integratedpayorsolutions.com');
        ApexPages.currentPage().getParameters().put('id', result);
		AdvancedEOBController  testAccPlan = new AdvancedEOBController();
		testAccPlan.getEOB();
        testAccPlan.getHealthPlan();
        testAccPlan.getServiceDate();
        testAccPlan.getremarkCodes();
        testAccPlan.getShowPDF();
        test.stopTest();
    }
    @IsTest
    public static void createEOBSuccessWithComplexCPT3() {
		prepareTestdata(false,false);
        Contact cont=[Select Id from Contact where Name='Mario Naharis' LIMIT 1];
          test.startTest();
        List<IntPS__Patient__c> patient=EOBEntryFormController.getPatient(cont.Id);
       // List<IntPS__Patient__c> dependents=EOBEntryFormController.getPatientDependents(patient.Id);
        String tpaAcro=EOBEntryFormController.getTPAAcro('BSI Companies');
         List<String> patientIds=new List<String>();
        patientIds.add(patient[0].Id);
        Map<String,List<IntPS__Eligibility__c>> patientInfo=EOBEntryFormController.getPatientInformation(patientIds,Date.newInstance(2022, 12,27),true);
        List<IntPS_NSA__Health_Plan_Content_Network__c> networks=EOBEntryFormController.getNetworksDetails(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,patient[0].Id);
        Boolean hasOutOfNetwork=EOBEntryFormController.hasOutOfNetwork(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);
        List<String>networkNames = new List<String>();
        List<String> outOfNetworkNames=new List<String>();
        for(IntPS_NSA__Health_Plan_Content_Network__c hpc:networks){
            networkNames.add(hpc.IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
             if(hpc.IntPS_NSA__RbP__c){
                outOfNetworkNames.add(hpc.Id);
            }
        }
        List<IntPS__Health_Plan_Content__c> hpcs=EOBEntryFormController.getHPCList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);
		List<IntPS__Health_Plan_Item__c> hpis2=  EOBEntryFormController.getHealthPlanItems(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);
		List<IntPS__Health_Plan_Item__c> hpis=EOBEntryFormController.getHPIList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, hpcs[0].Id);
        List<EOBEntryFormController.ProceduresFiltered> filteredProc=EOBEntryFormController.getProcedureCodesByHPI(hpis[0].Id);
        List<EOBEntryFormController.Providers> providers=EOBEntryFormController.checkExistingNPI('1164604591', true, false, networkNames, tpaAcro, hasOutOfNetwork);
        List<EOBEntryFormController.Providers> providersWithName=EOBEntryFormController.checkExistingNPI('Tania', false, true, networkNames, tpaAcro, hasOutOfNetwork);
       	List<String> availableNetworks=providers[0].availableNetworksForProvider;
        List<EOBEntryFormController.ProceduresFiltered> procedureCodes=EOBEntryFormController.getProcedureCodes('11730', true, false, patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, 'In-Network',false,'2.0');
        String claimFields='{"aServiceDate__c":"a","Provider_Network__c":"In-Network","Provider_Account_Name__c":"ROBERT SPRAGUE","Patient__c":"'+patient[0].Id+'","Guarantor__c":"a","IntPS_NSA__Service_Date__c":"2023-01-04","IntPS_NSA__Patient__c":"'+patient[0].Id+'","IntPS_NSA__Provider_Name__c":"ROBERT SPRAGUE","IntPS_NSA__Provider_NPI_Number__c":"1164604591","IntPS_NSA__Provider_Billing_Street__c":"703 RIVERWAY PL","IntPS_NSA__Provider_Billing_City__c":"BEDFORD","IntPS_NSA__Provider_Billing_State__c":"NH","IntPS_NSA__Provider_Billing_Postal_Code__c":"031106768","IntPS_NSA__Provider_Network__c":"In-Network","IntPS_NSA__Eligibility__c":"'+patientInfo.get('Eligibility')[0].Id+'"}';
        String procedures='[{"serviceDate":"2023-01-04","Code":"33409","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"","PregnancyOption":"None of the above","PreventativeOption":"None of the above","PlaceOfService":"22"},{"Code":"11730","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"Preventative Services","PreventativeOption":"Preventative Services","PlaceOfService":"11"}]';
        String result=EOBEntryFormController.serviceLineInsert(claimFields, procedures, '1164604591', Date.newInstance(2022, 12,27), networks, 'In-Network', tpaAcro, networkNames, 'aazzi@integratedpayorsolutions.com', patient[0].Id, outOfNetworkNames, '031106768',patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,availableNetworks,'2.0');
		String pdf=EOBEntryFormController.getPdfFileAsBase64String(result,false);
       	Boolean calculation=EOBEntryFormController.triggerCalculation(result, patient[0].Id, 'aazzi@integratedpayorsolutions.com');
        ApexPages.currentPage().getParameters().put('id', result);
		AdvancedEOBController  testAccPlan = new AdvancedEOBController();
		testAccPlan.getEOB();
        testAccPlan.getHealthPlan();
        test.stopTest();
    }
        @IsTest
    public static void createEOBSuccessWithComplexCPT4() {
		prepareTestdata(false,false);
        Contact cont=[Select Id from Contact where Name='Mario Naharis' LIMIT 1];
          test.startTest();
        List<IntPS__Patient__c> patient=EOBEntryFormController.getPatient(cont.Id);
       // List<IntPS__Patient__c> dependents=EOBEntryFormController.getPatientDependents(patient.Id);
        String tpaAcro=EOBEntryFormController.getTPAAcro('BSI Companies');
        List<String> patientIds=new List<String>();
        patientIds.add(patient[0].Id);
        Map<String,List<IntPS__Eligibility__c>> patientInfo=EOBEntryFormController.getPatientInformation(patientIds,Date.newInstance(2022, 12,27),false);
        List<IntPS_NSA__Health_Plan_Content_Network__c> networks=EOBEntryFormController.getNetworksDetails(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,patient[0].Id);
        Boolean hasOutOfNetwork=EOBEntryFormController.hasOutOfNetwork(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);
        List<String>networkNames = new List<String>();
        List<String> outOfNetworkNames=new List<String>();
        for(IntPS_NSA__Health_Plan_Content_Network__c hpc:networks){
            networkNames.add(hpc.IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
             if(hpc.IntPS_NSA__RbP__c){
                outOfNetworkNames.add(hpc.Id);
            }
        }
        List<IntPS__Health_Plan_Content__c> hpcs=EOBEntryFormController.getHPCList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);

		List<IntPS__Health_Plan_Item__c> hpis=EOBEntryFormController.getHPIList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, hpcs[0].Id);
        List<EOBEntryFormController.Providers> providers=EOBEntryFormController.checkExistingNPI('1164604591', true, false, networkNames, tpaAcro, hasOutOfNetwork);
        List<EOBEntryFormController.Providers> providersWithName=EOBEntryFormController.checkExistingNPI('Tania', false, true, networkNames, tpaAcro, hasOutOfNetwork);
       	List<String> availableNetworks=providers[0].availableNetworksForProvider;
        List<EOBEntryFormController.ProceduresFiltered> procedureCodes=EOBEntryFormController.getProcedureCodes('11730', true, false, patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, 'In-Network',false,'2.0');
        String claimFields='{"aServiceDate__c":"a","Provider_Network__c":"In-Network","Provider_Account_Name__c":"ROBERT SPRAGUE","Patient__c":"'+patient[0].Id+'","Guarantor__c":"a","IntPS_NSA__Service_Date__c":"2023-01-04","IntPS_NSA__Patient__c":"'+patient[0].Id+'","IntPS_NSA__Provider_Name__c":"ROBERT SPRAGUE","IntPS_NSA__Provider_NPI_Number__c":"1164604591","IntPS_NSA__Provider_Billing_Street__c":"703 RIVERWAY PL","IntPS_NSA__Provider_Billing_City__c":"BEDFORD","IntPS_NSA__Provider_Billing_State__c":"NH","IntPS_NSA__Provider_Billing_Postal_Code__c":"031106768","IntPS_NSA__Provider_Network__c":"In-Network","IntPS_NSA__Eligibility__c":"'+patientInfo.get('Eligibility')[0].Id+'"}';
        String procedures='[{"serviceDate":"2023-01-04", "Code":"99730","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"None of the above","PreventativeOption":"None of the above","PlaceOfService":"11"},{"Code":"0410","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"Preventative Services","PreventativeOption":"Preventative Services","PlaceOfService":"11"}]';
        String result=EOBEntryFormController.serviceLineInsert(claimFields, procedures, '1164604591', Date.newInstance(2022, 12,27), networks, 'In-Network', tpaAcro, networkNames, 'aazzi@integratedpayorsolutions.com', patient[0].Id, outOfNetworkNames, '031106768',patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,availableNetworks,'2.0');
		String pdf=EOBEntryFormController.getPdfFileAsBase64String(result,false);
       	Boolean calculation=EOBEntryFormController.triggerCalculation(result, patient[0].Id, 'aazzi@integratedpayorsolutions.com');
        ApexPages.currentPage().getParameters().put('id', result);
		AdvancedEOBController  testAccPlan = new AdvancedEOBController();
		testAccPlan.getEOB();
        testAccPlan.getHealthPlan();
        test.stopTest();
    }
    /*@IsTest
    public static void createEOBSuccess() {
		prepareTestdata(false,false);
        Contact cont=[Select Id from Contact where Name='Mario Naharis' LIMIT 1];
          test.startTest();
        List<IntPS__Patient__c> patient=EOBEntryFormController.getPatient(cont.Id);
       // List<IntPS__Patient__c> dependents=EOBEntryFormController.getPatientDependents(patient.Id);
        String tpaAcro=EOBEntryFormController.getTPAAcro('BSI Companies');
        List<String> patientIds=new List<String>();
        patientIds.add(patient[0].Id);
        Map<String,List<IntPS__Eligibility__c>> patientInfo=EOBEntryFormController.getPatientInformation(patientIds,Date.newInstance(2022, 12,27),false);
        List<IntPS_NSA__Health_Plan_Content_Network__c> networks=EOBEntryFormController.getNetworksDetails(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,patient[0].Id);
        Boolean hasOutOfNetwork=EOBEntryFormController.hasOutOfNetwork(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);
        List<String>networkNames = new List<String>();
        List<String> outOfNetworkNames=new List<String>();
        for(IntPS_NSA__Health_Plan_Content_Network__c hpc:networks){
            networkNames.add(hpc.IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
             if(hpc.IntPS_NSA__RbP__c){
                outOfNetworkNames.add(hpc.Id);
            }
        }
        List<IntPS__Health_Plan_Content__c> hpcs=EOBEntryFormController.getHPCList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);

		List<IntPS__Health_Plan_Item__c> hpis=EOBEntryFormController.getHPIList(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, hpcs[0].Id);
        List<EOBEntryFormController.Providers> providers=EOBEntryFormController.checkExistingNPI('1164604591', true, false, networkNames, tpaAcro, hasOutOfNetwork);
        List<EOBEntryFormController.Providers> providersWithName=EOBEntryFormController.checkExistingNPI('Tania', false, true, networkNames, tpaAcro, hasOutOfNetwork);
       	List<String> availableNetworks=providers[0].availableNetworksForProvider;
        List<EOBEntryFormController.ProceduresFiltered> procedureCodes=EOBEntryFormController.getProcedureCodes('11730', true, false, patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, 'In-Network',false,'2.0');
        String claimFields='{"aServiceDate__c":"a","Provider_Network__c":"In-Network","Provider_Account_Name__c":"ROBERT SPRAGUE","Patient__c":"'+patient[0].Id+'","Guarantor__c":"a","IntPS_NSA__Service_Date__c":"2023-01-04","IntPS_NSA__Patient__c":"'+patient[0].Id+'","IntPS_NSA__Provider_Name__c":"ROBERT SPRAGUE","IntPS_NSA__Provider_NPI_Number__c":"1164604591","IntPS_NSA__Provider_Billing_Street__c":"703 RIVERWAY PL","IntPS_NSA__Provider_Billing_City__c":"BEDFORD","IntPS_NSA__Provider_Billing_State__c":"NH","IntPS_NSA__Provider_Billing_Postal_Code__c":"031106768","IntPS_NSA__Provider_Network__c":"In-Network","IntPS_NSA__Eligibility__c":"'+patientInfo.get('Eligibility')[0].Id+'"}';
        String procedures='[{"serviceDate":"2023-01-04","Code":"11730","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"Preventative Services","PreventativeOption":"Preventative Services","PlaceOfService":"22"},{"Code":"11730","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"Preventative Services","PreventativeOption":"Preventative Services","PlaceOfService":"11"}]';
        String result=EOBEntryFormController.serviceLineInsert(claimFields, procedures, '1164604591', Date.newInstance(2022, 12,27), networks, 'In-Network', tpaAcro, networkNames, 'aazzi@integratedpayorsolutions.com', patient[0].Id, outOfNetworkNames, '031106768',patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,availableNetworks,'2.0');
		String pdf=EOBEntryFormController.getPdfFileAsBase64String(result,false);
       	Boolean calculation=EOBEntryFormController.triggerCalculation(result, patient[0].Id, 'aazzi@integratedpayorsolutions.com');
        ApexPages.currentPage().getParameters().put('id', result);
		AdvancedEOBController  testAccPlan = new AdvancedEOBController();
		testAccPlan.getEOB();
        testAccPlan.getHealthPlan();
        test.stopTest();
    }*/    
      @IsTest
    public static void createEOBError() {
		prepareTestdata(false,false);
        Contact cont=[Select Id from Contact where Name='Mario Naharis' LIMIT 1];
          test.startTest();
        List<IntPS__Patient__c> patient=EOBEntryFormController.getPatient(cont.Id);
       // List<IntPS__Patient__c> dependents=EOBEntryFormController.getPatientDependents(patient.Id);
        String tpaAcro=EOBEntryFormController.getTPAAcro('BSI Companies');
         List<String> patientIds=new List<String>();
        patientIds.add(patient[0].Id);
        Map<String,List<IntPS__Eligibility__c>> patientInfo=EOBEntryFormController.getPatientInformation(patientIds,Date.newInstance(2022, 12,27),false);
        List<IntPS_NSA__Health_Plan_Content_Network__c> networks=EOBEntryFormController.getNetworksDetails(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,patient[0].Id);
        Boolean hasOutOfNetwork=EOBEntryFormController.hasOutOfNetwork(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);
        List<String>networkNames = new List<String>();
        List<String> outOfNetworkNames=new List<String>();
        for(IntPS_NSA__Health_Plan_Content_Network__c hpc:networks){
            networkNames.add(hpc.IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
             if(hpc.IntPS_NSA__RbP__c){
                outOfNetworkNames.add(hpc.Id);
            }
        }

        List<EOBEntryFormController.Providers> providers=EOBEntryFormController.checkExistingNPI('1164604591', true, false, networkNames, tpaAcro, hasOutOfNetwork);
         List<String> availableNetworks=providers[0].availableNetworksForProvider;
        List<EOBEntryFormController.ProceduresFiltered> procedureCodes=EOBEntryFormController.getProcedureCodes('11730', true, false, patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, 'In-Network',false,'2.0');
       String claimFields='{"aServiceDate__c":"a","Provider_Network__c":"In-Network","Provider_Account_Name__c":"ROBERT SPRAGUE","Patient__c":"'+patient[0].Id+'","Guarantor__c":"a","IntPS_NSA__Service_Date__c":"2023-01-04","IntPS_NSA__Patient__c":"'+patient[0].Id+'","IntPS_NSA__Provider_Name__c":"ROBERT SPRAGUE","IntPS_NSA__Provider_NPI_Number__c":"1164604591","IntPS_NSA__Provider_Billing_Street__c":"703 RIVERWAY PL","IntPS_NSA__Provider_Billing_City__c":"BEDFORD","IntPS_NSA__Provider_Billing_State__c":"NH","IntPS_NSA__Provider_Billing_Postal_Code__c":"031106768","IntPS_NSA__Provider_Network__c":"In-Network","IntPS_NSA__Eligibility__c":"'+patientInfo.get('Eligibility')[0].Id+'"}';
        String procedures='[{"serviceDate":"2023-01-04","Code":"11730","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"Preventative Services","PreventativeOption":"Preventative Services","PlaceOfService":"11"}]';
 
        EOBEntryFormController.ErrorWrapper sqlerror=EOBEntryFormController.handleSQLError(networkNames, '1164604591', tpaAcro, procedures, true, claimFields, 'aazzi@integratedpayorsolutions.com', patient[0].Id, 'errorMessage',Date.newInstance(2022, 12,27),patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,'In-Network',availableNetworks,'2.0');

        test.stopTest();
    }
     @IsTest
    public static void createEOBSRbp() {
		prepareTestdata(false,false);
        Contact cont=[Select Id from Contact where Name='Mario Naharis' LIMIT 1];
        IntPS__Health_Plan_Content__c hpctoUpdate = [Select Id,IntPS__Health_Plan__c from IntPS__Health_Plan_Content__c where IntPS__Provider_Network__c = 'In-Network'];
    Id emptyId = null;
    hpctoUpdate.IntPS__Health_Plan__c =emptyId;
        update hpctoUpdate;
          test.startTest();
        List<IntPS__Patient__c> patient=EOBEntryFormController.getPatient(cont.Id);
       // List<IntPS__Patient__c> dependents=EOBEntryFormController.getPatientDependents(patient.Id);
        String tpaAcro=EOBEntryFormController.getTPAAcro('BSI Companies');
         List<String> patientIds=new List<String>();
        patientIds.add(patient[0].Id);
        Map<String,List<IntPS__Eligibility__c>> patientInfo=EOBEntryFormController.getPatientInformation(patientIds,Date.newInstance(2022, 12,27),false);
        List<IntPS_NSA__Health_Plan_Content_Network__c> networks=EOBEntryFormController.getNetworksDetails(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,patient[0].Id);
        Boolean hasOutOfNetwork=EOBEntryFormController.hasOutOfNetwork(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);
        List<String>networkNames = new List<String>();
        List<String> outOfNetworkNames=new List<String>();
        for(IntPS_NSA__Health_Plan_Content_Network__c hpc:networks){
            networkNames.add(hpc.IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
             if(hpc.IntPS_NSA__RbP__c){
                outOfNetworkNames.add(hpc.Id);
            }
        }

        List<EOBEntryFormController.Providers> providers=EOBEntryFormController.checkExistingNPI('1164604591', true, false, networkNames, tpaAcro, hasOutOfNetwork);
        List<String> availableNetworks=providers[0].availableNetworksForProvider;
        List<EOBEntryFormController.ProceduresFiltered> procedureCodes=EOBEntryFormController.getProcedureCodes('11730', true, false, patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, 'Out-Of-Network',false,'2.0');
        String claimFields='{"aServiceDate__c":"a","Provider_Network__c":"Out-Of-Network","Provider_Account_Name__c":"ROBERT SPRAGUE","Patient__c":"'+patient[0].Id+'","Guarantor__c":"a","IntPS_NSA__Service_Date__c":"2023-01-04","IntPS_NSA__Patient__c":"'+patient[0].Id+'","IntPS_NSA__Provider_Name__c":"ROBERT SPRAGUE","IntPS_NSA__Provider_NPI_Number__c":"1164604591","IntPS_NSA__Provider_Billing_Street__c":"703 RIVERWAY PL","IntPS_NSA__Provider_Billing_City__c":"BEDFORD","IntPS_NSA__Provider_Billing_State__c":"NH","IntPS_NSA__Provider_Billing_Postal_Code__c":"031106768","IntPS_NSA__Provider_Network__c":"Out-Of-Network","IntPS_NSA__Eligibility__c":"'+patientInfo.get('Eligibility')[0].Id+'"}';
        String procedures='[{"serviceDate":"2023-01-04","Code":"0410","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"Preventative Services","PreventativeOption":"Preventative Services","PlaceOfService":"11"}]';
        String result=EOBEntryFormController.serviceLineInsert(claimFields, procedures, '1164604591', Date.newInstance(2022, 12,27), networks, 'Out-Of-Network', tpaAcro, networkNames, 'aazzi@integratedpayorsolutions.com', patient[0].Id, outOfNetworkNames, '031106768',patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,availableNetworks,'2.0');
		String pdf=EOBEntryFormController.getPdfFileAsBase64String(result,false);
       	Boolean calculation=EOBEntryFormController.triggerCalculation(result, patient[0].Id, 'aazzi@integratedpayorsolutions.com');
        
        test.stopTest();
    }
     @IsTest
    public static void createEOBSRbpUCR() {
		prepareTestdata(true,false);
        Contact cont=[Select Id from Contact where Name='Mario Naharis' LIMIT 1];
        IntPS__Health_Plan_Content__c hpctoUpdate = [Select Id,IntPS__Health_Plan__c from IntPS__Health_Plan_Content__c where IntPS__Provider_Network__c = 'In-Network'];
    Id emptyId = null;
    hpctoUpdate.IntPS__Health_Plan__c =emptyId;
        update hpctoUpdate;
        IntPS_NSA__Health_Plan_Content_Network__c hpcnOONtoUpdate=[Select Id,IntPS_NSA__RbP_Basis__c from IntPS_NSA__Health_Plan_Content_Network__c where IntPS_NSA__RbP_Basis__c='Medicare'];
        
        hpcnOONtoUpdate.IntPS_NSA__RbP_Basis__c='UCR';
        update hpcnOONtoUpdate;
          test.startTest();
        List<IntPS__Patient__c> patient=EOBEntryFormController.getPatient(cont.Id);
      //  List<IntPS__Patient__c> dependents=EOBEntryFormController.getPatientDependents(patient.Id);
        String tpaAcro=EOBEntryFormController.getTPAAcro('BSI Companies');
         List<String> patientIds=new List<String>();
        patientIds.add(patient[0].Id);
        Map<String,List<IntPS__Eligibility__c>> patientInfo=EOBEntryFormController.getPatientInformation(patientIds,Date.newInstance(2022, 12,27),false);
        List<IntPS_NSA__Health_Plan_Content_Network__c> networks=EOBEntryFormController.getNetworksDetails(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,patient[0].Id);
        Boolean hasOutOfNetwork=EOBEntryFormController.hasOutOfNetwork(patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c);
        List<String>networkNames = new List<String>();
        List<String> outOfNetworkNames=new List<String>();
        for(IntPS_NSA__Health_Plan_Content_Network__c hpc:networks){
            networkNames.add(hpc.IntPS_NSA__Network__r.IntPS_NSA__External_ID__c);
             if(hpc.IntPS_NSA__RbP__c){
                outOfNetworkNames.add(hpc.Id);
            }
        }

        List<EOBEntryFormController.Providers> providers=EOBEntryFormController.checkExistingNPI('1164604591', true, false, networkNames, tpaAcro, hasOutOfNetwork);
        List<String> availableNetworks=providers[0].availableNetworksForProvider;
        List<EOBEntryFormController.ProceduresFiltered> procedureCodes=EOBEntryFormController.getProcedureCodes('11730', false, true, patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c, 'Out-Of-Network',false,'2.0');
        String claimFields='{"aServiceDate__c":"a","Provider_Network__c":"Out-Of-Network","Provider_Account_Name__c":"ROBERT SPRAGUE","Patient__c":"'+patient[0].Id+'","Guarantor__c":"a","IntPS_NSA__Service_Date__c":"2023-01-04","IntPS_NSA__Patient__c":"'+patient[0].Id+'","IntPS_NSA__Provider_Name__c":"ROBERT SPRAGUE","IntPS_NSA__Provider_NPI_Number__c":"1164604591","IntPS_NSA__Provider_Billing_Street__c":"703 RIVERWAY PL","IntPS_NSA__Provider_Billing_City__c":"BEDFORD","IntPS_NSA__Provider_Billing_State__c":"NH","IntPS_NSA__Provider_Billing_Postal_Code__c":"031106768","IntPS_NSA__Provider_Network__c":"Out-Of-Network","IntPS_NSA__Eligibility__c":"'+patientInfo.get('Eligibility')[0].Id+'"}';
        String procedures='[{"serviceDate":"2023-01-04","Code":"11730","Description":"REMOVAL OF NAIL PLATE","Quantity":1,"ProviderType":"My Primary Care Physician (PCP)","PregnancyOption":"Preventative Services","PreventativeOption":"Preventative Services","PlaceOfService":"11"}]';
        String result=EOBEntryFormController.serviceLineInsert(claimFields, procedures, '1164604591', Date.newInstance(2022, 12,27), networks, 'Out-Of-Network', tpaAcro, networkNames, 'aazzi@integratedpayorsolutions.com', patient[0].Id, outOfNetworkNames, '031106768',patientInfo.get('Eligibility')[0].IntPS__Health_Plan__c,availableNetworks,'2.0');
		String pdf=EOBEntryFormController.getPdfFileAsBase64String(result,false);
       	Boolean calculation=EOBEntryFormController.triggerCalculation(result, patient[0].Id, 'aazzi@integratedpayorsolutions.com');
        Boolean jira=EOBEntryFormController.createJiraTicket(result, 'test', false);
        test.stopTest();
    }
}