trigger LeadTriggerFuturemethodExample on Lead (after insert) {
    
    Set<Id> leadIds = new Set<Id>();
    if(trigger.isAfter && trigger.isInsert){
        for(Lead currentLead : trigger.new){
            leadIds.add(currentLead.Id);
        }
    }

    LeadTriggerFuturemethodProcessor.createFollowUpTask(leadIds);
}