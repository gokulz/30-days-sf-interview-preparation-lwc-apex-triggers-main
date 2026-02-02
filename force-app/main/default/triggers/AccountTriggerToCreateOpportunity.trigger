trigger AccountTriggerToCreateOpportunity on Account (after insert, after update) {

    /**
     * brute force approach
     * do not use dml operation inside the for loop
     */


    for(Account acc : trigger.new){
        if(acc.Industry == 'Agriculture'){
            //create a new opportunity
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.Name = acc.Name + 'Opportuniyt';
            opp.StageName = 'Prospecting';
            opp.CloseDate = Date.today().addDays(3);

            insert opp;
        }
    }

    

    /**
     * opptimal approach is same trigger 
     */

    Set<Id> accountIds = new Set<Id>();

    if(Trigger.isAfter && Trigger.isInsert){
    for(Account acc : trigger.new){
        if(acc.Id != null && acc.Industry == 'Agriculture'){
            accountIds.add(acc.Id);
        }
    }
}

    //for update

    if(Trigger.isAfter && Trigger.isUpdate){
        for(Account acc : trigger.new){
            //get the old value to check if the previouse account has industry field agriculture or not 
            Account oldAcc = Trigger.oldMap.get(acc.Id);

            if(acc.Industry == 'Agriculture' && oldAcc.Industry != 'Agriculture'){
                accountIds.add(acc.Id);
            }
        }
    }


    Map<Id,Account> allAccounts = new Map<Id,Account>([Select Id From Account Where Id In:accountIds]);

    List<Opportunity> listToUpdate = new List<Opportunity>();

    //loop the values in map
    for(Account acc : allAccounts.values()){
        Opportunity opp = new Opportunity();
        opp.Name = acc.Name + 'Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName ='Prospecting';
        opp.Amount = 0.0;
        opp.CloseDate = Date.today().addDays(3);

        listToUpdate.add(opp);
    }

    if(!listToUpdate.isEmpty()){
        insert listToUpdate;
    }


/**
 * call the handler method 
 */

 if(Trigger.isAfter){
    if(Trigger.isInsert){
        AccountTriggerHandlerForOppotunity.afterInsert(trigger.new);
    }
    if(Trigger.isUpdate){
        AccountTriggerHandlerForOppotunity.afterUpdate(trigger.new, trigger.oldMap);
    }
 }



}
//Explanation : solved using 3 approaches bruteforce, optimal using map and moving code to triggerhandler class for safer, readability and easymaintance for one trigger per object.**