/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_AP62_CreateContentVersionMailServ_TEST
  -- - Author        : ABT
  -- - Description   : Test class for NOB_AP62_CreateContentVersionMailServ
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 01-OCT-2021  SRA    1.0     Initial Version
  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class NOB_AP62_CreateCVMailServ_TEST {
    static User adminUser; 
    static PFR_Transaction__c trans;
    static PFR_FinancialDocument__c docFin;
    static ContentVersion doncFinConv = new ContentVersion();
    static Account acc;
    static List<ContentVersion> lstCV = new List<ContentVersion> ();
    static EmailReceptionManagement__mdt idLegalEntity = new EmailReceptionManagement__mdt ();
    static Profile profil1;
    static Profile profilBO;
    static User userBodyShop;
    static Contact cont;
    static user userBackOffice;
    static{
        adminUser = TestFactory.createUser('adminUser');
        insert adminUser;
        System.runAs(adminUser){
            //Create contentversion with contentDocumentLink
            doncFinConv = TestFactory.createContentVersion('FactureReparation', 'pdf');
            insert doncFinConv;
            doncFinConv.PFR_KeyD365Contentversion__c = '3301|4FTC0001235';
            update doncFinConv;
        }
    }

    
    @isTest static void getEmailSercive(){
        System.runAs(adminUser){
            Test.StartTest();
            NOB_AP62_CreateContentVersionMailServ emailProcess = new NOB_AP62_CreateContentVersionMailServ();
            // Create a new email, envelope object 
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

            email.subject = '3301|4FTC0001235';
            email.fromname = 'Test Test';
            envelope.fromAddress = 'Test@email.com';
            email.plainTextBody = 'Test';
            // Create Attachment Email
            Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
		    binaryAttachment.Filename = 'test.pdf';
            binaryAttachment.body = blob.valueOf('my attachment text');
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
            emailProcess.handleInboundEmail(email, envelope);
            Messaging.InboundEmailResult result = emailProcess.handleInboundEmail(email, envelope);
            Test.StopTest();        
            System.assertEquals( result.success  ,true);
            
        }
    }
}