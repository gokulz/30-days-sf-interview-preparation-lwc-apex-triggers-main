public with sharing class RollUpSummaryContactTriggerHandler {

    public static void afterInsert(List<Contact> cont){
       // rollupSummaryTriggerMethod(cont, null);
       checkBoxTriggerMethod(cont, null);
    }

    public static void afterUpdate (List<Contact> cont, Map<Id,Contact> oldMap){
        //rollupSummaryTriggerMethod(cont, oldMap);
        checkBoxTriggerMethod(cont, oldMap);
    }
    public static void afterDelete(List<Contact> cont){
      //  rollupSummaryTriggerMethod(cont, null);
      checkBoxTriggerMethod(cont, null);
    }
  
    private static void rollupSummaryTriggerMethod(List<Contact> cont, Map<Id,Contact> oldMap){

        Set<Id> accountIds = new Set<Id>();

        for(Contact newCon : cont){

            if(oldMap == null){
               
                if(newCon.AccountId != null){
                     accountIds.add(newCon.AccountId);
                }
            }
            else{
                 Contact oldCon = oldMap.get(newCon.Id);

                 if(newCon.AccountId != oldCon.AccountId){

                    if(newCon.AccountId != null){
                            accountIds.add(newCon.AccountId);
                        }

                    if(oldCon.AccountId != null){
                            accountIds.add(oldCon.AccountId);
                        }
                }

            }     
          
        }

        List<Account> allAccount = [Select Id, Name, No_of_Contacts__c From Account Where id in: accountIds];

        Map<Id,Decimal> contactCountMap = new Map<Id,Decimal>();
        
        List<AggregateResult> totalCon = [Select count(id) totalCont, AccountId From Contact Where accountId in : accountIds Group By AccountId];

        for(AggregateResult agr : totalCon){
            Id accId = (Id) agr.get('AccountId');
            System.debug('accId: ' + accId);
            Decimal totalCont = (Decimal) agr.get('totalCont');
            System.debug('totalcont: ' + totalCont);
            contactCountMap.put(accId, totalCont);
        }

        List<Account> updateToAccount = new List<Account>();
        for(Account acc : allAccount){
            if(contactCountMap.containsKey(acc.Id)){
            acc.No_of_Contacts__c = contactCountMap.get(acc.Id);
            updateToAccount.add(acc);
            }
        }

        if(!updateToAccount.isEmpty()){
            update updateToAccount;
        }

    }


    /**
     * Create a trigger whenever new contact is added it will check contact exist 
     * checkbox in Account object and whenever no contact is there for account then checkbox value false.
     */

     private static void checkBoxTriggerMethod(List<Contact> conts, Map<Id, Contact> oldMap){
        
        //for now i only build for insert operation 
         Set<Id> accountIds = new Set<Id>();
         
          for(Contact newCon : conts){
            //i can use this one for delete operation and new operation
            if(oldMap== null){
               if(newCon.AccountId != null){
                accountIds.add(newCon.AccountId);
               }
           } else{
                Contact Oldcon = oldMap.get(newCon.Id);

                if(newCon.AccountId != null){
                    accountIds.add(newCon.AccountId);
                }
                if(Oldcon.AccountId != null){
                    accountIds.add(Oldcon.AccountId);
                }
           }
            
          }

        List<Account> allAccounts = [Select Id, Name, Contact_Checkbox__c From Account Where Id in :accountIds];

          Map<Id,Integer> contactCountMap = new Map<Id,Integer>();

          List<AggregateResult> agrResult = [Select Count(Id) countId, AccountId accId From Contact Where AccountId in:accountIds Group By AccountId];

          for(AggregateResult ag : agrResult){
            Id accId = (Id) ag.get('accId');
            Integer countCont = (Integer) ag.get('countId');
            contactCountMap.put(accId, countCont);
          }

          
          List<Account> updateAccount = new List<Account>();

          for(Account acc : allAccounts){
              if(contactCountMap.containsKey(acc.Id) && contactCountMap.get(acc.Id) > 0){
                  acc.Contact_Checkbox__c = true;
              }else{
                acc.Contact_Checkbox__c = false;
              }
              updateAccount.add(acc);
          }

          if(!updateAccount.isEmpty()){
            update updateAccount;
          }
     }

     //Contact_Checkbox__c
}

/**
 * “Why do you use oldMap in update?”

You can answer:

“Because when a child record changes its parent, both the previous and current parents are impacted.
 Using oldMap ensures the previous parent is also recalculated.”
 */