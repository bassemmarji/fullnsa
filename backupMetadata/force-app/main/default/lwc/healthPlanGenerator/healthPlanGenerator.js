import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord, deleteRecord, getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

import getHpi from '@salesforce/apex/HealthPlanGenerator.getHpi';
import getHpContent from '@salesforce/apex/HealthPlanGenerator.getHpContent';
import getHpiStructure from '@salesforce/apex/HealthPlanGenerator.getHpiStructure';
import getSingleHPC from '@salesforce/apex/HealthPlanGenerator.getSingleHPC';
import deleteHPC from '@salesforce/apex/HealthPlanGenerator.deleteHPC';
import deleteHP from '@salesforce/apex/HealthPlanGenerator.deleteHP';
import deepCloneStructureMethod from '@salesforce/apex/HealthPlanGenerator.deepCloneStructureMethod';
import deepCloneInsertHPItemsMethod from '@salesforce/apex/HealthPlanGenerator.deepCloneInsertHPItemsMethod';
import getAllCriterias from '@salesforce/apex/HealthPlanGenerator.getAllCriterias';
import createMatchingRule from '@salesforce/apex/HealthPlanGenerator.createMatchingRule';
import getCloneHpiStructure from '@salesforce/apex/HealthPlanGenerator.getCloneHpiStructure';
import getHplanSummaryStructure from '@salesforce/apex/HealthPlanGenerator.getHplanSummaryStructure';
import getHPContentSummaryStructure from '@salesforce/apex/HealthPlanGenerator.getHPContentSummaryStructure';
import getAllMatchingRule from '@salesforce/apex/HealthPlanGenerator.getAllMatchingRule';

import Hp_OBJECT from '@salesforce/schema/IntPS__Health_Plan__c';
import HP_Name from '@salesforce/schema/IntPS__Health_Plan__c.Name';
import Hp_DeductCalType from '@salesforce/schema/IntPS__Health_Plan__c.IntPS__Deductible_Calculation_Type__c';
import Hp_OutCalType from '@salesforce/schema/IntPS__Health_Plan__c.IntPS__Out_Of_Pocket_Calculation_Type__c';
import Hp_PocketMaxFamily from '@salesforce/schema/IntPS__Health_Plan__c.IntPS__Out_of_Pocket_Max_Family__c';
import Hp_PocketMaxIndividual from '@salesforce/schema/IntPS__Health_Plan__c.IntPS__Out_of_Pocket_Max_Individual__c';
import Hp_PlanDeductibleFamily from '@salesforce/schema/IntPS__Health_Plan__c.IntPS__Plan_Deductible_Family__c';
import Hp_PlanDeductibleIndividual from '@salesforce/schema/IntPS__Health_Plan__c.IntPS__Plan_Deductible_Individual__c';
import Hp_ExternalId from '@salesforce/schema/IntPS__Health_Plan__c.IntPS__ExternalID__c';
import Hp_Employer from '@salesforce/schema/IntPS__Health_Plan__c.IntPS__Employer__c';
import Hp_Begin_Date from '@salesforce/schema/IntPS__Health_Plan__c.IntPS__Begin_Date__c';
import Hp_NSA__Disclaimer from '@salesforce/schema/IntPS__Health_Plan__c.IntPS_NSA__Disclaimer__c';
import Hp_PlanType from '@salesforce/schema/IntPS__Health_Plan__c.Plan_Type__c';


import Hpc_OBJECT from '@salesforce/schema/IntPS__Health_Plan_Content__c';
import Hpc_Name from '@salesforce/schema/IntPS__Health_Plan_Content__c.Name';
import Hpc_HP from '@salesforce/schema/IntPS__Health_Plan_Content__c.IntPS__Health_Plan__c';
import Hpc_ProviderNetwork from '@salesforce/schema/IntPS__Health_Plan_Content__c.IntPS__Provider_Network__c';
import Hpc_DeductInd from '@salesforce/schema/IntPS__Health_Plan_Content__c.IntPS__Plan_Deductible_Individual__c';
import Hpc_DeductFam from '@salesforce/schema/IntPS__Health_Plan_Content__c.IntPS__Plan_Deductible_Family__c';
import Hpc_OpInd from '@salesforce/schema/IntPS__Health_Plan_Content__c.IntPS__Out_of_Pocket_Max_Individual__c';
import Hpc_OpFam from '@salesforce/schema/IntPS__Health_Plan_Content__c.IntPS__Out_of_Pocket_Max_Family__c';
import Hpc_DeductCalType from '@salesforce/schema/IntPS__Health_Plan_Content__c.IntPS__Deductible_Calculation_Type__c';
import Hpc_OpCalType from '@salesforce/schema/IntPS__Health_Plan_Content__c.IntPS__Out_Of_Pocket_Calculation_Type__c';
import Hpc_ClaimType from '@salesforce/schema/IntPS__Health_Plan_Content__c.IntPS__Claim_Type__c';
import Hpc_CrossAcc from '@salesforce/schema/IntPS__Health_Plan_Content__c.IntPS__Cross_Accumulate__c';
import Hpc_DeductCalTypeF from '@salesforce/schema/IntPS__Health_Plan_Content__c.IntPS__Deductible_Calculation_TypeF__c';
import Hpc_OpCalTypeF from '@salesforce/schema/IntPS__Health_Plan_Content__c.IntPS__Out_Of_Pocket_Calculation_TypeF__c';
import Hpc_DeductFamF from '@salesforce/schema/IntPS__Health_Plan_Content__c.IntPS__Plan_Deductible_FamilyF__c';
import Hpc_DeductIndF from '@salesforce/schema/IntPS__Health_Plan_Content__c.IntPS__Plan_Deductible_IndividualF__c';
import Hpc_OpFamF from '@salesforce/schema/IntPS__Health_Plan_Content__c.IntPS__Out_of_Pocket_Max_FamilyF__c';
import Hpc_OpIndF from '@salesforce/schema/IntPS__Health_Plan_Content__c.IntPS__Out_of_Pocket_Max_IndividualF__c';

import Hpi_OBJECT from '@salesforce/schema/IntPS__Health_Plan_Item__c';
import Hpi_Name from '@salesforce/schema/IntPS__Health_Plan_Item__c.Name';
import Hpi_HealthPlan from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Health_Plan__c';
import Hpi_HealthPlanContent from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Health_Plan_Content__c';
import Hpi_DeductibleAmount from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Add_to_Deductible_Amount__c';
import Hpi_AfterPlanDeductible from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__After_Plan_Deductible__c';
import Hpi_Coinsurance from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Coinsurance__c';
import Hpi_Copay from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Copay__c';
import Hpi_NotCovered from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Not_Covered__c';
//import Hpi_MaxBenefit from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Maximum_Benefit__c';
import Hpi_MaxPaid from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Maximum_Paid_Amount__c';
import Hpi_MaxNumberPerYear from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Maximum_Number_Per_Year__c';
import Hpi_PCClass from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Procedure_Code_Classification__c';
//import Hpi_BenefitStep from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Benefit_Step__c';
import Hpi_PerAdmin from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Maximum_Number_Per_Admission__c';
import Hpi_Desc from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Description__c';
import Hpi_Network from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Provider_Network__c';
import Hpi_IsException from '@salesforce/schema/IntPS__Health_Plan_Item__c.Is_Exceptional_Case__c';
import Hpi_BeginDate from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Begin_Date__c';
import Hpi_TermDate from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Term_Date__c';
import Hpi_ExFromOutOfPocket from '@salesforce/schema/IntPS__Health_Plan_Item__c.IntPS__Exclude_From_Out_of_Pocket_Maximum_Limit__c';

import Criteria_OBJECT from '@salesforce/schema/IntPS__Criteria__c';
import Criteria_Name from '@salesforce/schema/IntPS__Criteria__c.Name';
import Criteria_Condition from '@salesforce/schema/IntPS__Criteria__c.IntPS__Condition__c';
import Criteria_EntityType from '@salesforce/schema/IntPS__Criteria__c.IntPS__Entity_Type__c';
import Criteria_Field from '@salesforce/schema/IntPS__Criteria__c.IntPS__Field__c';
import Criteria_FriendlyName from '@salesforce/schema/IntPS__Criteria__c.IntPS__Friendly_Name__c';
import Criteria_Index from '@salesforce/schema/IntPS__Criteria__c.IntPS__Index__c';
import Criteria_Value from '@salesforce/schema/IntPS__Criteria__c.IntPS__Value__c';
import Criteria_Desc from '@salesforce/schema/IntPS__Criteria__c.IntPS__Description__c';




/* eslint-disable no-console */
/* eslint-disable no-alert */
export default class HealthPlanGenerator extends NavigationMixin(LightningElement) {

    @track healthPlanId;
    @track healthPlanContentId;
    @track currentHPCid;
    @track currentHpcViewForm = false;
    @track currentStep = 'step-1';
    @track currentStep1 = true;
    @track currentStep2 = false;
    @track currentStep3 = false;
    @track searchValue;
    @track confirmModal = false;
    @track confirmModalHPI = false;
    @track deleteText;
    @track url;
    @track viewFormHp = false;
    @track viewFormHpc = false; 
    @track viewFormHpi = false; 
    @track newContent = true;
    @track hpEditForm = true;
    @track hpiEditForm = false;
    @track showContentButton = true;
    @track showItemButton = false;
    @track openmodalHPI = false;
    @track openmodalHPC = false;
    @track initialForm;
    @track updateFormHpc = false;
    @track updateHpcId;
    @track openUpdateModalHpi = false;
    @track updateHpiId;
    @track deleteHpcId;
    @track HpObj = false;
    @track HpiObj = false;
    @track cloneData;
    @track cloneHPC;
    @track CloneForm = false;
    @track activeSections = ['A'];
    @track activeSectionsHPI = [];
    @track activeSectionsMessage = '';
    @track buttonDisplay = true;
    @track blankHpi = false;
    @track blankHpc = false;
    @track error;
    @track name;
    @track checkId;
    @track activeSectionName = 'B';
    @track bos;
    @track completedCloneHPC = false;
    @track allHPI = [];
    @track openDeepCloneModal = false;
    @track deepClonePlan;
    @track deepCloneContent;
    @track MRulePage = false;
    @track criteriaData;
    @track criteriaField;
    @track criteriaIdList = [];
    @track openCreateCriteria = false;
    @track mRuleLogicText;
    @track mRuleLogicTextApex;
    @track value = '';
    @track healthPlanItemModalHeader = 'Create New Health Plan Item';
    @track healthPlanItemId;
    @track afterSubmit = false;
    @track sortedBy;
    @track sortedDirection;
    @track clonedHPitem;
    @track CloneFormSingleHPI = false;
    @track summarySection = false;
    @track hpContentSummary = [];
    @track hpContentSummaryFormatted = [];
    @track hpContentSummarySize;
    @track hpContentSummaryRowSize;
    @track hpSummary;
    @track hpSummaryFormatted = [];
    clickedOnce = false;
    @track matchingRuleData;
    @track matchingRuleField;
    @track activeMR = false;

    @api recordId;
    
    @wire(getHpContent, {healthPlanId: '$healthPlanId'}) wiredHpc;
    @wire(getHpi, {healthPlanContentId: '$healthPlanContentId'}) wiredHpi;

    hp_object = Hp_OBJECT;
    hp_fields = [HP_Name, Hp_DeductCalType, Hp_OutCalType, Hp_PocketMaxIndividual, Hp_PocketMaxFamily, Hp_PlanDeductibleIndividual, Hp_PlanDeductibleFamily, Hp_ExternalId,Hp_Employer,Hp_Begin_Date,Hp_PlanType,Hp_NSA__Disclaimer];

    hpc_object = Hpc_OBJECT;
    hpc_fields1 = [Hpc_Name, Hpc_ClaimType, Hpc_DeductInd, Hpc_OpInd,  Hpc_CrossAcc , Hpc_ProviderNetwork, Hpc_DeductFam, Hpc_OpFam, Hpc_OpCalType, Hpc_DeductCalType];
    hpc_fields = [Hpc_Name, Hpc_HP, Hpc_DeductIndF,  Hpc_OpIndF, Hpc_ClaimType,  Hpc_ProviderNetwork,  Hpc_DeductFamF,  Hpc_OpFamF, Hpc_CrossAcc , Hpc_OpCalTypeF, Hpc_DeductCalTypeF]; //for viewForm
    hpc_fields2 = [Hpc_Name, Hpc_HP,  Hpc_ClaimType, Hpc_ProviderNetwork];

    hpi_object = Hpi_OBJECT;
    hpi_fields1 = [Hpi_Name, Hpi_BeginDate, Hpi_TermDate, Hpi_Network, Hpi_Coinsurance, Hpi_Copay, Hpi_DeductibleAmount, Hpi_NotCovered,  Hpi_MaxNumberPerYear,Hpi_PerAdmin,Hpi_AfterPlanDeductible, Hpi_ExFromOutOfPocket, Hpi_MaxPaid, Hpi_PCClass, Hpi_IsException,  Hpi_Desc];
    hpi_fields = [Hpi_Name, Hpi_HealthPlan, Hpi_HealthPlanContent, Hpi_BeginDate, Hpi_TermDate, Hpi_Network, Hpi_Coinsurance, Hpi_Copay, Hpi_MaxNumberPerYear, Hpi_MaxPaid, Hpi_DeductibleAmount, Hpi_NotCovered,  Hpi_PerAdmin, Hpi_PCClass, Hpi_AfterPlanDeductible, Hpi_ExFromOutOfPocket, Hpi_IsException, Hpi_Desc];
    
    criteria_fields = [Criteria_EntityType,  Criteria_Field, Criteria_Condition, Criteria_Value, Criteria_Index, Criteria_Desc, Criteria_FriendlyName ];
    
    connectedCallback() { 
        console.log('duyguu');
        console.log('basladım');
        console.log(Criteria_Name);
        this.url = window.location.origin + window.location.pathname;
        this.searchValue = this.getURLParameter('IntPS__Id'); 
        console.log('searchValue');
        console.log(this.searchValue);
        if(this.searchValue){
            console.log('ifteyim');
            this.healthPlanId = this.searchValue;
            this.hpEditForm = false;
            this.viewFormHp = true;
        }else{
            this.hpEditForm = true;
            this.viewFormHp = false;
        } 
        //this.newContent = false;
        if(this.viewFormHpc){
            console.log('getHealthPlanContent');
          this.getHealthPlanContent();  
        }
    }
     
    getHealthPlanItem(){
        getHpi({
            healthPlanContentId: this.healthPlanContentId
        })
        .then((data) => {
            this.wiredHpi.data = data;
            this.allHPI = data;


            //added later
            this.viewFormHpi = true;
            this.funcWorks = true;
            this.currentStep1 = false;
            this.currentStep2 = false;
            this.currentStep3 = true;
            this.currentStep = 'step-3'; //burayı değiştrdm step3=true
            this.viewFormHpc = false; //Selected content visibility adsa
            this.newContent = false;
            this.currentHpcViewForm = false;
            this.viewFormHp = false;
            this.hpEditForm = false;
            //this.showContentButton = false;
            //this.showHpiButton = false;
            if(this.healthPlanContentId != null || this.healthPlanContentId !== "" ){
                this.currentHpcViewForm = true;
                this.showItemButton = true;
            }
            //this.healthPlanItemCreator();
            //this.refreshHpi();
            if(this.wiredHpi.data === undefined || this.wiredHpi.data.length < 1){
                console.log('blank');
                this.bos = true;
            }else{
                console.log('blank deel');
                this.bos = false;
            }
        })
        .catch((error) => {
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
    }

    getHealthPlanContent(){
        getHpContent({
            healthPlanId: this.healthPlanId
        })
        .then((data) => {
            this.wiredHpc.data=data;
            if(this.wiredHpc.data === undefined || this.wiredHpc.data.length === 0){
                this.blankHpc = true;
            }
        })
        .catch((error) => {
            this.blankHpc = true;
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
    }

    getHplanSummaryStructure(){
        getHplanSummaryStructure({
            healthPlanId : this.healthPlanId
        })
        .then((data) => {
            let constData = data;
            //this.hpContentSummary = JSON.parse(JSON.stringify(data));
            if(constData){
                for(let key in constData){
                   // this.hpContentSummary.push({value:constData[key], key:key});
                    if(constData[key]){
                        for(let network in constData[key]){
                            if(constData[key][network].IntPS__Not_Covered__c){
                                this.hpContentSummary.push({network:network, value:'Not Applicable', key:key});                        
                            }else{
                                this.hpContentSummary.push({network:network, value:constData[key][network].Summary__c, key:key});
                            }
                        } 
                    }
                }
            }
            console.log(this.hpContentSummary);
            //this.hpContentSummarySize = data.length;
            //this.SummaryTotalRowSize = data.length + data.length;
            for(let i = 0; this.hpContentSummary.length > i; i++){
                let completed = false;
                if(this.hpContentSummary[i+1].key !== this.hpContentSummary[i].key){
                    for(let j = 0; this.hpContentSummary.length > j; j++){
                        if(this.hpContentSummary[i].key === this.hpContentSummary[j].key && this.hpContentSummary[i].network !== this.hpContentSummary[j].network){
                            if(this.hpContentSummary[i].network){
                                if(this.hpContentSummary[j].network){
                                    if(this.hpContentSummary[i].network === 'In-Network'){
                                        this.hpContentSummaryFormatted.push({key:this.hpContentSummary[i].key, inNetwork:this.hpContentSummary[i].value, nonNetwork:this.hpContentSummary[j].value})                                
                                        completed = true;
                                        break;
                                    }else if(this.hpContentSummary[i].network === 'Out-of-Network'){
                                        this.hpContentSummaryFormatted.push({key:this.hpContentSummary[i].key, inNetwork:this.hpContentSummary[j].value, nonNetwork:this.hpContentSummary[i].value})                                
                                        completed = true;
                                        break;
                                    }
                                }
                            }
                        }
                        if(completed){
                            break;
                        }
                    }
                }
            }
            const array = this.hpContentSummaryFormatted;
            this.hpContentSummaryFormatted = Array.from(new Set(array));
            console.log(this.hpContentSummaryFormatted);
        })
        .catch((error) => {
            this.hpContentSummary = undefined;
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
    }

    getHPContentSummaryStructure(){
        getHPContentSummaryStructure({
            healthPlanId: this.healthPlanId
        })
        .then((data) => {
            this.hpSummary = data;
            this.hpSummaryFormatted = [];
            let networkIndex;
            let nonNetworkIndex;
            for(let i = 0; data.length > i; i++){
                if(data[i].IntPS__Provider_Network__c === 'In-Network'){
                    networkIndex = i;
                }else{
                    nonNetworkIndex = i;
                }
            }

            this.hpSummaryFormatted.push({ networkDeductibleIndividual: data[networkIndex].IntPS__Plan_Deductible_IndividualF__c ,
                                           nonnetworkDeductibleIndividual: data[nonNetworkIndex].IntPS__Plan_Deductible_IndividualF__c ,  
                                           networkDeductibleFamily: data[networkIndex].IntPS__Plan_Deductible_FamilyF__c,
                                           nonnetworkDeductibleFamily: data[nonNetworkIndex].IntPS__Plan_Deductible_FamilyF__c,
                                           networkOOPIndividual: data[networkIndex].IntPS__Out_of_Pocket_Max_IndividualF__c , 
                                           nonnetworkOOPIndividual: data[nonNetworkIndex].IntPS__Out_of_Pocket_Max_IndividualF__c , 
                                           networkOOPFamily: data[networkIndex].IntPS__Out_of_Pocket_Max_FamilyF__c,
                                           nonnetworkOOPFamily: data[nonNetworkIndex].IntPS__Out_of_Pocket_Max_FamilyF__c})
            this.getHplanSummaryStructure();
        })
        .catch((error) => {
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
    }

    getHpiStructure(){
        getHpiStructure({
            healthPlanContentId: this.healthPlanContentId
        })
        .then((data) => {
            this.cloneData = data;
            //this.tek = this.cloneData[0];
            //console.log(JSON.stringify(this.cloneData));
            //console.log(this.cloneData);
        })
        .catch((error) => {
            this.cloneData = undefined;
            this.blankHpi = true;
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
    }

    getAllCriterias(){
        getAllCriterias()
        .then((data) => {
            this.criteriaData = this.handleDatatableData(data.lstDataTableData);
            this.criteriaField = this.handleDatatableColumns(data.lstDataTableFields);
            this.openCreateCriteria = false;
        })
        .catch((error) => {
            this.criteriaData = undefined;
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
    } 

    getAllMatchingRule(){
        getAllMatchingRule({
            healthPlanItemId : this.healthPlanItemId
        })
        .then((data) => {
            this.matchingRuleData = this.handleDatatableData(data.lstDataTableData);
            this.matchingRuleField = this.handleDatatableColumns(data.lstDataTableFields);
            if(this.matchingRuleData.length > 0){
                this.activeMR = true;
            }else{
                this.activeMR = false;
            }
            //this.openCreateCriteria = false;
        })
        .catch((error) => {
            this.matchingRuleData = undefined;
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
    }

    deepCloneStructureMethod(){
        deepCloneStructureMethod({
            healthPlanId : this.healthPlanId
        })
        .then((data) => {
            this.deepClonePlan = data.hpClone;
            this.deepCloneContent = data.hpcCloneList;
        })
        .catch((error) => {
            this.deepClonePlan = undefined;
            this.deepCloneContent = undefined;
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
    }

    deepCloneInsertHPItemsMethod(originalHPCId, clonedHPCId, clonedHPId, eventId){
        deepCloneInsertHPItemsMethod({
            originalHPCId : originalHPCId,
            clonedHPCId : clonedHPCId,
            clonedHPId : clonedHPId
        })
        .then((response) => {
            if(response != null){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: response,
                        variant: 'error',
                    }),
                );
            }else{
                if(this.template.querySelectorAll("lightning-record-edit-form")){
                    this.template.querySelectorAll("lightning-record-edit-form").forEach (form => {
                       let objApiName = JSON.parse(JSON.stringify(form.objectApiName));
                        if(objApiName.objectApiName === 'IntPS__Health_Plan_Content__c'){
                            form.querySelectorAll('lightning-input-field').forEach(input => {
                                if(form.id === eventId){
                                    input.disabled = true;
                                }
                        })
                        this.template.querySelectorAll("lightning-accordion-section").forEach (accordion => {
                            accordion.querySelectorAll('lightning-button').forEach(button => {
                                if(accordion.id === eventId){
                                    button.disabled = true;
                                }
                            })
                        })
                        }
                    })
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Health Plan Content is created',
                        variant: 'success',
                    }),
                );
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Health Plan Items are cloned',
                        variant: 'success',
                    }),
                );
            }
        })
        .catch((error) => {
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
    }

    createMatchingRule(){
        createMatchingRule({
            matchingRuleLogic : this.mRuleLogicTextApex,
            healthPlanItemId : this.healthPlanItemId
        })
        .then((data) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Matching Rule is created',
                    variant: 'success',
                }),
            );
            this.mRuleLogicText = "";
            this.getAllMatchingRule();
        })
        .catch((error) => {
            console.log('Errrorr');
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
    }

    getSingleHPC(){
        getSingleHPC({
            healthPlanContentId: this.healthPlanContentId
        })
        .then((data) => {
            this.cloneHPC = data;
            this.getHpiStructure();
            
        })
        .cath((error) =>{
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
    }
    
    selectFromHeaderStep1(){
        if(this.initialForm === 'none'){
            this.currentStep1=true;
            this.currentStep ='step-1';
            this.viewFormHp = false;
            this.hpEditForm = true;
            this.currentHPCid = '';
        }
        else{
            this.currentHPCid = '';
            this.currentStep1 = true;
            this.currentStep2 = false;
            this.currentStep3 = false;
            this.currentStep ='step-1';
            this.viewFormHp = true;
            this.viewFormHpc = false;
            this.viewFormHpi = false;
            this.newContent = false;
            this.hpEditForm = false;
            this.currentHpcViewForm = false;
        }
        this.summarySection = false;
    }

    selectFromHeaderStep2(){
        if(this.healthPlanId === null || this.healthPlanId === "" || this.healthPlanId === undefined){
            console.log('duyguskoo');
            this.currentHPCid = '';
            this.currentStep1 = false;
            this.currentStep2  = false;
            this.currentStep3 = false;
            this.currentStep = 'step-1';
            this.viewFormHpi = false;
            this.newContent = false;
            this.viewFormHp = false;
            this.hpEditForm = false;
            this.currentHpcViewForm = false;
            this.initialForm = 'none';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Please, Create Health Plan!',
                    variant: 'error',
                }),
            );
            this.selectFromHeaderStep1();
        }else{
            this.initialForm = '';
            console.log('duyguskoo222');
            this.currentHPCid = '';
            this.currentStep1 = false;
            this.currentStep2  = true;
            this.currentStep3 = false;
            this.currentStep = 'step-2';
            this.viewFormHpi = false;
            this.newContent = true;
            this.currentHpcViewForm = false;
            this.viewFormHp = false;
            this.hpEditForm = false;
            this.viewFormHpc = true;
              /* this.blankHpc = true;
            if(this.wiredHpc.data === undefined){
                this.blankHpc = true;
            }*/
            this.getHealthPlanContent();
        }
        /*if(this.viewFormHpc){
            this.getHealthPlanContent();
            this.showContentButton = true; 
            this.initialForm = 'begins'
            this.currentHPCid = '';
        }
        if(this.healthPlanId == null || this.healthPlanId === "" ){
            this.currentHPCid = '';
            this.currentStep1 = false;
            this.currentStep2  = false;
            this.currentStep3 = false;
            this.currentStep = 'step-1';
            this.viewFormHpi = false;
            this.newContent = false;
            this.viewFormHp = false;
            this.hpEditForm = false;
            this.currentHpcViewForm = false;
            this.initialForm = 'none'
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Please, Create Health Plan!',
                    variant: 'error',
                }),
            );
            this.selectFromHeaderStep1();
        }else{
            this.currentHPCid = '';
            this.currentStep1 = false;
            this.currentStep2  = true;
            this.currentStep3 = false;
            this.currentStep = 'step-2';
            this.viewFormHpi = false;
            this.newContent = true;
            this.currentHpcViewForm = false;
            this.viewFormHp = false;
            this.hpEditForm = false;
            if(this.wiredHpc.data["length"] > 0){
                this.viewFormHpc = true;
                this.newContent = false;
            }
        }
        if(this.wiredHpc.data.length === 0){
            console.log('burdayımmm');
            this.viewFormHpc = true;
            this.blankHpc = true;
        }*/
        this.summarySection = false;
    }

    selectFromHeaderStep3(){
        if(this.healthPlanId != null || this.healthPlanId !== ""){
            if(this.currentHPCid == null || this.currentHPCid === ""){
                this.selectFromHeaderStep2();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Please, Create or Select Health Plan Content!',
                        variant: 'error',
                    }),
                );
            }
        }else if(this.healthPlanId == null || this.healthPlanId === ""){
            this.currentStep1 = false;
            this.currentStep2 = false;
            this.currentStep3 = false;
            this.currentStep = 'step-1';
            this.viewFormHpc = false; //Selected content visibility adsa
            this.viewFormHpi = false;
            this.newContent = false;
            this.currentHpcViewForm = false;
            this.viewFormHp = false;
            this.hpEditForm = false;
            this.dispatchEvent(
            new ShowToastEvent({
                title: 'Please, Create or Select Health Plan Content!',
                variant: 'error',
            }),
        );
        }
        this.summarySection = false;
    }

    healthPlanContentCreator(){
        this.currentStep2 = true;
        this.newContent = true;
    }

    healthPlanItemStep(event){
        this.currentHPCid = event.target.value; //event.target.dataset.recordid;  generation type modalı yaratılırken sildim,geri koydum
        this.healthPlanContentId = this.currentHPCid;
        this.getHealthPlanItem();
        /*//refreshApex(this.wiredHpi);
        this.viewFormHpi = true;
        this.funcWorks = true;
        this.currentStep1 = false;
        this.currentStep2 = false;
        this.currentStep3 = true;
        this.currentStep = 'step-3'; //burayı değiştrdm step3=true
        this.viewFormHpc = false; //Selected content visibility adsa
        this.newContent = false;
        this.currentHpcViewForm = false;
        this.viewFormHp = false;
        this.hpEditForm = false;
        //this.showContentButton = false;
        //this.showHpiButton = false;
        if(this.healthPlanContentId != null || this.healthPlanContentId !== "" ){
            this.currentHpcViewForm = true;
            this.showItemButton = true;
        }
        //this.healthPlanItemCreator();
        //this.refreshHpi();
        if(this.wiredHpi.data === undefined || this.wiredHpi.data.length < 1){
            console.log('blank');
            this.bos = true;
        }else{
            console.log('blank deel');
            this.bos = false;
        }*/
    }
    
    getURLParameter(name){
        return decodeURIComponent(
            (new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20')
        )||null
    }

    setURLParameter(key,value){
        var url= document.location.pathname + key + value;
        window.history.replaceState(null, null, url);
    }

    healthPlanItemOpenModal(){
        this.currentStep3 = true;
        this.openmodalHPI = true;
        this.activeMR = false;
        this.healthPlanItemId = "";
        this.MRulePage = false;
        this.afterSubmit = false;
        this.healthPlanItemModalHeader = 'Create New Health Plan Item';
        this.mRuleLogicText = "";
    }

    healthPlanItemCloseModal(){
        this.openmodalHPI = false;
        this.openmodalHPC = false;
        this.openUpdateModalHpi = false;
        this.CloneForm = false;
        //this.getHealthPlanItem();
    }

    //getting hp id for setting hpc and hpi
    healthPlanCreator(event){
        /*this.Hpi_HealthPlan = event.detail.id;
        this.Hpc_HP = event.detail.id;
        console.log("this.Hpc_HP");
        console.log(this.Hpc_HP);*/
        this.healthPlanId = event.detail.id;
        this.setURLParameter('?IntPS__Id=',this.healthPlanId);
        //this.showCreateButton = true;
        /*this.currentStep1= false;
        this.currentStep2= true;
        this.currentStep3= false;
        this.currentStep= 'step-2';
        this.newContent = true;
        this.initialForm = 'begins';
        this.hpEditForm = false;
        console.log("1111");
        if(this.wiredHpc.data === undefined){
            this.newContent = true;
            console.log("2222");
        }else if (this.wiredHpc.data["length"] > 0) { 
           this.viewFormHpc = true;
            this.newContent = false;
           console.log("3333");
        }
        console.log("4444");*/
        this.selectFromHeaderStep2();
    }

    healthPlanItemCreator(){
        if(this.wiredHpi.data !== undefined){
            console.log('fazlaayım');
            this.viewFormHpi = true;
        }else{
           this.viewFormHpi = false;
        }
    }
    
    handleSubmitHpc(event) {
        event.preventDefault();
        console.log("event");
        console.log(JSON.stringify(event.detail));
        const fields = event.detail.fields;
        fields[Hpc_HP.fieldApiName] = this.healthPlanId;
        const recordInput = { apiName: Hpc_OBJECT.objectApiName,fields };
        console.log("event.detail.fields");
        console.log(JSON.stringify(fields));
        console.log("recordInput");
        console.log(JSON.stringify(recordInput));
        //this.template.querySelector('lightning-record-form').submit(fields);
       
        createRecord(recordInput)
        .then(record => { 
            this.healthPlanContentId = record.id;
            console.log("healthPlanContentId");
            console.log(this.healthPlanContentId);
            this.currentStep1 = false;
            //this.currentStep2 = false;         
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Health Plan Content is created',
                    variant: 'success',
                }),
            );
        this.blankHpc = false;
        this.viewFormHpc = true;
        this.newContent = false;
        this.showContentButton = true;
        this.activeSectionName = 'B';
        this.getHealthPlanContent();
        //return refreshApex(this.wiredHpc);
    }
        )
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
    }

    handleSubmitHpi(event) { 
        event.stopPropagation();
        event.preventDefault();
    
        console.log("event");
        console.log(JSON.stringify(event.detail));
        const fields = event.detail.fields;
        fields[Hpi_HealthPlan.fieldApiName] = this.healthPlanId;
        fields[Hpi_HealthPlanContent.fieldApiName] = this.healthPlanContentId;
        const recordInput = { apiName: Hpi_OBJECT.objectApiName,fields };
        console.log("event.detail.fields");
        console.log(JSON.stringify(fields));
        console.log("recordInput");
        console.log(JSON.stringify(recordInput));
        //this.template.querySelector('lightning-record-form').submit(fields);
        console.log("healthPlanContentId111");
        console.log(this.healthPlanContentId);
        createRecord(recordInput)
        .then(record => { 
            this.healthPlanItemId = record.id;
            this.currentStep1 = false;
            this.currentStep2 = false;  
            this.currentStep3 = true;       
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Health Plan Item is created',
                    variant: 'success',
                }),
            );
        this.currentHpcViewForm = true;
        this.showItemButton = true;
        this.viewFormHpi = true;
        this.bos = false;
        this.afterSubmit = true;
        if(this.template.querySelectorAll("lightning-button")){
            this.template.querySelectorAll("lightning-button").forEach (button => {
                if(button.label === 'Create Matching Rule'){
                    button.disabled = false;
                }
            })
        }
        console.log('keko');
        this.getHealthPlanItem();
        //return refreshApex(this.wiredHpi);
        }
        )
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
    }

    createMatchingRuleButton(){
        this.MRulePage = true;
        this.healthPlanItemModalHeader = 'Generate Matching Rule';
        this.activeMR = false;
        this.getAllCriterias();
        this.getAllMatchingRule();
    }

    createMatchingRuleButton1(event){
        this.openmodalHPI = true;
        this.activeMR = false;
        this.healthPlanItemId = event.target.value;
        this.MRulePage = true;
        this.healthPlanItemModalHeader = 'Generate Matching Rule';
        this.getAllCriterias();
        this.getAllMatchingRule();
    }

    updateHpFunc(){
        this.hpEditForm = true;
        this.viewFormHp = false;
    }

    updateHpcFunc(event){
        this.openmodalHPC = true;
        this.updateHpcId = event.target.value;
    }

    updateHpiFunc(event){
        this.openUpdateModalHpi = true;
        this.updateHpiId = event.target.value;
    }

    deleteHpiFunc(event){
        this.deleteHpiId = event.target.value;
        this.confirmModalHPI = true;
    }

    deleteHpiFunc2(){
        deleteRecord (this.deleteHpiId)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Delete',
                    message: 'Health Plan Item Is Deleted',
                    variant: 'success',
                }),
            );
            this.viewFormHpi = true;//new
            this.confirmModalHPI = false;
            this.selectFromHeaderStep3();
            //refreshApex(this.wiredHpi);
            this.getHealthPlanItem();
        })
    }
    
    deleteHpcFunc(){
        //this.deleteHpcId = event.target.value;
        var IdList = [];
        IdList.push(this.deleteHpcId);
        deleteHPC({hpcIdList: IdList})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent ({
                    title: 'Success',
                    message: 'Health Plan Items are also deleted',
                    variant: 'success',
                }),
            );
            if(this.wiredHpc.data.length === 1){
                this.blankHpc = true;
            }
            this.getHealthPlanContent();
        //return refreshApex(this.wiredHpc);
        })
        this.confirmModal = false;
        
    }

    deleteHpFunc (){
        var IdList = [];
        IdList.push(this.healthPlanId);
        deleteHP({hpIdList: IdList})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent ({
                    title: 'Success',
                    message: 'Health Plan Contents are also deleted',
                    variant: 'success',
                }),
            );
            this.initialForm = 'none';
            this.healthPlanId = null;
            //this.hpEditForm = true;
            this.selectFromHeaderStep1();
            this.navigateToWebPage();
            this.confirmModal = false;
            this.setURLParameter('','');
        })
        /*deleteRecord(this.healthPlanId)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Health Plan is deleted',
                    variant: 'success',
                }),
            );
            this.initialForm = 'none';
            this.healthPlanId = null;
            //this.hpEditForm = true;
            this.selectFromHeaderStep1();
        })
        this.navigateToWebPage();
        this.confirmModal = false;
        this.setURLParameter('','');*/
       
    }
    

    navigateToWebPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.url
                
            }
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.url
            }
        });
    }

    //confirmation modals
    openConfirmModalHp(){
        this.confirmModal = true;
        this.deleteText = 'If you are going on, Health Plan Content(s) and Health Plan Item(s) are also deleted.'
        this.HpObj = true;
    }

    openConfirmModalHpc(event){
        this.deleteHpcId = event.target.value;
        this.confirmModal = true;
        this.deleteText = 'If you are going on, Health Plan Items(s) are also deleted.'
        this.HpObj = false;
    }
    
    closeConfirmModal(){
        this.confirmModal = false;
        this.confirmModalHPI = false;
        this.CloneFormSingleHPI = false;
    }

    closeDeepCloneModal(){
        this.openDeepCloneModal = false;
        //this.getHealthPlanContent(); 
    }

    cloneHpiFunc(event){
        this.healthPlanItemId = event.target.value;
        console.log(this.healthPlanItemId);
        getCloneHpiStructure({
            healthPlanItemId : this.healthPlanItemId
        })
        .then((data) => {
            this.clonedHPitem = data;
            console.log(this.clonedHPitem);
            this.CloneFormSingleHPI = true;
        })
        .catch((error) => {
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
    }

    cloneHPCFunc(event){
        this.healthPlanContentId = event.target.value;
        this.CloneForm = true;
        this.buttonDisplay = true;
        this.blankHpi = false;
        this.completedCloneHPC = false;
        //this.activeSections = ['A'];
        this.getSingleHPC();
        //this.getHpiStructure();
        //console.log('this.cloneData');
       //console.log(JSON.stringify(this.cloneData));
    }

    handleSectionToggle(event) {
       console.log(event);
    }

    createCloneHPC(event){
        var hpcFields = [];
        event.preventDefault();
        //const editForm = this.template.querySelectorAll("lightning-record-edit-form");
        if(this.template.querySelectorAll("lightning-record-edit-form")){
            this.template.querySelectorAll("lightning-record-edit-form").forEach (form => {
                if(form.objectApiName === 'IntPS__Health_Plan_Content__c'){
                    hpcFields = form.querySelectorAll('lightning-input-field');
                }
            })
        }
        console.log("hpcFields",JSON.stringify(hpcFields));
        const fields = {};
        if(hpcFields){
            hpcFields.forEach(field => {
                fields[field.fieldName] = field.value;
            })
        }
        console.log("fields");
        console.log(JSON.stringify(fields));

        fields[Hpc_HP.fieldApiName] = this.healthPlanId;
        const recordInput = { apiName: Hpc_OBJECT.objectApiName, fields };
        console.log("recordInput");
        console.log(JSON.stringify(recordInput));

          
        //this.template.querySelectorAll("lightning-record-edit-form").querySelectorAll('lightning-button').display = "none";
        

        createRecord(recordInput)
        .then(record => { 
            this.healthPlanContentId = record.id;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Health Plan Content is created',
                    variant: 'success',
                }),
            ); 
            this.completedCloneHPC = true;
            this.activeSections = [''];
            if(this.template.querySelectorAll("lightning-record-edit-form")){
                this.template.querySelectorAll("lightning-record-edit-form").forEach (form => {
                    if(form.objectApiName === 'IntPS__Health_Plan_Content__c'){
                        form.querySelectorAll('lightning-input-field').forEach(input => {
                            input.disabled = true;
                        })
                        this.buttonDisplay = false;
                    }
                })
            }
            this.getHealthPlanContent();
        //return refreshApex(this.wiredHpc);
        }
        )
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: 'Error creating record' + error,  //error.body.message
                    variant: 'error',
                }),
            );
        });
    }


    createCloneHPI(event){
        var hpiFields = [];
        var eventId =  event.target.id;
        console.log('event');
        console.log(event);
        event.preventDefault();
        if(this.template.querySelectorAll("lightning-record-edit-form")){
            this.template.querySelectorAll("lightning-record-edit-form").forEach (form => {
                if(form.objectApiName === 'IntPS__Health_Plan_Item__c'){
                   if(form.id === eventId){
                       hpiFields = form.querySelectorAll('lightning-input-field');
                   }
                }
            })
        }
        console.log("hpiFields");
        console.log(JSON.stringify(hpiFields));
        const fields = {};
        if(hpiFields){
            hpiFields.forEach(field => {
                fields[field.fieldName] = field.value;
            })
        }
        console.log("fields");
        console.log(JSON.stringify(fields));

        fields[Hpi_HealthPlan.fieldApiName] = this.healthPlanId;
        fields[Hpi_HealthPlanContent.fieldApiName] = this.healthPlanContentId;
        const recordInput = { apiName: Hpi_OBJECT.objectApiName, fields };
        console.log("recordInput");
        console.log(JSON.stringify(recordInput));
      
        createRecord(recordInput)
        .then(record => { 
            //this.healthPlanContentId = record.id;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Health Plan Item is created',
                    variant: 'success',
                }),
            );
            if(this.template.querySelectorAll("lightning-record-edit-form")){
                this.template.querySelectorAll("lightning-record-edit-form").forEach (form => {
                    if(form.objectApiName === 'IntPS__Health_Plan_Item__c'){
                            form.querySelectorAll('lightning-input-field').forEach(input => {
                                if(form.id === eventId){
                                    input.disabled = true;
                                }
                        })
                        this.template.querySelectorAll("lightning-accordion-section").forEach (accordion => {
                            accordion.querySelectorAll('lightning-button').forEach(button => {
                                if(accordion.id === eventId){
                                    button.disabled = true;
                                }
                            })
                        })
                    }
                })
                
            }
        this.getHealthPlanItem();
        this.CloneFormSingleHPI = false;
        //return refreshApex(this.wiredHpi);
        }
        )
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: 'Error creating record' + error,  //error.body.message
                    variant: 'error',
                }),
            );
        });
    }

    handleToggleSection(event){
        this.activeSectionName = event.detail.openSections;
    }

    handleSuccess(){
        console.log('succccesss');
    }
    
    deepCloneFunction(event){
        this.healthPlanId = event.target.value;
        this.openDeepCloneModal = true; 
        this.deepCloneStructureMethod();
    }

    deepCloneActionFunction(){
       
    }

    saveDeepCloneHP(event){
        var hpFields = [];
        event.preventDefault();
        if(this.template.querySelectorAll("lightning-record-edit-form")){
            this.template.querySelectorAll("lightning-record-edit-form").forEach (form => {
                if(form.objectApiName === 'IntPS__Health_Plan__c'){
                    hpFields = form.querySelectorAll('lightning-input-field');
                }
            })
        }

        const fields = {};
        if(hpFields){
            hpFields.forEach(field => {
                fields[field.fieldName] = field.value;
            })
        }

        const recordInput = { apiName: Hp_OBJECT.objectApiName, fields };
        createRecord(recordInput)
        .then(record => { 
            this.healthPlanId = record.id;
            this.setURLParameter('?IntPS__Id=',this.healthPlanId);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Health Plan is created',
                    variant: 'success',
                }),
            );

            if(this.template.querySelectorAll("lightning-record-edit-form")){
                this.template.querySelectorAll("lightning-record-edit-form").forEach (form => {
                    let objApiName = JSON.parse(JSON.stringify(form.objectApiName));
                    if(objApiName.objectApiName === 'IntPS__Health_Plan__c'){
                        form.querySelectorAll('lightning-input-field').forEach(input => {
                                input.disabled = true;
                    })
                    this.template.querySelectorAll("lightning-button").forEach (button => {
                                button.disabled = true;
                        })
                    }
                    else if(objApiName.objectApiName === 'IntPS__Health_Plan_Content__c'){
                            form.querySelectorAll('lightning-input-field').forEach(input => {
                                    input.disabled = false;
                        })
                        this.template.querySelectorAll("lightning-accordion-section").forEach (accordion => {
                            accordion.querySelectorAll('lightning-button').forEach(button => {
                                    button.disabled = false;
                            })
                        })
                    }
                })
            }

        }
        )
        .catch(error => {
            console.log(JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: 'Error creating record' + JSON.stringify(error),  //error.body.message
                    variant: 'error',
                }),
            );
        });
    }

    saveAndDeepCloneHPI(event){
        var eventId =  event.target.id;
        var hpcFields = [];
        let objApiName = '';
        const fields = {};
        event.preventDefault();
        if(this.template.querySelectorAll("lightning-record-edit-form")){
            this.template.querySelectorAll("lightning-record-edit-form").forEach (form => {
                console.log('objectApiName*****');
                console.log(form.objectApiName);
                console.log(JSON.parse(JSON.stringify(form.objectApiName)));
                objApiName = JSON.parse(JSON.stringify(form.objectApiName));
                if(objApiName.objectApiName === 'IntPS__Health_Plan_Content__c'){
                    if(form.id === eventId){
                        hpcFields = form.querySelectorAll("lightning-input-field");
                        for(let i = 0; i < hpcFields.length; i++){
                                fields[hpcFields[i].fieldName] = hpcFields[i].value;
                        }
                    }
                }
            })
        }

        fields[Hpc_HP.fieldApiName] = this.healthPlanId;
        const recordInput = { apiName: Hpc_OBJECT.objectApiName, fields };
        createRecord(recordInput)
        .then(record => { 
            this.healthPlanContentId = record.id;
            this.deepCloneInsertHPItemsMethod(fields.Cloned_Content_Id__c, this.healthPlanContentId, this.healthPlanId , eventId);
        }
        )
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: 'Error creating record' + JSON.stringify(error),  //error.body.message
                    variant: 'error',
                }),
            );
        });
    }

    getSelectedRow(event){
        this.criteriaIdList = [];
        const selectedRows = event.detail.selectedRows;
        for (let i = 0; i < selectedRows.length; i++){
            this.criteriaIdList.push(selectedRows[i].Id);
        }
        console.log(this.criteriaIdList);
        let logicList = [];
        let logicText = "";
        for(let j = 0; j < this.criteriaIdList.length; j++){
            for(let k = 0; k < this.criteriaData.length; k++){
                if(this.criteriaIdList[j] === this.criteriaData[k].Id){
                    if(!logicList.includes((this.criteriaData[k].IntPS__Index__c))){
                        logicList.push(this.criteriaData[k].IntPS__Index__c);
                        if(logicList.length === 1){
                            logicText += this.criteriaData[k].IntPS__Index__c;
                        }else{
                            logicText += ' AND ' + this.criteriaData[k].IntPS__Index__c ;
                        }
                        console.log(logicList);
                    }
                }
            }
        }

        this.mRuleLogicText = logicText;
    }

    handleMRuleText(){
        if(this.template.querySelector("lightning-textarea")){
            let MRuleText = this.template.querySelector("lightning-textarea").value;
            if(MRuleText){
                let text1 = MRuleText.replace('AND', '&&');
                let text2 = text1.replace('OR', '||');
                console.log(text2);
                /*
                let MRuleANDText = '';
                let MRuleORText = '';
                let MRuleTextList = [];
                let MRuleTextList1 = [];
                if(MRuleText.includes('AND')){
                    MRuleTextList = MRuleText.split("AND");
                    for(let i = 0; i < MRuleTextList.length; i++){
                        if(MRuleTextList[i].includes('OR')){
                            MRuleTextList1 = MRuleTextList[i].split("OR");
                            for(let j = 0; j < MRuleTextList1.length; j++){
                                MRuleANDText += MRuleTextList1[j] + ' || ';
                            }
                        }else{
                            MRuleANDText += MRuleTextList[i] + ' && ';
                        }
                    }
                }
               console.log(MRuleANDText);
               console.log(MRuleORText);
    
               MRuleText.replace('AND', '&&');
               MRuleText.replace('OR', '||');
               console.log('HEY');
               console.log(MRuleText);*/
               
               this.mRuleLogicTextApex = text1;
            }
           this.createMatchingRule();
           this.getAllMatchingRule();
        }
    }

    createNewCriteria(){
        this.openCreateCriteria = true;
    }

    createNewCriteriaFunction(event){
        const fields = event.detail.fields;
        const recordInput = { apiName: Criteria_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(account => {
                //this.accountId = account.id;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Criteria is created',
                        variant: 'success',
                    }),
                );
                this.getAllCriterias();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }
    

    handleDatatableColumns(lstColumns){
        //chargeData listesine bir de bu lookup'ın gideceği yeri ekliyoruz /id şeklinde
        //bu eklediğimiz datayı da column attributes'ta onclicke veriyoruz. 
        //yalnızca name tipinde olanlara url veriyoruz 
        //boolean tipinde olanları checkbox olarak gösteriyoz
        //by cemolokko
        var fixedColumnReturnArray = [];
        for(let i=0 ; i < lstColumns.length; i++){
            let fName = lstColumns[i].fieldName;
            let ftype = lstColumns[i].type;
            if(fName.includes('__r')){
               if(fName.includes('__r.Name')){
                let fnameURL = fName + 'URL';
                    fixedColumnReturnArray.push({
                        label: lstColumns[i].label ,
                        fieldName: fnameURL, 
                        type: 'url', 
                        
                        sortable : 'true',
                        typeAttributes: { label : { fieldName : fName} } 
                    });
               }
               else if(ftype === 'boolean'){
                fixedColumnReturnArray.push({label :lstColumns[i].label, type : 'boolean' , fieldName : fName , sortable : 'true'});
               }
               else if(ftype === 'double'){
                fixedColumnReturnArray.push({label :lstColumns[i].label, type : 'number' , fieldName : fName , sortable : 'true'});
               }
               else{
                fixedColumnReturnArray.push({label :lstColumns[i].label, type : 'string' , fieldName : fName , sortable : 'true'});
               }
            }
            
            else if(ftype === 'double'){//even if its not in relationship
                fixedColumnReturnArray.push({label :lstColumns[i].label, type : 'number' , fieldName : fName , sortable : 'true'});
               }
            else{
                fixedColumnReturnArray.push({label :lstColumns[i].label, type : lstColumns[i].type , fieldName : fName, sortable : 'true'});
            }
        }
        //console.log(JSON.parse(JSON.stringify(fixedColumnReturnArray)));
        return fixedColumnReturnArray;
    }

    handleDatatableData(lstdata){ 
        //handles incoming  table data to show Lookup fields.
        //if lookup__r.Id den farklı bir seyse hemen onun için bir url yaratıyoruz. bu url sayesinde onclickte doğru yere gidecek
        var fixedDataReturnArray = [];
        for(let i = 0 ; i < lstdata.length; i++){
            let dataArrayObject = {};
            let dataKeys = Object.keys(lstdata[i]);
            dataKeys.forEach(function(dataKey){
                if(dataKey.includes('__r')){
                    let lookupKeys = Object.keys(lstdata[i][dataKey]);
                    lookupKeys.forEach(function(lookupKey){
                        if(lookupKey !== 'Id'){
                            let thisName  = lstdata[i][dataKey][lookupKey];
                            let newName = dataKey + '.' + lookupKey;
                            dataArrayObject[newName] = thisName;
                            dataArrayObject[newName + 'URL'] = '/' + lstdata[i][dataKey].Id;
                        }
                    })
                }
                else{
                    dataArrayObject[dataKey] = lstdata[i][dataKey];
                }
            });

            fixedDataReturnArray.push(dataArrayObject);
        }
       // console.log(JSON.parse(JSON.stringify(fixedDataReturnArray)));
        return fixedDataReturnArray;
    }

    selectFromHeaderStep4(){
        this.currentStep1=false;
        this.currentStep ='step-4';
        this.viewFormHp = false;
        this.hpEditForm = false;
        this.currentStep1 = false;
        this.currentStep2 = false;
        this.currentStep3 = false;
        this.viewFormHp = false;
        this.viewFormHpc = false;
        this.viewFormHpi = false;
        this.newContent = false;
        this.hpEditForm = false;
        this.currentHpcViewForm = false;
        this.summarySection = true;
        this.clickedOnce = true;
        //this.getHplanSummaryStructure();
        this.getHPContentSummaryStructure();
    }
}