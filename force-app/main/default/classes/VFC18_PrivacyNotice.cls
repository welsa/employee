/*
----------------------------------------------------------------------
-- - Name          : VFC18_PrivacyNotice
-- - Author        : ABT
-- - Description   : Controller for VFP18_PrivacyNotice
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 10-JUL-2017  ABT     1.0         Initial version
-- 09-FEB-2018  VSU     1.1         Modified to cater for BE - languages nl_BE and fr_BE
-- 20-MAY-2019  WCH     1.2         C-002781 Spain R4 - [Dans la page ASPISPrivacyNotice, inclure un lien qui permet, 
                                    en cliquant dessus, d'e télécharger/'afficher la privacy notice sur cette même page.]
----------------------------------------------------------------------
**********************************************************************
*/
public with sharing class VFC18_PrivacyNotice
{
    public String agreementBody {get; set;}
    public String thePrivacyNoticePDF {get; set;}//WCH 20/05/2019 C-002781 Spain R4
    public String theUserLanguage {get; set;}//WCH 20/05/2019 C-002781 Spain R4
    // private User currentUser;

    public VFC18_PrivacyNotice()
    {
        CS_Agreement__c currentAgreement = getCurrentUserAgreement();

        if(currentAgreement != null &&
            String.isNotBlank(currentAgreement.Agreement_Document__c))
        {
            retrieveAgreementDocument(currentAgreement.Agreement_Document__c);
        }
    }

    // private void retrieveCurrentUser(CS_Agreement__c currentAgreement)
    // {
    //  String userQuery =  'SELECT Id, ' + currentAgreement.User_Field__c + ' ' +
    //                      'FROM   User ' +
    //                      'WHERE  Id = \'' + UserInfo.getId() + '\'';

    //  User currentUser = Database.query(userQuery);
    // }

    private CS_Agreement__c getCurrentUserAgreement()
    {
        Map<String, CS_Agreement__c> mapCountryCodeAgreement = CS_Agreement__c.getAll();

        String userLanguage = (UserInfo.getLanguage() == 'nl_BE' || UserInfo.getLanguage() == 'fr_BE')?
        UserInfo.getLanguage().right(5) : UserInfo.getLanguage().left(2).toUpperCase();
        
        if(mapCountryCodeAgreement.containsKey(userLanguage))
        {
            system.debug('##userLanguage '+userLanguage);
            system.debug('##agreement: '+mapCountryCodeAgreement.get(userLanguage));
            return mapCountryCodeAgreement.get(userLanguage);
        }
        
        // else take the general agreement
        return getDefaultAgreement(mapCountryCodeAgreement.values());
    }

    private CS_Agreement__c getDefaultAgreement(List<CS_Agreement__c> csAgreementList)
    {
        for(CS_Agreement__c currentAgreement : csAgreementList)
        {
            if(currentAgreement.General__c)
            {
                return currentAgreement;
            }
        }

        return null;
    }

    private void retrieveAgreementDocument(String documentName)
    {
        List<String> docToGet = new List<String>{documentName,documentName+'_PDF'};//WCH 20/05/2019 C-002781 Spain R4
        system.debug('docToGet>>'+docToGet);    
        List<Document> documentList = [ SELECT  Id, Body
                                        FROM    Document
                                        WHERE   DeveloperName IN: docToGet//WCH 20/05/2019 C-002781 Spain R4
                                        order by DeveloperName asc];
        if(!documentList.isEmpty())
        {
            agreementBody = documentList[0].Body.toString();

            //WCH 20/05/2019 C-002781 Spain R4
            theUserLanguage = (UserInfo.getLanguage().length()>2)?UserInfo.getLanguage().right(5) : UserInfo.getLanguage().left(2).toUpperCase();
            String docIds='';
            if(documentList.size()>1){
                docIds=documentList[1].Id;
            }
            thePrivacyNoticePDF= '';
            thePrivacyNoticePDF = URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' )+'/servlet/servlet.ImageServer?id='+docIds+'&oid='+userinfo.getorganizationid();
            system.debug('thePrivacyNoticePDF>>'+thePrivacyNoticePDF);
        }
        else
        {
            // The document was not found
            // Should I set a log ?
        }
    }
}