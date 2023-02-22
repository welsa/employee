/*************************************************************************************
Class Name - NOB_AP57_TauxNegOverlappingDates
Version - 1.0
Created Date - 23/12/2020
Function - Class to check that there are no overlapping dates among taux Negocies

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* USA           23/12/2020  Initial version
* USA           28/12/2020  RSIW-7115
*************************************************************************************/
public with sharing class NOB_AP57_TauxNegOverlappingDates {
    public static void checkOverlappingDates(map<Id,NOB_TauxNeg__c> mapTauxNeg, Set<Id> setIdRelCompte){
        map<Id,List<NOB_TauxNeg__c>> mapRelCompteTaux = new map<Id,List<NOB_TauxNeg__c>>();
        for (NOB_TauxNeg__c tauxNeg : [SELECT Id, NOB_RelationCompte__c, NOB_StartDate__c, NOB_EndDate__c
                                       FROM NOB_TauxNeg__c
                                       WHERE NOB_RelationCompte__c IN :setIdRelCompte
                                       AND (Id NOT IN :mapTauxNeg.keySet())
                                       //AND NOB_Active__c = TRUE
                                        ]){
            if (!mapRelCompteTaux.containsKey(tauxNeg.NOB_RelationCompte__c)){
                mapRelCompteTaux.put(tauxNeg.NOB_RelationCompte__c,new list<NOB_TauxNeg__c>{tauxNeg});
            }
            else {
                mapRelCompteTaux.get(tauxNeg.NOB_RelationCompte__c).add(tauxNeg);
            }
        }

        system.debug('mapTauxNeg:' + mapTauxNeg);
        System.debug('mapRelCompteTaux:' + mapRelCompteTaux);
        if (mapRelCompteTaux.size()>0) {
            for (NOB_TauxNeg__c tauxToChk : mapTauxNeg.values()) {
                System.debug('tauxToChk:' + tauxToChk);
                for (NOB_TauxNeg__c tauxExists : mapRelCompteTaux.get(tauxToChk.NOB_RelationCompte__c)) {
                    System.debug('tauxExists:' + tauxExists);
                    if (tauxExists.NOB_EndDate__c != null) { //end date filled in current taux neg
                        //check 1&2 : (i) end date filled (ii) start date and end date of new/updated taux neg between existing taux neg
                        //check 3 : (i) end date filled (ii) start date of new/updated taux neg <= start date existing taux neg (iii) end date of new/updated taux neg >= existing taux neg
                        //check 4 : (i) end date of new/updated taux neg is not filled (ii) start date new/updated taux neg <= existing taux neg
                        if (
                                ((tauxToChk.NOB_EndDate__c != null) && (tauxToChk.NOB_StartDate__c >= tauxExists.NOB_StartDate__c) && (tauxToChk.NOB_StartDate__c <= tauxExists.NOB_EndDate__c)) ||
                                ((tauxToChk.NOB_EndDate__c != null) && (tauxToChk.NOB_EndDate__c >= tauxExists.NOB_StartDate__c) && (tauxToChk.NOB_EndDate__c <= tauxExists.NOB_EndDate__c)) ||
                                ((tauxToChk.NOB_EndDate__c != null) && (tauxToChk.NOB_StartDate__c <= tauxExists.NOB_StartDate__c) && (tauxToChk.NOB_EndDate__c >= tauxExists.NOB_EndDate__c)) ||
                                ((tauxToChk.NOB_EndDate__c == null) &&(tauxToChk.NOB_StartDate__c <= tauxExists.NOB_EndDate__c))
                            ) {
                            tauxToChk.addError(Label.NOB_AP57_DateCovered);
                        }
                    }
                    else { //end date empty in current taux neg (unlimited)
                        //check 1 : (i) end date filled (ii) start date and end date of new/updated taux neg greater than start date of existing taux neg
                        //check 2 : end date of new/updated taux neg is not filled - cannot create taux neg with no enddate filled if existing taux neg is unlimited
                       System.debug('Entered here');
                        
                        if (
                            ((tauxToChk.NOB_EndDate__c != null) && ((tauxToChk.NOB_StartDate__c >= tauxExists.NOB_StartDate__c) || (tauxToChk.NOB_EndDate__c >= tauxExists.NOB_StartDate__c))) ||
                            (tauxToChk.NOB_EndDate__c == null)
                            ) {
                            tauxToChk.addError(Label.NOB_AP57_DateCovered);
                        }
                    }
                }
            }
        }
    }
}