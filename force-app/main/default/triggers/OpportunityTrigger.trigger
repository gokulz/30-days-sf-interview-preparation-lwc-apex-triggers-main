trigger OpportunityTrigger on Opportunity (after insert, after update) {
 //  OpportunityTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
 //OpportunityTriggerHandler.afterInsert(trigger.new);
 if(Trigger.isInsert){
    OpportunityTriggerHandler.afterInsert(trigger.new);
 }
 if(Trigger.isUpdate){
   OpportunityTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
 }
   
}