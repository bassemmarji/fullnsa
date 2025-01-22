/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-21-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing  class HelpMainPageController {
    
 public PageReference openOverview() {
    PageReference p = new PageReference('/apex/UserInstrunctionOverview');
   // p.setRedirect(true);
return p;
    
 }
 public PageReference openStepByStep() {
    PageReference p = new PageReference('/apex/UserInstrunctionStepByStep');
    p.setRedirect(true);
return p;
    
 }
 public PageReference openFAQ() {
    PageReference p = new PageReference('/apex/UserInstrunctionFAQ');
    p.setRedirect(true);
return p;
    
 }
}