public with sharing class OpportunityLineItemController {
    

    public static void updateCountOppotunityLineItem(List<OpportunityLineItem> oppLineItems){
       

        // for(OpportunityLineItem newoppLineItems: oppLineItems){
        //     Opportunity opp = [Select Id, AccountId From Opportunity where Id =: newoppLineItems.OpportunityId];
        //     Account ac = [Select Id, No_of_OppLineItem__c From Account Where Id =: opp.AccountId];
        //     ac.No_of_OppLineItem__c = oppLineItems.size();
        //     update ac;
        // }

        Set<Id> allOppIds = new Set<Id>();

        Map<Id,Decimal> oppLineItemMap = new Map<Id,Decimal>();

        for(OpportunityLineItem newOppLineItems : oppLineItems){
            
            if(newOppLineItems != null){
                allOppIds.add(newOppLineItems.OpportunityId);
            }
        }

      List<Opportunity> allOpps = [Select Id, AccountId From Opportunity Where Id in : allOppIds];

      for(Opportunity ops : allOpps){
          oppLineItemMap.put(ops.AccountId, 0);
      }

      List<AggregateResult> agResult = [Select Count(Id) oliCount, Opportunity.AccountId accountId From OpportunityLineItem Where Opportunity.AccountId in : oppLineItemMap.keySet() Group By Opportunity.AccountId];

      for(AggregateResult agr : agResult){
           Id accIds = (Id) agr.get('accountId');
           Decimal countOli = (Decimal) agr.get('oliCount');
           oppLineItemMap.put(accIds, countOli);
      }

      List<Account> accUpdate = new List<Account>();

      for(Id accIds : oppLineItemMap.keySet()){
          Account acc = new Account();
          acc.Id = accIds;
          acc.No_of_OppLineItem__c = oppLineItemMap.get(accIds);
          accUpdate.add(acc);
      }

      if(!accUpdate.isEmpty()){
         update accUpdate;
      }
    }
}