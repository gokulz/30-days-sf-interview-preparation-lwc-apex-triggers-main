trigger CaseTrigger on Case (after insert, after update, after delete, after undelete) {
 
    if(Trigger.isInsert || Trigger.isUndelete){
         CaseTriggerHandler.calculateCaseNumber(Trigger.new, null);
    }
    if(Trigger.isUpdate){
      CaseTriggerHandler.calculateCaseNumber(Trigger.new, Trigger.oldMap);    
    }
    if(Trigger.isDelete){
        //in delete no new records to compare that is why we are passing trigger.old;
        CaseTriggerHandler.calculateCaseNumber(Trigger.old, null);
    }
}