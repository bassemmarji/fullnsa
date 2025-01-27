import { LightningElement,track,wire } from 'lwc';
import USER_ID from "@salesforce/user/Id";
import orgName from '@salesforce/label/c.NSA_OrgName';
import Acceptance from "@salesforce/schema/User.T_C_Acceptance__c";
import Patient_Match_Status__c from "@salesforce/schema/User.Contact.Patient_Match_Status__c";
import { getRecord } from "lightning/uiRecordApi";
import aknowledgeUser from "@salesforce/apex/disclaimerController.aknowledgeUser";
import uId from '@salesforce/user/Id';


export default class disclaimerAknowledgment extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    @track userId = uId;
    @track orgName=orgName;
    @wire(getRecord, { recordId: USER_ID, fields: [Acceptance,Patient_Match_Status__c]})
    getUserProfileResponse({error, data}) {
        console.log('data '+JSON.stringify(data));
            if (data) {
                console.log('data '+JSON.stringify(data));
                console.log('T_C_Acceptance__c '+data.fields.T_C_Acceptance__c.value);
                console.log('Patient_Match_Status__c '+data.fields.Contact.value.fields.Patient_Match_Status__c.value);

               if(data.fields.T_C_Acceptance__c.value || data.fields.Contact.value.fields.Patient_Match_Status__c.value!='Successful'){
                    this.isModalOpen=false;
                    console.log('model opened? '+this.isModalOpen);     
                 }
                 else{
                    this.isModalOpen=true;
                    console.log('model opened? '+this.isModalOpen);

                 }
        }    
        else{
            console.log('error getting user details in aknowledgment'+JSON.stringify(error));
        }           
        }
   
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        aknowledgeUser({
            userId : this.userId
        })
        .then(result => {
            this.isModalOpen = false;

        })
        .catch(error => {
        });
    }
}