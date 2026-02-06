public class BatchApexController implements Database.Batchable<Contact> {
    /**
     * batch apex is used to process large volumes of data aynchrounously by breaking them into the smaller chunks
     * It implements Database.batchable and has start, execute and finish methods
     * 
     * Scenario 1 : Update all Contacts Where MailingCityCity = Hydrabad --> set the Region__c field to "South India"
     * if you know which object your going to implement use directly that object in batch instead of Database.Batchable<sObject>();
     */
     public String query;
     
     //construtor
    public BatchApexController(String query) {
         this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
         return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope){
       

        for(Contact con : scope){
            con.Region__c = 'South Inida';
        }

        if(!scope.isEmpty()){
           update scope;
        }
        
    }

    public void finish(Database.BatchableContext bc){
        System.debug('executed successfully');
    }
}