trigger LeadTrigger on Lead (after update) {
       

      if(Trigger.isAfter && Trigger.isUpdate){
           LeadTriggerHandler.leadConvert(trigger.new, trigger.oldMap);
      }
}