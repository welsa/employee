/*************************************************************************************
Class Name - NOB_AP62_CreateContentversionFromTransaction
Version - 1.0
Created Date - 22 SEPT 2021
Function - Class to Manage Apex Email service for only file PDF 

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Sedera            22/10/2021  RSIW 10882 - Traiter le rattachement de manière asynchrone par rapport à la réception du mail avec le PDF
*************************************************************************************/
global class NOB_AP62_CreateContentVersionMailServ implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail (Messaging.InboundEmail email, Messaging.InboundEnvelope enveloppe){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        String objectMail = (String.IsNotBlank(email.Subject)) ? email.Subject : null;
        System.debug('objectMail==' + objectMail);
        //if (String.isNotBlank(objectMail) && objectMail.contains('|')){
            try{
                if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                    for (Messaging.Inboundemail.BinaryAttachment binaryAttachment : email.binaryAttachments) {
                        //New ContentVersion record
                        ContentVersion pdfContentVersion = new ContentVersion();
                        pdfContentVersion.versionData = binaryAttachment.body;
                        pdfContentVersion.ContentLocation = 'S';
                        pdfContentVersion.SharingOption = 'A';
                        pdfContentVersion.Origin = 'H';
                        pdfContentVersion.SharingPrivacy='N';
                        pdfContentVersion.title = binaryAttachment.fileName;
                        pdfContentVersion.pathOnClient = binaryAttachment.fileName;
                        pdfContentVersion.IsMajorVersion = true;
                        pdfContentVersion.PFR_KeyD365Contentversion__c = objectMail;
                        lstContentVersion.add(pdfContentVersion);
                    }
                    insert lstContentVersion;
                    System.debug('lstContentVersion==' + lstContentVersion);
                }
            }catch(Exception e){
                System.debug('####Objet mail missing #####'+e.getMessage());
                }
        //}
        return result;
    }
}