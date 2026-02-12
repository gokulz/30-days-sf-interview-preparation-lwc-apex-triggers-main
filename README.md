# Lwc Scenarios and Practice

### Parent to child communication 
1. **Parent holds Search box and child holds the filter results**
    
    - [parentSearchBox](force-app/main/default/lwc/parentSearchBox)

## Apex Triggers Scenarios and Practice?

  ### Create Opportunity on Account Industry = Agriculture
1. **Write a trigger, to create new Opportunity whenever an account is created/updated for Industry – Agriculture.**
      - [Trigger](force-app/main/default/triggers/AccountTriggerToCreateOpportunity.trigger)
      - [HandlerClass](force-app/main/default/classes/AccountTriggerHandlerForOppotunity.cls)

  ### Roll-up-summary Trigger Concept
1. **Write a trigger on opportunity to count the number of child opportunites an account has and put that on account record**
2. **Write a trigger on contact to count the number of child contacts an account has and put that on account record**
3. **Create a trigger whenever new contact is added it will check contact exist checkbox in Account object and whenever no contact is there for account then checkbox value false.**
4. **create a trigger whenever new opportunity is added it will check opportunity exist checkbox in account object whenever no opportunity is there for accoount the checkbox vlaue false**.
5. **Create a trigger on opportunity , when the user inserts an opportunity trigger will check that the closing date of opportunity is greater than one month and amount is greater than 50000.**
6. **On updating an Account record, the total Amount of all Opportunities related to that Account should be calculated and stored in the Total Opportunity Amount field on the Account.**
7. **write a trigger to update the contact's Saluatation Field According to Gender**.
8. **Write a trigger to update the user phone number as same as the contact phone number once the contact phone number gets updated.**
9. **Trigger to count number of opportunitylineitems associated with an opportunity and display the count on account's custom field.**
10. **write an apex trigger that create task or update task based on stage changes(opportunity record stagename updated if the task name present update stage name in the tasks description else create a new task).**
11. **Trigger to count OpportunityLineItem whose listPrice is greater than $50,000 associated with opportunity and display that count on Account custom field.**
12. **Trigger to update Account's description by opportunityLineItem's description which is associated with opportunity.**
13. **Write a Trigger to update Account Rating based on Total Amount of Related Opportunities**.



### Asynchronous Apex 
**--> async apex is a way of running apex code in the background in the separate thread or separate transactions.**
### Future Method 
**--> future method runs in separate transaction after the current execution completes. it runs in a separate thread. mostly use for handling mixed dml errors. must be static and void. cannot accept sobjects directly.**
### Example
1. **Future Method example - create a follow up task everytime a new lead gets created and associate that task with lead.**
### Batch Apex
1. **Update all Contacts Where MailingCityCity = Hydrabad --> set the Region__c field to "South India"**.


## Configure Your Salesforce DX Project


## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
