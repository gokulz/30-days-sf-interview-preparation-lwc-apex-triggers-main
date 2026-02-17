public with sharing class LeadTriggerHandler {


    /**
     * Automatically create a followup task with additional info description when lead is converted.
     */

     public static void leadConvert(List<Lead> listOfLeads, Map<Id,Lead> oldMap){
          
        List<Lead> convertLead = new List<Lead>();
        Set<Id> convertedAccountIds = new Set<Id>();
        Set<Id> convertedOppIds = new Set<Id>();
        Set<Id> convertedConIds = new Set<Id>();
         for(Lead newLead : listOfLeads){
              Lead oldLead = oldMap.get(newLead.Id);

              if(newLead.IsConverted && !oldLead.IsConverted){
                    convertLead.add(newLead);

                    if(newLead.ConvertedAccountId != null){
                         convertedAccountIds.add(newLead.ConvertedAccountId);
                    }
                    if(newLead.ConvertedContactId != null){
                        convertedConIds.add(newLead.ConvertedContactId);
                    }
                    if(newLead.ConvertedOpportunityId != null){
                        convertedOppIds.add(newLead.ConvertedOpportunityId);
                    }
              }
         }
         //map to store converted account, con, oppo
         Map<Id,Account> accMap = new Map<Id,Account>([Select Id, Name From Account Where Id in : convertedAccountIds]);
         Map<Id,Contact> conMap = new Map<Id,Contact>([Select Id, Name From Contact Where Id in : convertedConIds]);
         Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([Select Id, Name, CloseDate From Opportunity Where Id in : convertedOppIds]);

         List<Task> taskToUpdate = new List<Task>();

         for(Lead allLead : convertLead){
              Task newTask = new Task();
              newTask.Subject = 'Follow-up with converted Leads';
              newTask.Priority = 'Normal';
              newTask.Status = 'Not Started';
              newTask.ActivityDate = Date.today() + 7;
              newTask.WhoId = allLead.ConvertedContactId;
              newTask.WhatId = allLead.ConvertedOpportunityId;

              String taskDescription = 'Lead Name ' + allLead.FirstName + '\n';
              taskDescription += 'Lead Email ' + allLead.Email + '\n';
              taskDescription += 'Lead Phone ' + allLead.Phone + '\n';

              if(accMap.containsKey(allLead.ConvertedAccountId)){
                  Account acc = accMap.get(allLead.ConvertedAccountId);
                  taskDescription += 'Account Name : ' + acc.Name + '\n';
              }
              if(conMap.containsKey(allLead.ConvertedContactId)){
                 Contact con = conMap.get(allLead.ConvertedContactId);
                 taskDescription += 'Contact Name : ' + con.Name + '\n';
              }
              if(oppMap.containsKey(allLead.ConvertedOpportunityId)){
                 Opportunity opp = oppMap.get(allLead.ConvertedOpportunityId);
                 taskDescription += 'Opportunity Name: ' + opp.Name + '\n';
              }

              newTask.Description = taskDescription;

              taskToUpdate.add(newTask);
         }

         if(!taskToUpdate.isEmpty()){
             insert taskToUpdate;
         }
     }
   
}