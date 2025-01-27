import { LightningElement, wire, track,api } from 'lwc';
 


export default class CptDataTable extends LightningElement {
    @track data;
    @track error;
    @api columns;
    @track searchString;
    @track tableData = [];
    page = 1; //initialize 1st page
    startingRecord = 1; //start record position per page
    endingRecord = 0; //end record position per page
    pageSize = 10; //default value we are assigning
    totalRecountCount = 0; //total record count received from all retrieved records
    totalPage = 0; //total number of page is needed to display all records
    
    @api
    get initialRecords() {
        return this._initialRecords;
    }
    set initialRecords(newValue) {
        // This is going to be executed every time 
        // projects receive a new value
        this._initialRecords = newValue;
        this.updateTableData();
    }
    updateTableData() {
        // Assuming your data structure is an array of objects
        // Modify this logic based on your actual data structure
        this.startingRecord = 1;
        this.page = 1;
        this.tableData = [...this._initialRecords];
        this.totalRecountCount = this.tableData.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
         this.data = this.tableData.slice(0, this.pageSize);
        this.endingRecord = this.pageSize;
        this.error = undefined;
    }
    connectedCallback() {
            this.totalRecountCount = this.tableData.length;
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
            this.data = this.tableData.slice(0, this.pageSize);
            this.endingRecord = this.pageSize;
            this.error = undefined;
    }

   
 
    handleSearch(event) {
        const searchKey = event.target.value.toLowerCase();
 
        if (searchKey) {
            if (searchKey.length > 2){
            this.data = this.tableData;
 
            if (this.data){
                let searchRecords = [];
 
                for (let record of this.data) {
                    let valuesArray = Object.values(record);
 
                    for (let val of valuesArray) {
                        console.log('val is ' + val);
                        let strVal = String(val);
 
                        if (strVal) {
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
                console.log('Matched CPTs are ' + JSON.stringify(searchRecords));
                this.data = searchRecords;
                this.tableData = this.data;
                this.startingRecord = 1;
                this.page = 1;
                this.totalRecountCount = this.data.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                this.data = this.data.slice(0, this.pageSize);
                this.endingRecord = this.pageSize;
           }
        }
        } else {
            this.startingRecord = 1;
            this.page = 1;
            this.tableData = [...this._initialRecords];
            this.totalRecountCount = this.tableData.length;
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
            this.data = this.tableData.slice(0, this.pageSize);
            this.endingRecord = this.pageSize;
            //this.displayRecordPerPage(this.page);
        }
    }

    getSelectedRec(event) {
            //show the selected value on UI
            this.value = event.detail.value;
            //fire event to send context and selected value to the data table
            this.dispatchEvent(new CustomEvent('procedurechosen', {
                composed: true,
                bubbles: true,
                cancelable: true,
                detail: {
                    data: {row: event.detail.row}
                }
            }));
        
      }

      previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordPerPage(this.page);
        }
    }

    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1;
            this.displayRecordPerPage(this.page);
        }
    }
    //this method displays records page by page
    displayRecordPerPage(page) {
        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;
        this.data = this.tableData.slice(this.startingRecord, this.endingRecord);
        //increment by 1 to display the startingRecord count, 
        //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
        this.startingRecord = this.startingRecord + 1;
        //this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRows;
    }
}