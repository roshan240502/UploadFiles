import {LightningElement,api,track,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFiles from '@salesforce/apex/FileUploadMultiController.uploadFiles';
import updateRecord from '@salesforce/apex/FileUploadMultiController.updateRecord';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation'
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import optionslist__c from '@salesforce/schema/Travelportal__c.optionslist__c';


 
export default class FileUploadMultiLWC extends NavigationMixin(LightningElement) {

    @api recordId;
    
    
    @track filesData = [];
    showSpinner = false;
    selectedOption = '';
    options = [
        { label: 'Option 1', value: 'Option 1' },
        { label: 'Option 2', value: 'Roshan Resume - 1' },
        { label: 'Option 3', value: 'Option 3' },
      ];

//     picklistValue;
//   picklistOptions = [];

//   @wire(getPicklistValues, { recordTypeId: 'recordId', fieldApiName: optionslist__c })
//   picklistValues({ error, data }) {
//     if (data) {
//       this.picklistOptions = data.values.map((option) => ({
//         label:  optionslist__c.label,
//         value:  optionslist__c.value,
//       }));
//     } else if (error) {
//         console.log("Failed to picklist a value");
//     }
//   }

  
    handleOptionChange(event) {
        this.selectedOption = event.target.value;
      }
    // handlePicklistChange(event) {
    //     this.picklistValue = event.detail.value;
    //   }
 
    handleFileUploaded(event) {
        if (event.target.files.length > 0) {
            for(var i=0; i< event.target.files.length; i++){
               
                let file = event.target.files[i];
                let reader = new FileReader();
                    reader.onload = e => {
                        var fileContents = reader.result.split(',')[1]
                        this.filesData.push({'fileName':file.name, 'fileContent':fileContents});
                    };
                    reader.readAsDataURL(file);
                
            }
        }
    }
      
 
    uploadFiles() {
        if(this.filesData == [] || this.filesData.length == 0) {
            this.showToast('Error', 'error', 'Please select files first'); return;
        }
        console.log('Selected Option==>',this.selectedOption);
       
        let setdata = JSON.parse(JSON.stringify(this.filesData[0].fileName)).split('.');
        console.log('file data==>',setdata[0]);
        if(this.selectedOption == setdata[0]){setdata
        this.showSpinner = true;
        uploadFiles({
            recordId : this.recordId,
            filedata : JSON.stringify(this.filesData), 
            selectedOption :this.selectedOption,
            setdata:setdata[0] 
            
        })
        .then(result => {
            console.log(result);
            
            if(result && result == 'success') {
                location.reload();
                this.filesData = [];
                this.showToast('Success', 'success', 'Files Uploaded successfully.');
            } 
            else {
                this.showToast('Error', 'error', result);
            }
        }).catch(error => {
            if(error && error.body && error.body.message) {
                this.showToast('Error', 'error', error.body.message);
            }
        }).finally(() => this.showSpinner = false );
        }else{
            this.showToast('Error', 'error', 'Files does not match');
        }
        }
 
    removeReceiptImage(event) {
        var index = event.currentTarget.dataset.id;
        this.filesData.splice(index, 1);
    }
   
 
    showToast(title, variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                variant: variant,
                message: message,
            })
        );
    }

    

}
