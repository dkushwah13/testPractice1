/**
 * @class EmployeeController
 * @description This Apex controller class is exposed to Lightning Components using @AuraEnabled.
 *              It provides a method to create a new Employee__c record in Salesforce.
 *              Error handling is included to catch and throw exceptions as AuraHandledException
 *              for proper client-side handling in Lightning components.
 *
 * @author Deepak Kushwah
 * @date April 2025
 * @version 1.0
 *
 * @modification_history
 * ------------------------------------------------------------------
 * Version   Date        Author           Description
 * 1.0       Apr 2025    Deepak Kushwah   Initial version with createEmployee method
 */

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