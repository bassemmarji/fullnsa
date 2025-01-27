import {
    api,
    LightningElement,
    track,
    wire
} from 'lwc';

import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';

import EOB_Line_Item_Obj from '@salesforce/schema/IntPS__EOB_Line_Item__c';
import Provider_Type from '@salesforce/schema/IntPS__EOB_Line_Item__c.Provider_Type__c';

import Elg_Obj from '@salesforce/schema/IntPS__RemarkCode__c';

export default class TestPicklist extends LightningElement {
    @track ProviderTypeLineItemValues = [];

    @wire(getObjectInfo, { 
        objectApiName: Elg_Obj 
      }) 
    setEOBInfo({
      error,
      data
    }) {
      console.log('---testpicklist --- 	IntPS__RemarkCode__c = ' + JSON.stringify(data));
      if (data) {
          console.log('---testpicklist ---  IntPS__RemarkCode__c = data ' + JSON.stringify(data));
      } else if (error) {
          console.log('---testpicklist --- 	IntPS__RemarkCode__c = error ' + JSON.stringify(error));
      }
   }

    @wire(getObjectInfo, { 
          objectApiName: EOB_Line_Item_Obj 
        }) 
    setObjectInformation({
        error,
        data
    }) {
        console.log('---testpicklist --- ObjectInfo= ' + JSON.stringify(data));
        if (data) {
            console.log('---testpicklist ---  ObjectInfo= data ' + JSON.stringify(data));
        } else if (error) {
            console.log('---testpicklist --- ObjectInfo= error ' + JSON.stringify(error));
        }
    }
    

    //get provider type field picklist values
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA'
       ,fieldApiName: Provider_Type
    })
    setProviderTypePicklistOptions({
        error,
        data
    }) {
        console.log('---testpicklist --- provider type data ' + JSON.stringify(data));
        if (data) {

            for (let i = 0; i < data.values.length; i++) {
                this.ProviderTypeLineItemValues.push({
                    label: data.values[i].label,
                    value: data.values[i].value,
                });
            }

            console.log('---testpicklist --- ProviderTypeLineItemValues ' + JSON.stringify(this.ProviderTypeLineItemValues));

        } else if (error) {
            console.log('---testpicklist --- perror provider type ' + JSON.stringify(error));
        }
    }

}