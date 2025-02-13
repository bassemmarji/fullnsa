public class NSA_DeactivateGroup {
       @InvocableMethod(label = 'Terminate Eligibilities')
       public static List<resultParameters> terminate_eligibilities(List<requestParameters> reqParams){
           		  System.debug('Calling Terminate Eligibilities...');
                  System.debug('Request Parameters >> ' + reqParams);
           		  System.debug('Request Parameters Account Id >> ' + reqParams[0].accountId);
           		  System.debug('Request Parameters Termination Date >> ' + reqParams[0].terminationDate);
           
                  List <IntPS__Eligibility__c> l_eligibilities = new List<IntPS__Eligibility__c>();
				  for (IntPS__Eligibility__c  elg:[Select ID, NAME, IntPS__Begin_Date__c, IntPS__Term_Date__c
                                                         ,IntPS__Health_Plan__c 
                                                     From IntPS__Eligibility__c  
                                                    Where IntPS__Health_Plan__r.IntPS__Employer__c  = :reqParams[0].accountId
                                                      And IntPS__Term_Date__c = NULL
                                                  ]){
                       elg.IntPS__Term_Date__c = reqParams[0].terminationDate;
                       l_eligibilities.add(elg);
                  }
                  if (!l_eligibilities.isEmpty()){
                      update l_eligibilities;
                      
                      //Get Count of Closed eligibilities by Health Plan ID
                      Map<Id, Integer> mrp = new Map<Id, Integer>();
                      for (IntPS__Eligibility__c  relg: l_eligibilities){
                          if (!mrp.containsKey(relg.IntPS__Health_Plan__c)) {    
                              mrp.put(relg.IntPS__Health_Plan__c , 1);
                          }
                          else {
                              mrp.put(relg.IntPS__Health_Plan__c,mrp.get(relg.IntPS__Health_Plan__c)+1);
                          }
                      }
                      
                      //Formalize return Variable
                      List<resultParameters> rpl = new List<resultParameters>();
                      for (IntPS__Health_Plan__c  hp:[Select ID, IntPS__ExternalID__c, NAME, IntPS__Begin_Date__c, IntPS__Term_Date__c 
                                   From IntPS__Health_Plan__c
                                  Where Id in :mrp.keySet()
                                                     ]){
                           resultParameters rp = new resultParameters();
                           rp.hpId         = hp.Id;
                           rp.hpExternalId = hp.IntPS__ExternalID__c;                        
                           rp.countUpdElg  = mrp.get(hp.Id);                       
                           rpl.add(rp);
                      }
                      return rpl;
                  }
                  return Null;
       }
	       
       public class requestParameters {
        	@InvocableVariable(required=true)
        	public Id accountId;
                
        	@InvocableVariable(required=true)
        	public date terminationDate;
       }

       public class resultParameters {
        	@InvocableVariable
        	public Id hpId;
           
        	@InvocableVariable
        	public String hpExternalId;
           
            @InvocableVariable
        	public integer countUpdElg;
       }

}