public class NSA_DeactivatePlan {
       @InvocableMethod(label = 'Terminate Eligibilities')
       public static List<resultParameters> terminate_eligibilities(List<requestParameters> reqParams){
           		  
           	  System.debug('Calling Terminate Eligibilities...');
              System.debug('Request Parameters >> ' + reqParams);
           	  System.debug('Request Parameters hpList >> ' + reqParams[0].hpList);
           	  System.debug('Request Parameters Termination Date >> ' + reqParams[0].terminationDate);
              If (!reqParams[0].hpList.isEmpty())
              { 
                  List <IntPS__Eligibility__c> l_eligibilities = new List<IntPS__Eligibility__c>();
				  for (IntPS__Eligibility__c  elg:[Select ID, NAME, IntPS__Begin_Date__c, IntPS__Term_Date__c 
                                                     From IntPS__Eligibility__c  
                                                    Where IntPS__Health_Plan__c in :reqParams[0].hpList
                                                      And IntPS__Term_Date__c = NULL
                                                  ]){
                       elg.IntPS__Term_Date__c = reqParams[0].terminationDate;
                       l_eligibilities.add(elg);
                  }
                  if (!l_eligibilities.isEmpty()){
                      update l_eligibilities;
                      
                      resultParameters rp = new resultParameters();
                      rp.countUpdElg = l_eligibilities.size();
                      List<resultParameters> rpl = new List<resultParameters>();
                      rpl.add(rp);
                      
                      return rpl;
                  }
              }
              return Null;
       }
	       
       public class requestParameters {
        	@InvocableVariable(required=true)
        	public list<Id> hpList;
                
        	@InvocableVariable(required=true)
        	public date terminationDate;
       }

       public class resultParameters {
        	@InvocableVariable
        	public integer countUpdElg;
       }
}