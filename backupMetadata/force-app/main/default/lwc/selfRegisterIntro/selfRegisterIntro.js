import { LightningElement,api,track } from 'lwc';
import getUser from '@salesforce/apex/SelfRegisterIntroController.getUser';
import updateUser from '@salesforce/apex/SelfRegisterIntroController.updateUser';
import afterConfirm from './afterConfirm.html';
import selfRegisterTemplate from './selfRegisterIntro.html';

// import successMessage from '@salesforce/label/c.SelfRegisterSuccess';
// import failMessage from '@salesforce/label/c.SelfRegisterFail';
export default class SelfRegisterIntro extends LightningElement {
    @track showModal = false;
    @track showAfterModal = false;
    @track showAfterErrorModal = false;
    @track showAfterProcessModal = false;
    @track isLoading = false;
    @track updateSuccess = false;
    @track updateFail = false;
    @api successMessage = 'Thank you. Your updates have been saved. You should receive an email within 10 minutes confirming your access. If you do not receive an email, please contact Customer Support at the number on the back of your member card.';
    @api failMessage = 'Please refresh the page and resubmit your information.  If the error persists, contact Customer Support at the number on the back of your member card.';
    @api enforceMemberId = false;
    @api batchInProcessMessage = 'We are processing your request. Please wait 30 minutes from the initial request before trying again. \n\nYou will receive an email with the status of your request. If you continue to experience connection problems, please contact Customer Support at the number on the back of your member card';
    @api noMatchMessage = 'Unfortunately we could not find a member that matches the information you entered. Please check your email for further information and contact Customer Support at the number on the back of your member card.';
    @api avoidedProfileName = 'System Administrator';
    user = {};
    connectedCallback(){
        this.isLoading = true;
        this.getUserInfo();
        
    }

    render() {
        return this.showAfterModal? afterConfirm : selfRegisterTemplate;
    }

    getUserInfo(){
        getUser()
        .then(result => {
            this.user = result[0];
            // console.log(this.user);
            // console.log(this.user.Confirmed_User_Info__c);
            if (this.user.Profile.Name == this.avoidedProfileName) {
                this.isLoading = false;
                return this.render();
            }
            if (this.user.Confirmed_User_Info__c === false) {
                // console.log('Show Modal');
                this.showModal = true;
            }else{
                this.showModal = false;
                if (this.user.Contact?.Patient_Match_Status__c === 'Failed') {
                    this.showAfterModal = true;
                    this.showAfterErrorModal = true;
                }else if(this.user.Contact?.Patient_Match_Status__c !== 'Successful'){
                    this.showAfterModal = true;
                    this.showAfterProcessModal = true;
                }

            }
            this.isLoading = false;
            this.render();
            
        })
        .catch(error => {
            console.error(error);
        });
    }

    updateUser(event){
        this.isLoading = true;
        this.showModal = false;
        event.preventDefault();
        this.user.FirstName = event.detail.fields.FirstName;
        this.user.LastName = event.detail.fields.LastName;
        this.user.Member_ID__c = event.detail.fields.Member_ID__c;
        this.user.Date_Of_Birth__c = event.detail.fields.Date_Of_Birth__c;
        updateUser({
            user:this.user
        })
        .then(result => {
            if (result=='Success') {
                this.isLoading = false;
                this.updateSuccess = true;
            }
        })
        .catch(error => {
            console.error(error);
            this.isLoading = false;
            // this.showModal = true;
            this.updateFail = true;
            
        });
    }

    closeModal(event){
        this.updateSuccess = false;
        this.updateFail = false;
    }

}