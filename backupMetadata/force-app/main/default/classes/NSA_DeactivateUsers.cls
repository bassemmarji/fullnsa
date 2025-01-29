public class NSA_DeactivateUsers {
       @future(callout=true)
       public static void deactivate_async_users(List<Id> contactsIds){
           		  System.debug('Calling Deactivate Async Users...');
                  System.debug('deactivate_async_users Parameters >> ' + contactsIds);

                  List <User> l_users = new List<User>();
				  for (User  usr:[Select Id, Name, Email, UserName, AccountId, ContactId,IsActive,IsPortalEnabled 
                                    From User 
                                   Where ContactId in :contactsIds
                                     And IsActive = True
                                 ]){
                       usr.IsActive        = False;
                       usr.IsPortalEnabled = False;        
                       l_users.add(usr);
                  }
                  if (!l_users.isEmpty()){
                      update l_users;
                  }
       }
     
       @InvocableMethod(label = 'Deactivate Users Based On Their Contacts Ids')
       public static List<resultParameters> deactivate_users(List<requestParameters> reqParams){
           		  System.debug('Calling Deactivate Users...');
                  System.debug('Request Parameters >> ' + reqParams);
           		  System.debug('Request Parameters contactsList >> ' + reqParams[0].contactsList);
                  List<Id> contactsIds = reqParams[0].contactsList;
         		  if (!contactsIds.isEmpty()) {
                      //Get List of Users out of contacts list
               		  List<User> l_users = [Select Id, Name, Email, UserName, AccountId, ContactId,IsActive,IsPortalEnabled 
                                           From User 
                                           Where ContactId in :reqParams[0].contactsList
                                             And IsActive = True
                                        ];
 
           		 	  if (!l_users.isEmpty())
                      {
                          deactivate_async_users(contactsIds);
                  
                          resultParameters rp = new resultParameters();
                          rp.countUpdUsr = l_users.size();
                          List<resultParameters> rpl = new List<resultParameters>();
                          rpl.add(rp);
                          return rpl;
                      }
           		  }

                  return Null;

       }
	       
       public class requestParameters {
        	@InvocableVariable(required=true)
        	public list<Id> contactsList;
       }

       public class resultParameters {
        	@InvocableVariable
        	public integer countUpdUsr;
       }
}