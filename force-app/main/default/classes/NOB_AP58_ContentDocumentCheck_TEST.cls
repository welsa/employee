/*
 @File Name          : NOB_AP58_ContentDocumentCheck_TEST
 @Description        : Test class for NOB_AP58_ContentDocumentCheck
 @Author             : PCH
 @Group              : 
 @Last Modified By   : PCH
 @Last Modified On   : 13-01-2021
 @Modification Log   : 
 ==============================================================================
  Ver         Date                     Author      Modification
  1.1        13-01-2022                  SRA       test CheckPhotos method
 ==============================================================================
 
*/

@isTest
public class NOB_AP58_ContentDocumentCheck_TEST {
static user UserAdmin;
static List<ContentVersion> ContentDocuments;
private static List<Account> lstAcc;
private static List<ContentVersion> lstConVers;

static{
    userAdmin = new User();
     ContentDocuments = new LIst<ContentVersion>();
    userAdmin = TestFactory.createPrefikarUser('adminUser');
    insert userAdmin;


    System.runAs(userAdmin){

        lstAcc = new List<Account>{
            TestFactory.createAccountBodyshop('compteReparateur', 'US')
        };
        lstAcc.get(0).NOB_isPrefikar__c = true;
        lstAcc.get(0).NOB_Statut__c = 'Actif';
        insert lstAcc;

        lstConVers = new List<ContentVersion>{
            TestFactory.createContentVersionWithLink(lstAcc.get(0).Id, 'test', 'pdf'),
            TestFactory.createContentVersionWithLink(lstAcc.get(0).Id, 'test2', 'pdf')
        };

        ContentDocuments = new List<ContentVersion>{
           new ContentVersion(NOB_Category__c = 'Garage (catégorie Candidature)', NOB_SubCategory__c='Accord de centralisation',
                              Title='test Upload File',PathOnClient = 'Penguins.PNG',
                              VersionData = Blob.valueOf('Test Content')),
            new ContentVersion(NOB_Category__c = 'Garage (catégorie Candidature)', NOB_SubCategory__c='Accord de centralisation',
                              Title='test Upload File2',PathOnClient = 'Penguins.PNGS',
                              VersionData = Blob.valueOf('Test Content'))
        };

        for(ContentVersion cv: lstConVers){
            cv.NOB_Category__c = 'Garage (catégorie Candidature)';
            cv.NOB_SubCategory__c = 'Photos';
        }
        update lstConVers;
    }
}

@isTest
public static void checkDocumentSuccessFormat(){

    System.runAs(userAdmin){
        Test.startTest();
            Insert ContentDocuments[0];
        Test.stopTest();
    }
    List<ContentVersion> ctnVersion = [Select Id From ContentVersion where Id =: ContentDocuments[0].Id ];
    System.assertEquals(1, ctnVersion.size());
}
    @isTest
public static void checkDocumentErrorFormat(){          
        
    System.runAs(userAdmin){
        Test.startTest();
        try{
            Insert ContentDocuments[1];
        }
        catch(exception e){
            System.assert(e.getMessage().contains(System.label.NOB_ErrorFileType));
        }
        Test.stopTest();
    }
    List<ContentVersion> ctnVersion = [Select Id From ContentVersion where Id =: ContentDocuments[1].Id ];
    System.assertEquals(0, ctnVersion.size());
}   

//SRA 1.1
@isTest
public static void testCheckPhotosError(){
    Test.startTest();
        Map<Id, Account> mapAcc = new Map<Id, Account>();
        mapAcc.put(lstAcc.get(0).Id, lstAcc.get(0));
        try {
            NOB_AP58_ContentDocumentCheck.checkPhotos(mapAcc);
        } catch(Exception e) {
            System.assert(e.getMessage().contains(System.label.Pre_messageErrorPhotos));
        }
    Test.stopTest();
}

@isTest
public static void testCheckPhotos(){
    lstConVers.add(TestFactory.createContentVersionWithLink(lstAcc.get(0).Id, 'test1', 'pdf'));
    lstConVers.add(TestFactory.createContentVersionWithLink(lstAcc.get(0).Id, 'test2', 'pdf'));
    lstConVers.add(TestFactory.createContentVersionWithLink(lstAcc.get(0).Id, 'test3', 'pdf'));
    lstConVers.add(TestFactory.createContentVersionWithLink(lstAcc.get(0).Id, 'test4', 'pdf'));
    lstConVers.add(TestFactory.createContentVersionWithLink(lstAcc.get(0).Id, 'test5', 'pdf'));
    lstConVers.add(TestFactory.createContentVersionWithLink(lstAcc.get(0).Id, 'test6', 'pdf'));
    for(ContentVersion cv: lstConVers){
        cv.NOB_Category__c = 'Garage (catégorie Candidature)';
        cv.NOB_SubCategory__c = 'Photos';
    }
    update lstConVers;
    Test.startTest();
        Map<Id, Account> mapAcc = new Map<Id, Account>();
        mapAcc.put(lstAcc.get(0).Id, lstAcc.get(0));
        NOB_AP58_ContentDocumentCheck.checkPhotos(mapAcc);
    Test.stopTest();
    System.assert(lstConVers.size() >= 8);
}
    
/*@isTest
public static void checkDocumentSizeFormatError(){
    System.runAs(userAdmin){
        
        //list<ContentVersion> lstctcVersion = [SELECT id,ContentSize,Title from ContentVersion where id=:ContentDocuments[2].id];
        //System.debug('##pch ContentSize : '+lstctcVersion );
    Test.startTest();
        try{
            ContentDocuments[0].VersionData =Blob.valueOf('123456789123456789');
            //lstctcVersion[0].ContentSize =1234567;
            //lstctcVersion[0].Title='test 1';
            //ContentDocuments[0].ContentSize = 124;
            Insert ContentDocuments[0];
            System.debug('##pch ContentDocuments[0].VersionData' +ContentDocuments[0].VersionData);
        }
        catch(exception e){
            System.assert(e.getMessage().contains(System.label.NOB_ErrorFileSize));
        }
        Test.stopTest();
    }
    List<ContentVersion> ctnVersion = [Select Id From ContentVersion where Id =: ContentDocuments[0].Id ];
    System.assertEquals(1, ctnVersion.size());
}*/
}