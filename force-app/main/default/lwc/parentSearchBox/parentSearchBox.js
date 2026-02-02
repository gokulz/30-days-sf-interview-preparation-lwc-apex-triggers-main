import { LightningElement } from 'lwc';

export default class ParentSearchBox extends LightningElement {
    searchKey = '';

    handleKeyUp(event){
        this.searchKey = event.target.value;
    }
}

 //Explanation : The parent component is responsible for capturing the user input and the child component fetching and displaying filtered results.**