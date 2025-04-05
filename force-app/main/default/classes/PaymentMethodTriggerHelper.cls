public class PaymentMethodTriggerHelper {
    public static void beforeInsert(List<Payment_Method__c> newList){
        Set<Id> accountIds = new Set<Id>();
        for (Payment_Method__c paymentMethod : newList) {
            system.debug('##paymentMethod=='+paymentMethod.Name);
            if(paymentMethod.Account__c != null){
                accountIds.add(paymentMethod.Account__c);
            }
        }
        system.debug('accountIds:'+accountIds);
        Set<Id> accIdsWithPaymentMethods = new Set<Id>();
        if(accountIds.size()>0){
            // Map<Id, Account> accMap = new Map<Id, Account>([Account acc: [SELECT Id, (SELECT Id FROM Payment_Methods__r) FROM Account WHERE Id IN: accountIds]);
            // system.debug('accMap::'+accMap);
            for(Payment_Method__c payMthd: [SELECT Id,Account__c FROM Payment_Method__c WHERE Account__c IN: accountIds]){
                accIdsWithPaymentMethods.add(payMthd.Account__c);
            }
        }
        for (Payment_Method__c paymentMethod : newList) {
            if(paymentMethod.Account__c != null){
                if(!accIdsWithPaymentMethods.contains(paymentMethod.Account__c)){
                    paymentMethod.default__c = true;
                }
                else if(paymentMethod.default__c && accIdsWithPaymentMethods.contains(paymentMethod.Account__c)){
                    paymentMethod.addError('Default Payment Method already exists!');
                }
            }
            
        }

    }
    public static void beforeDelete(List<Payment_Method__c> oldList){
        for (Payment_Method__c paymentMethod : oldList) {
            if(paymentMethod.Default__c){
                paymentMethod.addError('You cannot delete default payment method!');
            }
        }
    }

    public static void beforeUpdate(List<Payment_Method__c> newPayments, Map<Id, Payment_Method__c> oldPayments) {
        Set<Id> accountIds = new Set<Id>();
        List<Payment_Method__c> paymentMethodsToUpdate = new List<Payment_Method__c>();
    
        // Collect account IDs from the updated records
        for (Payment_Method__c pm : newPayments) {
            accountIds.add(pm.Account__c);
        }
    
        // Fetch existing default payment methods for the affected accounts
        Map<Id, Payment_Method__c> existingDefaults = new Map<Id, Payment_Method__c>(
            [SELECT Id, Account__c FROM Payment_Method__c WHERE Account__c IN :accountIds AND Default__c = true]
        );
    
        for (Payment_Method__c pm : newPayments) {
            Payment_Method__c oldPm = oldPayments.get(pm.Id);
    
            // Prevent unchecking of the current default method
            if (oldPm.Default__c && !pm.Default__c) {
                throw new AuraHandledException('You cannot uncheck the default payment method.');
            }
    
            // Handle the case where a non-default method is set to default
            if (!oldPm.Default__c && pm.Default__c) {
                Payment_Method__c existingDefault = existingDefaults.get(pm.Account__c);
                if (existingDefault != null) {
                    existingDefault.Default__c = false;
                    paymentMethodsToUpdate.add(existingDefault); // Add to the list for updating later
                }
            }
        }
    
        // Perform the DML operation outside the loop
        if (!paymentMethodsToUpdate.isEmpty()) {
            update paymentMethodsToUpdate;
        }
    }

    // public static void beforeUpdate(List<Payment_Method__c> newList, Map<Id, Payment_Method__c> oldMap){
    //     system.debug('beforeUpdate::');
    //     Set<Id> accountIds = new Set<Id>();

        
    //     Set<Id> accountIds2 = new Set<Id>();
    //     for (Payment_Method__c paymentMethod : newList) {
    //         if(paymentMethod.Account__c != null){
    //             accountIds2.add(paymentMethod.Account__c);
    //         }
    //     }
    //     system.debug('accountIds2:'+accountIds2);
    //     Set<Id> accIdsWithPaymentMethods = new Set<Id>();
    //     Map<Id, Integer> accIdPaymethodCount = new Map<Id, Integer>();
    //     if(accountIds2.size()>0){
    //         for(Payment_Method__c payMthd: [SELECT Id,Account__c FROM Payment_Method__c WHERE Account__c IN: accountIds2 AND Default__c = true]){
    //             if(accIdPaymethodCount.containsKey(payMthd.Account__c)){
    //                 Integer existingNum = accIdPaymethodCount.get(payMthd.Account__c);
    //                 existingNum++;
    //                 accIdPaymethodCount.put(payMthd.Account__c, existingNum);
    //             }else{
    //                 accIdPaymethodCount.put(payMthd.Account__c, 1);
    //             }
    //         }
    //     }
    //     system.debug('accIdPaymethodCount::'+accIdPaymethodCount);


    //     for (Payment_Method__c paymentMethod : newList) {
    //         if(oldMap.get(paymentMethod.Id).Default__c && !paymentMethod.Default__c && accIdPaymethodCount.get(paymentMethod.Account__c)==0 ){
    //             //paymentMethod.addError('You cannot make non default from payment method!');
    //         }

    //         //Making non default to default
    //         if(paymentMethod.Account__c != null && !oldMap.get(paymentMethod.Id).Default__c && paymentMethod.Default__c){
    //             accountIds.add(paymentMethod.Account__c);
    //         }
    //     }
    //     if(accountIds.size()>0){
    //         List<Payment_Method__c> paymentMethodsToUpdate = new List<Payment_Method__c>();
    //         for (Payment_Method__c payMthd: [SELECT Id,Account__c FROM Payment_Method__c WHERE Account__c IN: accountIds AND Default__c = true]) {
    //             paymentMethodsToUpdate.add(new Payment_Method__c(Id = payMthd.Id, Default__c = false));
    //         }
    //         if(paymentMethodsToUpdate.size()>0){
    //             update paymentMethodsToUpdate;
    //         }
    //     }
    // }

    // public static void afterUpdate(List<Payment_Method__c> newList, Map<Id, Payment_Method__c> oldMap){
    //     Set<Id> accountIds2 = new Set<Id>();
    //     for (Payment_Method__c paymentMethod : newList) {
    //         if(paymentMethod.Account__c != null){
    //             accountIds2.add(paymentMethod.Account__c);
    //         }
    //     }
    //     system.debug('accountIds2:'+accountIds2);
    //     Set<Id> accIdsWithPaymentMethods = new Set<Id>();
    //     Map<Id, Integer> accIdPaymethodCount = new Map<Id, Integer>();
    //     if(accountIds2.size()>0){
    //         for(Payment_Method__c payMthd: [SELECT Id,Account__c FROM Payment_Method__c WHERE Account__c IN: accountIds2 AND Default__c = true]){
    //             if(accIdPaymethodCount.containsKey(payMthd.Account__c)){
    //                 Integer existingNum = accIdPaymethodCount.get(payMthd.Account__c);
    //                 existingNum++;
    //                 accIdPaymethodCount.put(payMthd.Account__c, existingNum);
    //             }else{
    //                 accIdPaymethodCount.put(payMthd.Account__c, 1);
    //             }
    //         }
    //     }
    //     system.debug('accIdPaymethodCount::'+accIdPaymethodCount);


    //     for (Payment_Method__c paymentMethod : newList) {
    //         if(oldMap.get(paymentMethod.Id).Default__c && !paymentMethod.Default__c && accIdPaymethodCount.get(paymentMethod.Account__c)==0 ){
    //             paymentMethod.addError('You cannot make non default from payment method!');
    //         }
    //     }
    // }
}