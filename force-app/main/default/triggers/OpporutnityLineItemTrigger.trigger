trigger OpporutnityLineItemTrigger on OpportunityLineItem (after insert) {
         
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            OpportunityLineItemController.updaateAccountsDescription(trigger.new);
        }
        // if(Trigger.isDelete){
        //     OpportunityLineItemController.updateCountOppotunityLineItem(trigger.old);
        // }
    }
}