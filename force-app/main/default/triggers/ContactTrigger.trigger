trigger ContactTrigger on Contact (before insert, before update) {
      ContactTriggerHandler.beforeUpdate(trigger.new);
}