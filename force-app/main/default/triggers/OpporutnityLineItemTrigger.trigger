trigger OpporutnityLineItemTrigger on OpportunityLineItem (after insert, after delete) {
         
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            OpportunityLineItemController.updateCountOppotunityLineItem(trigger.new);
        }
        if(Trigger.isDelete){
            OpportunityLineItemController.updateCountOppotunityLineItem(trigger.old);
        }
    }
}