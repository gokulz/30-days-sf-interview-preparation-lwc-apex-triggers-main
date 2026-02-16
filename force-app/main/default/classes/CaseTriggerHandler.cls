public with sharing class CaseTriggerHandler {
  



    /**
     *  write a trigger to calculate number of cases for each account based on their Status (New, Working, Escalated)
     * 
     */

     public static void calculateCaseNumber(List<Case> listOfCases, Map<Id,Case> oldMap){
         
          Set<Id> accIds = new Set<Id>();
          for(Case newCase : listOfCases){
              Case oldCase = oldMap.get(newCase.Id);
               
              if(newCase.AccountId != null){
                  accIds.add(newCase.AccountId);
                }
             if(oldMap != null){
                 if(oldCase != null && oldCase.AccountId != null){
                     accIds.add(oldCase.AccountId);
                 }
             } 
          }

          List<AggregateResult> agrResult = [Select Count(Id) totalCount, AccountId accId, Status status From Case Where AccountId in:accIds Group By AccountId, Status];

          Map<Id,Account> accMap = new Map<Id,Account>(
            [Select Id, TotalNewCases__c, TotalExcalatedCases__c, TotalWorkingCases__c From Account Where Id in : accIds]
          );

          //Rest to zero
          for(Account acc : accMap.values()){
              acc.TotalNewCases__c =0;
              acc.TotalExcalatedCases__c =0;
              acc.TotalWorkingCases__c =0;
          }
          
         
          List<Account> updateToList = new List<Account>();
          for(AggregateResult agr : agrResult){
              Id accId = (Id) agr.get('accId');
              String status = (String) agr.get('status');
              Integer count = (Integer) agr.get('totalCount');
              
              if(status == 'New'){
                 accMap.get(accId).TotalNewCases__c = count;
              }else if(status == 'Working'){
                 accMap.get(accId).TotalExcalatedCases__c = count;
              } else if(status == 'Escalation'){
                 accMap.get(accId).TotalWorkingCases__c = count;
              }
          }

         update accMap.values();
        
     }
}