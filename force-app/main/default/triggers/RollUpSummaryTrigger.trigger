trigger RollUpSummaryTrigger on Opportunity (after insert, after update, after delete) {
     
    //brute force without any bulkification and dml operation was inside the for loop
    //this work for single records
    for(Opportunity opp : trigger.new){
        Account acc = [Select Id, Name, No_of_Child_Opp__c From Account Where Id =:opp.AccountId];
        List<Opportunity> allOpp = [Select Id, Name From Opportunity Where AccountId =: acc.Id];
        acc.No_of_Child_Opp__c = allOpp.size();
        update acc;
    }

    /**
     * better approach then previous one is try to remove 1 soql query inside the loop 
     */

     Set<Id> allAccount = new Set<Id>();

     for(Opportunity opp : trigger.new){
        allAccount.add(opp.AccountId);
     }
     
     List<Account> listOfAccounts = [Select Id, Name, No_of_Child_Opp__c From Account Where Id in :allAccount];

     for(Account currentAcc : listOfAccounts){
        //here every account has a listof opportunity so if you want to avoid the soql query inside the loop again you have to use map inside list of opportunity
        List<Opportunity> allAssociateOppty = [Select Id, Name From Opportunity Where AccountId =: currentAcc.Id];
        currentAcc.No_of_Child_Opp__c = allAssociateOppty.size();
        update currentAcc;
     }



     /**
      * using map approach this loigc is optimal
      */

      for(Opportunity opp : trigger.new){
        allAccount.add(opp.AccountId);
      }

      List<Account> allAccounts = [Select Id, Name, No_of_Child_Opp__c From Account where id in : allAccount];

      Map<Id,List<Opportunity>> allAccountOppMap = new Map<Id,List<Opportunity>>();
      
      List<Opportunity> allOppty = [Select Id, Name, AccountId From Opportunity Where AccountId in : allAccount];

     for(Opportunity oppty : allOppty){
         if(allAccountOppMap.containsKey(oppty.AccountId)){
            allAccountOppMap.get(oppty.AccountId).add(oppty);
         } else{
            allAccountOppMap.put(oppty.AccountId, new List<Opportunity>(oppty));
         }
     }

     List<Account> listOfAccountToUpdate = new List<Account>();

     for(Account currAcc : allAccounts){
        if(allAccountOppMap.containsKey(currAcc.Id)){
             currAcc.No_of_Child_Opp__c = allAccountOppMap.get(currAcc.Id).size();
             listOfAccountToUpdate.add(currAcc);
        }
       
     }

     if(!listOfAccountToUpdate.isEmpty()){
        update listOfAccountToUpdate;
     }


     /**
      * simpler approch using the aggregateResult
      */

      if(Trigger.isInsert){
         for(Opportunity opp : trigger.new){
            allAccount.add(opp.AccountId);
           }
         }  

      if(Trigger.isUpdate){
         for(Opportunity opp : trigger.new){
            if((trigger.oldMap.get(opp.Id).AccountId != opp.AccountId) && opp.AccountId != null ){
               allAccount.add(opp.AccountId);
            }
         }
      } 
      
      
      if(Trigger.isDelete){
         for(Opportunity deletedOppty : trigger.old){
            allAccount.add(deletedOppty.AccountId);
         }
      }

       List<Account> allAccounts = [Select Id, Name, No_of_Child_Opp__c From Account where id in : allAccount];

       Map<Id,Decimal> allCountMap = new Map<Id,Decimal>();

       List<AggregateResult> totalOppty = [Select Count(id)totalOppty, AccountId From Opportunity Where AccountId in :allAccount group by AccountId];

       for(AggregateResult agr : totalOppty){
          Id accId = (Id) agr.get('AccountId');
          Decimal totalOppty = (Decimal) agr.get('totalOppty');
          totalOppty.put(accId, totalOppty);
       }

     List<Account> updateAccount = new List<Account>();
       for(Account currAcc : allAccounts){
         if(allCountMap.containsKey(currAcc.Id)){
             currAcc.No_of_Child_Opp__c = allAccountOppMap.get(currAcc.Id);
             updeteAccount.add(currAcc);
         }
       }

       if(!updateAccount.isEmpty()){
        update updateAccount;
       }



}