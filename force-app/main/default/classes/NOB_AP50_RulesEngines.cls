/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_AP50_RulesEngines
  -- - Author        : DUN
  -- - Description   : rules engines class
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 24-AUG-2020    DUN     1.0     Initial version
  -- 03-NOV-2020    ASE     1.0     RSIW-2868: Alignement des notes de critère du rule engine
  -- 08-JUN-2021    DUN     1.3     RSIW-8602 : Priorisation I Dé-priorisation de réparateur
  **********************************************************************
*/
public without sharing class NOB_AP50_RulesEngines {
    public static List<Account> getReparateur(Id caseId, map<String,list<String>> mapParameters){
        System.debug('## Start NOB_AP50_RulesEngines.getReparateur');
        System.debug('££ Start NOB_AP50_RulesEngines.getReparateur');
        map <String,list<Account>> mapUnsortedReparateur = new map <String,list<Account>>();
        List <Account> listSortedReparateur = new List <Account>();
        system.debug('## mapParameters ' + mapParameters);
        list<MasterRules__c> masterRules = [SELECT Id, Entity__c, Process__c, RuleStatus__c, RecordType.DeveloperName,
                                                    sObject__c, FilterLogic__c,version__c,Name,
                                                    (SELECT Id, sObject__c, FieldsAPI__c, Operator__c, Process__c, Value__c, Number__c,
                                                            OutputParam__c,recordtypeId, recordtype.DeveloperName, ValueFrom__c, NOB_RangeValue__c
                                                    FROM DetailRules__r
                                                    ORDER BY Number__c ASC),
                                                    (SELECT Id, NOB_Field__c, NOB_Function__c, NOB_MasterRule__c, NOB_Object__c, NOB_ValueFrom__c,
                                                    NOB_ValueType__c, NOB_Weightage__c, /* ASE: 03/11/20 : RSIW-2868 */ NOB_Limit__c
                                                    FROM Objectifs__r)
                                            FROM MasterRules__c
                                            WHERE Process__c    = 'NOB_Recherche Réparateur'
                                            AND RuleStatus__c   =: system.Label.RULESTATUSACTIVELABEL];
        if(masterRules.size() > 0 && masterRules[0].DetailRules__r != null){
           
            mapUnsortedReparateur = NOB_AP50_SelectionReparateur.getReparateur(caseId, masterRules[0], masterRules[0].DetailRules__r, mapParameters);
        }
        system.debug('## mapUnsortedReparateur ' + mapUnsortedReparateur);
        
        if(masterRules.size() > 0 && masterRules[0].Objectifs__r != null && mapUnsortedReparateur != null){
            //RSIW-8602
            if(mapUnsortedReparateur.containsKey('Priority') && mapUnsortedReparateur.get('Priority').size() > 0){
                if(mapUnsortedReparateur.get('Priority').size() == 1){
                    listSortedReparateur.addAll(mapUnsortedReparateur.get('Priority'));
                }
                else{
                    listSortedReparateur.addAll(NOB_AP50_ObjectifsReparateur.getSortedReparateur(mapUnsortedReparateur.get('Priority'), masterRules[0].Objectifs__r));
                }
            }
            if(mapUnsortedReparateur.containsKey('Standard') && mapUnsortedReparateur.get('Standard').size() > 0){
                if(mapUnsortedReparateur.get('Standard').size() == 1){
                    listSortedReparateur.addAll(mapUnsortedReparateur.get('Standard'));
                }
                else{
                    listSortedReparateur.addAll(NOB_AP50_ObjectifsReparateur.getSortedReparateur(mapUnsortedReparateur.get('Standard'), masterRules[0].Objectifs__r));
                }
            }
            if(mapUnsortedReparateur.containsKey('NotPriority') && mapUnsortedReparateur.get('NotPriority').size() > 0){
                if(mapUnsortedReparateur.get('NotPriority').size() == 1){
                    listSortedReparateur.addAll(mapUnsortedReparateur.get('NotPriority'));
                }
                else{
                    listSortedReparateur.addAll(NOB_AP50_ObjectifsReparateur.getSortedReparateur(mapUnsortedReparateur.get('NotPriority'), masterRules[0].Objectifs__r));
                }
            }
            /*if(mapUnsortedReparateur.containsKey('Priority')){
                if(mapUnsortedReparateur.get('Priority').size() == 1){
                    listSortedReparateur.addAll(mapUnsortedReparateur.get('Priority'));
                }
                else{
                    listSortedReparateur.addAll(NOB_AP50_ObjectifsReparateur.getSortedReparateur(mapUnsortedReparateur.get('Priority'), masterRules[0].Objectifs__r));
                }
            }
            if(mapUnsortedReparateur.containsKey('NotPriority')){
                listSortedReparateur.addAll(NOB_AP50_ObjectifsReparateur.getSortedReparateur(mapUnsortedReparateur.get('NotPriority'), masterRules[0].Objectifs__r));
            }*/
            }
        System.debug('## listSortedReparateur ' + listSortedReparateur);
        System.debug('## END NOB_AP50_RulesEngines.getReparateur');
        return listSortedReparateur;
    }
}