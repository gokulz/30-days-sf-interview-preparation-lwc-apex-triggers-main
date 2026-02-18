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

        List<AggregateResult> agrResult = [Select AccountId accId, Sum(Amount) amt From Opportunity Where AccountId in :allAccountIds Group By AccountId];

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
      
    //   public static void createNumberContacts(List<Account> allAccounts){

    //     List<Contact> listOfCont = new List<Contact>();
           
    //       for(Account acc : allAccounts){
    //           if(acc.No_Of_Con__c != null){
    //               for(int i=0; i<acc.No_Of_Con__c; i++){
    //                   Contact con = new Contact();
    //                   con.FirstName = 'Test';
    //                   con.LastName = 'Contact' + i;
    //                   con.AccountId = acc.Id;
    //                    listOfCont.add(con);
    //               }
    //           }
    //       }

    //       if(!listOfCont.isEmpty()){
    //          insert listOfCont;
    //       }
    //   }


    /**
     * Delete all Related Opportunities and
     *  check do not contact checkbox on related contact when user changes Account status from Active to Inactive.
     */
    public static void deleteRelatedOpp(List<Account> listofAccounts, Map<Id,Account> oldMap){

        // //bruteforce
        // for(Account acc : listofAccounts){
        //       if(acc != null && acc.Status__c == 'InActive'){
        //            Account acct = [Select Id, Status__c, (Select Id, Do_not_Contact__c From Contacts), (Select Id, Name From Opportunities) From Account Where Id =: acc.Id];
        //            Contact con = acct.Contacts;
        //            con.Do_not_Contact__c = true;
        //            update con;
        //            Opportunity opp = acct.Opportunities;
        //            delete opp;
        //       }
        // }

        //better approach with 3 loops 

        // Set<Id> accIds = new Set<Id>();
        // for(Account acc : listofAccounts){
        //     Account oldAcc = oldMap.get(acc.Id);
        //     if(acc != null && acc.Status__c == 'InActive' && oldAcc.Status__c == 'Active'){
        //           accIds.add(acc.Id);
        //     }
        // }

        // List<Account> allAccountsRelated = [Select Id, Name, (Select Id, Do_not_Contact__c From Contacts), (Select Id, Name From Opportunities) From Account Where Id in : accIds];

        // List<Opportunity> oppToDelete = new List<Opportunity>();
        // List<Contact> contToUpdate = new List<Contact>();
        // for(Account acc : allAccountsRelated){
             
        //     for(Opportunity opp : acc.Opportunities){
        //          oppToDelete.add(opp);
        //     }
        //     for(Contact con : acc.Contacts){
        //          con.Do_not_Contact__c = true;
        //          contToUpdate.add(con);
        //     }
        // }

        // delete oppToDelete;
        // update contToUpdate;



      //optimal approach 
      Set<Id> accIds = new Set<Id>();

      for(Account acc : listofAccounts){
           Account oldAcc = oldMap.get(acc.Id);
           
           if(acc != null && acc.Status__c == 'InActive' && oldAcc.Status__c == 'Active'){
                 accIds.add(acc.Id);
           }
       }

       List<Opportunity> allOpp = [Select Id, AccountId, StageName From Opportunity Where AccountId in : accIds and StageName != 'Closed Won'];
       List<Contact> allCont = [Select Id, Do_not_Contact__c, AccountId From Contact Where AccountId in : accIds and Do_not_Contact__c = false];
       List<Contact> conListToUpdate = new List<Contact>();
       if(!accIds.isEmpty()){
           
        if(!allCont.isEmpty()){
             for(Contact con : allCont){
                 con.Do_not_Contact__c = true;
                 conListToUpdate.add(con);
             }
        }

          if(!conListToUpdate.isEmpty()){
             update conListToUpdate;
          }
          if(!allOpp.isEmpty()){
             delete allOpp;
          }
       }

    }

       
}