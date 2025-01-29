import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import LWCDatatablePicklist from '@salesforce/resourceUrl/LWCDatatablePicklist';
 
export default class DatePicker extends LightningElement {
    @api label;
    @api placeholder;
    @api options;
    @api value;
    @api context;
    @api name;
    @api fieldname;
    @api disabled;
    @track minDate;
    connectedCallback() {
        // Get today's date in YYYY-MM-DD format
        const today = new Date();
        const yyyy = today.getFullYear();
        const mm = String(today.getMonth() + 1).padStart(2, '0'); // Months are zero-based
        const dd = String(today.getDate()).padStart(2, '0');
        
        // Set the minDate property to today's date
        this.minDate = `${yyyy}-${mm}-${dd}`;
    }
    renderedCallback() {
        Promise.all([
            loadStyle(this, LWCDatatablePicklist),
        ]).then(() => { });
        console.log('isDisabled '+this.disabled);
        this.template.querySelector("lightning-datepicker")?.focus();
    }
 

 
    handleChange(event) {
        //show the selected value on UI
        this.value = event.detail.value;
      
        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('datepickerchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: {fieldname: this.fieldname, context: this.context, value: this.value}
            }
        }));
    }
 
}