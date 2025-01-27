import LightningDatatable from 'lightning/datatable';
import picklistColumn from './picklistColumn.html';
import datePicker from './datePicker.html';

 import { api } from 'lwc';
export default class LWCCustomDatatableType extends LightningDatatable {

    static customTypes = {
        picklistColumn: {
            template: picklistColumn,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','fieldName','disabled']
        },
        datePicker: {
            template: datePicker,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','fieldName','disabled']
        },
    };
}