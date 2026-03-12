public with sharing class OpportunityTriggerHandler {
 
    public static void afterInsert(List<Opportunity> opps){
      //  checboxChecker(opps, null);
     // updateTheAccountRating(opps);
      closedWonPriority(opps, null);
    }

    public static void afterUpdate(List<Opportunity> opps, Map<Id,Opportunity> oldMap){
         //checboxChecker(opps, oldMap);
        // createTask(opps, oldMap);
       // updateAccountAnnualRevenue(opps, oldMap);
       closedWonPriority(opps, oldMap);

    }
    public static void afterDelete (List<Opportunity> opps){
        checboxChecker(opps, null);
    }

    public static void beforeInsert(List<Opportunity> oppList){
       preventDuplicateOpp(oppList, null);    
    }
    public static void beforeUpdate(List<Opportunity> oppList, Map<Id,Opportunity> oldMap){
        preventDuplicateOpp(oppList, oldMap);
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

    private static void checkClosingDate(List<Opportunity> opps){

        // //brute force
        // for(Opportunity newOpp : opps){
        //     if(newOpp.CloseDate() > newOpp.CloseDate().addMonths(1) && newOpp.Amount > 5000){
        //        newOpp.add('you cannot insert the oppotunity because amount is not greater than 5000 and close date is not greater than one month');
        //     }
        // }

        //the optimal approach
        // Date oneMonthFromNow = Date.today().addMonths(1);

        // for(Opportunity newOpp : opps){
        //     if(!newOpp.CloseDate() <= oneMonthFromNow || !newOpp.Amount <= 5000){
        //         newOpp.addError('you cannot able to insert');
        //     }
        // }

    }

    /**
     * write an apex trigger that create task or update task based on stage changes (opportunity record stagename updated if the task name 
     * present update stage name in the tasks description else create a new task)  
     */



     private static void createTask(List<Opportunity> listOfOps, Map<Id,Opportunity> oldMap){
           
           Set<Id> oppIds = new Set<Id>();
           Map<Id,Task> tskMap = new Map<Id,Task>();
           List<Task> updateToTask = new List<Task>();
           List<Task> insetToTask = new List<Task>();


           for(Opportunity newOpp : listOfOps){
                Opportunity oldStage = oldMap.get(newOpp.Id);
                if(newOpp.StageName != null && newOpp.StageName != oldStage.StageName){
                     oppIds.add(newOpp.Id);
                }
           }
          

           List<Task> listOfTask = [Select Id, Subject, Description, WhatId From Task Where WhatId in : oppIds];

           for(Task tsk : listOfTask){
                tskMap.put(tsk.WhatId, tsk);
           }
           
           for(Opportunity opp : listOfOps){
               if(opp.StageName != oldMap.get(opp.Id).StageName){
                  Task newTask;

                  if(tskMap.containsKey(opp.Id)){
                     newTask = tskMap.get(opp.Id);
                     newTask.Description = 'Opportunity hasbeen update to the statgeName: ' + opp.StageName;
                     updateToTask.add(newTask);
                  }else{
                      newTask = new Task();
                      newTask.Subject = 'Folloup on stage';
                      newTask.Description ='Newly created task with stagename: ' + opp.StageName;
                      newTask.WhatId = opp.Id;
                      insetToTask.add(newTask);
                  }
               }
           }

           if(!updateToTask.isEmpty()){
              update updateToTask;
           }
           if(!insetToTask.isEmpty()){
              insert insetToTask;
           }
     }


     /**
      * Write a Trigger to update Account Rating based on Total Amount of Related Opportunities
      * Amount less than or equal to 50k --> Rating will be cold
        Amount less than or equal to 1L --> Rating will be Warm
        Amount greater than 1L --> Rating will be hot
      */


     private static void updateTheAccountRating(List<Opportunity> listOfOpp){
           
        //brute force 
        // for(Opportunity opp : listOfOpp){
        //      Account acc = [Select Id, Rating From Account Where Id =: opp.AccountId];

        //      if(opp.Amount > 50000){
        //         acc.Rating = 'Cold';
        //         update acc;
        //      }

        //optimized

        Set<Id> accIds = new Set<Id>();
        for(Opportunity opp : listOfOpp){
             if(opp != null){
               accIds.add(opp.AccountId);
             }
        }

         List<Opportunity>  allOps = [Select Id, AccountId, Amount From Opportunity Where AccountId in : accIds];

         Map<Id,Decimal> amountMap = new Map<Id,Decimal>();

          for(Opportunity opps : allOps){
            if(amountMap.containsKey(opps.AccountId)){
             amountMap.put(opps.AccountId, amountMap.get(opps.AccountId)+ opps.Amount);
            }else{
                 amountMap.put(opps.AccountId, opps.Amount);
            }
          }

          List<Account> allAccount = [Select Id, Rating From Account Where Id in : accIds];

          List<Account> accountsToUpdate = new List<Account>();

          for(Account acc : allAccount){
               if(amountMap.containsKey(acc.Id)){
                   Decimal totalAmount = amountMap.get(acc.Id);
                   
                   if(totalAmount <= 50000){
                     acc.Rating = 'Cold';
                   } else if(totalAmount <=100000){
                       acc.Rating = 'Warm';
                   }else{
                      acc.Rating = 'Hot';
                   }
                  accountsToUpdate.add(acc);
               }
          }

          if(!accountsToUpdate.isEmpty()){
              update accountsToUpdate;
          }
         
        }
     

          /**
  Write a trigger that prevents an Opportunity from being deleted if the Opportunity Stage
is 'Closed Won'
   */
   private static void preventDeletion(List<Opportunity> listOfOpportunity){
     
     for(Opportunity opp : listOfOpportunity){
          
          if(opp != null && opp.StageName == 'Closed Won'){
              opp.addError('you cannot able to delete the triggger');
        }
     }
  }

 
  /**
   Write a trigger to ensure that the Account's "AnnualRevenue" is updated every time an
Opportunity is closed.
      **/

  private static void updateAccountAnnualRevenue(List<Opportunity> listOfOpportunity, Map<Id, Opportunity> oldMap){

    //this by solving with aggreate function 

    //  Set<Id> accIds = new Set<Id>();
       
    //   for(Opportunity newOpp : listOfOpportunity){
    //       Opportunity oldOpp = oldMap.get(newOpp.Id);

    //      if(newOpp != null && newOpp.StageName == 'Closed Won' && oldOpp.StageName != newOpp.StageName){
    //         accIds.add(newOpp.AccountId);
    //      }
        
    // }


    //         List<AggregateResult> agrResult = [Select Sum(Amount) amt, AccountId accId From Opportunity Where AccountId in : accIds and StageName = 'Closed Won' Group By AccountId];

    //         List<Account> allAccounts = [Select Id, AnnualRevenue From Account Where Id in: accIds];
            
            
    //         Map<Id,Double> totalAmountMap = new Map<Id,Double>();

    //         for(AggregateResult agr : agrResult){
    //                 Double amount = (Double) agr.get('amt');
    //                 Id acId = (Id) agr.get('accId');
                    
    //                 totalAmountMap.put(acId, amount);
                
    //             }

    //         List<Account> accListToUpdate = new List<Account>();
                
    //         for(Account acc : allAccounts){
    //             if(totalAmountMap.containsKey(acc.Id)){
    //                 acc.AnnualRevenue = totalAmountMap.get(acc.Id);
    //                 accListToUpdate.add(acc);
    //             }
    //         }
            
            
    //         if(!accListToUpdate.isEmpty()){
    //             update accListToUpdate;
    //         }
         
        //solving without aggregate 
        Set<Id> accIds = new Set<Id>();

        for(Opportunity newOpp : listOfOpportunity){
            Opportunity oldOpp = oldMap.get(newOpp.Id);

            if(newOpp != null && newOpp.AccountId != null && newOpp.StageName == 'Closed Won' && newOpp.StageName != oldOpp.StageName){
                 accIds.add(newOpp.AccountId);
            }
        }
        
        List<Opportunity> allOpps = [Select Id, AccountId, Amount, StageName From Opportunity Where AccountId in : accIds and StageName = 'Closed Won'];
        Map<Id,Decimal> amountMap = new Map<Id,Decimal>();


        for(Opportunity opp : allOpps){
            if(amountMap.containsKey(opp.AccountId)){
               amountMap.put(opp.AccountId, amountMap.get(opp.AccountId) + opp.Amount);
            }else{
                 amountMap.put(opp.AccountId, opp.Amount);
            }
           
        }

      List<Account> allAccount = [Select Id, AnnualRevenue From Account Where Id  in : accIds];

      List<Account> accToUpdate = new List<Account>();
      for(Account acc : allAccount){
           acc.AnnualRevenue = amountMap.get(acc.Id);
           accToUpdate.add(acc);
      }
     
      if(!accToUpdate.isEmpty()){
          update accToUpdate;
      }
  }


  /**
   * Write a trigger that ensures a custom "Status" field on Account is updated when an Opportunity is closed.
   */

   private static void updateCustomStatus(List<Opportunity> listOfOpp, Map<Id,Opportunity> oldMap){
      
     Set<Id> accIds = new Set<Id>();
      for(Opportunity newOpp : listOfOpp){
         
         Opportunity oldOpp = oldMap.get(newOpp.Id);

          if(newOpp.AccountId != null && oldOpp.StageName != 'Closed Won' && newOpp.StageName == 'Closed Won'){
              accIds.add(newOpp.AccountId);
          }
      }
      
      List<Account> allAccounts = [Select Id, Status__c From Account Where Id in : accIds];
     
      List<Account> accToupdate = new List<Account>();

      for(Account acc : allAccounts){
          acc.Status__c = 'Active';
          accToupdate.add(acc);
      }
      
      if(!accToupdate.isEmpty()){
          update accToupdate;
      }
       
   }


   /**
    * Write a trigger that automatically sends an email when an Opportunity is closed-won and its Amount exceeds a certain value.
    */

    private static void sendsAnEmail(List<Opportunity> allOps, Map<Id,Opportunity> oldMap){

       List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
       Decimal certainValue = 50000;

         
         for(Opportunity newOps : allOps){
             Opportunity oldOps = oldMap != null ? oldMap.get(newOps.Id) : null ;
             
             Boolean isNewlyWon = newOps.StageName == 'Closed Won' && (oldOps != null || oldOps.StageName != 'Closed Won');

             if(isNewlyWon && newOps.Amount > certainValue){
                 Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                 email.setTargetObjectId(newOps.OwnerId);
                 email.setSubject('High value Deal Closed: ' + newOps.Name);
                 email.setPlainTextBody('Congratulations a deal worth: $' + newOps.Amount);
                 emailsToSend.add(email);
             }
         }

         if(!emailsToSend.isEmpty()){
            Messaging.sendEmail(emailsToSend);
         }
    }

    // /**
    //  * Create a trigger to update a custom field on the Account when a related Opportunity is closed-lost.
    //  */

    //  private static void updateCustomField(List<Opportunity> oppList, Map<Id,Opportunity> oldMap){
          
    //       Set<Id> accIds = new Set<Id>();
    //       for(Opportunity newOpp : oppList){
               
    //           Opportunity oldOpp = oldMap != null ? oldMap.get(newOpp.Id) : null;

    //           if(newOpp.AccountId != null && oldOpp != null && oldOpp.StageName != newOpp.StageName && newOpp.StageName == 'Closed Lost'){
    //                accIds.add(newOpp.AccountId);
    //           }
              
    //       }

    //      List<Account> allAccounts = [Select Id, Custom_Field__c From Account Where Id In : accIds];

    //      List<Account> accountsToUpdate = new Account();
          
    //      for(Account acc : allAccounts){
    //          acc.Custom_Field__c = 'Opportunity is Closed Lost';
    //          accountsToUpdate.add(acc);
    //      }

    //      if(!accountsToUpdate.isEmpty()){
    //          update accountsToUpdate;
    //      }
    //  }

     /**
      * Create a trigger that updates an Account’s "Priority" when an Opportunity reaches a "Closed Won" stage
      */

      private static void closedWonPriority(List<Opportunity> oppList, Map<Id,Opportunity> oldMap){

          Set<Id> accountIds = new Set<Id>();
           
           for(Opportunity newOpp : oppList){
               Opportunity oldOpp = oldMap != null ? oldMap.get(newOpp.Id) : null;

               if(newOpp.AccountId != null  && newOpp.StageName == 'Closed Won' || oldOpp.StageName != 'Closed Won'){
                   accountIds.add(newOpp.AccountId);
               }
           }

           List<Account> accountToUpdate = new List<Account>();

           for(Id accId : accountIds){
              accountToUpdate.add(new Account(Id = accId,Priority__c = 'Priority' ));
           }

           if(!accountToUpdate.isEmpty()){
              update accountToUpdate;
           }
      }


      /**
       * Write a trigger that prevents creating a duplicate Opportunity for the same Account and Opportunity Name.
       */

       private static void preventDuplicateOpp(List<Opportunity> oppList, Map<Id, Opportunity> oldMap){
            
          //use two sets to store accountIds and OppNames

          Set<Id> accIds = new Set<Id>();
          Set<String> oppNames = new Set<String>();

          for(Opportunity newOpp : oppList){
             if(newOpp.AccountId != null && newOpp.Name != null){
                if(oldMap == null || newOpp.Name != oldMap.get(newOpp.Id).Name || newOpp.AccountId != oldMap.get(newOpp.Id).AccountId){
                    accIds.add(newOpp.AccountId);
                    oppNames.add(newOpp.Name.toLowerCase());
                }
             }
          }

          Map<Id,Set<String>> duplicateMap = new Map<Id,Set<String>>();

          for(Opportunity existingOpp : [Select Id, Name, AccountId From Opportunity Where Id in : accIds and Name in : oppNames]){
               
               if(!duplicateMap.containsKey(existingOpp.AccountId)){
                   duplicateMap.put(existingOpp.AccountId, new Set<String>());
               }

               duplicateMap.get(existingOpp.AccountId).add(existingOpp.Name.toLowerCase());
          }
          
          for(Opportunity opp : oppList){
            //checking if the account exisiting in the map
              if(duplicateMap.containsKey(opp.AccountId)){
                //checking if the opp name is existing in that account
                if(duplicateMap.get(opp.AccountId).contains(opp.Name.toLowerCase())){
                    opp.addError('Duplicate Opportunity Name Found for this Account');
                }
              }
          }
       }

       /**
        * Implement a trigger that populates a custom "Total Value" field on Account, summing up the "Amount" of related Opportunities
        */

        private static void calculateTotalValue(List<Opportunity> oppList, Map<Id,Opportunity> oldMap){
              
            Set<Id> accIds = new Set<Id>();
             for(Opportunity newOpp : oppList){
                 Opportunity oldOpp = oldMap != null ? oldMap.get(newOpp.Id) : null;

                 if(newOpp.AccountId != null){
                     accIds.add(newOpp.AccountId);
                 }
                 if(oldOpp != null && oldOpp.AccountId != null){
                      accIds.add(oldOpp.AccountId);
                 }
             }

            List<AggregateResult> agrResults = [SELECT AccountId accId, SUM(Amount) totalAmount FROM Opportunity WHERE AccountId IN :accIds GROUP BY AccountId];
             
             Map<Id,Decimal> accountMap = new Map<Id,Decimal>();
            for(AggregateResult agr : agrResults){
                Id accId = (Id) agr.get('accId');
                Decimal amount = (Decimal) agr.get('totalAmount');
                accountMap.put(accId, amount);
            }

            List<Account> accountToUpdate = new List<Account>();
            for(Id accId : accIds){
                accountToUpdate.add(new Account(
                    Id = accId, 
                    TotalValue__c = accountMap.containsKey(accId) ? accountMap.get(accId) : 0 
                    ));
            }

            if(!accountToUpdate.isEmpty()){
                update accountToUpdate;
            }
        }
}

    /**
     * challenge 16-02-2026 same trigger try with after update after undelete, after delete then use aggregateresult
     * 
      * Write a Trigger to update Account Rating based on Total Amount of Related Opportunities
      * Amount less than or equal to 50k --> Rating will be cold
        Amount less than or equal to 1L --> Rating will be Warm
        Amount greater than 1L --> Rating will be hot
      */

    

    //  private static void createTask(List<Opportunity> opps, Map<Id,Opportunity> oldMap){
         
    //     // //bruteforce approach 
    //     // for(Opportunity opp : opps){
    //     //     Opportunity oldMapStage = oldMap.get(opp.Id);
    //     //     if(opp.StageName != null  && oldMapStage.StageName  != opp.StageName){
    //     //         Task tsk = new Task();
    //     //         tsk.Subject = opp.StageName;
    //     //         tsk.WhatId = opp.Id;
    //     //         tsk.Description = opp.StageName;
    //     //         tsk.Status = 'Progress';
    //     //         upsert tsk;
    //     //     }
    //     // }

    //     Set<Id> allOppIds = new Set<Id>();

    //     //making bulkification this approach will create every time the new task for each stage name
    //     for(Opportunity newOpp : opps){
    //         Opportunity oldMapStage = oldMap.get(newOpp.Id);

    //         if(newOpp.StageName != null && newOpp.StageName != oldMapStage.StageName){
    //               allOppIds.add(newOpp.Id);
    //         }
    //     }

    //     List<Opportunity> allOpps = [Select Id, StageName From Opportunity Where Id in :allOppIds];

    //    List<Task> taskToUpdate = new List<Task>();
    //     for(Opportunity op : allOpps){
    //         Task tsk = new Task();
    //          tsk.Subject = op.StageName;
    //          tsk.WhatId = op.Id;
    //          tsk.Description = op.StageName;
    //         tsk.Status = 'Progress';
    //         taskToUpdate.add(tsk);
    //     }

    //     if(!taskToUpdate.isEmpty()){
    //         upsert taskToUpdate;
    //     }
   //  }
//}
