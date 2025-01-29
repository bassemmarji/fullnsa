import {
    api,
    LightningElement,
    track,
    wire
} from 'lwc';
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
    getRecord,
    getFieldValue
} from "lightning/uiRecordApi";
import {
    loadStyle
} from 'lightning/platformResourceLoader';
import {
    getPicklistValues
} from 'lightning/uiObjectInfoApi';

//Custom Labels
import NSA_CPTSearchTimeoutError from '@salesforce/label/c.NSA_CPTSearchTimeoutError';
import NSA_CPTSearchTimeout from '@salesforce/label/c.NSA_CPTSearchTimeout';
import NSA_ProcedureListURL from '@salesforce/label/c.NSA_ProcedureListURL';
import NSA_ProcedureListText from '@salesforce/label/c.NSA_ProcedureListText';
import NSA_ProcedureIntro from '@salesforce/label/c.NSA_ProcedureIntro';
import NSA_AdminOverrideEmployer from '@salesforce/label/c.NSA_AdminOverrideEmployer';
import NSA_ElligibilityFound from '@salesforce/label/c.NSA_ElligibilityFound';
import NSA_ElligibilityNotFound from '@salesforce/label/c.NSA_ElligibilityNotFound';
import NSA_SystemNotAvailableMessage from '@salesforce/label/c.NSA_SystemNotAvailableMessage';
import orgName from '@salesforce/label/c.NSA_OrgName';
import checkEligIntro from '@salesforce/label/c.NSA_CheckEligibilityIntro';
import providerLine1 from '@salesforce/label/c.NSA_ProviderLine1';
import providerLine2 from '@salesforce/label/c.NSA_ProviderLine2';
import providerLine3 from '@salesforce/label/c.NSA_ProviderLine3';
import providerLine4 from '@salesforce/label/c.NSA_ProviderLine4';
import oonErrorLabel from '@salesforce/label/c.NSA_OONError';
import adminProfileId from '@salesforce/label/c.NSA_adminProfileId';
import NSA_CustomerSupportProfileId from '@salesforce/label/c.NSA_CustomerSupportProfileId';
import NSAEOBMessageDisplayed from '@salesforce/label/c.NSA_EOBMessageDisplayed';
import needsValidation from '@salesforce/label/c.NSA_NeedsValidation';
import providerSearchError from '@salesforce/label/c.NSA_ProviderSearchError';
import providerExample from '@salesforce/label/c.NSA_ProviderExample';
import NSA_PageTitle from '@salesforce/label/c.NSA_PageTitle';
import NSA_EligibilityTitle from '@salesforce/label/c.NSA_EligibilityTitle';
import NSA_EligibilityMessage from '@salesforce/label/c.NSA_EligibilityMessage';
import NSA_EligibilityInfo from '@salesforce/label/c.NSA_EligibilityInfo';
import NSA_EligibilityInfo_Client from '@salesforce/label/c.NSA_EligibilityInfo_Client';
import NSA_EligibilityInfo_EligibilityTitle from '@salesforce/label/c.NSA_EligibilityInfo_EligibilityTitle';
import NSA_EligibilityInfo_Networks from '@salesforce/label/c.NSA_EligibilityInfo_Networks';
import NSA_NPI_Title from '@salesforce/label/c.NSA_NPI_Title';
import NSA_NPI_Result from '@salesforce/label/c.NSA_NPI_Result';
import NSA_NPI_Selected from '@salesforce/label/c.NSA_NPI_Selected';
import NSA_CPT_ByCodeTitle from '@salesforce/label/c.NSA_CPT_ByCodeTitle';
import NSA_CPT_ByCodeExample from '@salesforce/label/c.NSA_CPT_ByCodeExample';
import NSA_CPT_ByDescriptionTitle from '@salesforce/label/c.NSA_CPT_ByDescriptionTitle';
import NSA_CPT_ByDescriptionExample from '@salesforce/label/c.NSA_CPT_ByDescriptionExample';
import NSA_CPT_SearchResults from '@salesforce/label/c.NSA_CPT_SearchResults';
import NSA_CPT_SelectedProcedures from '@salesforce/label/c.NSA_CPT_SelectedProcedures';
import NSA_CPT_PreConfirmMessage from '@salesforce/label/c.NSA_CPT_PreConfirmMessage';
import NSA_CPT_ConfirmButtonMessage from '@salesforce/label/c.NSA_CPT_ConfirmButtonMessage';
import NSA_Confirm_Title from '@salesforce/label/c.NSA_Confirm_Title';
import NSA_Confirm_TableTitle from '@salesforce/label/c.NSA_Confirm_TableTitle';
import NSA_Confirm_Message1 from '@salesforce/label/c.NSA_Confirm_Message1';
import NSA_Confirm_Message2 from '@salesforce/label/c.NSA_Confirm_Message2';
import NSA_NewQuery from '@salesforce/label/c.NSA_NewQuery';
import NSA_Submit from '@salesforce/label/c.NSA_Submit';
import NSA_Footer from '@salesforce/label/c.NSA_Footer';
import NSA_ProviderNPILink from '@salesforce/label/c.NSA_ProviderNPILink';
import NSA_ServersDown from '@salesforce/label/c.NSA_ServersDown';

//Static Ressources
import NSAToolHeader from '@salesforce/resourceUrl/NSAToolHeader';
import customTableDesign from '@salesforce/resourceUrl/customTableDesign';

//Backend Functions

import checkEmployerGroup from "@salesforce/apex/EOBEntryFormController.checkEmployerGroup";
//import getProviderByNPI from "@salesforce/apex/EOBEntryFormController.getProviderByNPI";
import createJiraTicket from "@salesforce/apex/EOBEntryFormController.createJiraTicket";
import hasOutOfNetwork from "@salesforce/apex/EOBEntryFormController.hasOutOfNetwork";
import handleSQLError from "@salesforce/apex/EOBEntryFormController.handleSQLError";
import getNetworksDetails from "@salesforce/apex/EOBEntryFormController.getNetworksDetails";
import getTPAAcro from "@salesforce/apex/EOBEntryFormController.getTPAAcro";
import insertSL from "@salesforce/apex/EOBEntryFormController.serviceLineInsert";
import serviceLineInsertPodPlan from "@salesforce/apex/EOBEntryFormController.serviceLineInsertPodPlan";
import getPatientInfo from "@salesforce/apex/EOBEntryFormController.getPatientInformation";
import getPatient from "@salesforce/apex/EOBEntryFormController.getPatient";
import getHPIList from "@salesforce/apex/EOBEntryFormController.getHPIList";
import getHPCList from "@salesforce/apex/EOBEntryFormController.getHPCList";
import checkExistingNPI from "@salesforce/apex/EOBEntryFormController.checkExistingNPI";
//import getPatientDependents from "@salesforce/apex/EOBEntryFormController.getPatientDependents";
import triggerCalculation from "@salesforce/apex/EOBEntryFormController.triggerCalculation";
import getProcedureCodes from "@salesforce/apex/EOBEntryFormController.getProcedureCodes";
import downloadPDF from '@salesforce/apex/EOBEntryFormController.getPdfFileAsBase64String';
import serversHeartbeat from "@salesforce/apex/EOBEntryFormController.serversHeartbeat";

//fields
import Place_Of_Service from '@salesforce/schema/IntPS__EOB_Line_Item__c.IntPS_NSA__Place_Of_Service__c';
import Provider_Type from '@salesforce/schema/IntPS__EOB_Line_Item__c.Provider_Type__c';
import PreventativePregn from '@salesforce/schema/IntPS__EOB_Line_Item__c.PreventativePregn__c';
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import USERPROFILE_ID from '@salesforce/schema/User.ProfileId';

import USER_ID from "@salesforce/user/Id";



export default class PricingApplication extends LightningElement {
    @api logoUrl;
    @api fieldSetName;
    @api isUsedForExperience;
    @api isPatient;
    @api isProvider;
    @api isPodPlan;
    @track cptcodetimeouterror;
    @track cptcodetimeout=false;
    @track isDisabled=false;
    @track NSA_ProcedureIntro=NSA_ProcedureIntro;
    @track serversUp=true;
    @track NSA_ServersDown=NSA_ServersDown;
    @track NSA_CPTSearchTimeout=NSA_CPTSearchTimeout;
    @track NSA_CPTSearchTimeoutError=NSA_CPTSearchTimeoutError;
    @track NSA_CustomerSupportProfileId=NSA_CustomerSupportProfileId;
    @track NSA_ElligibilityFound=NSA_ElligibilityFound;
    @track NSA_ElligibilityNotFound=NSA_ElligibilityNotFound;
    @track NSA_SystemNotAvailableMessage=NSA_SystemNotAvailableMessage;
    @track isEmployerActivated=true;
    @track oldDate=false;
    @track dateAndPatientSelected=true;
    @track patientSelected=false;
    @track todaysDate;
    @track NSA_ProcedureListURL=NSA_ProcedureListURL;
    @track NSA_ProcedureListText=NSA_ProcedureListText;
    @track NSA_ProviderNPILink=NSA_ProviderNPILink;
    @track npıSearchDisplayByGeo = false;
    @track npıSearchDisplayByName = true;
    @track selectedProviderType;
    @track startSearch = false;
    @track healthPlanName;
    @track NSA_Footer = NSA_Footer;
    @track NSA_Submit = NSA_Submit;
    @track NSA_NewQuery = NSA_NewQuery;
    @track NSA_Confirm_Message2 = NSA_Confirm_Message2;
    @track NSA_Confirm_Message1 = NSA_Confirm_Message1;
    @track NSA_Confirm_TableTitle = NSA_Confirm_TableTitle;
    @track NSA_Confirm_Title = NSA_Confirm_Title;
    @track NSA_CPT_ConfirmButtonMessage = NSA_CPT_ConfirmButtonMessage;
    @track NSA_CPT_PreConfirmMessage = NSA_CPT_PreConfirmMessage
    @track NSA_CPT_SelectedProcedures = NSA_CPT_SelectedProcedures;
    @track NSA_CPT_SearchResults = NSA_CPT_SearchResults
    @track NSA_CPT_ByDescriptionExample = NSA_CPT_ByDescriptionExample;
    @track NSA_CPT_ByDescriptionTitle = NSA_CPT_ByDescriptionTitle;
    @track NSA_CPT_ByCodeExample = NSA_CPT_ByCodeExample;
    @track NSA_CPT_ByCodeTitle = NSA_CPT_ByCodeTitle;
    @track NSA_NPI_Selected = NSA_NPI_Selected;
    @track NSA_NPI_Result = NSA_NPI_Result;
    @track NSA_NPI_Title = NSA_NPI_Title;
    @track NSA_EligibilityInfo_Networks = NSA_EligibilityInfo_Networks;
    @track NSA_EligibilityInfo_EligibilityTitle = NSA_EligibilityInfo_EligibilityTitle;
    @track NSA_EligibilityInfo_Client = NSA_EligibilityInfo_Client;
    @track NSA_EligibilityInfo = NSA_EligibilityInfo;
    @track NSA_EligibilityMessage = NSA_EligibilityMessage;
    @track NSA_EligibilityTitle = NSA_EligibilityTitle;
    @track NSA_PageTitle = NSA_PageTitle;
    @track tpaAcro;
    @track proceduresToInsert = [];
    @track allPlaceOfServiceValues = [];
    @track buttonsDisabled = false;
    @track oon;
    @track checkEligIntro = checkEligIntro
    @track tempIsProvider;
    @track networks = [];
    @track orgName = orgName;
    @track networkNames = [];
    @track networkNamesDisplay = [];
    @track availableNetworksForProvider= [];
    @track availablevalues = '';
    @track availableInController = false;
    @track providerLine1 = providerLine1;
    @track providerLine2 = providerLine2;
    @track providerLine3 = providerLine3;
    @track providerLine4 = providerLine4;
    @track needsValidation = needsValidation;
    @track needsValidationKey = true;
    @track NSAEOBMessageDisplayed = NSAEOBMessageDisplayed;
    @track oonErrorLabel = oonErrorLabel;
    @track searchForProcedures = false;
    @track procedureSelected = false;
    @track selectedProcedureCodes = [];
    @track eobSubmitted = false;
    @track procedures = [];
    @track selectedProcedures = [];
    @track npıSearchDisplay = false;
    @track eobError = false;
    @track lineItemDisplay = false;
    @track submitacc = false;
    @track clientName;
    @track networkOption;
    @track searchwithCode = false;
    @track searchNPIwithCode = false;
    @track searchwithDescription = false;
    @track searchNPIwithName = false;
    @track searched = false;
    @track searchValue;
    @track providerSearchError = providerSearchError;
    @track adminProfileId = adminProfileId;
    @track NPIsearchValue;
    @track accId = '';
    @track questionsError = false;
    @track procedureCodeList = [];
    @track searchedLine = false;
    @track searchedNPILine = false;
    @track hasProcedureCode = false;
    @track hasNPICode;
    @track templine = [];
    @track selectedProvider;
    @track userEmail;
    @track providerSelected = false;
    @track count = 0;
    @track providerNetwork;
    @track placeOfServicePickListValues = [];
    @track placeOfServicePickListValuesToDisplay = [];
    @track ProviderTypeLineItemValues = [];
    @track preventativeScreeningValues = [];
    @track LineitemInfo = false;
    @track oonError = false;
    @track outOfNetworkNames=[];
    @track outOfNetworks=[];
    @track providerNameInProvider;
    @track isAdmin = false;
    @track adminOverrideEmployer=NSA_AdminOverrideEmployer;
    @track isCustomerSupport=false;
    @track contactId;
    @track questionsChangeError = '';
    @track selectedprocedureSelectedConfirmed = false;
    @track providerId;
    @track pdfString;
    @track companyLogo = NSAToolHeader;
    @track dependents = [];
    @track dependentValue = '';
    @track submittedEob;
    @track eobId;
    @track serviceLineCount = 0;
    @track defaultServiceLineCount;
    @track openPatientInfoSection = false;
    @track openEOBInfoSection = true;
    @track clientId;
    @track eligibilityId;
    @track healthPlanId;
    @track properEligibilityList = [];
    @track selectedRowId;
    @track rowIndex;
    @track searchedDate;
    @track customTitle;
    @track npiNumber;
    @track patientId;
    @track patientName;
    @track providerExample = providerExample;
    @track eobFieldsSubmitted = {
        aServiceDate__c: 'a',
        Provider_Network__c: 'b',
        Provider_Account_Name__c: 'c',
        Patient__c: 'a',
    };

    @track hideCheckbox = false;
    @track NPIList = [];
    @track searchKey;
    @track records;
    @track error;
    @track selectedRecord;
    @track hpiList = [];
    @track hpcList = [];
    @track eobUrl;
    @track eobUrlOK = false;
    @track isLoaded = true;
    @track isNPILoaded = true;
    @track isProceduresLoaded = true;
    @track isEOBLoaded = true;
    @track hasSelectedProcedureCode = false;
    @track selectedElg;

    //datatable columns
    //column of a datatable 
    selectedProcedurescolumnsResults = [{
            label: 'Procedure Code',
            fieldName: 'Name',
            headerSort: false,
            hideDefaultActions: true,
            initialWidth: 150,
            wrapText: true,
            cellAttributes: {
                class: 'slds-size_1-of-5'
            },
        },
        {
            label: 'Description',
            fieldName: 'Description',
            headerSort: false,
            hideDefaultActions: true,
            wrapText: true,
            initialWidth: 335,
            cellAttributes: {
                class: 'slds-size_2-of-5'
            },
        },
        {
            label: 'Quantity',
            fieldName: 'IntPS__L2110_Units_of_Service_Paid_Count__c',
            headerSort: false,
            hideDefaultActions: true,
            wrapText: true,
            editable: true,
            initialWidth: 80,
            cellAttributes: {
                class: 'slds-size_1-of-5'
            },
        },
        {
            label: 'Action',
            type: 'button',
            hideDefaultActions: true,
            headerSort: false,
            wrapText: true,
            cellAttributes: {
                class: 'slds-size_1-of-5'
            },
            initialWidth: 100,
            disabled: this.buttonsDisabled,
            typeAttributes: {
                //iconName: 'utility:delete',
                title: 'Delete',
                variant: 'bare',
                alternativeText: 'Delete',
                label: 'Remove',
                name: 'Delete'


            }

        }
    ];
    //columns of the datatable where the user answers questions related to each procedure code
    selectedProceduresConfirmationcolumnsResults = [{
            label: 'Procedure Code',
            fieldName: 'Name',
            headerSort: false,
            hideDefaultActions: true,
            initialWidth: 150,
            wrapText: true,
            cellAttributes: {
                class: 'slds-size_1-of-5'
            },
        },
        {
            label: 'Description',
            fieldName: 'Description',
            headerSort: false,
            hideDefaultActions: true,
            wrapText: true,
            initialWidth: 335,
            cellAttributes: {
                class: 'slds-size_2-of-5'
            },
        },
        {
            label: 'Quantity',
            fieldName: 'IntPS__L2110_Units_of_Service_Paid_Count__c',
            headerSort: false,
            hideDefaultActions: true,
            wrapText: true,
            initialWidth: 80,
            cellAttributes: {
                class: 'slds-size_1-of-5'
            },
        },
        {
            label: 'What are these services related to?',
            fieldName: 'PreventativePregn__c',
            type: 'picklistColumn',
            headerSort: false,
            hideDefaultActions: true,
            wrapText: true,
            editable: false,
            typeAttributes: {
                placeholder: 'Choose Your Option',
                options: this.preventativeScreeningValues,
                value: 'Choose Your Option' // default value for picklist
                    ,
                context: {
                    fieldName: 'Name'
                },
                fieldName: 'PreventativePregn__c',
                disabled: { fieldName: 'tacticsDisabled' }
                },
            cellAttributes: {
                class: 'slds-size_1-of-5'
            }
        },
        {
            label: 'Where are the services being done?',
            fieldName: 'Place_Of_Service__c',
            type: 'picklistColumn',
            headerSort: false,
            hideDefaultActions: true,
            wrapText: true,
            editable: false,
            typeAttributes: {
                placeholder: 'Choose Your Option',
                options: this.placeOfServicePickListValuesToDisplay,
                value: 'Choose Your Option' // default value for picklist
                    ,
                context: {
                    fieldName: 'Name'
                },
                fieldName: 'Place_Of_Service__c',
                disabled: { fieldName: 'tacticsDisabled' }

            },
            cellAttributes: {
                class: 'slds-size_1-of-5'
            }
        },
        {
            label: 'What type of provider are you seeing?',
            fieldName: 'Provider_Type__c',
            type: 'picklistColumn',
            headerSort: false,
            hideDefaultActions: true,
            wrapText: true,
            editable: false,
            typeAttributes: {
                placeholder: 'Choose Your Option',
                options: this.ProviderTypeLineItemValues,
                value: 'Choose Your Option' // default value for picklist
                    ,
                context: {
                    fieldName: 'Name'
                },
                fieldName: 'Provider_Type__c',
                disabled: { fieldName: 'tacticsDisabled' }

            },
            cellAttributes: {
                class: 'slds-size_1-of-5'
            }
        }
    ];
    //column of the searched procedure codes datatable
    columnsResults = [{
            label: 'Procedure Code',
            fieldName: 'Name',
            headerSort: false,
            hideDefaultActions: true,
            wrapText: true,
            initialWidth: 120,
            cellAttributes: {
                class: 'slds-size_2-of-5'
            },
        },
        {
            label: 'Description',
            fieldName: 'Description',
            headerSort: false,
            hideDefaultActions: true,
            wrapText: true,
            initialWidth: 250,
            cellAttributes: {
                class: 'slds-size_2-of-5'
            },
        },
        {
            label: 'Status',
            fieldName: 'Status',
            headerSort: false,
            hideDefaultActions: true,
            wrapText: true,
            initialWidth: 120,
            cellAttributes: {
                class: {
                    fieldName: 'format'
                }
            },
        },
        {
            label: 'Action',
            type: 'button',
            hideDefaultActions: true,
            headerSort: false,
            wrapText: true,
            cellAttributes: {
                class: 'slds-size_1-of-5'
            },
            initialWidth: 90,
            disabled: this.buttonsDisabled,
            typeAttributes: {
                //iconName: 'utility:add',
                //title: 'Add',
                variant: 'bare',
                alternativeText: 'Add',
                label: 'Add',
                name: 'Add',
                disabled: {
                    fieldName: 'buttonsDisable'
                }


            }

        }
    ];

    //columns of the provider datatable

    @track NPIcolumnsResults = [{
            label: 'Provider Name',
            fieldName: 'ProviderName',
            headerSort: false,
            hideDefaultActions: true,
            type: 'text'
        },
        {
            label: 'Provider Code',
            fieldName: 'NPINumber',
            headerSort: false,
            hideDefaultActions: true,
            type: 'text'
        },
       
        {
            label: 'Provider City',
            fieldName: 'ProviderCity',
            headerSort: false,
            hideDefaultActions: true,
            type: 'text'

        },
        {
            label: 'Provider Street',
            fieldName: 'ProviderStreet',
            headerSort: false,
            hideDefaultActions: true,
            type: 'text'

        },
        {
            label: 'Provider State',
            fieldName: 'ProviderState',
            headerSort: false,
            hideDefaultActions: true,
            type: 'text'

        },
        {
            label: 'Provider Postal Code',
            fieldName: 'ProviderPostalCode',
            headerSort: false,
            hideDefaultActions: true,
            type: 'text'

        },
        {
            label: 'Provider Country',
            fieldName: 'ProviderCountry',
            headerSort: false,
            hideDefaultActions: true,
            type: 'text'

        },
        {
            label: 'Provider Phone',
            fieldName: 'ProviderPhone',
            hideDefaultActions: true,
            headerSort: false,
            type: 'text'

        },
        {
            label: 'Provider Network',
            fieldName: 'networkOption',
            hideDefaultActions: true,
            headerSort: false,
            type: 'text'

        }
        /*  {
              label: 'Select Provider',
              type: 'button',
              wrapText: true,
              typeAttributes: {
                  iconName: 'utility:bookmark',
                  title: 'Select',
                  variant: 'brand',
                  alternativeText: 'Select',
                  disabled: false,
                  label: 'Select',
                  name: 'Select'

              }
          }*/

    ];



    //wires
    // function used to determine if the user logged in , is an admin or a community user
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [USERPROFILE_ID, CONTACT_ID]
    })
    getUserProfileResponse({
        error,
        data
    }) {
        if (data) {
            console.log('checking profile details ' + data.fields.ProfileId.value + ' ' + adminProfileId);
            if (adminProfileId.includes(data.fields.ProfileId.value)) {
                this.isAdmin = true;
                this.eobFieldsSubmitted.IntPS__Data_Source__c = 'Paper';
                console.log('is admins ' + this.isAdmin);

            } else {
                if(this.NSA_CustomerSupportProfileId.includes(data.fields.ProfileId.value)){
                    this.isCustomerSupport = true;
                    this.eobFieldsSubmitted.IntPS__Data_Source__c = 'Paper';
                    console.log('is customer support ' + this.isCustomerSupport);
                }
                else{
                this.isAdmin = false;
                this.isCustomerSupport=false;
                this.eobFieldsSubmitted.IntPS__Data_Source__c = 'Portal';
                console.log('is admins ' + this.isAdmin);
                this.contactId = data.fields.ContactId.value;
                console.log('contact id ' + this.contactId);
               
                //if the user is not an admin, we search if the user is a patient in our system
                getPatient({
                    contactId: this.contactId
                }).then(result => {
                    console.log('results are?' + result.IntPS__Employer__c);
             //check if the employer group is activated for pricing application
                checkEmployerGroup({
                    patientEmployer: result[0].IntPS__Employer__c,
                    isAdmin:this.isAdmin
                }).then(result => {
                 this.isEmployerActivated=result;
                }).catch(error => {
                    console.log("errorrr");
                });
                    this.patientId = result[0].Id;
                    this.userEmail = result[0].IntPS__Email__c;
                    this.patientName = result[0].Name;
                    result.forEach(dependent => {
                        console.log('dependent ' + dependent);
                        console.log('dependen2t ' + dependent.Name)
                        const element = {
                            label: dependent.Name,
                            value: dependent.Id
                        };
                        this.dependents = [...this.dependents, element];
                        console.log('dependents ' + this.dependents)

                    })
                 
                    //if the user is a patient, we search for the familyt dependents
                  /*  getPatientDependents({
                        patientId: this.patientId
                    }).then(result => {
                        console.log('results dependents are?' + result);
                        result.forEach(dependent => {
                            console.log('dependent ' + dependent);
                            console.log('dependen2t ' + dependent.Name)
                            const element = {
                                label: dependent.Name,
                                value: dependent.Id
                            };
                            this.dependents = [...this.dependents, element];
                            console.log('dependents ' + this.dependents)

                        })
                    }).catch(error => {
                        console.log("errorrr");
                    });*/
                }).catch(error => {
                    console.log("errorrr" + JSON.stringify(error));
                });

            }
        }
        }
    }
    //get provider type field picklist values
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: Provider_Type
    })
    setProviderTypePicklistOptions({
        error,
        data
    }) {
        console.log('provider type data ' + JSON.stringify(data));
        if (data) {

            for (let i = 0; i < data.values.length; i++) {
                this.ProviderTypeLineItemValues.push({
                    label: data.values[i].label,
                    value: data.values[i].value,
                });
            }

            console.log('ProviderTypeLineItemValues ' + JSON.stringify(this.ProviderTypeLineItemValues));

        } else if (error) {
            console.log('error provider type ' + JSON.stringify(error));
        }
    }
    //get PreventativePregn field picklist values
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: PreventativePregn
    })
    setPreventativesPicklistOptions({
        error,
        data
    }) {
        if (data) {

            for (let i = 0; i < data.values.length; i++) {
                this.preventativeScreeningValues.push({
                    label: data.values[i].label,
                    value: data.values[i].value,
                });
            }

            console.log('preventativeScreeningValues ' + JSON.stringify(this.preventativeScreeningValues));

        } else if (error) {
            console.log(error);
        }
    }
    //get Place_Of_Service field picklist values
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: Place_Of_Service
    })
    setPicklistOptions({
        error,
        data
    }) {
        if (data) {
            this.allPlaceOfServiceValues = data;
            for (let i = 0; i < data.values.length; i++) {
                this.placeOfServicePickListValues.push({
                    label: data.values[i].label,
                    value: data.values[i].value,
                });
                this.placeOfServicePickListValuesToDisplay.push({
                    label: data.values[i].label,
                    value: data.values[i].label,
                });

            }


            console.log('placeOfServicePickListValues ' + JSON.stringify(this.placeOfServicePickListValues));

        } else if (error) {
            console.log(error);
        }
    }

    //handles
    //used when a system admin/customer service user searches for a patient
    handlePatientLookupChange(event) {
        console.log('You selected the patient: ' + event.detail.value[0]);
        this.patientId = event.detail.value[0];
        this.dependentValue = event.detail.value[0];
        console.log('dependentValue' +this.dependentValue);
        this.patientSelected=true;
        if(this.oldDate && this.dependentValue!=null){
            this.dateAndPatientSelected=false;
        }
        else{
            this.dateAndPatientSelected=true
        }
    }
    //this is used when we have a community user selecting himself or one of his dependents        
    handleDependentsChange(event) {
        this.dependentValue = event.detail.value;
        console.log('dependent value ' + this.dependentValue);
        this.patientSelected=true;
        if(this.oldDate && this.dependentValue!=null){
            this.dateAndPatientSelected=false;
        }
        else{
            this.dateAndPatientSelected=true
        }
    }
    // used when the user starts writing on the search bar of the procedure codes
    handleKeyUp(event) {
        const isEnterKey = event.keyCode === 13;
        this.searchValue = event.target.value;
        if (isEnterKey && this.searchValue.length > 3) {
            this.getProcedureCodes();
        }
      
    }
    //used when the user pasted an NPI in NPI Search
    handleNPIPaste(event){
        this.NPIsearchValue = event.target.value;
        if (isEnterKey && this.NPIsearchValue.length > 3) {
            this.isLoaded = false;
            this.checkExistingNPIAlll(this.NPIsearchValue);
        }
    }
    // used when the user starts writing on the search bar of the NPIs
    handleNPIKeyUp(event) {
        const isEnterKey = event.keyCode === 13;
        this.NPIsearchValue = event.target.value;
        if (isEnterKey && this.NPIsearchValue.length > 3) {
            this.isLoaded = false;
            this.checkExistingNPIAlll(this.NPIsearchValue);
        }
    }
    // used to increase/decrease quantity of the procedures selected
    handleCellChange(event) {
        const selectedProceduresMock = [...this.selectedProcedures];

        console.log('test handle');
        console.log('draftValues ' + JSON.stringify(event.detail.draftValues));
        this.template.querySelectorAll(".datatable-full-size").forEach((input) => {
            console.log('in datatable');
            input.suppressBottomBar = true;
            console.log(input.suppressBottomBar);
        })
        for (var i = 0; i < event.detail.draftValues.length; i++) {
            console.log('code changed ' + JSON.stringify(event.detail.draftValues[i]));
            const index = selectedProceduresMock.findIndex(object => {
                return object.Name === event.detail.draftValues[i].Name;
            });
            console.log(index); // Prints: 1
            selectedProceduresMock[index].IntPS__L2110_Units_of_Service_Paid_Count__c = event.detail.draftValues[i].IntPS__L2110_Units_of_Service_Paid_Count__c;
            for (let i = 0; i < selectedProceduresMock.length; i++) {
                console.log('selectedProceduresMock ' + selectedProceduresMock[i].IntPS__L2110_Units_of_Service_Paid_Count__c + ' ' + selectedProceduresMock[i].PreventativePregn__c);
            }
        }
        this.selectedProcedures = [];
        this.selectedProcedures.length = 0;
        console.log('selectedProcedures  ' + this.selectedProcedures);
        this.selectedProcedures = selectedProceduresMock;
        console.log('selectedProcedures2  ' + this.selectedProcedures);
    }
    // used when the user selects the provider on the datatable
    handleRowSelected(event) {
        var selectedRows = event.detail.selectedRows;
        this.providerSelected = true;
        console.log(this.providerSelected);
        this.providerId = selectedRows[0].ProviderName;
        this.selectedProvider = selectedRows[0];
   
        
        this.networkOption = this.selectedProvider.networkOption;
        console.log('networkOption2 ' + this.networkOption);

        this.submitacc = true;
        this.searchForProcedures = true;
        console.log('selectedProvider ' + this.selectedProvider.ProviderName + ' this.submitacc ' + this.submitacc + ' searchForProcedures ' + this.searchForProcedures + ' providerSelected ' + this.providerSelected);
    }
    //used to  add procedure codes, it means that when the user clicks on the Add button of the procedure list datatable
    handleRowAction(event) {
        this.hasSelectedProcedureCode = true;
        this.procedureSelected = true;
        this.addNewServiceLine();
        console.log('client1111 ' + this.clientName);
        const row = JSON.parse(JSON.stringify(event.detail.row));
        console.log('client2222 ' + this.clientName);
        const element = {
            Code: row.Name,
            Description: row.Description,
            Rate: row.Contracted_Rate__c,
            Quantity: 1
        };
        console.log('clien333 ');

        const element2 = {
            Name: row.Name,
            Description: row.Description,
            IntPS__L2110_Units_of_Service_Paid_Count__c: 1,
            Place_Of_Service__c: 'Choose Your Option',
            Provider_Type__c: 'Choose Your Option',
            PreventativePregn__c: 'Choose Your Option',
            Status: row.Status,
            healthPlanItemID: row.healthPlanItemID,
            CodeType: row.CodeType
        };
        this.selectedProcedures = [...this.selectedProcedures, element2];
        console.log('clien666 ');
        for (let i = 0; i < this.procedureCodeList.length; i++) {
            if (this.procedureCodeList[i].Name == row.Name) {
                console.log('before ' + this.procedureCodeList.length);
                this.procedureCodeList.splice(i, 1);
                this.procedureCodeList = [...this.procedureCodeList];
                console.log('after ' + this.procedureCodeList.length);
            }
        }
        for (let i = 0; i < this.selectedProcedures.length; i++) {
            console.log('selectedProcedures ' + this.selectedProcedures[i].Name + ' ' + this.selectedProcedures[i].IntPS__L2110_Units_of_Service_Paid_Count__c);
        }

    }
    //used to save the eob and the eob line items. ANd also does the error handling of the eob creation
    handleEobFormSubmit(event) {
        this.isDisabled=true;
        
        this.selectedProcedures = this.selectedProcedures.map((acc) => ({ ...acc, tacticsDisabled: true}));

        console.log('changing is disabled '+this.isDisabled);
        this.createProcedureListObject();
        this.eobError = false;
        this.isEOBLoaded = false;
        this.disableAll();
        this.removeProceduresDiv();
        this.toggleCheckEligibility();
        this.toggleNPI();
        this.toggleProcedures();
        this.removeEligibilityDiv();
        this.removeNPIDiv();
        this.removeProceduresDiv();
        console.log('handleEobFormSubmit');
        this.template.querySelectorAll(".checkClaimValidation")[0].innerHTML = '';
        console.log('test1');
        event.preventDefault();
        console.log('test2');
        this.eobFieldsSubmitted.IntPS_NSA__Service_Date__c = this.searchedDate;
        this.eobFieldsSubmitted.Provider_Network__c = this.networkOption;
        this.eobFieldsSubmitted.IntPS_NSA__Patient__c = this.dependentValue;
        console.log('test3');
        //fields.Provider_Name__c=this.providerId;
        this.eobFieldsSubmitted.Provider_Account_Name__c = this.providerId;
        this.eobFieldsSubmitted.IntPS_NSA__Provider_Name__c = this.selectedProvider.ProviderName;
        this.eobFieldsSubmitted.IntPS_NSA__Provider_NPI_Number__c = this.selectedProvider.NPINumber;
        this.eobFieldsSubmitted.IntPS_NSA__Provider_Billing_Street__c = this.selectedProvider.ProviderStreet;
        this.eobFieldsSubmitted.IntPS_NSA__Provider_Billing_City__c = this.selectedProvider.ProviderCity;
        this.eobFieldsSubmitted.IntPS_NSA__Provider_Billing_State__c = this.selectedProvider.ProviderState;
        this.eobFieldsSubmitted.IntPS_NSA__Provider_Billing_Postal_Code__c = this.selectedProvider.ProviderPostalCode;
        this.eobFieldsSubmitted.IntPS_NSA__Provider_Network__c = this.networkOption;
        console.log('test4 ' + this.dependentValue);
        this.eobFieldsSubmitted.Patient__c = this.dependentValue;
        console.log('test4 patient  ' + this.eobFieldsSubmitted.Patient__c + ' ' + this.eobFieldsSubmitted.IntPS_NSA__Patient__c);

        //this.eobFieldsSubmitted[EOB_ELIGIBILITY_FIELD.fieldApiName] = this.eligibilityId;
        console.log('2');
        console.log('client id ' + this.clientId);
        // this.eobFieldsSubmitted.IntPS_NSA__Client__c = this.clientId;
        console.log('3 ' + this.eobFieldsSubmitted.IntPS_NSA__Client__c);
        this.eobFieldsSubmitted.IntPS_NSA__Eligibility__c = this.eligibilityId;
        console.log('4' + this.eobFieldsSubmitted.IntPS_NSA__Eligibility__c);
        this.submittedEob = JSON.stringify(this.eobFieldsSubmitted);
        console.log('submittedEob ' + this.submittedEob);
        console.log('JSON.stringify(this.proceduresToInsert)' + JSON.stringify(this.proceduresToInsert));
        console.log('this.selectedProvider.ProviderPostalCode ' + this.selectedProvider.ProviderPostalCode);
        console.log('5');

        if (this.isPodPlan) {
            serviceLineInsertPodPlan({
                claimFields: this.submittedEob,
                procedures: JSON.stringify(this.proceduresToInsert),
                providerNumber: this.selectedProvider.NPINumber,
                serviceDate: this.searchedDate,
                networks: this.networks,
                networkOption: this.networkOption,
                tpaAcro: this.tpaAcro,
                networkNames: this.networkNames,
                userEmail: this.userEmail,
                patientId: this.dependentValue,
                outOfNetworkNames: this.outOfNetworkNames,
                providerZIP: this.selectedProvider.ProviderPostalCode,
                availableNetworksForProvider:this.availableNetworksForProvider
            }).then((result) => {
                this.eobSubmitted = true;
                this.CalculateTPA(result);
                this.eobError = false;
                this.eobUrlOK = true;
                this.isEOBLoaded = true;
                this.eobId = result;
            }).catch((error) => {});
        } else {
            console.log('outOfNetworkNames '+this.outOfNetworkNames);
            insertSL({
                claimFields: this.submittedEob,
                procedures: JSON.stringify(this.proceduresToInsert),
                providerNumber: this.selectedProvider.NPINumber,
                serviceDate: this.searchedDate,
                networks: this.networks,
                networkOption: this.networkOption,
                tpaAcro: this.tpaAcro,
                networkNames: this.networkNames,
                userEmail: this.userEmail,
                patientId: this.dependentValue,
                outOfNetworkNames: this.outOfNetworkNames,
                providerZIP: this.selectedProvider.ProviderPostalCode,
                healthPlanId:this.healthPlanId,
                availableNetworksForProvider:this.availableNetworksForProvider
            }).then((result) => {
                this.eobSubmitted = true;
                this.eobError = false;
                this.eobUrlOK = true;
                this.CalculateTPA(result);
                this.eobId = result;
                this.isEOBLoaded = true;
                console.log(result);
                let anyErrors = false;
                if (result.claimSWRList) {
                    for (var i = 0; i < result.claimSWRList.length; i++) {
                        if (!result.claimSWRList[i].isSucces) {
                            anyErrors = true;
                            //  this.template.querySelectorAll(".checkClaimValidation")[i].innerHTML = '<button color="red" class="slds-button slds-button_neutral" style=" margin-left:10px; margin-top:5px; border: none;background-color: red;color: white;"><label color="red">Error !</label></button>';
                            this.template.querySelectorAll(".checkClaimValidation")[i].innerHTML = '<button color="red" class="slds-button slds-button_neutral" style=" width:74.25px; margin-top:5px; border: none;background-color: red;color: white;"><label color="red">Error !</label></button>';
                            this.template.querySelectorAll(".checkClaimValidation")[i].title = result.claimSWRList[i].handleErrorList;
                            this.eobUrlOK = false;
                        } else {
                            this.eobId = result.claimSWRList[0].Id;
                            this.eobUrl = '/' + this.eobId;
                            this.eobUrlOK = true;
                            this.template.querySelectorAll(".fileUpload").forEach((input) => {
                                input.disabled = false;
                            })
                        }
                    }
                }

                if (result.serviceSWRList) {
                    for (var i = 0; i < result.serviceSWRList.length; i++) {
                        var customTitle = '';
                        var customHTML = '';
                        var customText = '';
                        var csstext = '';
                        this.template.querySelectorAll(".infoSection")[i].style.cssText = ' display: block;';
                        if (result.serviceSWRList[i].isSucces) {
                            customTitle = '!'
                            this.template.querySelectorAll(".successbtn")[i].style.cssText = ' display: block;';
                            this.template.querySelectorAll(".successbtn")[i].title = customTitle;

                            this.template.querySelectorAll(".errorbtn")[i].style.cssText = ' display: none;';
                            this.template.querySelectorAll(".errorbtn")[i].title = "";
                            // this.template.querySelectorAll(".errorbtn")[i].style.backgroundcolor = "rgb(113, 240, 113) !important";
                            this.eobUrlOK = false;
                            this.customTitle = null;
                            this.template.querySelectorAll(".allInputs").forEach((input) => {
                                input.disabled = true;
                            })
                        } else {
                            csstext = ' display: block;';
                            // this.template.querySelectorAll(".errorbtn")[i].style.backgroundcolor = "red !important";
                            // classs = "error";
                            anyErrors = true;
                            customTitle = result.serviceSWRList[i].handleErrorList;
                            this.template.querySelectorAll(".errorbtn")[i].style.cssText = ' display: block;';
                            this.template.querySelectorAll(".errorbtn")[i].title = customTitle;
                            this.customTitle = customTitle;

                            this.template.querySelectorAll(".successbtn")[i].style.cssText = ' display: none;';
                            this.template.querySelectorAll(".successbtn")[i].title = "";
                            this.eobUrlOK = true;
                        }
                        // /this.template.querySelectorAll(".checkValidation")[i].appendChild(linput);



                        //  this.template.querySelectorAll(".checkValidation")[i].title = customTitle;
                        // this.template.querySelectorAll(".checkValidation")[i].innerHTML = customHTML;
                    }
                }



                this.NPIcolumnsResults = this.NPIcolumnsResults.filter(col => col.label != 'Select Provider');
                this.columnsResults = this.columnsResults.filter(col => col.label != 'Action');
                console.log('creating jira ticket with no error');
                createJiraTicket({
                    claimId: result,
                    errorMessage: 'No Error',
                    withError: false
                }).then((result) => {



                }).catch((error) => {
                    console.log('error' + error.message);
                });
            }).catch((error) => {
                this.eobUrlOK = false;
                this.isEOBLoaded = true;
                this.eobError = true;

                console.log('error in creating eob' + JSON.stringify(error));
                console.log('this.submittedEob' + this.submittedEob + ' this.userEmail' + this.userEmail + 'this.dependentValue ' + this.dependentValue + ' error ' + error);
                handleSQLError({
                    networkNames: this.networkNames,
                    providerNumber: this.selectedProvider.NPINumber,
                    tpaAcro: this.tpaAcro,
                    procedures: JSON.stringify(this.proceduresToInsert),
                    includeEOB: true,
                    fields: this.submittedEob,
                    userEmail: this.userEmail,
                    patientId: this.dependentValue,
                    errorMessage: JSON.stringify(error),
                    serviceDate: this.searchedDate,
                    healthPlanId: this.healthPlanId,
                    networkOption:this.networkOption,
                    availableNetworksForProvider:this.availableNetworksForProvider

                }).then((result) => {
                    console.log('creating jira ticket with  error');

                    createJiraTicket({
                        claimId: result.claimId,
                        errorMessage: result.errorMessage,
                        withError: true
                    }).then((result) => {



                    }).catch((error) => {
                        console.log('error' + error.message);
                    });


                }).catch((error) => {
                    console.log('error' + error.message);
                });
            });
        }
    }

    //used when the user presses on the button Confirm Selected Procedures
    confirmSelectedProcedures(event) {
        this.selectedprocedureSelectedConfirmed = true;
        this.checkQuestionsAsked();
    }
    //close the popup of the geolocation
    handleOkay() {
        console.log('entering the close');
        this.disableClose = false;
        console.log('entering the close2');

        this.npıSearchDisplayByGeo = false;
        console.log('entering the close3');

    }
    //view report button to create the vf page and open it as pdf
    generatePdf() {
        this.boolShowSpinner = true;
        downloadPDF({
            eobId: this.eobId,
            isPodPlan: this.isPodPlan
        }).then(response => {
            console.log(response);
            /* const linkSource = `data:application/pdf;base64,${response}`;
            const downloadLink = document.createElement("a");
            const fileName = "vct_illustration.pdf";
        
            downloadLink.href = linkSource;
            downloadLink.download = fileName;
            downloadLink.click();*/
            const urlWithParameters = response;
            console.log('vfpage url ' + urlWithParameters);
            window.open(urlWithParameters);

        }).catch(error => {
            console.log('Error: ' + error.body.message);
        });
    }

    //get the contact id linked to the logged in community user
    get contactId() {
        return getFieldValue(this.user.data, CONTACT_ID);
    }


    //when a user submits a request, we disable all inputs from the screen
    disableAll() {
        // const initDetails = this.template.querySelector(".init");
        //initDetails.style = 'pointer-events:none;';
        this.template.querySelectorAll(".allInputs").forEach((input) => {
            input.disabled = true;
        })
        this.hideCheckbox = true;
        this.buttonsDisabled = true;
        this.columnsResults = [{
                label: 'Procedure Code',
                fieldName: 'Name',
                headerSort: false,
                hideDefaultActions: true,
                wrapText: true,
                cellAttributes: {
                    class: 'slds-size_2-of-5'
                },
            },
            {
                label: 'Description',
                fieldName: 'Description',
                headerSort: false,
                hideDefaultActions: true,
                wrapText: true,
                cellAttributes: {
                    class: 'slds-size_2-of-5'
                },
            }
        ];
        this.selectedProcedurescolumnsResults = [{
                label: 'Procedure Code',
                fieldName: 'Name',
                headerSort: false,
                hideDefaultActions: true,
                wrapText: true,
                cellAttributes: {
                    class: 'slds-size_1-of-5'
                },
            },
            {
                label: 'Description',
                fieldName: 'Description',
                headerSort: false,
                hideDefaultActions: true,
                wrapText: true,
                cellAttributes: {
                    class: 'slds-size_2-of-5'
                },
            },
            {
                label: 'Quantity',
                fieldName: 'IntPS__L2110_Units_of_Service_Paid_Count__c',
                hideDefaultActions: true,
                headerSort: false,
                wrapText: true,
                editable: false,
                cellAttributes: {
                    class: 'slds-size_1-of-5'
                },
            }
        ];

    }
    //open the eligibility div if it is closed and close all other divs, and closes the eligibility div if opened
    toggleCheckEligibility(event) {
        const eligibilityDetails = this.template.querySelector(".eligibilityDetails");
        const style = getComputedStyle(eligibilityDetails);
        console.log('style' + style.content);
        const visiblity = style.getPropertyValue('visibility');
        console.log('visibility' + visiblity);
        if (visiblity == 'hidden') {
            eligibilityDetails.style = 'background-color: lightgray;display: block; visibility: visible';
            this.activateEligibilityDiv();
            this.removeNPIDiv();
            this.removeProceduresDiv();
        } else {
            eligibilityDetails.style = 'background-color: lightgray;display: none;visibility: hidden';
            this.removeEligibilityDiv();
        }

    }
    // closes the eligibility div
    removeEligibilityDiv() {
        const eligibilityDetails = this.template.querySelector(".eligibilityDetails");
        eligibilityDetails.style = 'background-color: lightgray;display: none;visibility: hidden';
        console.log('test remove elig');
        const checkForEligibility = this.template.querySelector('[data-id="checkForEligibility"]');
        console.log('checkForEligibility ' + checkForEligibility);
        checkForEligibility.style = 'background-color: lightgray;border-left: 5px solid #273A93;';
        console.log('checkForEligibility2 ' + checkForEligibility);
        //test color orange E53E25
    }
    //opens the eligibility div
    activateEligibilityDiv() {

        const checkForEligibility = this.template.querySelector('[data-id="checkForEligibility"]');
        console.log('checkForEligibility ' + checkForEligibility);
        checkForEligibility.style = 'background-color: lightgray;border-left: 5px solid #E53E25;';
        console.log('checkForEligibility2 ' + checkForEligibility);
    }
    // opens the Providers div
    activateNPIDiv() {
        const NPIDetails = this.template.querySelector('[data-id="NPIDetails"]');
        console.log('NPIDetails ' + NPIDetails);
        NPIDetails.style = 'background-color: lightgray;border-left: 5px solid #E53E25;';
        console.log('NPIDetails2 ' + NPIDetails);
    }
    // closes the Providers div
    removeNPIDiv() {
        const NPIDetails = this.template.querySelector(".NPIDetails");
        NPIDetails.style = 'background-color: lightgray;display: none;visibility: hidden;';
        const NPIDetailsId = this.template.querySelector('[data-id="NPIDetails"]');
        NPIDetailsId.style = 'background-color: lightgray;border-left: 5px solid #273A93;';

    }
    //opens the procedures div
    activateProceduresDiv() {
        const proceduresDetails = this.template.querySelector('[data-id="proceduresDetails"]');
        console.log('proceduresDetails ' + proceduresDetails);
        proceduresDetails.style = 'background-color: lightgray;border-left: 5px solid #E53E25;';
        console.log('proceduresDetails2 ' + proceduresDetails);
    }
    // closes the procedures div
    removeProceduresDiv() {
        const proceduresDetails = this.template.querySelector(".proceduresDetails");
        proceduresDetails.style = 'background-color: lightgray;display: none;visibility: hidden;border-left: 5px solid #273A93;';
        const proceduresDetailsId = this.template.querySelector('[data-id="proceduresDetails"]');
        proceduresDetailsId.style = 'background-color: lightgray;border-left: 5px solid #273A93;';
    }
    //opens the Providers div if closed and closes all other divs, and closes the providers div if opened
    toggleNPI(event) {

        const NPIDetails = this.template.querySelector(".NPIDetails");
        const style = getComputedStyle(NPIDetails);
        console.log('style' + style.content);
        const visiblity = style.getPropertyValue('visibility');
        console.log('visibility' + visiblity);
        if (visiblity == 'hidden') {
            NPIDetails.style = 'background-color: lightgray;display: block; visibility: visible';
            this.removeEligibilityDiv();
            this.removeProceduresDiv();
            this.activateNPIDiv();
        } else {
            NPIDetails.style = 'background-color: lightgray;display: none;visibility: hidden';
            this.removeNPIDiv();
        }

    }

    //opens the Procedures div if closed and closes all other divs, and closes the Procedures div if opened
    toggleProcedures(event) {
        const proceduresDetails = this.template.querySelector(".proceduresDetails");
        const style = getComputedStyle(proceduresDetails);
        console.log('style' + style.content);
        const visiblity = style.getPropertyValue('visibility');
        console.log('visibility' + visiblity);
        if (visiblity == 'hidden') {
            proceduresDetails.style = 'background-color: lightgray;display: block; visibility: visible';
            this.activateProceduresDiv();
            this.removeEligibilityDiv();
            this.removeNPIDiv();
        } else {
            proceduresDetails.style = 'background-color: lightgray;display: none;visibility: hidden';
            this.removeProceduresDiv();
        }

    }
    //calls the backend to search for providers by NPI number and to indicate if the providers searched are included in the networks of the Patient
    checkExistingNPIAlll(npiNumber) {
        let searchByName = false;
        if (!this.isPodPlan) {
            searchByName = false;
        } else {
            searchByName = this.npıSearchDisplayByName;
        }

        console.log('searching by name or by code ' + this.npıSearchDisplayByName + ' ' + this.searchNPIwithCode);
        checkExistingNPI({
                searchValue: npiNumber,
                searchwithCode: this.searchNPIwithCode,
                searchwithName: searchByName,
                networks: this.networkNames,
                tpaAcro: this.tpaAcro,
                hasOON: this.oon
            })
            .then(result => {
                console.log('results ' + JSON.stringify(this.result));
                this.isNPILoaded = true;
                this.searchedNPILine = true;
                //this.city = result[0].IntPS__City__c;
                if (result != null && result.length > 0) {
                    this.oonError = false;
                    var keys = Object.keys(result);
                    this.availableNetworksForProvider=result[0].availableNetworksForProvider;
                    this.hasNPICode = true;
                    this.isLoaded = true;
                    this.NPIList = result;
                    console.log('results found ' + this.hasNPICode + ' result ' + JSON.stringify(this.NPIList));

                    this.lineItemDisplay = true;
                    if (this.tempIsProvider == false) {
                        this.submitacc = true;
                    }
                    if (this.tempIsProvider == true) {
                        this.providerNameInProvider = result[0].Id
                    }



                } else {
                    console.log('results not found ' + this.hasNPICode);
                    this.oonError = false;
                    this.hasNPICode = false;
                    const billing = this.template.querySelectorAll(".billing");
                    for (let i = 0; i < billing.length; i++) {
                        billing[i].value = null;
                    }
                    const errorText = this.template.querySelector(".errorText");
                    errorText.style = 'display:block; font-size: 12px; color: red;';
                    this.lineItemDisplay = false;
                    this.submitacc = false;
                }
            })
            .catch(error => {
                console.log('results error ' + JSON.stringify(error));
                console.log('results error ' + error.body.message);
                if (error.body.message == 'OON Error') {
                    console.log('other error')
                    this.isNPILoaded = true;
                    this.searchedNPILine = true;
                    this.oonError = true;
                    this.hasNPICode = false;
                    console.log(' this.hasNPICode ' + this.hasNPICode);
                    this.lineItemDisplay = false;
                    this.submitacc = false;
                } else {
                    this.oonError = false;
                    this.isNPILoaded = true;
                    this.searchedNPILine = true;

                    this.hasNPICode = false;
                    console.log(' this.hasNPICode ' + this.hasNPICode);
                    this.lineItemDisplay = false;
                    this.submitacc = false;
                }
            });
    }
    checkQuestionsAsked(){
        for (let i = 0; i < this.selectedProcedures.length; i++) {
            if(this.selectedProcedures[i].Provider_Type__c=='Choose Your Option' || this.selectedProcedures[i].PreventativePregn__c=='Choose Your Option' || this.selectedProcedures[i].Place_Of_Service__c=='Choose Your Option')
            {
                 this.questionsError=true;   
            }
            
        }
     
    }
    // when the procedures questions are being answered, this will handle and validate the answers based on the Field dependencies between place of service and preventativePregnancy
    picklistChanged(event) {
        console.log('in the picklist changed');
        this.questionsError = false;
        this.questionsChangeError='';
        this.availablevalues = '';
        this.availableInController = false;

        if (event.detail.data.fieldname == 'Place_Of_Service__c') {
            const index = this.selectedProcedures.findIndex(object => {
                return object.Name === event.detail.data.context;
            });
            const fieldname = event.detail.data.fieldname;
            const testProc = this.selectedProcedures[index];
            console.log('event.detail.data.value ' + event.detail.data.value);
            console.log('22.1' + JSON.stringify(this.placeOfServicePickListValues));

            let obj = this.placeOfServicePickListValues.find(o => o.label === event.detail.data.value);
            console.log('2' + JSON.stringify(obj));
            testProc[fieldname] = obj.value;
            this.selectedProcedures[index] = testProc;
            console.log('event.detail.data.value3 ' + event.detail.data.value);

            const prevPregn = this.selectedProcedures[index].PreventativePregn__c;
            console.log('prevPregn ' + prevPregn);
            let controllerValues = this.allPlaceOfServiceValues.controllerValues;
            console.log(JSON.stringify(controllerValues))
            this.allPlaceOfServiceValues.values.forEach(depVal => {

                console.log('value selected' + obj.value);
                console.log('depVal' + JSON.stringify(depVal));
                depVal.validFor.forEach(depKey => {
                    console.log('depKey' + JSON.stringify(depKey) + ' controllerValues[prevPregn] ' + controllerValues[prevPregn]);
                    console.log('depVal label' + depVal.label);

                    if (depKey === controllerValues[prevPregn]) {
                        console.log('let me in');
                        this.availablevalues = this.availablevalues.concat(" ", depVal.label+',');
                        console.log('availablevalues ' + this.availablevalues);

                        if (depVal.value == obj.value) {
                            console.log('let me in 2');

                            this.availableInController = true;
                        }

                    }
                });

            });
            console.log('availableInController ' + this.availableInController);
            if (!this.availableInController) {
                console.log('let me in 3');
                this.questionsError = true;
                var avValues = this.availablevalues.substring(0, this.availablevalues.length-1);
                this.questionsChangeError = '"Where the services are being performed". Options are: ' + avValues + ')';
                console.log('questionsChangeError ' + this.questionsChangeError);
            }

        } else {
            const index = this.selectedProcedures.findIndex(object => {
                return object.Name === event.detail.data.context;
            });
            const fieldname = event.detail.data.fieldname;
            const testProc = this.selectedProcedures[index];

            testProc[fieldname] = event.detail.data.value;
            this.selectedProcedures[index] = testProc;
            console.log('event.detail.data.value3 ' + event.detail.data.value);

            const prevPregn = this.selectedProcedures[index].PreventativePregn__c;
            console.log('prevPregn ' + prevPregn);
            let controllerValues = this.allPlaceOfServiceValues.controllerValues;
            console.log(JSON.stringify(controllerValues))
            this.allPlaceOfServiceValues.values.forEach(depVal => {

                console.log('value selected' + this.selectedProcedures[index].Place_Of_Service__c);
                console.log('depVal' + JSON.stringify(depVal));
                depVal.validFor.forEach(depKey => {
                    console.log('depKey' + JSON.stringify(depKey) + ' controllerValues[prevPregn] ' + controllerValues[prevPregn]);
                    console.log('depVal label' + depVal.label);

                    if (depKey === controllerValues[prevPregn]) {
                        console.log('let me in');
                        this.availablevalues = this.availablevalues.concat(" ", depVal.label+',');
                        console.log('availablevalues ' + this.availablevalues);

                        if (depVal.value == this.selectedProcedures[index].Place_Of_Service__c) {
                            console.log('let me in 2');

                            this.availableInController = true;
                        }

                    }
                });

            });
            console.log('availableInController ' + this.availableInController);
            if (!this.availableInController) {
                console.log('let me in 3');
                this.questionsError = true;
                var avValues = this.availablevalues.substring(0, this.availablevalues.length-1);
                this.questionsChangeError = '"Where the services are being performed". Options are: ' + avValues + ')';
                console.log('questionsChangeError ' + this.questionsChangeError);
            }

        }

this.checkQuestionsAsked();
    }
    //when the geolocation search is done, we receive the selected NPI and search in the system
    //to be activated when podplan goes live
  /*  handleVFResponse(message) {
        console.log('message ' + message.data);
        console.log('received ' + (JSON.stringify(message)));
        this.npıSearchDisplayByGeo = false;


        getProviderByNPI({
                npi: message.data
            })
            .then(result => {
                console.log('results ' + JSON.stringify(this.result));
                this.isNPILoaded = true;
                this.searchedNPILine = true;
                //this.city = result[0].IntPS__City__c;
                if (result != null && result.length > 0) {
                    this.oonError = false;
                    var keys = Object.keys(result);

                    this.hasNPICode = true;
                    this.isLoaded = true;
                    this.NPIList = result;
                    console.log('results found ' + this.hasNPICode + ' result ' + JSON.stringify(this.NPIList));

                    this.lineItemDisplay = true;
                    if (this.tempIsProvider == false) {
                        this.submitacc = true;
                    }
                    if (this.tempIsProvider == true) {
                        this.providerNameInProvider = result[0].Id
                    }



                } else {
                    console.log('results not found ' + this.hasNPICode);
                    this.oonError = false;
                    this.hasNPICode = false;
                    const billing = this.template.querySelectorAll(".billing");
                    for (let i = 0; i < billing.length; i++) {
                        billing[i].value = null;
                    }
                    const errorText = this.template.querySelector(".errorText");
                    errorText.style = 'display:block; font-size: 12px; color: red;';
                    this.lineItemDisplay = false;
                    this.submitacc = false;
                }
            })
            .catch(error => {
                console.log('results error ' + JSON.stringify(error));
                console.log('results error ' + error.body.message);
                if (error.body.message == 'OON Error') {
                    console.log('other error')
                    this.isNPILoaded = true;
                    this.searchedNPILine = true;
                    this.oonError = true;
                    this.hasNPICode = false;
                    console.log(' this.hasNPICode ' + this.hasNPICode);
                    this.lineItemDisplay = false;
                    this.submitacc = false;
                } else {
                    this.oonError = false;
                    this.isNPILoaded = true;
                    this.searchedNPILine = true;

                    this.hasNPICode = false;
                    console.log(' this.hasNPICode ' + this.hasNPICode);
                    this.lineItemDisplay = false;
                    this.submitacc = false;
                }
            });
    }*/
    connectedCallback() {
        serversHeartbeat()
        .then(data => {

                this.serversUp=data;
         

        })
        .catch(error => {});
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        this.todaysDate = yyyy + '-' + mm + '-' + dd;
        console.log('todaysDate '+this.todaysDate);
     
        // Binding EventListener here when Data received from VF
        
        if (this.isPodPlan) {
            window.addEventListener("message", this.handleVFResponse.bind(this));

            this.NPIcolumnsResults = [{
                    label: 'Provider Name',
                    fieldName: 'ProviderName',
                    headerSort: false,
                    hideDefaultActions: true,
                    type: 'text'
                },
                {
                    label: 'Provider Code',
                    fieldName: 'NPINumber',
                    headerSort: false,
                    hideDefaultActions: true,
                    type: 'text'
                },


                {
                    label: 'Provider City',
                    fieldName: 'ProviderCity',
                    headerSort: false,
                    hideDefaultActions: true,
                    type: 'text'

                },
                {
                    label: 'Provider Street',
                    fieldName: 'ProviderStreet',
                    headerSort: false,
                    hideDefaultActions: true,
                    type: 'text'

                },
                {
                    label: 'Provider State',
                    fieldName: 'ProviderState',
                    headerSort: false,
                    hideDefaultActions: true,
                    type: 'text'

                },
                {
                    label: 'Provider Postal Code',
                    fieldName: 'ProviderPostalCode',
                    headerSort: false,
                    hideDefaultActions: true,
                    type: 'text'

                },
                {
                    label: 'Provider Country',
                    fieldName: 'ProviderCountry',
                    headerSort: false,
                    hideDefaultActions: true,
                    type: 'text'

                },
                {
                    label: 'Provider Phone',
                    fieldName: 'ProviderPhone',
                    hideDefaultActions: true,
                    headerSort: false,
                    type: 'text'

                }


            ];
        } else {
            this.isPodPlan = false;
        }
        if (this.needsValidation == 'true') {
            this.needsValidationKey = true;
        } else {
            this.needsValidationKey = false;
        }
        this.template.querySelectorAll(".datatable-full-size").forEach((input) => {
            console.log('in datatable');
            input.suppressBottomBar = true;
            console.log(input.suppressBottomBar);
        })
        Promise.all([
                loadStyle(this, customTableDesign)
            ])
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading 1',
                        message: error,
                        variant: 'error'
                    })
                );
            });
        this.tempIsProvider = false;
        this.defaultServiceLineCount = this.serviceLineCount;

        getTPAAcro({
                companyName: this.orgName
            })
            .then(result => {
                console.log('tpaAcro ' + result);

                this.tpaAcro = result;
                console.log('tpaAcro ' + this.tpaAcro);

            })
            .catch(error => {

            });
    }

    refreshPage() {
        window.location.reload();
    }
    //create a list of the procedure object that will be used in the backend
    createProcedureListObject() {
        for (let i = 0; i < this.selectedProcedures.length; i++) {
            const element = {
                Code: this.selectedProcedures[i].Name,
                Description: this.selectedProcedures[i].Description,
                Quantity: this.selectedProcedures[i].IntPS__L2110_Units_of_Service_Paid_Count__c,
                ProviderType: this.selectedProcedures[i].Provider_Type__c,
                PregnancyOption: this.selectedProcedures[i].PreventativePregn__c,
                PreventativeOption: this.selectedProcedures[i].PreventativePregn__c,
                PlaceOfService: this.selectedProcedures[i].Place_Of_Service__c,
                healthPlanItemID: this.selectedProcedures[i].healthPlanItemID,
                CodeType: this.selectedProcedures[i].CodeType
            };
            this.proceduresToInsert = [...this.proceduresToInsert, element];
        }




    }
    //trigger the calculate tpa to get the needed amounts based on the accumulators
    CalculateTPA(eobId) {
        triggerCalculation({
                eobId: eobId,
                patientId: this.dependentValue,
                userEmail: this.userEmail
            })
            .then(data => {

                if (data) {

                } else {}

            })
            .catch(error => {});
    }
    //when choosing date, we check if the date picked is older than today to make the user select future date
    handleServiceDateChange(event){
        console.log(event.target.value+ ' '+this.todaysDate);
        if(new Date(event.target.value) < new Date(this.todaysDate)){
        
            if(event.target.value.toString()==this.todaysDate.toString()){
                this.oldDate=true;
            }else{
                this.oldDate=false;
            }
            
        }
        else{
            this.oldDate=true;
        }
        if(this.oldDate && this.patientSelected){
            this.dateAndPatientSelected=false;
        }
        else{
            this.dateAndPatientSelected=true;
        }
     }
     //search for a patient elligibility
     getPatientInformation(tempServiceDate){
        console.log('calling patient infor');
        this.openEOBInfoSection = false;
        this.openPatientInfoSection = false;
        this.npıSearchDisplay = false;
        this.outOfNetworks = [];
        this.outOfNetworkNames=[];
		this.networkNamesDisplay=[];
		this.networkNames=[];
        console.log(JSON.stringify(this.networkNames)+JSON.stringify(this.networkNamesDisplay)+JSON.stringify(this.outOfNetworkNames)+JSON.stringify(this.outOfNetworks))
        getPatientInfo({
            patientId: this.dependentValue,
            serviceDate: tempServiceDate,
            continueWElig: null
        }).then((result) => {
            console.log((JSON.stringify(result.Eligibility)));
            console.log('result.Eligibility.length' + result.Eligibility.length)
            if (result.Eligibility != null && result.Eligibility.length > 0) {
                if (result.Eligibility.length == 1) {
                    this.eligibilityId = result.Eligibility[0].Id;
                    this.clientId = result.Eligibility[0].IntPS__Patient__r.IntPS__Employer__c;
                    this.clientName = result.Eligibility[0].IntPS__Patient__r.IntPS__Employer__r.Name;
                    this.healthPlanName=result.Eligibility[0].IntPS__Health_Plan__r.Name;
                    console.log('22');
                    console.log('clientName ' + this.clientName);
                    this.accId = result.Eligibility[0].IntPS__Patient__r.IntPS__Employer__c;
                    this.healthPlanId = result.Eligibility[0].IntPS__Health_Plan__c;
                    console.log('test hp id ' + this.healthPlanId);
                    this.openEOBInfoSection = true;
                    this.openPatientInfoSection = true;
                    this.npıSearchDisplay = true;
                    this.getNetworks();
                    this.hasOutOfNetwork();
                    this.showToast('success', 'Success!', this.NSA_ElligibilityFound);
                    this.template.querySelectorAll(".lineItemFields").forEach((input) => {
                        input.disabled = false;
                    })
                    this.template.querySelectorAll(".eobFields").forEach((input) => {
                        input.disabled = false;
                    })
                }

            } else {
                this.showToast('warning', 'No Active Health Plans Found', this.NSA_ElligibilityNotFound);
                this.openEOBInfoSection = false;
                this.openPatientInfoSection = false;
                this.npıSearchDisplay = false;
                this.template.querySelectorAll(".lineItemFields").forEach((input) => {
                    input.disabled = true;
                })

                this.template.querySelectorAll(".eobFields").forEach((input) => {
                    input.disabled = true;
                })
            }

        }).catch((error) => {
            console.log('error' + error);
            this.npıSearchDisplay = false;
        });
        if (this.tempIsProvider == true) {
            this.submitacc = true;
        }
     }
    // check if the patient has an active employer group and then check for elligibility
    searchPatient(event) {
        let tempPatientId = this.dependentValue;
        let tempServiceDate = '';
        this.networkNamesDisplay = [];
        this.networks = [];
        this.networkNames = [];
        this.template.querySelectorAll(".searchCriterias").forEach((input) => {
            if (input.dataset.name == 'patientName') {
                tempPatientId = input.value;
            }
            if (input.dataset.name == 'serviceDate') {
                tempServiceDate = input.value;
                this.searchedDate = tempServiceDate;
            }

        })
        console.log(this.dependentValue + ' ' + tempServiceDate);
        if(this.isAdmin && this.adminOverrideEmployer=='false'){
          //check if the employer group is activated for pricing application
          checkEmployerGroup({
            patientEmployer: this.dependentValue,
            isAdmin:this.isAdmin
        }).then(result => {
            if(!result){
                this.showToast('warning', 'Employer Not Active', this.NSA_SystemNotAvailableMessage);
            }
            else{
               this.getPatientInformation(tempServiceDate);
            }
        }).catch(error => {
            console.log("errorrr");
        });  
        }
        else{
            if(this.isCustomerSupport){
        //check if the employer group is activated for pricing application
        checkEmployerGroup({
            patientEmployer: this.dependentValue,
            isAdmin:this.isCustomerSupport
        }).then(result => {
        if(!result){
        this.showToast('warning', 'Employer Not Active', this.NSA_SystemNotAvailableMessage);
        }
        else{
       this.getPatientInformation(tempServiceDate);
        }
        }).catch(error => {
    console.log("errorrr");
        });  
            }
            else{
            this.getPatientInformation(tempServiceDate);
            }

    }

    }
    testOnChange(event){
        console.log('on change npi '+event.detail.value);
        const isEnterKey = event.keyCode === 13;
        this.NPIsearchValue = event.detail.value;
        if (isEnterKey && this.NPIsearchValue.length > 3) {
            this.isLoaded = false;
            this.checkExistingNPIAlll(this.NPIsearchValue);
        }
       
    }
    //check if the patient's health plan has any out of network  health plan contents
    hasOutOfNetwork() {
        hasOutOfNetwork({
            healthPlanId: this.healthPlanId
        }).then((result) => {
            this.oon = result;


        }).catch((error) => {
            console.log('error' + error);
        });
    }
    // get all the networks(in and out of networks) related to the patient's health plan
    getNetworks() {
        console.log('patient id '+this.dependentValue );
        getNetworksDetails({
            healthPlanId: this.healthPlanId,
            patientId:this.dependentValue       
        }).then((result) => {
            this.networks = result;
            console.log('this.networks.length ' + this.networks.length);
            console.log((JSON.stringify(this.networks)));
            for (let i = 0; i < this.networks.length; i++) {
                if (this.networks[i].IntPS_NSA__Network__c == null) {} else {
                   
                    console.log('filling in network names');
                    this.networkNames = [...this.networkNames, this.networks[i].IntPS_NSA__Network__r.IntPS_NSA__External_ID__c];

                    console.log('filling in network names array ' + JSON.stringify(this.networkNames));

                }
                console.log('IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c ' + this.networks[i].IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c);
                if (this.networks[i].IntPS_NSA__Health_Plan_Content__r.IntPS__Provider_Network__c=='Out-of-Network') {
                    console.log('filling out out ofnetwok ' + this.networks[i].IntPS_NSA__RbP_Basis__c);
                    this.outOfNetworks = [...this.outOfNetworks, this.networks[i]];
                    this.outOfNetworkNames.push(this.networks[i].Id);


                } else {
                    if(this.networks[i].IntPS_NSA__RbP__c){
                        console.log('filling out INNRBP ' + this.networks[i].IntPS_NSA__RbP_Basis__c);
                        this.outOfNetworks = [...this.outOfNetworks, this.networks[i]];
                        this.outOfNetworkNames.push(this.networks[i].Id); 
                    }
                    else{
                    if(!this.networkNamesDisplay.includes(this.networks[i].IntPS_NSA__Network__r.Name)){
                    this.networkNamesDisplay = [...this.networkNamesDisplay, this.networks[i].IntPS_NSA__Network__r.Name];
                    }
                }
                }
            }


        }).catch((error) => {
            console.log('error' + error);
        });
    }
    // Select the needed procedures by the patient
    addNewServiceLine() {
        console.log('client4 ' + this.clientName);

        this.count = this.count + 1;
        console.log('client5 ' + this.clientName);

        this.templine.push(this.count);
        console.log('client6 ' + this.clientName);

        this.LineitemInfo = true;
        console.log('client7 ' + this.clientName);
        console.log('templine ' + this.templine);
        // let countArr = [];
        // for (var i = 1; i <= this.serviceLineCount; i++) {
        //     countArr.push(i);
        // }
        // return countArr;

    }
    // remove procedures from the selected procedures datatable. WHen the user clicks on the button delete
    removeServiceLine(event) {
        const selectedProceduresMock = [...this.selectedProcedures];
        console.log("row " + event.detail.row.Name);
        let temp = event.detail.row.Name;
        console.log(temp);
        for (let i = 0; i < selectedProceduresMock.length; i++) {
            if (selectedProceduresMock[i].Name == temp) {
                console.log('fetna 3a if ' + selectedProceduresMock[i].Name);
                const element = {
                    Name: temp,
                    Description: selectedProceduresMock[i].Description,
                    Status: selectedProceduresMock[i].Status,
                    healthPlanItemID: selectedProceduresMock[i].healthPlanItemID,
                    CodeType: selectedProceduresMock[i].CodeType
                };
                this.procedureCodeList = [...this.procedureCodeList, element];
                this.procedureCodeList.forEach(ele => {
                    console.log('ele ' + ele.Status);
                    ele.buttonsDisable = ele.Status == 'Not Included in Your Health Plan' ? true : false;
                    console.log('ele3 ' + ele.buttonsDisable);
                    ele.format = ele.Status == 'Not Included in Your Health Plan' ? 'slds-text-color_error' : 'slds-text-color_success';
                    console.log('ele2 ' + ele.format);
                });
                this.procedureCodeList = [...this.procedureCodeList];
                console.log('selectedprocedure lenght before ' + selectedProceduresMock.length);
                selectedProceduresMock[i].IntPS__L2110_Units_of_Service_Paid_Count__c = 1;
                console.log('selectedProceduresMock removed is ' + selectedProceduresMock[i].Name + ' ' + selectedProceduresMock[i].IntPS__L2110_Units_of_Service_Paid_Count__c);
                selectedProceduresMock.splice(i, 1);

                console.log('selectedprocedure lenght after ' + selectedProceduresMock.length);

            }
        }

        if (selectedProceduresMock.length == 0) {
            this.LineitemInfo = false;
            this.procedureSelected = false;
            this.hasSelectedProcedureCode = false;

        }

        this.selectedProcedures = [];
        this.selectedProcedures.length = 0;
        console.log('selectedProcedures  ' + this.selectedProcedures);
        this.selectedProcedures = selectedProceduresMock;
        console.log('selectedProcedures2  ' + this.selectedProcedures);
        this.procedureCodeList.sort((a, b) => (a.Status > b.Status) ? 1 : -1)

    }


    showToast(variant, title, message) {
        const event = new ShowToastEvent({
            variant: variant,
            title: title,
            message: message,
        });
        this.dispatchEvent(event);
    }
    //handle checkbox click, it is not currently used, it may be added later on
    searchNPIwithCodeonchange(event) {
        this.removeEligibilityDiv();
        this.activateNPIDiv();
        // this.clickedButtonLabel = event.target.label;
        this.NPIsearchValue = '';
        this.searchNPIwithCode = event.detail.checked;
        if (event.detail.checked) {
            Array.from(this.template.querySelectorAll('lightning-input'))
                .forEach(element => {
                    if (element.name == "NPIinput2") {
                        element.checked = false;
                    }

                });

            this.searchNPIwithName = false;
        }


    }
    // when user checks the procedure code checkbox to start searching by procedure code and not procedure description
    searchwithCodeonchande(event) {
        this.removeEligibilityDiv();
        this.removeNPIDiv();
        this.activateProceduresDiv();
        // this.clickedButtonLabel = event.target.label;
        this.searchValue = '';
        this.searchwithCode = event.detail.checked;
        if (event.detail.checked) {
            Array.from(this.template.querySelectorAll('lightning-input'))
                .forEach(element => {
                    if (element.name == "input2") {
                        element.checked = false;
                    }

                });

            this.searchwithDescription = false;
        }


    }
    //searchNPIwithGeoLocation
    searchNPIwithGeoLocation(event) {
        this.npıSearchDisplayByName = false;
        this.npıSearchDisplayByGeo = true;
        this.removeEligibilityDiv();
        this.activateNPIDiv();
    }
    //not used now, may be added later
    searchNPIwithNamechange(event) {
        this.npıSearchDisplayByName = true;
        this.npıSearchDisplayByGeo = false;
        this.removeEligibilityDiv();
        this.activateNPIDiv();
        this.NPIsearchValue = '';
        // this.clickedButtonLabel = event.target.label;
        this.searchNPIwithName = event.detail.checked;
        if (event.detail.checked) {
            Array.from(this.template.querySelectorAll('lightning-input'))
                .forEach(element => {
                    if (element.name == "NPIinput1") {
                        element.checked = false;
                    }

                });

            this.searchNPIwithCode = false;
        }


    }
    // when user checks the procedure code checkbox to start searching by procedure description and not procedure code
    searchwithDescriptionnchande(event) {
        this.removeEligibilityDiv();
        this.removeNPIDiv();
        this.activateProceduresDiv();
        this.searchValue = '';
        // this.clickedButtonLabel = event.target.label;
        this.searchwithDescription = event.detail.checked;
        if (event.detail.checked) {
            Array.from(this.template.querySelectorAll('lightning-input'))
                .forEach(element => {
                    if (element.name == "input1") {
                        element.checked = false;
                    }

                });

            this.searchwithCode = false;
        }


    }

  
    get openSearchBar() {
        if (this.searchwithDescription || this.searchwithCode) {
            return true;
        } else {
            return false;
        }

    }
    // when the user clicks on the search button of the procedure codes
    Search(event) {
        this.isProceduresLoaded = false;
        this.removeNPIDiv();
        this.searched = true;
        if (this.searchValue.length > 2) {
            this.getProcedureCodes();
        }
        else{
            this.isProceduresLoaded = true;
            this.searchedLine = true;
            this.hasProcedureCode = false;
            this.cptcodetimeout=true;
            this.cptcodetimeouterror='You should fill out at least 3 characters in order to start searching'
        
        }
    }
    // when the user clicks on the search button of the provider
    SearchNPI(event) {
        this.removeEligibilityDiv();
        this.activateNPIDiv();
        this.isNPILoaded = false;
        this.searched = true;
        console.log('NPIsearchValue ' + this.NPIsearchValue);
        this.checkExistingNPIAlll(this.NPIsearchValue);

    }
    // calls the backend to return the procedure codes based on the search criteria of the user.
    // The result will be filtered to specify which procedure is available in the patient's health plan and not
    getProcedureCodes() {
        const timeoutDuration = this.NSA_CPTSearchTimeout;
        this.cptcodetimeout=false;
        this.cptcodetimeouterror='';
        getProcedureCodes({
                searchValue: this.searchValue,
                searchwithCode: this.searchwithCode,
                searchwithDescription: this.searchwithDescription,
                healthPlanID: this.healthPlanId,
                networkOption: this.networkOption,
                isPodPlan: this.isPodPlan
            })
            .then(data => {
                this.isProceduresLoaded = true;

                if (data != null && data.length > 0) {
                    data.forEach(ele => {
                        console.log('ele ' + ele.Status);
                        ele.buttonsDisable = ele.Status == 'Not Included in Your Health Plan' ? true : false;
                        console.log('ele3 ' + ele.buttonsDisable);
                        ele.format = ele.Status == 'Not Included in Your Health Plan' ? 'slds-text-color_error' : 'slds-text-color_success';
                        console.log('ele2 ' + ele.format);
                    });
                    this.procedureCodeList = data;
                    this.procedureCodeList.sort((a, b) => (a.Status > b.Status) ? 1 : -1)
                    const selectedProceduresMock = [...this.procedureCodeList];
                    console.log(' procedureCodeList initial length '+this.procedureCodeList.length);
                    console.log('selectedProcedures '+JSON.stringify(this.selectedProcedures));
                    // when a user searches multiple times, we remove from the result the procedures that are already selected
                    for (let i = 0; i < selectedProceduresMock.length; i++) {
                        console.log('selectedProceduresMock[i].Name '+selectedProceduresMock[i].Name);
                        if (this.selectedProcedures.find(e => e.Name === selectedProceduresMock[i].Name)) {
                            console.log('removing a duplicate '+selectedProceduresMock[i].Name);
                            selectedProceduresMock.splice(i, 1);
                          }
                       
                    }
                   this.procedureCodeList= selectedProceduresMock;
                   console.log(' procedureCodeList final length '+this.procedureCodeList.length);



                    this.searchedLine = true;
                    this.hasProcedureCode = true;
                } else {
                    this.searchedLine = true;
                    this.hasProcedureCode = false;

                }

            })
            .catch(error => {
                this.searchedLine = true;
                this.hasProcedureCode = false;


            });
             // Set a timeout to handle if the call takes too long
        setTimeout(() => {
            // Check if the result is still undefined (meaning the timeout occurred)
            if (this.procedureCodeList === undefined) {
                // Handle the timeout here
                console.error('Apex call timed out');
                this.searchedLine = true;
                this.hasProcedureCode = false;
                this.cptcodetimeout=true;
                this.cptcodetimeouterror=this.NSA_CPTSearchTimeoutError;
            }
        }, timeoutDuration);
    }

}