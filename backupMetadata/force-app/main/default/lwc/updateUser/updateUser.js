import getUsers from '@salesforce/apex/UpdateUserController.getUsers';
import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateEmailAddress from '@salesforce/apex/UpdateUserController.updateEmailAddress';
import { RefreshEvent } from 'lightning/refresh';
export default class UpdateUser extends LightningElement {
    @api recordId;
    @track userRecordId;
    @track buttonActive = false;
    @track isLoading = false;
    @track hasUser = false;
    user = '';
    connectedCallback() {
        this.getUser();
    }
    getUser(){
        this.isLoading = true;
        getUsers({Id:this.recordId})
        .then(result=>{
            console.log( result[0].Id);
            this.userRecordId = result[0].Id;
            this.user = result[0];
            this.hasUser = true;
            this.isLoading = false;
        })
        .catch(error=>{
            console.error(error);
            this.isLoading = false;
        });
    }
    enableButton(event){
        this.buttonActive = true;
    }
    disableButton(){
        this.buttonActive = false;
    }
    updateEmail(event,email,userId){
        if (!email) {
            return;
        }
        updateEmailAddress({
            email:email,
            userId:userId
        })
        .then((result) => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Contact and Patient Email updated successfully.',
                variant: 'success'
            }));
            this.disableButton();
            this.isLoading = false;
            // this.dispatchEvent(new RefreshEvent());
        }).catch((err) => {
            console.error(err);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: JSON.stringify(err),
                variant: 'error'
            }));
            this.isLoading = false;
        });
    }
    handleSubmit(event){
        this.isLoading = true;
        // event.stopPropagation();
        event.preventDefault();
        const email = event.detail.fields.Email;
        const fields = event.detail.fields;
        fields.Username = email;
        fields.Email = email;

        this.user.Email = email;
        this.user.Username = email;
        if (email.length>=40) {
            let subemail = email.substr(0,40);
            fields.CommunityNickname = subemail;
            this.user.CommunityNickname = subemail;
        }else{
            fields.CommunityNickname = email;
            this.user.CommunityNickname = email;
        }
        this.template.querySelector('lightning-record-edit-form').submit(fields);

    }

    handleSuccess(event){
        // updateUser({
        //     user:this.user
        // })
        // .then(result=>{
        //     if(result='Success'){
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'User information updated.',
            variant: 'success'
        }));
        this.updateEmail(event,this.user.Email,this.userRecordId);
        //     }
        // })
        // .catch(err=>{
        //     console.log(err);
        //     this.dispatchEvent(new ShowToastEvent({
        //         title: 'Error',
        //         message: JSON.stringify(err),
        //         variant: 'error'
        //     }));
        // })
    }

    handleCancel(event){
        this.disableButton();
        const inputFields = this.template.querySelector('lightning-record-edit-form');
        const email = this.template.querySelector('lightning-input-field[data-name="username"]').value;
        inputFields.forEach(element => {
            if (element.fieldName === 'Email') {
                element.value = email;
            }
        });
        // this.dispatchEvent(new RefreshEvent());
        // this.template.querySelector('lightning-record-edit-form').reset();
    }

    handleError(event){
        console.log(event);
        let err = event.detail.detail;
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: err,
            variant: 'error'
        }));
        this.isLoading = false;
    }
}