import makeRequest from '@salesforce/apex/NSATestToolController.makeRequest';
import fairHealthAndMedicareRequest from '@salesforce/apex/NSATestToolController.fairHealthRequest';
import retrieveMRFDetails from '@salesforce/apex/NSATestToolController.retrieveMRFDetails';
import getClaimType from '@salesforce/apex/NSATestToolController.getClaimType';
import getNetworks from '@salesforce/apex/NSATestToolController.retrieveNetwork';
import { LightningElement,track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class NsaTestTool extends LightningElement {
    @api inputJSON = '';
    @api customerServiceMode = false;
    @api requestCardName = 'NSA Test Tool';
    @track isLoading = false;
    @track valuePlaceOfService='11';
    @track requestTypeOptions = [
        {label:'Provider',value:'provider'},
        {label:'Price (In Network)',value:'price'},
        {label:'Price (Out Of Network)',value:'priceoon'}
    ];
    @track networkAcronymsOptions = [];
    @track networksMap = [];
    @track tpaAcronymOptions = [
        {label:'BSI Companies', value:'BSi'},
        {label:'Baker', value:'BKR'},
        {label:'Coeur', value:'COR'},
        {label:'Providence', value:'PVD'},
        {label:'Maverick', value:'MVK'},
        {label:'Secure One', value:'SON'},
        {label:'HMA', value:'HMA'},
        {label:'BMA', value:'BMA'},
        {label:'Cornerstone', value:'CNS'},
        {label:'Clearwater', value:'CW'}
    ];
    @track isRequestProvider = true;
    @track selectedRequestType = 'provider';
    @track procedureCodes = '';
    @track tins = '';
    @track zip = '';
    @track tpaAcronym = '';
    @track networkAcronyms = '';
    @track priceResponse = [];
    @track providerResponse = [];
    @track showPriceResponse = false;
    @track showProviderResponse = false;
    @track priceoon = [];
    @track showPriceoon = false;
    @track isOutOfNetwork=false;

    @track fromDate;
    @track toDate;
    @track revCodeCheckBox=false;
    @track drgCodeCheckBox=false;
    @track quantity=1;
   /* networkMap = {
        'BSi':[
            {label:'Cigna', value:'CG'},
            {label:'MedCost', value:'MC'},
            {label:'First Choice Health Network', value:'FCHN'},
            {label:'Merative on behalf of HealthPartners(Cigna)', value:'CG1'},
            {label:'Sagamore Health Network(Cigna)', value:'CG2'}
        ],
        'BKR':[
            {label:'Cigna', value:'CG'},
            {label:'PHCSPrimary', value:'PHCS'},
            {label:'PHCSPracAncil', value:'PHCSPA'},
            {label:'Merative on behalf of HealthPartners(Cigna)', value:'CG1'},
            {label:'Sagamore Health Network', value:'CG2'},
            {label:'PHCSPracAncil', value:'PHCSPA'}
        ],
        'COR':[
            {label:'Cigna Health Life Insurance Company', value:'CG'},
            {label:'Merative on behalf of HealthPartners', value:'CG1'},
            {label:'Sagamore Health Network', value:'CG2'},
            {label:'PHCSPrimary', value:'PHCS'},
            {label:'PHCSPracAncil', value:'PHCSPA'},
            {label:'Imagine360', value:'I360'}
        ],
        'CNS':[
            {label:'PHCSPrimary', value:'PHCS'}
        ],
        'PVD':[
            {label:'Cigna Health Life Insurance Company', value:'CG'},
            {label:'PHCSPrimary', value:'PHCS'},
            {label:'Merative on behalf of HealthPartners', value:'CG1'},
            {label:'Sagamore Health Network', value:'CG2'}
        ],
        'MVK':[],
        'SON':[
            {label:'PHCSPracAncil', value:'PHCSPA'},
            {label:'PHCSPrimary', value:'PHCS'},
            {label:'HON-Prod', value:'HON'},
            {label:'Sagamore Health Network', value:'SAG'}
        ],
        'HMA':[
            {label:'Cigna Health Life Insurance Company', value:'CG'},
            {label:'Merative on behalf of HealthPartners', value:'CG1'},
            {label:'Sagamore Health Network', value:'CG2'},
            {label:'PHCSPracAncil', value:'PHCSPA'},
            {label:'PHCSPrimary', value:'PHCS'},
            {label:'MPNHMA', value:'MPNHMA'},
            {label:'PNOA', value:'PNOA'},
            {label:'PNOAE', value:'PNOAE'},
            {label:'CNT', value:'CNT'},
            {label:'PREST', value:'PREST'},
            {label:'Midlands Choice', value:'MC'},
            {label:'H2B-Prod', value:'H2B'},
            {label:'Encore-ECMB', value:'ECMB'},
            {label:'Encore-ENCP', value:'ENCP'},
            {label:'RCI', value:'RCI'}
        ]
    };*/
    @track placeOfService= [
        {label:'Office', value:'11'},
        {label:'Inpatient hospital', value:'21'},
        {label:'Outpatient hospital', value:'22'},
        {label:'Telehealth', value:'10'},
        {label:'Urgent Care', value:'20'},
        {label:'Birthing Center', value:'25'},
        {label:'Emergency Room', value:'23'},
    ];
    @track claimType= [
        {label:'Professional Claim', value:'P'},
        {label:'Outpatient Facility Claim', value:'O'},
        {label:'Inpatient Facility Claim', value:'I'},
    ];
    @track claimTypeValue='P'

    @track testRequestBoolen=true;

    // get options() {
    //     return [
    //         { label: 'Professional claim', value: 'P' },
    //         { label: 'Outpatient Facility claim', value: 'O' },
    //         { label: 'Inpatient Facility claim', value: 'I' },
    //     ];
    // }
    get todayDate(){
        const date = new Date();
        let day = date.getDate();
        let month = date.getMonth() + 1;
        let year = date.getFullYear();

        return year+"-"+month+"-"+day;
    }
    
    connectedCallback(){
        if (this.isValidJSON(this.inputJSON) && this.customerServiceMode) {
            //this.networkMap = {};
            this.tpaAcronymOptions = [];
            //let networkMap = {};
            let tpaAcOptions = [];
            let parsedJSON = JSON.parse(this.inputJSON);
            Object.keys(parsedJSON).forEach(element => {
                tpaAcOptions.push(parsedJSON[element].TPAAcronym);
                //networkMap[element] = parsedJSON[element].NetworkMap;
            });
            //this.networkMap = networkMap;
            this.tpaAcronymOptions = tpaAcOptions;
            // this.networkMap = JSON.parse(this.networkMapInput);
        }else if(this.customerServiceMode){
            //this.networkMap = {};
            this.networksMap = {};
            this.tpaAcronymOptions = [];
            this.dispatchEvent(new ShowToastEvent({
                title: 'Configuration JSON is not valid!',
                message: 'Please check Configuration JSON from Design Token.',
                variant: 'error'
            }));
        }
        // if (this.isValidJSON(this.tpaAcronymOptionsInput) && this.customerServiceMode) {
        //     this.tpaAcronymOptions = JSON.parse(this.tpaAcronymOptionsInput);
        // }else if(this.customerServiceMode){
        //     this.tpaAcronymOptions = [];
        //     this.dispatchEvent(new ShowToastEvent({
        //         title: 'TPA Acronym JSON is not valid!',
        //         message: 'Please check TPA Acronym JSON Design Token.',
        //         variant: 'error'
        //     }));
        // }

    }

    oonNetworkAcroynms = [{label:'Medicare(Valenz)',value:'medicare'},{label:'Fair Health',value:'fh'}]; // OON Network Acronyms
    requestTypeChange(event){
        this.valuePlaceOfService='11';
        this.claimTypeValue='P'
        this.sendRequestTrue=false;
        this.selectedRequestType = event.detail.value;
        if (this.selectedRequestType == 'price') { // If Request type is In Network, acronyms will be updated by getting values from Network Map
            this.networkAcronymsOptions = this.networksMap;
            this.isRequestProvider = false;
            this.isOutOfNetwork=false; //        
            this.placeOfService= [
                {label:'Office', value:'11'},
                {label:'Inpatient hospital', value:'21'},
                {label:'Outpatient hospital', value:'22'},
                {label:'Telehealth', value:'10'},
                {label:'Urgent Care', value:'20'},
                {label:'Birthing Center', value:'25'},
                {label:'Emergency Room', value:'23'},
                {label:'No Filter', value:'ALL'}
            ];
            this.testRequestBoolen=true;
            this.drgCodeCheckBox=false;
        }
        else if (this.selectedRequestType == 'priceoon') { // If Request type is Out Of Network, acronyms will be updated by using the variable above function.
            this.networkAcronymsOptions = this.oonNetworkAcroynms;
            this.isRequestProvider = false;
            this.isOutOfNetwork=true;
            this.placeOfService= [
                {label:'Office', value:'11'},
                {label:'Inpatient hospital', value:'21'},
                {label:'Outpatient hospital', value:'22'},
                {label:'Telehealth', value:'10'},
                {label:'Urgent Care', value:'20'},
                {label:'Birthing Center', value:'25'},
                {label:'Emergency Room', value:'23'}
            ];
        }else{
            this.networkAcronymsOptions = this.networksMap;
            this.isRequestProvider = true;
            this.isOutOfNetwork=false;
            this.testRequestBoolen=true;
            this.drgCodeCheckBox=false;
        }
    }
    testRequest=false;
    forTestRequest(){
        this.testRequest=true;
        console.log('test1');
        this.sendRequest();
        console.log('test3');
        this.testRequest=false;
    }

    sendRequestTrue=false;
    isError=false;
    sendRequest(){
        this.isError=false;
        this.sendRequestTrue=true;
        this.priceResponse = [];
        this.providerResponse = [];
        console.log('test2');
        if (!this.procedureCodes && (this.requestType == 'price' || this.selectedRequestType == 'priceoon') ) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Procedure Code is required!',
                message: 'Please enter at least a Procedure Code',
                variant: 'error'
            }));
            return;
        }
        //console.log(this.selectedRequestType)
        //console.log('this.selectedRequestType')
        if (!this.tins && this.selectedRequestType != 'priceoon') {
            this.dispatchEvent(new ShowToastEvent({
                title: 'TIN is required!',
                message: 'Please enter at least a TIN.',
                variant: 'error'
            }));
            return;
        }
        if (!this.tpaAcronym) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'TPA Acronym is required!',
                message: 'Please select a TPA Acronym.',
                variant: 'error'
            }));
            return;
        }
        if (!this.networkAcronyms) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Network Acronyms is required!',
                message: 'Please select at least a Network Acronym.',
                variant: 'error'
            }));
            return;
        }
        if (!this.zip && this.selectedRequestType == 'priceoon') {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Zip Code is required!',
                message: 'Please enter at least a Zip Code.',
                variant: 'error'
            }));
            return;
        }



        this.isLoading = true;
        let selectedProcedureCodes = [];
        let selectedTins = [];
        let selectedzip = [];
        let selectedTpaAcronym = '';
        let selectedNetworkAcronyms = [];
        selectedProcedureCodes = this.procedureCodes;
        selectedTins = this.tins;
        selectedzip = this.zip;
        selectedTpaAcronym = this.tpaAcronym;
        selectedNetworkAcronyms = Object.values(this.networkAcronyms);
        //console.log('network acronyms');
        //console.log(selectedNetworkAcronyms);
        if (selectedProcedureCodes.includes(',')) {
            selectedProcedureCodes = selectedProcedureCodes.split(',');
        }else{
            selectedProcedureCodes = [selectedProcedureCodes];
        }
        if (selectedTins.includes(',')) {
            selectedTins = selectedTins.split(',');
        }else{
            selectedTins = [selectedTins];
        }
        if (selectedzip.includes(',')) {
            selectedzip = selectedzip.split(',');
        }else{
            selectedzip = [selectedzip];
        }
        if (selectedNetworkAcronyms.includes(',')) {
            selectedNetworkAcronyms = selectedNetworkAcronyms.split(',');
        }
        selectedProcedureCodes.forEach(element => {
            element = '"'+element+'"';
        });
        selectedTins.forEach(element => {
            element = '"'+element+'"';
        });
        selectedzip.forEach(element => {
            element = '"'+element+'"';

        });
        
        selectedNetworkAcronyms.forEach(element => {
            element = '"'+element+'"';
        });
        if (this.selectedRequestType!='priceoon'){
            makeRequest({
                procedureCodes:JSON.stringify(selectedProcedureCodes),
                tins:JSON.stringify(selectedTins),
                tpaAcronym:selectedTpaAcronym,
                networkAcronyms: JSON.stringify(selectedNetworkAcronyms),
                requestType:this.selectedRequestType,
                zips:JSON.stringify(selectedzip),
                isTest:this.testRequest
            })
            .then(result => {
                if (result) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: 'You have successfuly sent the request.',
                        variant: 'success'
                    }));
                    let parsedResponse = JSON.parse(result);
                    let testparsedresponse=[];
                    if (!this.isRequestProvider) {
                        for (let index = 0; index < parsedResponse.length; index++) {
                            console.log(parsedResponse[index]);
                            console.log(parsedResponse[index].error);
                            if (parsedResponse[index].error!=undefined) {
                                testparsedresponse.push(parsedResponse[index]);
                            } else {
                                if (this.valuePlaceOfService=='ALL') {
                                    testparsedresponse.push(parsedResponse[index]);
                                }else{
                                    if (parsedResponse[index].service_code.some(item => String(item) === String(this.valuePlaceOfService))) {
                                        testparsedresponse.push(parsedResponse[index]);
                                    }
                                    if (parsedResponse[index].service_code.length==0) {
                                        testparsedresponse.push(parsedResponse[index]);
                                    }
                                }
                            }

                        }
                    }else{
                        testparsedresponse=parsedResponse;
                    }
                    console.log('len');
                    console.log(this.valuePlaceOfService);
                    console.log(testparsedresponse.length);
                    console.table(testparsedresponse);
                    if (testparsedresponse.length && testparsedresponse[0].error == undefined) {
                        console.log('test')
                        this.showPriceoon = false;
                        if (this.selectedRequestType == 'price') {
                            this.priceResponse = testparsedresponse;
                            this.showPriceResponse = true;
                        }else{
                            this.providerResponse = testparsedresponse;
                            this.showProviderResponse = true;
                        }

                        this.isLoading = false;
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success',
                            message: 'Data fetched successfuly!',
                            variant: 'success'
                        }));
                    }else{
                        
                        console.log('test1')
                        this.isLoading = false;
                        console.log('no data1');
                        if (testparsedresponse.length==0) {
                            this.errorMessage='There is no data in the given parameters!'
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'There is no data in the given parameters!',
                                variant: 'error'
                            }));
                        }else{
                            this.errorMessage=testparsedresponse[0].error.message
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'There is no data in the given parameters!',
                                message: testparsedresponse[0].error.message,
                                variant: 'error'
                            }));
                        }
                        this.isError=true;
                    }
                    
                    
                    
                }
            })
            .catch(error => {
                console.log('error')
                console.error(error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'An error occured.',
                    variant: 'error'
                }));
            });
        }else{
            if (this.fromDate==undefined || this.fromDate==null || this.fromDate==='') {
                this.fromDate=this.todayDate;
            }
            if (this.toDate==undefined || this.toDate==null || this.toDate==='') {
                this.toDate=this.todayDate;
            }
            console.log('test');
            console.log(this.toDate);
            console.log(this.fromDate);
            console.log(this.revCodeCheckBox);
            fairHealthAndMedicareRequest({
                procedureCodes:JSON.stringify(selectedProcedureCodes),
                tins:JSON.stringify(selectedTins),
                tpaAcronym:selectedTpaAcronym,
                networkAcronyms: JSON.stringify(selectedNetworkAcronyms),
                claimType:this.valuePlaceOfService,
                zips:JSON.stringify(selectedzip),
                fromDate:this.fromDate,
                toDate:this.toDate,
                revCodeCheckBox:this.revCodeCheckBox,
                quantity:this.quantity,
                drgCodeCheckBox:this.drgCodeCheckBox
            })
            .then(result => {
                console.log('test');
                console.log(result[0]);
                if (result) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: 'You have successfuly sent the request.',
                        variant: 'success'
                    }));
                    let tempValues=[];
                    for (let index = 0; index < result.length; index++) {
                        let value={networkAcronyms:result[index].networkAcronyms, parsedResponse:JSON.parse(result[index].returnValue),showPriceoon:false};
                        //let parsedResponse = JSON.parse(result[index].returnValue);
                        
                        console.table(value.parsedResponse);
                        if (value.parsedResponse.success==true) {
                            value.parsedResponse.Data.forEach(element=>{
                                element.ScrubID=element.ScrubID.substring(0,5);
                            })
                            // console.log('deneme');
                            // console.log(value.parsedResponse.Data.ScrubID);
                            // let temp=value.parsedResponse.Data.ScrubID;
                            // temp=String(temp).substring(0,2);
                            // console.log(temp);
                            // value.parsedResponse.Data.ScrubID=temp;
                            value.showPriceoon=true;
                            tempValues.push(value);
                            //this.priceoon=value.parsedResponse.Data;

                            this.showPriceoon = true;
                            this.showPriceResponse = false;
                            this.showProviderResponse = false;
    
                            this.isLoading = false;
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'Success',
                                message: 'Data fetched successfuly!',
                                variant: 'success'
                            }));
                        }else{
                            console.log('test1')
                            this.isLoading = false;
                            console.log('no data2');
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'There is no data in the given parameters!',
                                message: value.parsedResponse.Message,
                                variant: 'error'
                            }));
                        }
                        
                    }
                    this.priceoon=tempValues;
                    console.log('test');
                    console.log(this.priceoon);

                }
            })
            .catch(error => {
                console.log('error')
                console.error(error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'An error occured.',
                    variant: 'error'
                }));
            });
        }
        
    }


    handleProcedureCodeChange(event){
        let inputVal = event.target.value;
        event.target.value = inputVal.replace("[^0-9]", "");
        this.procedureCodes = inputVal;
    }
    handleTinChange(event){
        this.tins = event.detail.value;
    }
    handleTPAAcronymChange(event){
        this.tpaAcronym = event.detail.value;
        if (this.selectedRequestType!='priceoon') {
            this.isLoading = true;
            getNetworks({tpaAcronym:this.tpaAcronym})
            .then(result => {
                console.log(result);
                this.isLoading = false;
                let tempRecs = [];
            result.forEach( ( record ) => {
                let tempRec = Object.assign( {}, record );  
                tempRec.label = tempRec.Network__c;
                tempRec.value = tempRec.Acronym__c;
                tempRecs.push( tempRec );
            });
            this.networksMap = tempRecs;
            this.networkAcronymsOptions = this.networksMap;
            console.log('this.networksMap ',this.networksMap)
            })
            .catch(error => {
                console.log('Errored out.');
            });
            //this.networkAcronymsOptions = this.networkMap[this.tpaAcronym];
        }
        
        // if (this.tpaAcronym == 'HMA' || this.tpaAcronym == 'BMA' || this.tpaAcronym == 'CNS'||this.tpaAcronym == 'CW') {
        //     this.networkAcronymsOptions = this.networkMap['DMA'];
        // }
        
    }
    handleNetworkAcronymChange(event){
        this.networkAcronyms = event.detail.value;
        console.log(this.networkAcronyms);
    }

    isValidJSON(input){
        try {
            JSON.parse(input);
        } catch (error) {
            return false;
        }
        return true;
    }
    handleZipChange(event){
        this.zip=event.detail.value;
    }
    handleChangePlaceOfService(event){
        this.valuePlaceOfService = event.detail.value;
        if (!this.drgCodeCheckBox) {
            getClaimType({
                claimType:this.valuePlaceOfService
            }).then(result=>{
                this.claimTypeValue=result;
            }).catch(error=>{
                console.log('claim type error');
                console.log(error);
            })
        }

    }
    changeDate(event){
        console.log(event.target.dataset.name);
        let name=event.target.dataset.name;
        if (name=='FromDate') {
            this.fromDate=event.detail.value;
        }
        if(name=='ToDate') {
            this.toDate=event.detail.value;
        }
        console.log(this.fromDate);
        console.log(this.toDate);
    }
    RevCodeCheckbox(event){
        console.log(event.detail.checked)
        this.revCodeCheckBox=event.detail.checked;
    }
    changeQuantity(event){
        this.quantity=event.detail.value;
    }

    forTestRequestMRF(){
        this.testRequest=true;
        this.getRetrieveMRFDetails();
        this.testRequest=false;
    }
    @track returnValueJsonParse=[];
    @track mrfDetailBoolen=false;
    @track lastUploadDate='';
    @track lastUploadDateBoolen=false;
    getRetrieveMRFDetails(){
        this.returnValueJsonParse=[];
        retrieveMRFDetails({
            tpaAcronym:this.tpaAcronym,
            isTest:this.testRequest
        }).then(result=>{
            console.log('result');
            console.log(result);
            let returnValueJsonParse=JSON.parse(result);
            
            console.log(returnValueJsonParse.length);
            console.table(returnValueJsonParse);
            if (returnValueJsonParse!='' && returnValueJsonParse.error == undefined) {
                this.returnValueJsonParse.push(returnValueJsonParse);
                
                this.mrfDetailBoolen=true;

            } else {
                this.isLoading = false;
                console.log('no data3');
                if (returnValueJsonParse=='') {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'There is no data in the given parameters!',
                        variant: 'error'
                    }));
                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'There is no data in the given parameters!',
                        message: returnValueJsonParse.error.message,
                        variant: 'error'
                    }));
                }
            }
            if (this.returnValueJsonParse.length>0) {
                this.returnValueJsonParse.forEach(elementForFile => {
                    elementForFile.files.forEach(element => {
                        element.style="overflow-wrap: break-word; "
                        var date1=new Date(element.created_date);
                        var todayDate=new Date(this.todayDate);
                        
                        const diffTime = Math.abs(todayDate - date1);
                        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)); 
                        console.log('date1')
                        console.log(date1)
                        console.log(todayDate)
                        console.log(diffTime)
                        console.log(diffDays)
                        element.daysAgo=diffDays
                        if (diffDays>=45) {
                            console.log('if ici')
                            console.log(diffDays)
                            this.lastUploadDateBoolen=true;
                            element.style="overflow-wrap: break-word; background: #b73530; color:white; border-radius: 15px;"
                            this.lastUploadDate=diffDays;
                            console.log(element.style)
                        }
    
                    });
                });


            }
            

            
        }).catch(error=>{
            console.log('error');
            console.log(error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'An error occured.',
                variant: 'error'
            }));
        })
    }
    @track showResponse;
    showResponseBoolen=false;
    myJSON;
    @track errorMessage;
    ShowResponceClick(event){
        this.showResponseBoolen = event.target.checked;
        var Response1;
        if (this.selectedRequestType == 'price') {
            
            Response1=this.priceResponse;
            console.log('price')
            console.log(Response1)
        }else if(this.selectedRequestType == 'priceoon'){
            Response1=this.priceoon;
            console.log('priceoon')
            console.log(Response1)
        }else if(this.selectedRequestType == 'provider'){
            Response1=this.providerResponse;
            console.log('provider')
            console.log(Response1)
        }
        if ((this.errorMessage!=null || this.errorMessage!='' || this.errorMessage!=undefined) && this.isError) {
            Response1=this.errorMessage;
            console.log('errorMessage')
            console.log(Response1)
            console.log(this.showResponse)
            console.log(this.isError)
        }
        // else{
        //     Response1=this.returnValueJsonParse;
        // }
        console.log(JSON.stringify(Response1,null,2));
        this.showResponse=JSON.stringify(Response1,null,2);
    }
    CloseModel(event){
        this.showResponseBoolen=false;
        this.template.querySelectorAll('.checkboxForValue')[0].checked=false;
    }
    drgCodeCheckbox(event){
        console.log(event.detail.checked)
        this.drgCodeCheckBox=event.detail.checked;
        if (event.detail.checked) {
            this.claimTypeValue='I';
        }else{
            this.valuePlaceOfService='11';
            this.claimTypeValue='P'
        }

    }
}