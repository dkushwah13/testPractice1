import { LightningElement, wire, track } from 'lwc';
// Import message service features required for subscribing and the message channel
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/Record_Selected__c';
const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Age', fieldName: 'Age__c'},
    { label: 'DOB', fieldName: 'DOB__c', type: "date-local" },
];
export default class Employees extends LightningElement {
    subscription = null;
    record;
    @track data = [];
    columns = columns;

    @wire(MessageContext)
    messageContext;
    connectedCallback() {
        console.log('connectedCallback :Employees ');
        this.subscribeToMessageChannel();

    }
    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                recordSelected,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    // Handler for message received by component
    handleMessage(message) {
        this.record = message.record;
        console.log('OUTPUT : this.record',this.record);
        //this.data.push({id:'1234',Name: 'Rajesh44', Age__c: '11', DOB__c: '2024-08-28'});
        this.data.push(this.record);
        //console.log('OUTPUT : ',JSON.parse(JSON.stringify(this.data)));
        this.data = JSON.parse(JSON.stringify(this.data));
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
}