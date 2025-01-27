import resetUserPassword from '@salesforce/apex/ResetUserPasswordController.resetUserPassword';
import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class ResetUserPassword extends LightningElement {
    @api recordId;
    @track isLoading = false;
    // connectedCallback(){
        
    //   setTimeout(() => {
    //     // alert(this.recordId);
    //     this.resetUserPassword();
    //     }, 50);
    // }

    resetUserPassword(){
        this.isLoading = true;
        resetUserPassword({
            recordId:this.recordId
        })
        .then(result=>{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Password reset email sent to user!',
                variant: 'success'
            }));
            this.isLoading = false;
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch(error=>{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error'
            }));
            this.isLoading = false;
            this.dispatchEvent(new CloseActionScreenEvent());
        })
    }

    closeModal(){
        this.isLoading = false;
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}