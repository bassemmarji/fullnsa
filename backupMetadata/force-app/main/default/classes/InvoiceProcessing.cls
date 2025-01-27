public class InvoiceProcessing {
    private final String accName = 'BSI';
    
    private class cElg{
        Id      ElgID;
        Id 	   PatientID;
        Id 	   HpID;
     	String  Hp_ExternalID;
     	String  Hp_Name;
     	Double  Third_Party_PEPM_Rate;
     	Date    Elg_Begin_Date;
     	Date    Elg_Term_Date;

        Integer RBP; 
        Double  RBP_PEPM_Rate;
    }
    
    private class cPatient {
        private Id         PatientID;
        private String     MemberID;
        private Id         EmployerID;
        private List<cElg> lElg;
        
        private Integer    get_Count_Eligibilities(){
            if (lElg != NULL){
               return lElg.size();
            }
            return 0;
        }
        
        private Integer    get_Count_RBP(){
            if (lElg != NULL){
                Integer tot_RBP = 0;
                for (cElg elg:lElg){
                    if (elg.RBP > 0){
                        tot_RBP += elg.RBP;
                    }
                }
                return tot_RBP;
            }
            return 0;
        }
        
        private Double     get_Total_Third_Party_PEPM_Rate(){
               if (lElg != NULL){
                   Double total_Third_Party_PEPM_Rate = 0;
                   for (cElg elg:lElg){
                       if (elg.RBP_PEPM_Rate > 0){
                       	   total_Third_Party_PEPM_Rate += elg.RBP_PEPM_Rate;
                       }    
                   }
                   return total_Third_Party_PEPM_Rate;
               }
               return 0;
        }
    }
    
    private class cEmployer {
        Id         EmployerID;
        String     Employer_ExternalID;
        String     Employer_Name;
        List<cPatient> lPat;
        
        private Integer get_Count_Eligibilities(){
            if (lPat != NULL){
                Integer tot_Elg = 0;
                for (cPatient pat:lPat){
                    tot_Elg += pat.get_Count_Eligibilities();
                }
                return tot_Elg;
            }
            return 0;
        }
        
        private Integer get_Count_RBP(){
            if (lPat != NULL){
                Integer tot_RBP = 0;
                for (cPatient pat:lPat){
                     tot_RBP += pat.get_Count_RBP();
                }
                return tot_RBP;
            }
            return 0;
        }
        
        private Double get_Total_Third_Party_PEPM_Rate(){
               if (lPat != NULL){
                   Double total_Third_Party_PEPM_Rate = 0;
                   for (cPatient pat:lPat){
                       	total_Third_Party_PEPM_Rate += pat.get_Total_Third_Party_PEPM_Rate();
                   }
                   return total_Third_Party_PEPM_Rate;
               }
               return 0;
        }
        
    }
    
    Date lastDayOfCurrentMonth = NULL;
        
    //Calculate the last day of current month
    private Date getLastDayOfCurrentMonth(){
        Integer numberOfDays = Date.daysInMonth(System.today().year(), System.today().month());
		Date lastDayOfCurrentMonth = Date.newInstance(System.today().year(), System.today().month(), numberOfDays);
        return lastDayOfCurrentMonth;
    }

    //Query Patients
    private List<IntPS__Patient__c> queryPatients(Date lastDayOfCurrentMonth){
            List<IntPS__Patient__c> l_patients = [ 
                 Select Id
                      , Name
                      , IntPS__Member_Id__c
                      , IntPS__Employer__c
                      , IntPS__Employer__r.IntPS__External_ID__c
                      , IntPS__Employer__r.Name
                   From IntPS__Patient__c
                  Where Id in (Select IntPS__Patient__c 
                                 From IntPS__Eligibility__c 
                                Where (IntPS__Term_Date__c = NULL or IntPS__Term_Date__c >= :lastDayOfCurrentMonth)
                              )
                    And IntPS__Plan_Member__c = NULL
                    And IntPS__Member_Id__c  != NULL
                    And IntPS__Employer__r.IntPS__External_ID__c != 'Test'
               Order by IntPS__Employer__r.IntPS__External_ID__c
            ];
            return l_patients;
    }
    
    //Query RBP Plans
    private Set<Id> queryRBPPlans(){
            Set<Id> s_RbpPlans = new Set<Id>();
            List<AggregateResult> l_result = [ 
                 Select IntPS_NSA__Health_Plan_Content__r.IntPS__Health_Plan__c HP_Id
 				   From IntPS_NSA__Health_Plan_Content_Network__c
 				  Where IntPS_NSA__Patient__c = NULL
                    AND IntPS_NSA__Health_Plan_Content__c != NULL
                    AND IntPS_NSA__RbP__c = True
                    AND IntPS_NSA__Health_Plan_Content__r.IntPS__Health_Plan__c != NULL
               Group By IntPS_NSA__Health_Plan_Content__r.IntPS__Health_Plan__c
            ];
            for (AggregateResult rec:l_result){
            	s_RbpPlans.add((Id)rec.get('HP_Id'));
            }
            return s_RbpPlans;
    }
    
    //Query Eligibilities
    private List<IntPS__Eligibility__c> queryEligibilities(Date lastDayOfCurrentMonth){
            List<IntPS__Eligibility__c> l_eligibilities = [ 
                 Select Id
                      , IntPS__Patient__c
     				  , IntPS__Health_Plan__c
     				  , IntPS__Health_Plan__r.IntPS__ExternalID__c
     				  , IntPS__Health_Plan__r.Name
     				  , IntPS__Health_Plan__r.Third_Party_PEPM_Rate__c
     				  , IntPS__Begin_Date__c
     				  , IntPS__Term_Date__c
  				   From IntPS__Eligibility__c   				
                  Where (IntPS__Term_Date__c = NULL or IntPS__Term_Date__c >= :lastDayOfCurrentMonth)
  					And IntPS__Patient__r.IntPS__Plan_Member__c = NULL
  					And IntPS__Patient__r.IntPS__Member_Id__c  != NULL
  					And IntPS__Patient__r.IntPS__Employer__r.IntPS__External_ID__c != 'Test'
			   Order by IntPS__Patient__c
            ];
            return l_eligibilities;
    }
	
    private List<cEmployer> merge_DF(List<IntPS__Patient__c> l_patients
                                     , List<IntPS__Eligibility__c> l_eligibilities
                                     , Set<Id> s_RbpPlans)
    {
          Map<Id, List<cElg>> elgMap = new Map<Id, List<cElg>>();

          for (IntPS__Eligibility__c elg:l_eligibilities){
             cElg ce   		          = new cElg();
            
        	 ce.ElgID  		          = elg.Id;
             ce.PatientID             = elg.IntPS__Patient__c;
             ce.HpID                  = elg.IntPS__Health_Plan__c;
			 ce.Hp_ExternalID         = elg.IntPS__Health_Plan__r.IntPS__ExternalID__c;
     	     ce.Hp_Name               = elg.IntPS__Health_Plan__r.Name;
     		 ce.Third_Party_PEPM_Rate = elg.IntPS__Health_Plan__r.Third_Party_PEPM_Rate__c;
     	     ce.Elg_Begin_Date        = elg.IntPS__Begin_Date__c;
     	     ce.Elg_Term_Date         = elg.IntPS__Term_Date__c;
        	 ce.RBP = 0;
             if(s_RbpPlans.contains(ce.HpID)){ 
                ce.RBP = 1; 
             }
             ce.RBP_PEPM_Rate         = ce.Third_Party_PEPM_Rate * ce.RBP;
             
             if(elgMap.containsKey(ce.PatientID)){
       		   elgMap.get(ce.PatientID).add(ce);
   			 } else {
       		   elgMap.put(ce.PatientID, new List<cElg>{ce});
    		 }
        }
        
        Map<Id, cEmployer> employerMap = new Map<Id, cEmployer>();
        //List<cPatient> l_cPatient = new List<cPatient>();
        for (IntPS__Patient__c pat:l_patients)
        {
             cPatient cPat      = new cPatient();
             cPat.PatientID     = pat.Id; 
             cPat.MemberID      = pat.IntPS__Member_Id__c; 
             cPat.EmployerID    = pat.IntPS__Employer__c;
             
             if (elgMap.containsKey(cPat.PatientID)){
                 cPat.lElg      = elgMap.get(cPat.PatientID);
             }
 			 
             if (employerMap.containsKey(cPat.EmployerID)){
               cEmployer cEmp           =  (cEmployer)employerMap.get(cPat.EmployerID).lPat.add(cPat); 
             } else {
				cEmployer cEmp           = new cEmployer();
                cEmp.EmployerID          = pat.IntPS__Employer__c;
                cEmp.Employer_ExternalID = pat.IntPS__Employer__r.IntPS__External_ID__c;
                cEmp.Employer_Name       = pat.IntPS__Employer__r.Name; 
                cEmp.lPat                = new List<cPatient>{cPat};
                employerMap.put(pat.IntPS__Employer__c, cEmp);
             }
            
             //l_cPatient.add(cPat);
        }
        List<cEmployer> l_cEmployer = new List<cEmployer>();
        for (Id key : employerMap.keySet()) {
             l_cEmployer.add(employerMap.get(key));
		}

        
        return l_cEmployer;
    }
    
    private Map<Id, List<cPatient>> mapEmployerByPatient(List<cPatient> l_cPatient){
        	Map<Id, List<cPatient>> recordsMap = new Map<Id, List<cPatient>>();
        	for (cPatient pat: l_cPatient){
                if (!recordsMap.containsKey(pat.EmployerID)){
                    recordsMap.put(pat.EmployerID, new List<cPatient>());
                }
                recordsMap.get(pat.EmployerID).add(pat);
            }
        	return recordsMap;
    }
	
    private String buildCSV(List<cEmployer> l_cEmployer){
        String csvFile = NULL;
        String csvColumnHeader = 'Account External ID,Account Name,Count Of Patients,Count Of Eligibilities,Count of RBP Patients,Total Third Party PEPM Rate';
        List<String> csvDetails = new List<String>();
        if (l_cEmployer != NULL && !l_cEmployer.isEmpty()){         
            for (cEmployer cEmp:l_cEmployer){
                csvDetails.add(
                          //cEmp.EmployerID + ',' +
                          cEmp.Employer_ExternalID 
                  + ',' + '"' + cEmp.Employer_Name + '"'   
                  + ',' + cEmp.lPat.size()     //Count of patients - Enrollment
                  + ',' + cEmp.get_Count_Eligibilities() //Count of Enrollments
                  + ',' + cEmp.get_Count_RBP()   //Count of RBP
                  + ',' + cEmp.get_Total_Third_Party_PEPM_Rate()  //Total Third Party PEPM Rate      
                );
            }
        }
        csvFile = csvColumnHeader + '\n' + String.join(csvDetails,'\n');
        return csvFile;
    }
    
    private void createSFDoc(String csv){
        Datetime myDT       = Datetime.now();    
		String   myDTString = myDT.format('yyyy-MM');

        //Attach the Doc to BSI Account 
        Id accId = [Select Id, Name From Account Where Name = :accName Limit 1].Id;
        
        //String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        //Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String docName = 'Inv' + '-' + accName + '-' + myDTString;
        
        //Delete Old Document Version
		Delete[select id from ContentDocument where Title = :docName];
           
        //Insert ContentVersion
        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf(csv);
        cv.Title = docName;
        //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cv.ContentLocation= 'S';
        cv.PathOnClient= docName+ '.csv';
        cv.IsMajorVersion = true;
        //cv.OwnerId = acc.OwnerId;
        insert cv;
        
        //get the ContentDocumentId
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id LIMIT 1].ContentDocumentId;
 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conDocId;
        cdl.LinkedEntityId = accId;
        //V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cdl.ShareType = 'V';
        //AllUsers, InternalUsers, SharedUsers
        cdl.Visibility = 'AllUsers';
        //cdl.ParentId   = 
        insert cdl;
    }
    
    public void runProcess(){
           this.lastDayOfCurrentMonth = getLastDayOfCurrentMonth();
           System.debug('Last Day of Current Month =' + this.lastDayOfCurrentMonth);
           List<IntPS__Patient__c> l_patients = queryPatients(this.lastDayOfCurrentMonth);
           System.debug('List Of Patients Size =' + l_patients.size());
           Set<Id> s_RbpPlans = queryRBPPlans();
           System.debug('List Of RBP Plans Size =' + s_RbpPlans.size());
           List<IntPS__Eligibility__c> l_eligibilities = queryEligibilities(this.lastDayOfCurrentMonth);
           System.debug('List Of Eligibilities Size =' + l_eligibilities.size());
           if (l_patients.size() != l_eligibilities.size()){
               System.debug('List Of Patients Size != List Of Eligibilities Size, Check for Patients with Duplicate Eligibilities.');
           }
           else {
               System.debug('List Of Patients Size = List Of Eligibilities Size');
           }
           List<cEmployer> l_cEmployer = merge_DF(l_patients, l_eligibilities, s_RbpPlans);
           System.debug('List Of Employers Size =' + l_cEmployer.size());
        
           String csvFile = buildCSV(l_cEmployer);
           System.debug('CSV File =' + csvFile);
           createSFDoc(csvFile);
        
           
        
           /*
           for (cEmployer cEmp:l_cEmployer){
                System.debug(cEmp.EmployerID 
                     + ' ' + cEmp.Employer_ExternalID 
                     + ' ' + cEmp.Employer_Name
                     + ' ' + cEmp.lPat.size()     //Count of patients - Enrollment
                     + ' ' + cEmp.get_Count_Eligibilities() //Count of Enrollments
                     + ' ' + cEmp.get_Count_RBP()   //Count of RBP
                     + ' ' + cEmp.get_Total_Third_Party_PEPM_Rate()  //Total Third Party PEPM Rate      
                            );
           }
		   */

           //Map<Id, List<cPatient>> recordsMap = mapEmployerByPatient(l_cPatient);
           //Integer countEmployers = recordsMap.keySet().size();
           //System.debug('Count of Employers = '+ countEmployers);           
    }
}