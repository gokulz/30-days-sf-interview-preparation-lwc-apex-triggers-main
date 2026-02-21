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

    /**
     * Trigger to count OpportunityLineItem 
     * whose listPrice is greater than $50,000 associated with opportunity and display that count on Account custom field.
     */

     public static void updateCountOpportunityLineItemPrice50k(List<OpportunityLineItem> oppLineItems){

           Set<Id> oppIds = new Set<Id>(); 
           Map<Id,Decimal> oppMap = new Map<Id,Decimal>();

           //checking if the list price is more than 50,000
          for(OpportunityLineItem newOppLineItem : oppLineItems){
               if(newOppLineItem.Id != null){
                     oppIds.add(newOppLineItem.OpportunityId);
               }   
          }

         //getting all the opportunity accountId based on the related opportunitylineitem 
          List<Opportunity> allOps = [Select Id, AccountId From Opportunity Where Id in : oppIds];

          //storing related account id in the map 
          for(Opportunity opp : allOps){
              oppMap.put(opp.AccountId, 0);
          }

          //using aggreagete querey count the total 
          List<AggregateResult> agrResult = [Select Count(Id) totalCount, Opportunity.AccountId accId From OpportunityLineItem Where Opportunity.AccountId in :oppMap.keySet() And ListPrice > 50000 Group By Opportunity.AccountId];

          for(AggregateResult agr : agrResult){
              Id accId = (Id) agr.get('accId');
              Decimal totalCount= (Decimal) agr.get('totalCount');
              oppMap.put(accId, totalCount);
          }

          List<Account> updateAccList = new List<Account>();

          //looping the account id and updating the account fields
          for(Id accIds : oppMap.keySet()){
             Account acc = new Account();
             acc.Id = accIds;
             acc.No_of_OppLineItem__c = oppMap.get(accIds);
             updateAccList.add(acc);
          }

          if(!updateAccList.isEmpty()){
             update updateAccList;
          }
     }

     /**
      * Trigger to update Account's description by opportunityLineItem's description which is associated with opportunity
      */

      public static void updaateAccountsDescription(List<OpportunityLineItem> oppLineItems){
          
          //burteforce looks like 
        //   for(OpporutnityLineItem newOppLineItems : oppLineItems){
        //       Opportunity opp = [Select Id, AccountId From Opportunity Where Id =: newOppLineItems.OpportunityId];
        //       Account acc = [Select Id, Description From Account Where Id =: opp.AccountId];

        //       acc.Description = newOppLineItems.Description;
        //       update acc;
        //   }

          //optimize with bulkification
          Set<Id> oppIds = new Set<Id>();
          Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();

          for(OpportunityLineItem newOppLineItem : oppLineItems){
              
            if(newOppLineItem.Id != null){
                 oppIds.add(newOppLineItem.OpportunityId);
            }
          }

          List<Opportunity> allOpps = [Select Id, AccountId From Opportunity Where Id in: oppIds];

          for(Opportunity opp : allOpps){
              oppMap.put(opp.Id, opp);
          }

          Map<Id,String> accountDesMap = new Map<Id,String>();

          for(OpportunityLineItem oppsLineItem : oppLineItems){
             Opportunity oops = oppMap.get(oppsLineItem.OpportunityId);
             if(oops != null){
                accountDesMap.put(oops.AccountId, oppsLineItem.Description);
             }
          }

          List<Account> allAcc = [Select Id, Description From Account Where Id in : accountDesMap.keySet()];
          List<Account> accToUpdateList = new List<Account>();

          for(Account acc : allAcc){
             acc.Description = accountDesMap.get(acc.Id);
             accToUpdateList.add(acc);
          }

          if(!accToUpdateList.isEmpty()){
             update accToUpdateList;
          }
      }


      //11-02-2026 challenge
      /** Trigger to update Account's Amount field by opportunityLineItem's listPrice which is associated with opportunity. */
     
      public static void updateAmountField(List<OpportunityLineItem> oppLineItems){
         
         Set<Id> oppIds = new Set<Id>();

          for(OpportunityLineItem oppLine : oppLineItems){
               if(oppLine != null){
                  oppIds.add(oppLine.OpportunityId);
               }
          }

          List<Opportunity> allops = [Select Id, AccountId From Opportunity Where Id in :oppIds];

          Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();

         for(Opportunity opp : allops){
             oppMap.put(opp.Id, opp);
         }

        Map<Id,Decimal> accountAmountMap = new Map<Id,Decimal>();

         for(OpportunityLineItem newOppLineItems : oppLineItems){
             Opportunity ops = oppMap.get(newOppLineItems.OpportunityId);

             if(ops != null){
                 accountAmountMap.put(ops.AccountId, newOppLineItems.ListPrice);
             }
         }

         List<Account> allAccounts = [Select Id, ListPriceAmount__c From Account Where Id in : accountAmountMap.keySet()];
         List<Account> accToUpdate = new List<Account>();

         for(Account acc : allAccounts){
             acc.ListPriceAmount__c = accountAmountMap.get(acc.Id);
             accToUpdate.add(acc);
         }

         if(!accToUpdate.isEmpty()){
             update accToUpdate;
         }
      }


 






}