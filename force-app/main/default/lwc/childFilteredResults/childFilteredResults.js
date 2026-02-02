import { LightningElement, api, wire} from 'lwc';
import getSearchAccount from '@salesforce/apex/AccountSearchController.getSearchAccount';

export default class ChildFilteredResults extends LightningElement {

   @api searchKey;
   accounts;

   @wire(getSearchAccount, {searchTerm : '$searchKey'})
   wiredAccount({data, error}){
        if(data){
            this.accounts = data;
        }else if(error){
            console.error(error);
        }
   }


}