public with sharing class EmployeeController {
    @AuraEnabled
    public static void createEmployee(Employee__c newEmployee){
        try {
            insert newEmployee;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}