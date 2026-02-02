trigger RollupSummaryContactTrigger on Contact (after insert, after update, after delete) {
  
    if(Trigger.isAfter){

        if(Trigger.isInsert){
             RollUpSummaryContactTriggerHandler.afterInsert(trigger.new);
        }
        if(Trigger.isUpdate){
             RollUpSummaryContactTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
        }

        if(Trigger.isDelete){
            RollUpSummaryContactTriggerHandler.afterDelete(trigger.old);
        }
    }
   

}

 // /**
    //  * using aggregate fucntion 
    //  */

    //  Set<Id> allAccountIds = new Set<Id>();

    //  for(Contact con : trigger.new){
    //      allAccountIds.add(con.AccountId);
    //  }

    //  //retreive all accounts that has contact
    //  List<Account> allAccountsCon = [Select Id, Name, No_of_Contacts__c From Account Where Id in : allAccountIds];

    //  //assign the map to store the count and account id
    //  Map<Id, Decimal> conCountMap = new Map<Id,Decimal>();

    //  //use aggregate function to get the count and group by account id
    //  List<AggregateResult> totalCont = [Select Count(id) totalCont, AccountId From Contact Where AccountId in : allAccountIds Group By AccountId ];

    //  for(AggregateResult agr : totalCont){
    //       Decimal totalCont = (Decimal) agr.get('totalCont');
    //       Id accId = (Id) agr.get('AccountId');
    //       totalCont.put(accId, totalCont);
    //  }

    //  List<Account> ls = new List<Account>();

    //  for(Account currAcc : allAccountsCon){
    //     if(conCountMap.containsKey(currAcc.Id)){
    //         currAcc.No_of_Contacts__c = conCountMap.get(currAcc.Id);
    //         ls.add(currAcc);
    //     }
    //  }

    //  if(!ls.isEmpty()){
    //     update ls;
    //  }