trigger ContactTrigger on Contact (after update) {
     // ContactTriggerHandler.beforeUpdate(trigger.new);
     ContactTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
}

/**
 * trigger ContactTrigger on Contact (before insert, before update) {
     // ContactTriggerHandler.beforeUpdate(trigger.new);
}
 */