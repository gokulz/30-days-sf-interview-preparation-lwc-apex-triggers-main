public with sharing class ContactTriggerHandler {
   

//   public static void beforeUpdate(List<Contact> conList){
//       updateTheSalutation(conList);
//   }

  public static void afterUpdate(List<Contact> listOfCon, Map<Id,Contact> oldMap){
    updateTheUserPhoneNumber(listOfCon, oldMap);
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

    /**
     * Write a trigger to update the user phone number as same as the contact phone number once 
     * where the user email and contact email is same 
     * the contact phone number gets updated (2 class, one annotated with @future)
     */
    private static void updateTheUserPhoneNumber(List<Contact> listOfCon, Map<Id,Contact> oldMap){
       
    
       /**
        * this method is for brute force now it is updating for single contact try to bulkifie the code
        */
        // for(Contact con : listOfCon){
        //    Contact cont = [Select Id, MobilePhone From Contact Where Id =: con.Id];
        //    User user = [Select Id, Phone From User Where Id =:cont.Id];
            
        //     user.Phone = cont.MobilePhone;
        //    update user;

        // }

        Set<Id> conIds = new Set<Id>();
       
        for(Contact con : listOfCon){
            Contact oldCon = oldMap.get(con.Id);

            if(con.MobilePhone != oldCon.MobilePhone && con.MobilePhone != null){
                conIds.add(con.Id);
            }
        }
      
        if(!conIds.isEmpty()){
            updatePhoneNumber(conIds);
        }
      
    }

    @future
    private static void updatePhoneNumber(Set<Id> conIds){
        
        Map<Id,Contact> contactMap = new Map<Id,Contact>();

        //take the list of contacts
        List<Contact> allCont = [Select Id, MobilePhone From Contact Where Id in :conIds];

        for(Contact con : allCont){
            contactMap.put(con.Id, con);
        }

        //now take the list of users related to that contact
     //   List<User> allUser = [Select Id, Phone, ContactId From User Where ContactId in : conIds];
        List<User> allUser = [Select Id, Phone, ContactId From User Where Id =: UserInfo.getUserId()];
         
       // List<User> userToUpdate = new List<User>();
        for(User us : allUser){
        
            if(contactMap.containsKey(us.ContactId)){
                 us.Phone = contactMap.get(us.ContactId).MobilePhone;
            }
        }

        if(!allUser.isEmpty()){
            update allUser;
        }

    }
}