/*
----------------------------------------------------------------------
-- - Name          : VFC30_ConditionsGenerales_TEST
-- - Author        : 
-- - Description   : Test class for VFC30_ConditionsGenerales
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 13/05/2022   KEM    	  1.0	    Initial version
----------------------------------------------------------------------
**********************************************************************
*/

@isTest 
private class VFC30_ConditionsGenerales_TEST {
    static User adminUser;
	static List<User> userList;
	static List<Document> documentList;
	static List<ConditionGeneraleDeVente__mdt> ConditionGeneraleDeVenteList;

    static{
        adminuser = TestFactory.createUser('adminUser');
        insert adminUser;

        System.runAs(adminUser){

            userList = new List<User>{
                TestFactory.createUserBodyshop('First_BodyShop')
            };

            userList[0].CountryCode 		= 'FR';
			userList[0].LanguageLocaleKey 	= 'fr';

            insert userList;

            system.debug('NPE retrieve user id '+ UserInfo.getUserId());

			documentList = new List<Document>
			{
				new Document(Name			= 'CGeneraleFrenchCol1',
							DeveloperName	= 'CGeneraleFrenchCol1',
							Description		= 'Jaime le Français',
							Body			= Blob.valueOf('jaime le Français'),
							ContentType		= 'text/plain; charset=UTF-8',
							AuthorId		= userList[0].id,
							FolderId        = userList[0].id),
                

				new Document(Name			= 'CGeneraleFrenchCol2',
							DeveloperName	= 'CGeneraleFrenchCol2',
							Description		= 'Jaime le Français',
							Body			= Blob.valueOf('jaime le Français'),
							ContentType		= 'text/plain; charset=UTF-8',
							AuthorId		= userList[0].id,
							FolderId        = userList[0].id),
                            
				new Document(Name			= 'CGeneraleFrenchCol3',
							DeveloperName	= 'CGeneraleFrenchCol3',
							Description		= 'Hola clase de prueba',
							Body			= Blob.valueOf('Hola clase de prueba'),
							ContentType		= 'text/plain; charset=UTF-8',
							AuthorId		= userList[0].id,
							FolderId		= userList[0].id),

				new Document(Name			= 'CGFrench_PDF',
							DeveloperName	= 'CGFrench_PDF',
							Description		= 'Ciao la classe di prova',
							Body			= Blob.valueOf('Ciao la classe di prova'),
							ContentType		= 'text/plain; charset=UTF-8',
							AuthorId		= userList[0].id,
							FolderId		= userList[0].id)				
			};
            insert documentList;
        } 

    }
    @isTest static void frenchUser_TEST()
    {
        System.runAs(userList[0])
        {
            Test.setCurrentPage(Page.VFP30_ConditionsGenerales);
            Test.startTest();
            VFC30_ConditionsGenerales controller = new VFC30_ConditionsGenerales();
            Test.stopTest();
        }
    }
}