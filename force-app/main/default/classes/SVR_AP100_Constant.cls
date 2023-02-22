/**
 * @description       : Cette classe contiendra toutes les constantes de chaque objet
 * @author            : JPI
 * @group             : AP
 * @last modified on  : 21/04/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   30/11/2020   JPI      Initial Version
**/
public with sharing class SVR_AP100_Constant {

    /***********************************************************************
    * Audit Reseau constant 
    ************************************************************************/ 
    public static String auditStatutNonAcquis = 'Non acquis';

    // Recordtype
    public static String recordTypeAuditReseauQualite = 'SVR_ReseauQualite';
    public static String recordTypeAuditReseauCoutMoyen = 'SVR_ReseauCoutMoyen';
    public static String recordTypeAuditReseauQualiteChild = 'SVR_ReseauQualiteChild';
    public static String recordTypeAuditReseauCoutMoyenChild = 'SVR_ReseauCoutMoyenChild';

    /***********************************************************************
    * Audit Operationnel constant 
    ************************************************************************/ 

    // Recordtype
    public static String recordTypeAuditOPBOFactuAdmin = 'SVR_OPBOFactu_Admin';
    public static String recordTypeAuditOPBOFactu = 'SVR_OPBOFactu';
    public static String recordTypeAuditOPGrosChoc = 'SVR_OPBOGrosChocs';
    public static String recordTypeAuditOPAppels = 'SVR_OPFOAppels';
    public static String recordTypeAuditOPQualite = 'SVR_OPQualite';

    /***********************************************************************
    * Performance constant 
    ************************************************************************/ 

    // Recordtype
    public static String recordTypePerfReseauCM = 'SVR_RSCM';
   

    /***********************************************************************
    * Plan Action constant
    ************************************************************************/ 

    // Recordtype - Reseau
    public static String recordTypePAReseauCM = 'SVR_PACM';
    public static String recordTypePAReseauQualite = 'SVR_PAQualite';

    // Recordtype - Operationnel
    public static String recordTypePAOperationnelBOFactu = 'OPBOFactu';
    public static String recordTypePAOperationnelBOAdmin = 'SVR_Plan_action_Operationnel_BO_Admin';
    public static String recordTypePAOperationnelBOGrosChoc = 'SVR_Plan_action_operationnel_Gros_chocs';
    public static String recordTypePAOperationnelBOAppel = 'SVR_PlanActionOperationel';
    public static String recordTypePAOperationnelBOQualite = 'SVR_Plan_action_Operationnel_Qualite';

    // Profile PRE Animation réseau
    public static id getProfilePrePRE_AnimationId(){
        return ([Select Id From Profile
                Where name = 'PRE_Animation réseau'].Id);
    }
    
     public static id getProfileCCP_BodyshopId(){
       return ([Select Id From Profile
                 Where name = 'CCP Bodyshop'].Id);
    }
	
    
    public static id getProfilePRE_FrontOfficeId(){
        return ([Select Id From Profile
                Where name = 'PRE_Front Office'].Id);
    }
    public static id getPortalUserId(){ //GarageDUNCustomerUser
        //return([SELECT Id,Name FROM UserRole where Name = 'nazanaCustomerUser' LIMIT 1].Id);
        //return([SELECT Id from UserRole WHERE PortalType = 'None' LIMIT 1].Id);
        // return([SELECT Id from UserRole WHERE DeveloperName  ='Manager_Global_Reseau' LIMIT 1].Id);

        return([Select PortalType, PortalAccountId From UserRole where PortalType ='CustomerPortal' limit 1].Id);
    }
    //Recordtype Dossier Preficontrol.
    public static String recordTypeDPCM = 'CM';
    public static String recordTypeDPTutelle = 'Tutelle';
    //Recordtype Audit Preficontrol.
    public static String recordTypeAPCM = 'Audit_Preficontrol_CM';
    public static String recordTypeAPTutelle = 'Audit_Preficontrol_Tutelle';

}