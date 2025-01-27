import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import networkId from '@salesforce/community/Id';
import basePath from '@salesforce/community/basePath';

export default class NavigateToNSA extends NavigationMixin(LightningElement) {

    navigateToNSA(event) {
       //const before_ = '${basePath}'.substring(0, '${basePath}'.indexOf('/s')+1);
       //const communityUrl = 'https://${location.host}${before_}';
    
        // Make sure the event is only handled here
        event.stopPropagation();
 
        // Create a PageReference object for generating the record page URL
        //const pageReference = {
        //      type: 'standard__recordPage',
        //            attributes: {
        //                recordId: '001Qy00000d9YDjIAM', // Replace with the actual record ID
        //                objectApiName: 'Account', // Replace with the object API name
        //                actionName: 'view'
        //            }
        //};
        
        // Use the GenerateUrl method to get a promise resolving to the resulting URL
        //this[NavigationMixin.GenerateUrl](pageReference)
        //    .then(url => {
                // Output the generated URL to the console
        //        console.log('Generated URL:', url);
 
                // Open a new browser window using the generated URL
        //        window.open(url, '_blank');
        //    })
        //    .catch(error => {
        //        console.error('Error generating URL:', error);
        //    });

        const url_ = `https://${location.host}/nsa/s`;

        console.log('url=' + url_ );

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
              attributes: {
                url: url_
              }
        });
        //window.open(url);
        console.log('after');
    }    
}