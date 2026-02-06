trigger OpportunityTrigger on Opportunity (after update) {
   OpportunityTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
}