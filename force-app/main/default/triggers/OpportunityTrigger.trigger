trigger OpportunityTrigger on Opportunity (after update) {
 //  OpportunityTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
 //OpportunityTriggerHandler.afterInsert(trigger.new);
   OpportunityTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
}