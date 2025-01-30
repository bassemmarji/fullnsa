/**
 * @description       : 
 * @author            : Anthony Azzi
 * @group             : DC Risk Solutions
 * @last modified on  : 01-22-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
public with sharing class HelpMainPageControllerTest {

        @IsTest
    public static void openRessources() {
		HelpMainPageController  testAccPlan = new HelpMainPageController();
		testAccPlan.openOverview();
        testAccPlan.openFAQ();
        testAccPlan.openStepByStep();
    }
     
    
}