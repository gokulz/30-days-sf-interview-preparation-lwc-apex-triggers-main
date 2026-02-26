trigger ContactTrigger on Contact (after update) {
     // ContactTriggerHandler.beforeUpdate(trigger.new);
     ContactTriggerHandler.afterUpdate(trigger.new, null);
}

/**
 * trigger ContactTrigger on Contact (before insert, before update) {
     // ContactTriggerHandler.beforeUpdate(trigger.new);
}
 */