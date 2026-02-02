public with sharing class OpportunityTriggerHandler {
 
    public static void afterInsert(List<Opportunity> opps){
        checboxChecker(opps, null);
    }

    public static void afterUpdate(List<Opportunity> opps, Map<Id,Opportunity> oldMap){
         checboxChecker(opps, oldMap);
    }
    public static void afterDelete (List<Opportunity> opps){
        checboxChecker(opps, null);
    }

    /**
     * create a trigger whenever new opportunity is added
     * it will check opportunity exist checkbox in account object whenever no opportunity is there for accoount the checkbox vlaue false
     */

   private static void checboxChecker(List<Opportunity> opps, Map<Id,Opportunity> oldMap){

      Set<Id> accountIds = new Set<Id>();
      for(Opportunity newOpp : opps){
            if (oldMap == null) {
                if (newOpp.AccountId != null) {
                    accountIds.add(newOpp.AccountId);
                }
            }
            else {
                Opportunity oldOpp = oldMap.get(newOpp.Id);

                if (newOpp.AccountId != null) {
                    accountIds.add(newOpp.AccountId);
                }
                if (oldOpp != null && oldOpp.AccountId != null) {
                    accountIds.add(oldOpp.AccountId);
                }
            }
      }

      List<Account> allAccount = [Select Id, Name, Opportunity_Checkbox__c From Account Where id in :accountIds];

      Map<Id,Integer> countOpp = new Map<Id,Integer>();

      //aggregate function 
      List<AggregateResult> ls = [Select AccountId accId , Count(Id) totalCount From Opportunity Where AccountId in : accountIds Group By AccountId];
      
      for(AggregateResult agr : ls){
          Id accId = (Id) agr.get('accId');
          Integer count = (Integer) agr.get('totalCount');
          countOpp.put(accId, count);
      }

      List<Account> updateList = new List<Account>();

      for(Account acc : allAccount){
          if(countOpp.containsKey(acc.Id) && countOpp.get(acc.Id) > 0){
              acc.Opportunity_Checkbox__c = true;
          }else{
              acc.Opportunity_Checkbox__c = false;
          }
          updateList.add(acc);
          
      }

      if(!updateList.isEmpty()){
         update updateList;
      }

   }

   /**
    * Create a trigger on opportunity , when the user inserts an opportunity trigger
     will check that the closing date of opportunity is greater than one month and amount is greater than 50000.
    */

    private static void checkClosingDate(List<Opportuniyt> opps){

        // //brute force
        // for(Opportunity newOpp : opps){
        //     if(newOpp.CloseDate() > newOpp.CloseDate().addMonths(1) && newOpp.Amount > 5000){
        //        newOpp.add('you cannot insert the oppotunity because amount is not greater than 5000 and close date is not greater than one month');
        //     }
        // }

        //the optimal approach
        Date oneMonthFromNow = Date.today().addMonths(1);

        for(Opportunity newOpp : opps){
            if(!newOpp.CloseDate() <= oneMonthFromNow || !newOpp.Amount <= 5000){
                newOpp.addError('you cannot able to insert');
            }
        }


    }

}

//Opportunity_Checkbox__c