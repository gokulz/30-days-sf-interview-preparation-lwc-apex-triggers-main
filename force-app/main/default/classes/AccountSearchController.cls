
public with sharing class AccountSearchController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getSearchAccount(String searchTerm){
        String searchKey = '%' + searchTerm + '%';

        return [Select Id, Name, Phone From Account Where Name Like :searchKey Limit 100];
    }
}