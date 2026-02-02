public class LeadTriggerFuturemethodProcessor {
   
    
    @future
    public static void createFollowUpTask(Set<Id> listOfIds){
         List<Lead> allLeads = [Select Id, OwnerId from Lead Where Id In : listOfIds];

         List<Task> taskToCreate = new List<Task>();
         for(Lead currentLead : allLeads){
              Task t = new Task();
              t.Subject = 'Follow up with lead';
              t.WhoId = currentLead.Id;
              t.OwnerId = currentLead.OwnerId;
              t.Status = 'Not Started';
              t.Priority = 'Normal';
              taskToCreate.add(t);
         }

         if(!taskToCreate.isEmpty()){
            insert taskToCreate;
         }
    }


}