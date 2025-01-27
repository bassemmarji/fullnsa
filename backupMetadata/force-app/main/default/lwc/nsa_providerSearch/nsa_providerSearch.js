import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchProviders from '@salesforce/apex/EOBEntryFormController.retriveProviders';
import oonErrorLabel from '@salesforce/label/c.NSA_OONError';
import getUSStates from '@salesforce/apex/EOBEntryFormController.getUSStates';
import providerLine7 from '@salesforce/label/c.NSA_ProviderLine7';
import title from "@salesforce/label/c.NSA_ProviderSeach_Title";
import cityPlaceholder from "@salesforce/label/c.NSA_ProviderSeach_CityPlaceholder";
import fNameLabel from "@salesforce/label/c.NSA_ProviderSeach_FNameLabel";
import fNamePlaceholder from "@salesforce/label/c.NSA_ProviderSeach_FNamePlaceholder";
import iCityLabel from "@salesforce/label/c.NSA_ProviderSeach_ICityLabel";
import iPostalCodeLabel from "@salesforce/label/c.NSA_ProviderSeach_IPostalCodeLabel";
import iStateLabel from "@salesforce/label/c.NSA_ProviderSeach_IStateLabel";
import lNameLabel from "@salesforce/label/c.NSA_ProviderSeach_LNameLabel";
import lNamePlaceholder from "@salesforce/label/c.NSA_ProviderSeach_LNamePlaceholder";
import nameLabel from "@salesforce/label/c.NSA_ProviderSeach_NameLabel";
import namePlaceholder from "@salesforce/label/c.NSA_ProviderSeach_NamePlaceholder";
import oCityLabel from "@salesforce/label/c.NSA_ProviderSeach_OCityLabel";
import oPostalCodeLabel from "@salesforce/label/c.NSA_ProviderSeach_OPostalCodeLabel";
import oStateLabel from "@salesforce/label/c.NSA_ProviderSeach_OStateLabel";
import postalCodePlaceholder from "@salesforce/label/c.NSA_ProviderSeach_PostalCodePlaceholder";
import searchButton from "@salesforce/label/c.NSA_ProviderSeach_SearchButton";
import statePlaceholder from "@salesforce/label/c.NSA_ProviderSeach_StatePlaceholder";
import npiLabel from "@salesforce/label/c.NSA_ProviderSearch_NPILabel";
import npiPlaceholder from "@salesforce/label/c.NSA_ProviderSearch_NPIPlaceholder";
import noCriteriaError from "@salesforce/label/c.NSA_ProviderSeach_MissingCriteriaError";
import genericSearchError from "@salesforce/label/c.NSA_ProviderSeach_GenericSearchError";
import missingAddressError from "@salesforce/label/c.NSA_ProviderSeach_MissingAddressError";
import selectionErrorTitle from "@salesforce/label/c.NSA_ProviderSeach_SelectionErrorTitle";
import providerNotSupported from "@salesforce/label/c.NSA_ProviderSeach_ProviderNotSupported";

// datatable columns
const columns = [
{
    label: 'Provider Name',
    fieldName: 'ProviderName',
    type: 'text',
}, {
    label: 'Provider Code',
    fieldName: 'NPINumber',
    type: 'text',
}, {
    label: 'Provider City',
    fieldName: 'ProviderCity',
    type: 'text',
}, {
    label: 'Provider Street',
    fieldName: 'ProviderStreet',
    type: 'text',
}, {
    label: 'Provider State',
    fieldName: 'ProviderState',
    type: 'text',
},{
    label: 'Provider Postal Code',
    fieldName: 'ProviderPostalCode',
    type: 'text',
}, {
    label: 'Provider Country',
    fieldName: 'ProviderCountry',
    type: 'text',
}, {
    label: 'Provider Phone',
    fieldName: 'ProviderPhone',
    type: 'text',
}, 
{
    label: 'Provider Network',
    fieldName: 'networkOption',
    type: 'text',
}, 
];

export default class Nsa_providerSearch extends LightningElement {
@api npiColumns;
@api networkNames;
@api tpaAcro;
@api oon;
@api selectedProvider;
@track providerLine7=providerLine7;
@track providerId=[];
@track isSearchDisabled=false;
@track hideCheckbox=false;
@track stateOptions;
@track states;
@track hasNPICode=true;
@track oonErrorLabel = oonErrorLabel;
@track oonError=false;
@track searchData=[];
@track columns = columns;
@track providerNPI;
@track isNPIDisabled = true;
@track isProviderIndividual = true;
@track providerFName;
@track providerLName;
@track providerIPostalCode;
@track providerICity;
@track providerIState;
@track isProviderOrganization = true;
@track providerName;
@track providerOPostalCode;
@track providerOCity;
@track providerOState;
@track searchKey;
@track isLoading = false;
@track searchString;
@track tableData = [];
@track data=[];
@track isPreviousDisable = true;
@track isNextDisable = true;
@track searchSelection = '';
page = 1; //initialize 1st page
startingRecord = 1; //start record position per page
endingRecord = 0; //end record position per page
pageSize = 10; //default value we are assigning
totalRecountCount = 0; //total record count received from all retrieved records
totalPage = 0; //total number of page is needed to display all records
@api
refreshAll() {

}
@api
disableAllInputs() {
    this.isProviderIndividual=true;
    this.isProviderOrganization=true;
    this.isPreviousDisable=true;
    this.isNextDisable=true;
    this.isNPIDisabled=true;
    this.hideCheckbox=true;
    this.isSearchDisabled=true;
}

label = {
    title,
    cityPlaceholder,
    fNameLabel,
    fNamePlaceholder,
    iCityLabel,
    iPostalCodeLabel,
    iStateLabel,
    lNameLabel,
    lNamePlaceholder,
    nameLabel,
    namePlaceholder,
    oCityLabel,
    oPostalCodeLabel,
    oStateLabel,
    postalCodePlaceholder,
    searchButton,
    statePlaceholder,
    npiLabel,
    npiPlaceholder,
    noCriteriaError,
    genericSearchError,
    missingAddressError,
    oonErrorLabel,
    selectionErrorTitle,
    providerNotSupported,
  };


@wire(getUSStates, {})
    WiredStates({ error, data }) {
 
        if (data) {
            try {
                this.states = data; 
                let options = [];
                options.push({ label: 'None', value: 'None'});
                for (var key in data) {
                    options.push({ label: data[key].MasterLabel, value: data[key].DeveloperName});
                }
                this.stateOptions = options;
            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }
    }

    get searchOptionNPI() {
        return [
            { label: 'Search By NPI Number', value: 'NPI' },
        ];
    }

    get searchOptionIndividual() {
        return [
            { label: 'Search By Individual', value: 'Individual' },
        ];
    }

    get searchOptionOrganization() {
        return [
            { label: 'Search By Organization', value: 'Organization' },
        ];
    }

    handleSearchOption(event) {
        this.searchSelection = event.detail.value;
        if(this.searchSelection == 'NPI'){
            this.isNPIDisabled = false;
            this.isProviderIndividual = true;
            this.isProviderOrganization = true;
            this.providerLName='';
            this.providerFName='';
            this.providerICity='';
            this.providerIState='';
            this.providerIPostalCode='';
            this.providerName='';
            this.providerOCity='';
            this.providerOPostalCode='';
            this.providerOState='';
        }
        else if(this.searchSelection == 'Individual'){
            this.isNPIDisabled = true;
            this.isProviderIndividual = false;
            this.isProviderOrganization = true;
            this.providerNPI='';
            this.providerName='';
            this.providerOCity='';
            this.providerOPostalCode='';
            this.providerOState='';
        }
        else if(this.searchSelection == 'Organization'){
            this.isNPIDisabled = true;
            this.isProviderIndividual = true;
            this.isProviderOrganization = false;
            this.providerNPI='';
            this.providerLName='';
            this.providerFName='';
            this.providerICity='';
            this.providerIState='';
            this.providerIPostalCode='';
        }
}

    handleNPI(event) {
            this.providerNPI = event.detail.value;
    }

    handleProviderFName(event) {
        this.providerFName = event.detail.value;
    }

    handleProviderLName(event) {
    this.providerLName = event.detail.value;
    }

    handleProviderName(event) {
        this.providerName = event.detail.value;
    }

    handleProviderPostalCode(event) {
        if(event.target.name == 'providerIPostalCode'){
            this.providerIPostalCode = event.detail.value;
        }
        else if(event.target.name == 'providerOPostalCode'){
        this.providerOPostalCode = event.detail.value;
        }
    }

    handleProviderCity(event) {
        if(event.target.name == 'providerICity'){
            this.providerICity = event.detail.value;
        }
        else if(event.target.name == 'providerOCity'){
            this.providerOCity = event.detail.value;
        }
    }

    handleProviderState(event) {
        if(event.target.name == 'providerIState'){
            this.providerIState = event.detail.value;
        }
        else if(event.target.name == 'providerOState'){
            this.providerOState = event.detail.value;
        }
        }

handleSearch(event) {
    this.isPreviousDisable = true;
    this.isNextDisable = true;
    this.hasNPICode=true;
    if((this.searchSelection == 'NPI' && (this.providerNPI == '' || this.providerNPI == undefined)) || (this.searchSelection == 'Individual' &&((this.providerFName == '' || this.providerFName == undefined) && (this.providerLName == '' || this.providerLName == undefined) && (this.providerICity == '' || this.providerICity == undefined) && (this.providerIPostalCode == '' || this.providerIPostalCode == undefined) && (this.providerIState == '' || this.providerIState == undefined || this.providerIState == 'None'))) || (this.searchSelection == 'Organization' && ((this.providerName == '' || this.providerName == undefined) && (this.providerOCity == '' || this.providerOCity == undefined) && (this.providerOPostalCode == '' || this.providerOPostalCode == undefined) && (this.providerOState == '' || this.providerOState == undefined || this.providerOState == 'None')))
    || this.searchSelection == ''){
        const event = new ShowToastEvent({
            title: 'Error',
            variant: 'error',
            message: this.label.noCriteriaError,
        });
        this.dispatchEvent(event);
        }

           else if((this.searchSelection == 'Individual' && ((this.providerIState != '' && this.providerIState != undefined && this.providerIState != 'None') && (this.providerFName == '' || this.providerFName == undefined) && (this.providerLName == '' || this.providerLName == undefined) && (this.providerICity == '' || this.providerICity == undefined) && (this.providerIPostalCode == '' || this.providerIPostalCode == undefined))) 
        || (this.searchSelection == 'Organization' && ((this.providerOState != '' && this.providerOState != undefined && this.providerOState != 'None') && (this.providerName == '' || this.providerName == undefined) && (this.providerOCity == '' || this.providerOCity == undefined) && (this.providerOPostalCode == '' || this.providerOPostalCode == undefined)))){
             const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: this.label.genericSearchError,
            });
            this.dispatchEvent(event);
            }

            else if((this.searchSelection == 'Individual' && (((this.providerFName != '' && this.providerFName != undefined) || (this.providerLName != '' && this.providerLName != undefined)) && ((this.providerIState == '' || this.providerIState == undefined || this.providerIState == 'None') && (this.providerICity == '' || this.providerICity == undefined) && (this.providerIPostalCode == '' || this.providerIPostalCode == undefined)))) 
        || (this.searchSelection == 'Organization' && ((this.providerName != '' && this.providerName != undefined) && ((this.providerOState == '' || this.providerOState == undefined || this.providerOState == 'None') && (this.providerOCity == '' || this.providerOCity == undefined) && (this.providerOPostalCode == '' || this.providerOPostalCode == undefined))))){
             const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: this.label.missingAddressError,
            });
            this.dispatchEvent(event);
            }

        else{
            console.log('this.networkNames'+this.networkNames);
            console.log('this.tpaAcro '+this.tpaAcro);
            if(this.searchSelection == 'NPI' && this.providerNPI != '' && this.providerNPI != undefined){
                this.isLoading = true;
                this.searchKey = 'number=' + this.providerNPI;
                searchProviders({searchString : this.searchKey,
                    networks: this.networkNames,
                    tpaAcro: this.tpaAcro,
                    hasOON: this.oon})
                .then(result => {
                    console.log('success?'); 
               
                    if(result.length==0 && !this.oon){
                        console.log('other error')
                        this.hasNPICode = false;
                        this.oonErrorLabel = oonErrorLabel;
    
                        console.log(' this.hasNPICode ' + this.hasNPICode);
                    }
                    else{
                        this.hasNPICode = true;
                        this.searchData = result;
                        this.displayData();
                    }
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                console.log('results error ' + JSON.stringify(error));
                console.log('results error ' + error.body.message);
               this.hasNPICode = false;
                    this.oonErrorLabel = oonErrorLabel;
                    console.log(' this.hasNPICode ' + this.hasNPICode);
                
            });
            }
            else if(this.searchSelection == 'Organization' && ((this.providerName != '' && this.providerName != undefined) || (this.providerOCity != '' && this.providerOCity != undefined) || (this.providerOPostalCode != '' && this.providerOPostalCode != undefined) || (this.providerOState != '' && this.providerOState != undefined && this.providerOState != 'None'))){
                if(this.providerName != '' && this.providerName != undefined){
                    this.isLoading = true;
                    this.searchKey = 'organization_name=' + this.providerName;
                    if(this.providerOPostalCode != '' && this.providerOPostalCode != undefined){
                        this.searchKey = this.searchKey + '&postal_code=' + this.providerOPostalCode;
                        if(this.providerOCity != '' && this.providerOCity != undefined){
                            this.searchKey = this.searchKey + '&city=' + this.providerOCity;
                            if(this.providerOState != '' && this.providerOState != undefined && this.providerOState != 'None'){
                                this.searchKey = this.searchKey + '&state=' + this.providerOState;
                            }
                        }
                    }
                    else if(this.providerOCity != '' && this.providerOCity != undefined){
                        this.isLoading = true;
                        this.searchKey = this.searchKey + '&city=' + this.providerOCity;
                        if(this.providerOState != '' && this.providerOState != undefined && this.providerOState != 'None'){
                            this.searchKey = this.searchKey + '&state=' + this.providerOState;
                        }
                    }
                    else if(this.providerOState != '' && this.providerOState != undefined && this.providerOState != 'None'){
                        this.isLoading = true;
                        this.searchKey = this.searchKey + '&state=' + this.providerOState;
                    }
                }
                else if(this.providerOPostalCode != '' && this.providerOPostalCode != undefined){
                    this.isLoading = true;
                    this.searchKey = 'postal_code=' + this.providerOPostalCode;
                    if(this.providerOCity != '' && this.providerOCity != undefined){
                        this.searchKey = this.searchKey + '&city=' + this.providerOCity;
                        if(this.providerOState != '' && this.providerOState != undefined && this.providerOState != 'None'){
                            this.searchKey = this.searchKey + '&state=' + this.providerOState;
                        }
                    }
                    else if(this.providerOState != '' && this.providerOState != undefined && this.providerOState != 'None'){
                        this.isLoading = true;
                        this.searchKey = this.searchKey + '&state=' + this.providerOState;
                    }
                }
                else if(this.providerOCity != '' && this.providerOCity != undefined){
                    this.isLoading = true;
                    this.searchKey = 'city=' + this.providerOCity;
                    if(this.providerOState != '' && this.providerOState != undefined && this.providerOState != 'None'){
                        this.searchKey = this.searchKey + '&state=' + this.providerOState;
                    }
                }
                this.searchKey = this.searchKey + '&enumeration_type=NPI-2';
                console.log('search ',this.searchKey);
                searchProviders({searchString : this.searchKey,
                    networks: this.networkNames,
                    tpaAcro: this.tpaAcro,
                    hasOON: this.oon})
                .then(result => { console.log('success2?');
                if(result.length==0 && !this.oon){
                    console.log('other error')
                    this.hasNPICode = false;
                    this.oonErrorLabel = oonErrorLabel;

                    console.log(' this.hasNPICode ' + this.hasNPICode);
                }
                else{
                    this.hasNPICode = true;
                    this.searchData = result;
                    this.displayData();
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                console.log('results error ' + JSON.stringify(error));
                console.log('results error ' + error.body.message);
                this.hasNPICode = false;
                    this.oonErrorLabel = this.label.oonErrorLabel;
                    console.log(' this.hasNPICode ' + this.hasNPICode);
                
            });
            }
            else if(this.searchSelection == 'Individual' && ((this.providerFName != '' && this.providerFName != undefined) || (this.providerLName != '' && this.providerLName != undefined) || (this.providerICity != '' && this.providerICity != undefined) || (this.providerIPostalCode != '' && this.providerIPostalCode != undefined) || (this.providerIState != '' && this.providerIState != undefined && this.providerIState != 'None'))){
                if(this.providerFName != '' && this.providerFName != undefined){
                    this.isLoading = true;
                    console.log('this.isLoading ',this.isLoading);
                    this.searchKey = 'first_name=' + this.providerFName;
                    if(this.providerLName != '' && this.providerLName != undefined){
                        this.searchKey = this.searchKey + '&last_name=' + this.providerLName;
                        if(this.providerIPostalCode != '' && this.providerIPostalCode != undefined){
                            this.searchKey = this.searchKey + '&postal_code=' + this.providerIPostalCode;
                            if(this.providerICity != '' && this.providerICity != undefined){
                                this.searchKey = this.searchKey + '&city=' + this.providerICity;
                                if(this.providerIState != '' && this.providerIState != undefined && this.providerIState != 'None'){
                                    this.searchKey = this.searchKey + '&state=' + this.providerIState;
                                }
                            }
                        }
                    }
                    else if(this.providerIPostalCode != '' && this.providerIPostalCode != undefined){
                        this.isLoading = true;
                        this.searchKey = this.searchKey + '&postal_code=' + this.providerIPostalCode;
                        if(this.providerICity != '' && this.providerICity != undefined){
                            this.searchKey = this.searchKey + '&city=' + this.providerICity;
                            if(this.providerIState != '' && this.providerIState != undefined && this.providerIState != 'None'){
                                this.searchKey = this.searchKey + '&state=' + this.providerIState;
                            }
                        }
                    }
                    else if(this.providerICity != '' && this.providerICity != undefined){
                        this.isLoading = true;
                        this.searchKey = this.searchKey + '&city=' + this.providerICity;
                        if(this.providerIState != '' && this.providerIState != undefined && this.providerIState != 'None'){
                            this.searchKey = this.searchKey + '&state=' + this.providerIState;
                        }
                    }
                    else if(this.providerIState != '' && this.providerIState != undefined && this.providerIState != 'None'){
                        this.isLoading = true;
                        this.searchKey = this.searchKey + '&state=' + this.providerIState;
                    }
                }
                else if(this.providerLName != '' && this.providerLName != undefined){
                    this.isLoading = true;
                    this.searchKey = 'last_name=' + this.providerLName;
                    if(this.providerIPostalCode != '' && this.providerIPostalCode != undefined){
                        this.searchKey = this.searchKey + '&postal_code=' + this.providerIPostalCode;
                        if(this.providerICity != '' && this.providerICity != undefined){
                            this.searchKey = this.searchKey + '&city=' + this.providerICity;
                            if(this.providerIState != '' && this.providerIState != undefined && this.providerIState != 'None'){
                                this.searchKey = this.searchKey + '&state=' + this.providerIState;
                            }
                        }
                    }
                    else if(this.providerICity != '' && this.providerICity != undefined){
                        this.isLoading = true;
                        this.searchKey = this.searchKey + '&city=' + this.providerICity;
                        if(this.providerIState != '' && this.providerIState != undefined && this.providerIState != 'None'){
                            this.searchKey = this.searchKey + '&state=' + this.providerIState;
                        }
                    }
                    else if(this.providerIState != '' && this.providerIState != undefined && this.providerIState != 'None'){
                        this.isLoading = true;
                        this.searchKey = this.searchKey + '&state=' + this.providerIState;
                    }
                }
                else if(this.providerIPostalCode != '' && this.providerIPostalCode != undefined){
                    this.isLoading = true;
                    this.searchKey = 'postal_code=' + this.providerIPostalCode;
                    if(this.providerICity != '' && this.providerICity != undefined){
                        this.searchKey = this.searchKey + '&city=' + this.providerICity;
                        if(this.providerIState != '' && this.providerIState != undefined && this.providerIState != 'None'){
                            this.searchKey = this.searchKey + '&state=' + this.providerIState;
                        }
                    }
                    else if(this.providerIState != '' && this.providerIState != undefined && this.providerIState != 'None'){
                        this.isLoading = true;
                        this.searchKey = this.searchKey + '&state=' + this.providerIState;
                    }
                }
                else if(this.providerICity != '' && this.providerICity != undefined){
                    this.isLoading = true;
                    this.searchKey = 'city=' + this.providerICity;
                    if(this.providerIState != '' && this.providerIState != undefined && this.providerIState != 'None'){
                        this.searchKey = this.searchKey + '&state=' + this.providerIState;
                    }
                }
                console.log('search ',this.searchKey);
                this.searchKey = this.searchKey + '&enumeration_type=NPI-1';
                searchProviders({searchString : this.searchKey,
                    networks: this.networkNames,
                    tpaAcro: this.tpaAcro,
                    hasOON: this.oon})
                .then(result => {
                    console.log('success3?');
                    if(result.length==0 && !this.oon){
                        console.log('other error')
                        this.hasNPICode = false;
                        this.oonErrorLabel = oonErrorLabel;
    
                        console.log(' this.hasNPICode ' + this.hasNPICode);
                    }
                    else{
                        this.hasNPICode = true;
                        this.searchData = result;
                        this.displayData();
                    }
                
                this.isLoading = false;
            })
          
            .catch(error => {
                this.isLoading = false;
                console.log('results error ' + JSON.stringify(error));
                console.log('results error ' + error.body.message);
            
                    this.hasNPICode = false;
                    this.oonErrorLabel = this.label.oonErrorLabel;
                    console.log(' this.hasNPICode ' + this.hasNPICode);
                
            });
            }
        }

    }
    displayData(){
        this.startingRecord = 1;
        this.page = 1;
        this.tableData = [...this.searchData];
        this.totalRecountCount = this.tableData.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        if(this.totalPage>1){
            this.isNextDisable=false;
        }
        this.data = this.tableData.slice(0, this.pageSize);
        this.endingRecord = this.pageSize;
        this.totalRecountCount = this.tableData.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        this.data = this.tableData.slice(0, this.pageSize);
        this.endingRecord = this.pageSize;
        this.totalRecountCount = this.searchData.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        this.data = this.searchData.slice(0, this.pageSize);
        this.endingRecord = this.pageSize;
        this.template.querySelector('[data-id="datatable"]').selectedRows=[];
        this.template.querySelector('[data-id="datatable"]').selectedRows = [...this.template.querySelector('[data-id="datatable"]').selectedRows, this.selectedProvider];
        this.providerId = [];
        this.providerId = [...this.providerId, this.selectedProvider.NPINumber];

        console.log(JSON.stringify(this.providerId));

    }
    /*handleSearchTable(event) {
        const matchedProvider = event.target.value.toLowerCase();
 
        if (matchedProvider) {
            this.data = this.tableData;
 
            if (this.data){
                let searchRecords = [];
 
                for (let record of this.data) {
                    let valuesArray = Object.values(record);
 
                    for (let val of valuesArray) {
                        console.log('val is ' + val);
                        let strVal = String(val);
 
                        if (strVal) {
                            if (strVal.toLowerCase().includes(matchedProvider)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
                console.log('Matched providers are ' + JSON.stringify(searchRecords));
                this.data = searchRecords;
                console.log('searchhh '+this.data);
            }
        } else {
            this.displayRecordPerPage(this.page);
        }
    }*/

    getSelectedRec(event) {
        console.log('event.detail.row'+ event.detail.selectedRows);
        if(event.detail.selectedRows!=null){
            this.selectedProvider = event.detail.selectedRows;
            console.log('event.detail.row'+ event.detail.selectedRows);
            console.log('event.detail.row2'+ this.oon+' '+this.selectedProvider[0].networkOption );

            if(!this.oon && this.selectedProvider[0].networkOption=='Out-of-Network'){
                this.providerId = [];
            
                const event = new ShowToastEvent({
                    title: this.label.selectionErrorTitle,
                        message: this.label.providerNotSupported,
                        variant: 'error'
                });
                this.dispatchEvent(event); 
            }
            else{
             
                this.dispatchEvent(new CustomEvent('providerchosen', {
                    composed: true,
                    bubbles: true,
                    cancelable: true,
                    detail: {
                        data: {row: this.selectedProvider}
    
                    }
                }));
                this.providerId = [];
                this.providerId = [...this.providerId, this.selectedProvider.NPINumber];
                console.log('providerchosen dispatched'+this.providerId);  
            }
          
        }

             
      }

      previousHandler() {
        this.isNextDisable = false;
        this.isPreviousDisable = false;
        if (this.page > 1) {
            this.isPreviousDisable = false;
            this.page = this.page - 1;
            this.displayRecordPerPage(this.page);
        }
        console.log('page ',this.page);
        if (this.page == 1){
            this.isPreviousDisable = true;
            this.isNextDisable=false;
        }
        this.template.querySelector('[data-id="datatable"]').selectedRows=[];
        this.template.querySelector('[data-id="datatable"]').selectedRows = [...this.template.querySelector('[data-id="datatable"]').selectedRows, this.selectedProvider];
        this.providerId = [];
        this.providerId = [...this.providerId, this.selectedProvider.NPINumber];
        console.log(JSON.stringify(this.selectedProvider));

    }

    nextHandler() {
        this.isNextDisable = false;
        this.isPreviousDisable = false;
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.isNextDisable = false;
            this.page = this.page + 1;
            this.displayRecordPerPage(this.page);
        }
        console.log('page ',this.page);
        if(this.page != 1){
            this.isPreviousDisable = false;
        }
        if(this.page == this.totalPage){
            this.isNextDisable = true;
        }
        this.template.querySelector('[data-id="datatable"]').selectedRows=[];
        this.template.querySelector('[data-id="datatable"]').selectedRows = [...this.template.querySelector('[data-id="datatable"]').selectedRows, this.selectedProvider];
        this.providerId = [];
        this.providerId = [...this.providerId, this.selectedProvider.NPINumber];
        console.log(JSON.stringify(this.selectedProvider));
    }
    //this method displays records page by page
    displayRecordPerPage(page) {
        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;
        this.data = this.tableData.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
        this.template.querySelector('[data-id="datatable"]').selectedRows=[];
        this.template.querySelector('[data-id="datatable"]').selectedRows = [...this.template.querySelector('[data-id="datatable"]').selectedRows, this.selectedProvider];
        this.providerId = [];
        this.providerId = [...this.providerId, this.selectedProvider.NPINumber];
        console.log(JSON.stringify(this.selectedProvider));}
}