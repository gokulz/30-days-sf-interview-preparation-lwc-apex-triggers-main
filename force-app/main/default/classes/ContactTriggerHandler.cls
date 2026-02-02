public with sharing class ContactTriggerHandler {
   

  public static void beforeUpdate(List<Contact> conList){
      updateTheSalutation(conList);
  }


    private static void updateTheSalutation(List<Contact> listOfCon){

      
        for(Contact newCon : listOfCon){
            if(newCon.Gender__c == 'Male'){
                newCon.Salutation = 'MR';
            }else if(newCon.Gender__c == 'Female'){
                newCon.Salutation = 'Ms';
            }
        }

    }
}