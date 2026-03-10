public with sharing class AsyncHandler {
    
    /**
     * 1. **Create a dummy HTTP callout using a Future method and invoke it from a trigger.**
     */

     @future(callout=true)
     public static void sendDummyCallout(Set<Id> leadIds){
          
        List<Lead> allLeads = [Select Id, FirstName, LastName, Email, Company From Lead Where Id in : leadIds];

        Http http = new Http();
        for(Lead lead : allLeads){
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https//example.com/api/leads');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');

            Map<String,Object> requestBody = new Map<String,Object>{
                'firstName' => lead.FirstName,
                'lastName' => lead.LastName,
                'email' => lead.Email,
                'company' => lead.Company
            };
            req.setBody(JSON.serialize(requestBody));

            try{
                HttpResponse res = http.send(req);
            }catch(Exception e){
                System.debug('Callout exception: ' + e.getMessage());
            }
        }
     }
}