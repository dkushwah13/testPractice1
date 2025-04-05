trigger PaymentMethodTrigger on Payment_Method__c (before insert, before update, before delete) {
    System.debug('TriggerOperatiType::'+Trigger.OperationType);
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            PaymentMethodTriggerHelper.beforeInsert(Trigger.new);
        }else if(Trigger.isUpdate){
            PaymentMethodTriggerHelper.beforeUpdate(Trigger.new, Trigger.oldMap);
        }else if(Trigger.isDelete){
            PaymentMethodTriggerHelper.beforeDelete(Trigger.old);
        }
    }else if(Trigger.isAfter){
        if(Trigger.isUpdate){
            PaymentMethodTriggerHelper.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}