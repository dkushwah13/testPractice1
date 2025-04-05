import { LightningElement, wire } from 'lwc';
import createEmployee from "@salesforce/apex/EmployeeController.createEmployee";
// Import message service features required for publishing and the message channel
import { publish, MessageContext } from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/Record_Selected__c';

export default class Employee extends LightningElement {
    name;
    age;
    dob;
    @wire(MessageContext)
    messageContext;
    handleInputChange(event){
        let name = event.target.name;
        let value = event.target.value;

        // console.log('OUTPUT :name ',name);
        // console.log('OUTPUT :value ',value);
        if(name == 'name'){
            this.name = value;
        }else if(name == 'age'){
            this.age = value;
        }else{
            //assuming dob
            this.dob = value;
        }
    }
    handleSaveClick(){
        let newEmployee = {};
        newEmployee.Name = this.name;
        newEmployee.Age__c = this.age;
        newEmployee.DOB__c = this.dob;
        console.log('OUTPUT save click : ',newEmployee);

        createEmployee({ newEmployee: newEmployee })
          .then(result => {
            console.log('Result', result);
            console.log('New EMployee Added!');

            // Respond to UI event by publishing message
            const payload = { record: newEmployee };
            publish(this.messageContext, recordSelected, payload);
            this.template.querySelectorAll('.inputs').forEach((eachInput)=>{eachInput.value = '';});
            this.name = '';
            this.age = '';
            this.dob = '';
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }
}