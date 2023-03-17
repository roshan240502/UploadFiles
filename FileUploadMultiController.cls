public class FileUploadMultiController {
    
    @AuraEnabled
    public static String uploadFiles(String recordId, String filedata, String selectedOption, String setdata) {
        try {
            if(String.isNotBlank(FileData)) {
                List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(filedata, List<FileDataWP>.class);
                System.debug(files);
                System.debug(selectedOption);
                System.debug(setdata);
                list<Travelportal__c> updateRecord = new list<Travelportal__c>();
                if(selectedOption == 'Option 1'){
                    Travelportal__c newRec = new Travelportal__c();
                newRec.id = recordId;
                newRec.Option_1__c = true;
                updateRecord.add(newRec);
                }
                

                if(selectedOption == 'Roshan Resume - 1'){
                    Travelportal__c newRec = new Travelportal__c();
                newRec.id = recordId;
                newRec.Option_2__c = true;
                updateRecord.add(newRec);
                }

                if(selectedOption == 'Option 3'){
                    Travelportal__c newRec = new Travelportal__c();
                newRec.id = recordId;
                newRec.Option_3__c = true;
                updateRecord.add(newRec);
                }
 
                List<ContentVersion> cvList = new List<ContentVersion>();
                for(FileDataWP file : files) {
                    ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S'; // S = Salesforce, E = External Files
                    conVer.VersionData = EncodingUtil.base64Decode(file.fileContent);
                    conVer.Title = file.fileName;
                    conVer.PathOnClient = file.fileName;
                    cvList.add(conVer);
                }
                Insert cvList;
                
                if(updateRecord.size() > 0){
                    update updateRecord;
                }

                List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
                for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cvList]) {
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    conDocLink.LinkedEntityId = recordId;
                    conDocLink.ContentDocumentId = cv.ContentDocumentId;
                    conDocLink.Visibility = 'AllUsers';
                    conDocLink.shareType = 'V'; // V = Viewer, C = Collaborator, I = Inferred
                    cdList.add(conDocLink);
                }
                Insert cdList;        
            } else {
                return 'record Id is Blank';
            }
            return 'success';
        } catch (Exception ex) {
            System.debug(ex.getMessage() + ' -> ' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
    }
 
    public class FileDataWP {
        public String fileName;
        public String fileContent;
    }
    @AuraEnabled(cacheable=true)
public static void updateRecord(Id recordId, String filedata) {
    System.debug('-->RecordId'+recordId);
    list<Travelportal__c> updatedTravel = [SELECT Id, Option_2__c, Option_3__c, Option_1__c FROM Travelportal__c WHERE Id = :recordId];
    System.debug('-->updtaetravellist'+updatedTravel);
    List<ContentDocumentLink> documentLinks = [SELECT LinkedEntityId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
    System.debug('-->documentlinkslist'+documentLinks);
    list<Travelportal__c> updateRecord = new list<Travelportal__c>();

    for (ContentDocumentLink documentLink : documentLinks) {
            if (documentLink.ContentDocument.Title == 'Option 1') {
                Travelportal__c newRec = new Travelportal__c();
                newRec.id = recordId;
                newRec.Option_1__c = true;
                updateRecord.add(newRec);
               
        } else if (documentLink.ContentDocument.Title == 'Roshan Resume - 1') {
            Travelportal__c newRec = new Travelportal__c();
            newRec.id = recordId;
            newRec.Option_2__c = true;
            updateRecord.add(newRec);
        } else if (documentLink.ContentDocument.Title == 'Option 3') {
            Travelportal__c newRec = new Travelportal__c();
                newRec.id = recordId;
                newRec.Option_3__c = true;
                updateRecord.add(newRec);
        }
    }
    System.debug('REcord list==> '+ updateRecord);
    if(updateRecord.size() > 0){
        update updateRecord;
    }

}
}
