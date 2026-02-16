public with sharing class AccountTriggerHandlerForOppotunity {

     //method for after insert
     public static void afterInsert(List<Account> allAccounts){
           handleAgricultureAccounts(allAccounts, null);
     }
    
     public static void afterUpdate(List<Account> allAccounts , Map<Id,Account> oldMap){
         handleAgricultureAccounts(allAccounts, oldMap);
     }


    //why i use private do not want to expose the logic method to public
    private static void handleAgricultureAccounts(List<Account> allAccounts, Map<Id,Account> oldMap){

        Set<Id> accountIds = new Set<Id>();

       //for insert operation 
        for(Account acc : allAccounts){
            if(oldMap == null && acc.Industry == 'Agriculture'){
                accountIds.add(acc.Id);
            }
        }

        //for update operation
        for(Account acc : allAccounts){
            if(oldMap != null){
                Account oldAcc = oldMap.get(acc.Id);

                if(oldAcc.Industry != 'Agriculture' && acc.Industry == 'Agriculture'){
                    accountIds.add(acc.Id);
                }
            }
        }
       
     Map<Id,Account> accMap = new Map<Id,Account>([Select Id, Name From Account Where Id In:accountIds]);
     List<Opportunity> oppList  = new List<Opportunity>();

     for(Account acc : accMap.values()){
        Opportunity opp = new Opportunity(
                Name = acc.Name + ' Opportunity',
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(3)
            );
            oppList.add(opp);
     }

     if(!oppList.isEmpty()){
        insert oppList;
     }

    }

    /**
     * On updating an Account record, the total Amount of all Opportunities 
     * related to that Account should be calculated and stored in the Total Opportunity Amount field on the Account.
     */

     public static void calucalteSumAmount(List<Account> allAcc){
          
        //retrive the oppotunity based on the id 
        Set<Id> allAccountIds = new Set<Id>();
        for(Account newAcc : allAcc){
             if(newAcc.Id != null){
                allAccountIds.add(newAcc.Id);
             }
          }

        List<Account> accountwithField =[Select Id, Name, Total_Opportunity_Amount__c From Account Where Id in : allAccountIds];
        

        Map<Id,Decimal> sumOfAmoutn = new Map<Id,Decimal>();

        List<AggregateResult> agrResult = [Select Id, AccountId accId, Sum(Amount) amt From Opportunity Where AccountId in :allAccountIds Group By AccountId];

        for(AggregateResult agr : agrResult){
            Id accId = (Id)agr.get('accId');
            Decimal sumAmount = (Decimal) agr.get('amt');
            sumOfAmoutn.put(accId, sumAmount);
        }

        List<Account> accountToUpdate = new List<Account>();
        for(Account acc : accountwithField){
            if(sumOfAmoutn.containsKey(acc.Id)){
                acc.Total_Opportunity_Amount__c = sumOfAmoutn.get(acc.Id);
            }else{
                 acc.Total_Opportunity_Amount__c = 0;
            }

            accountToUpdate.add(acc);
        }

        if(!accountToUpdate.isEmpty()){
            update accountToUpdate;
        }
     }

     /**
      * Write a trigger on Account, to create No Of Contacts based on a field value from account record.
      */
      
      public static void createNumberContacts(List<Account> allAccounts){

        List<Contact> listOfCont = new List<Contact>();
           
          for(Account acc : allAccounts){
              if(acc.No_Of_Con__c != null){
                  for(int i=0; i<acc.No_Of_Con__c; i++){
                      Contact con = new Contact();
                      con.FirstName = 'Test';
                      con.LastName = 'Contact' + i;
                      con.AccountId = acc.Id;
                       listOfCont.add(con);
                  }
              }
          }

          if(!listOfCont.isEmpty()){
             insert listOfCont;
          }
      }


      /**
       * write a trigger to calculate number of cases for each account based on their Status (New, Working, Escalated)
       */

       
}