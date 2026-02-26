public with sharing class ContactTriggerHandler {
   

//   public static void beforeUpdate(List<Contact> conList){
//       updateTheSalutation(conList);
//   }

  public static void afterUpdate(List<Contact> listOfCon, Map<Id,Contact> oldMap){
    //updateTheUserPhoneNumber(listOfCon, oldMap);
    populateLeadSource(listOfCon);
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

/**
 * Write a trigger to automatically populate the "Lead Source" field on an Account when a new Contact is created.
 */
private static void  populateLeadSource(List<Contact> listOfContacts){

//   //for this approach we are again querying the triggering list
//   Set<Id> accountIds = new Set<Id>();
//    for(Contact con : listOfContacts){
//       if(con.AccountId != null && con.LeadSource != null){
//          accountIds.add(con.AccountId);
//       }   
//    }

//    List<Contact> conList =  [Select Id, AccountId, Account.Lead_Source__c, LeadSource From Contact Where AccountId in : accountIds];
//    List<Account> accToUpdate = new List<Account>();

//     for(Contact con : conList){
//          Account acc = new Account();
//          acc.Id = con.AccountId;
//          acc.LeadSource__c = con.LeadSource;
//          accToUpdate.add(acc);
//     }

//     if(!accToUpdate.isEmpty()){
//          update accToUpdate;
//     }



    //Map with clean approach 

    Map<Id,String> accountMap = new Map<Id,String>();

    for(Contact newCon : listOfContacts){
        if(newCon.AccountId != null && newCon.LeadSource != null){
             accountMap.put(newCon.AccountId, newCon.LeadSource);
        }
    }

    List<Account> accToUpdate = new List<Account>();
    for(Id accId : accountMap.keySet()){
         accToUpdate.add(new Account(Id = accId, Lead_Source__c = accountMap.get(accId)));
    }

    if(!accToUpdate.isEmpty()){
         update accToUpdate;
    }

  }

  /**
   * Create a trigger to prevent the creation of duplicate Contact records based on Email.
   */

   private static void preventDuplicate(List<Contact> listOfContacts, Map<Id,Contact> oldMap){
       
    //brute force approach
    //    List<String> storeTheEmails = new List<String>();
    //     for(Contact newCon : listOfContacts){
    //         Contact oldCon = oldMapBeforeUpdate.get(newCon.Id);

    //         if(newCon.Email != null){
    //             storeTheEmails.add(newCon.Email);
    //         }
    //         if(oldCon != null && oldCon.Email != newCon.Email){
    //             storeTheEmails.add(newCon.Email);
    //         }
    //     }

    //     Set<String> duplicateEmails = new Set<String>();

    //     for(Contact existing : [Select Id, Email, Name From Contact where Email in : storeTheEmails]){
    //         duplicateEmails.add(existing.Email);
    //     }

    //     for(Contact cont  : listOfContacts){
    //         if(duplicateEmails.contains(cont.Email)){
    //             cont.addError('Duplicate email found');
    //         }
    //     }
     

    //single direct map approach
    Map<String,Contact> contactEmailMap = new Map<String,Contact>();

    for(Contact newCon : listOfContacts){
        
        Contact oldCon = oldMap != null ? oldMap.get(newCon.Id) : null;
        
         if(newCon.Email != null || newCon.Email != oldCon.Email){
              String emailKey = newCon.Email.toLowerCase();
              //why checking duplicates in same transactions
              /**
               * Because records in Trigger.new are not yet committed to the database. 
               * If multiple records in the same transaction share the same Email, 
               * a database query will not detect them. Therefore, we must validate intra-batch duplicates before querying existing records
               */

              if(contactEmailMap.containsKey(emailKey)){
                 newCon.addError('Email duplicate is not allowed');
              }else{
                 contactEmailMap.put(emailKey, newCon);
              }
         }
    }

      if(!contactEmailMap.isEmpty()){
          for(Contact existingRecord : [Select Id, Name, Email From Contact Where Email in : contactEmailMap.keySet()]){
             String emailKey = existingRecord.Email.toLowerCase();

             if(contactEmailMap.containsKey(emailKey)){
                 contactEmailMap.get(emailKey).Email.addError('Email cannot be duplicate');
             }
          }
      }

      //map and set approach

      Set<String> emailSet = new Set<String>();

      for(Contact newCon : listOfContacts){
           Contact oldCon = oldMap != null ? oldMap.get(newCon.Id) : null;

           if(oldMap == null || oldCon == null || newCon.Email != oldCon.Email){
                 emailSet.add(newCon.Email.toLowerCase());
        }
      }

      Map<String,Contact> existingMap = new Map<String,Contact>();

      for(Contact exitingCont : [Select Id, Email From Contact Where Email in : emailSet]){
           existingMap.put(exitingCont.Email.toLowerCase(), exitingCont);
      }

      for(Contact con : listOfContacts){
         if(con.Email != null && existingMap.containsKey(con.Email.toLowerCase())){
             con.Email.addError('Email cannot be duplicate');
         }
      }

   }
 
}