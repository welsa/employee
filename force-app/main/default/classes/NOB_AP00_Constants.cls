/**
 * Created by Hansraj Mohiputlall on 28/10/2020
 */
/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_AP00_Constants
  -- - Author        : HMO
  -- - Description   : classe constant - contain only static values
  -- - #Ticket       : 
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 28-OCT-2020    HMO     1.0     Initial version
  **********************************************************************
*/
public with sharing class NOB_AP00_Constants {
    public NOB_AP00_Constants() {

    }

    public static String PLANNING_STATUS_RESERVE = 'Réservé';

    public static String PLANNING_STATUS_ANNULE = 'Annulé';

    public static String PLANNING_STATUS_CONFIRME = 'Confirmé';

    public static String PLANNING_STATUS_DISPONIBLE = 'Disponible';

    public static String PLANNING_STATUS_ABSENCE = 'Absence';

    public static String PLANNING_RECORDTYPE_PLANNING_NOBILAS = 'NOB_PlanningNobilas';
    
    public static String TASK_SUBJECT_Appel_Planifie = 'Appel Planifié';

    //HMO -- 03-03-2022 RSIW 11528
    public static String TASK_TYPE_DOCUMENTCONTRACUEL = 'DocumentContractuel';

    //SRA --24/01/2022
    public static String TASK_STATUS_COMPLETED = 'Completed';

    public static String TASK_CALL_STATUS_ECHECS_NBR_TENTATIVE = 'Échecs (nombre de tentative atteint)';

    public static String SERVICE_CONTRAT_STATUS_ACTIVE = 'Active';

    public static String ACCOUNT_RANKING_GOLD = 'Gold';

    public static String ACCOUNT_RANKING_SILVER = 'Silver';

    public static String ACCOUNT_RANKING_BRONZE = 'Bronze';

    public static String ACCOUNT_RECORDTYPE_BODYSHOP = 'BODYSHOP';

    public static String ACCOUNT_NETWORKTYPE_HORSRESEAU = 'Hors réseau';

    public static String ACCOUNT_EXPERT_SUBSTITUTION_METHOD_FORCED = 'FORCED';

    public static String ACCOUNT_ASENTITY_ASBE1 = 'ASBE1';



    public static String DETAILRULE_RECORDTYPE_FILTERCONDITION = 'FILTERCONDITION';

    public static String DETAILRULE_RECORDTYPE_PRIMARY_FIELDS_NEEDED = 'PrimaryFieldsNeeded';

    public static String DETAILRULE_RECORDTYPE_QUERYLIMIT = 'NOB_QueryLimit';

    public static String DETAILRULE_RECORDTYPE_CRITERIA = 'CRITERIA';

    public static String DETAILRULE_VALUE_FROM_MASTERsOBJECT = 'Master sObject';

    public static String DETAILRULE_VALUE_FROM_CRITERIAsOBJECT = 'Criteria sObject';


    public static String WORKORDER_VEHICULERETURNDATE_FORMAT_DATE = 'dd/MM/yyyy';

    public static String WORKORDER_VEHICULERETURNDATE_FORMAT_TIME = 'HH:mm';



    public static String SMS_LOG_LABEL_SMS_ETAPE_1 = 'NOB_SMS_Etape_1';

    public static String SMS_LOG_LABEL_SMS_ETAPE_2 = 'NOB_SMS_Etape_2';

    public static String SMS_LOG_LABEL_SMS_ETAPE_3 = 'NOB_SMS_Etape_3';

    public static String SMS_LOG_LABEL_SMS_ETAPE_4 = 'NOB_SMS_Etape_4';

    public static String SMS_LOG_LABEL_SMS_ETAPE_5 = 'NOB_SMS_Etape_5';

    public static String SMS_LOG_LABEL_SMS_ETAPE_5B = 'NOB_SMS_Etape_5b';

    public static String SMS_LOG_LABEL_SMS_ETAPE_6 = 'NOB_SMS_Etape_6';

    public static String DARVA_MESSAGE_LOG_MESSAGE_TYPE_GENESYS = 'Genesys';

    public static String DARVA_MESSAGE_LOG_MESSAGE_SUB_TYPE_CREATETASK = 'CreateTask';

    public static String DARVA_MESSAGE_LOG_MESSAGE_SUB_TYPE_UPDATETASK = 'UpdateTask';

    public static String DARVA_MESSAGE_LOG_MESSAGE_TYPE_ICE = 'ICE';

    public static String DARVA_MESSAGE_LOG_MESSAGE_TYPE_SD32 = 'SD32';
    public static String DARVA_MESSAGE_LOG_MESSAGE_TYPE_SD40 = 'SD40';

    public static Integer TimeZoneHours = UserInfo.getTimezone().getOffset( Datetime.now() ) / 3600000 ;

    public static String PRICEBOOK_OFFRE_SAD = 'SAD';

    //HMO -- 20/07/2021
    public static String PRICEBOOK_OFFRE_DR = 'DR';

    public static String PRICEBOOK_OFFRE_DRPLUS = 'DR "plus"';

    public static String CASE_STATUT_FACTURATION = 'Facturation';
    //SRA -- 24/01/2022
    public static String CASE_STATUS_CLOSED = 'Closed';
    public static String CASE_STATUS_CANCELED = 'Annulée';
    public static String CASE_RAISON_INJOIGNABLE = 'Assuré reste injoignable';
    

    //HMO -- 05/09/2021
    public static String contextDF = 'DF';
    public static String contextEG = 'EG';
    public static String contextRK = 'RK';
    public static String contextCR = 'CR';

    
    //HMO - 13/12/2021
    public static String CONTRAT_PROXIMITE = 'Proximité';
    public static String CONTRAT_PARTINUM = 'Partinium';
    public static String CONTRAT_PRIVILEGE = 'Privilège';

    public static String CONTRAT_PROXIMITER = 'Réseau Proximité';
    public static String CONTRAT_PARTINUMR = 'Réseau Platinium';
    public static String CONTRAT_PRIVILEGER = 'Réseau Premium';

    //HMO - 16-04-2022 RSIW 12130
    public static String COMMUNICATION_NONLUE = 'NonLue';
    public static String COMMUNICATION_LUE = 'Lue';


    public static String EXPEDITION_DRAFT = 'Brouillon';
    public static String EXPEDITION_PUBLISH = 'Publiée';


    public static String ACCOUNT_RELATIONSHIP_TYPE_REPARATEUR_ASSUREUR = 'Réparateur - Assureur';

    // ARA 26/11/2020 :Method check null
    public static String checkNull(String s){
      if(s == null){
          return '';
      }
      return s;
    }
    
    public static Integer getTimeZoneDiff(DateTime dt){
        return UserInfo.getTimezone().getOffset( dt ) / 3600000 ;
    }
    public static String checkNull(Datetime s, String strRequestType){
      if(s == null){
          return '';
      }
      else if (strRequestType== NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_ICE){
          return s.format('yyyy-MM-DD\'T\'HH:mm:ss');
      }
      else if (strRequestType== NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_GENESYS){
          return s.format('dd/MM/yyyy HH:mm:ss');
      }
      return '';
   }
   
    //GBH	RSIW-10600
    public static DateTime addEuropeParisOffset(DateTime dt){
        dt = dt.addHours(-UserInfo.getTimezone().getOffset( dt ) / 3600000 );
        return dt.addhours(Timezone.getTimeZone('Europe/Paris').getOffset(dt)/3600000);
    }
    
    

}