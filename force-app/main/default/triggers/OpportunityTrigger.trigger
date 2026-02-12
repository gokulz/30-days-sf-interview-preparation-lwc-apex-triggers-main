trigger OpportunityTrigger on Opportunity (after insert) {
 //  OpportunityTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
 OpportunityTriggerHandler.afterInsert(trigger.new);
}