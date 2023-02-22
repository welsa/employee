/*************************************************************************************
Class Name - NOB_Batch_UpdateEngagementServiceContrat
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 12-07-2021
Function - Class to update engagement fields on service contracts
#Ticket  - RSIW : 9655

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           12-07-2021   Initial version
*************************************************************************************/

public class NOB_Batch_UpdateEngagementServiceContrat implements Schedulable, Database.Batchable<SObject> {
        //Hansraj -- 21-09-2021 -- test classes
	public static Date runDate;
    public final integer NUMDAYS_PERQUARTER = 91;
    public final Map<String,Date> MAP_ENDQUARTER = new Map<String, Date>{
        'quarter1' => Date.newInstance(System.today().year(), 3, 31),
        'quarter2' => Date.newInstance(System.today().year(), 6, 30),
        'quarter3' => Date.newInstance(System.today().year(), 9, 30),
        'quarter4' => Date.newInstance(System.today().year(), 12, 31)
    };
    private Boolean runAllSC = false;
    private Boolean majHistorique = false;
    public static String scheduleDate = '0 0 23 ? * MON-FRI';

    public NOB_Batch_UpdateEngagementServiceContrat(Boolean runAllServiceContrats, Boolean parametreMajHistorique) {
        this.runAllSC = runAllServiceContrats;
        this.majHistorique = parametreMajHistorique;
    }
    
    //HMO -- 16-09-2021
    public static String scheduleClassInDB(){
        NOB_Batch_UpdateEngagementServiceContrat bat_Engagement = new NOB_Batch_UpdateEngagementServiceContrat(false, false);
        return System.schedule('9655 batch engagement', scheduleDate, bat_Engagement);
    }

    public void execute (SchedulableContext sc){
        NOB_Batch_UpdateEngagementServiceContrat batchEngagement = new NOB_Batch_UpdateEngagementServiceContrat(runAllSC, majHistorique);
        ID batchprocessid = Database.executeBatch(batchEngagement);   
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String recordTypeId = Schema.SObjectType.ServiceContract.getRecordTypeInfosByDeveloperName()
        .get('NOB_BodyshopContract').getRecordTypeId();
        String query = '';
        query = 'SELECT Id, NOB_Engagement_annuel_si_Bronze__c, NOB_NombreMissionAnnuel__c, NOB_Engagement_annuel_si_Silver__c, NOB_EngagementQ1__c, NOB_EngagementQ1N1__c, NOB_EngagementQ2__c, NOB_EngagementQ2N1__c, NOB_EngagementQ3__c, NOB_EngagementQ3N1__c, NOB_EngagementQ4__c, NOB_EngagementQ4N1__c, Account.NOB_TrainingDate__c, Account.NOB_Ranking__c, Status, NOB_TechToProcess__c, NOB_ContexteEngagement__c ';
        query += 'FROM ServiceContract ';
        query += 'WHERE Status = \'Active\' AND RecordTypeId = \''+recordTypeId+'\' AND Account.NOB_isPrefikar__c = TRUE';
        
        if (!runAllSC){
            String onlyTech = ' AND NOB_TechToProcess__c = true ';
            query += onlyTech;
        }
        System.debug('££££ queryString '+ query);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<ServiceContract> scope){
        System.debug('## start of execute method NOB_Batch_UpdateEngagementServiceContrat');
        System.debug('££££ scope service contract  '+ scope);
        List<ServiceContract> lstServiceUpdate = new List<ServiceContract>();

        for (ServiceContract sc : scope){
            System.debug('££££ sc '+ sc);
         
            
        Integer numMonth = (!Test.isRunningTest()) ? System.today().month() : runDate.month();
      
          
            System.debug('££££ safe nav numMonth '+ numMonth);


            if (sc.NOB_NombreMissionAnnuel__c != null && sc.Account.NOB_TrainingDate__c != null && sc.Account.NOB_Ranking__c != null){
                Decimal engagementRep = getEngagementByRanking(sc);
                System.debug('££££ yessai !');
                Map<String, Decimal> mapResult = getEngagementVals(numMonth, sc, engagementRep);
                System.debug('££££ mapResult '+ mapResult);

                if (mapResult != null){
                    ServiceContract serviceC = scUtility(mapResult, sc);
                    lstServiceUpdate.add(serviceC);
                }
                
                System.debug('££££ lstSCtoUpdate '+ lstServiceUpdate);
            }
        }

        if (lstServiceUpdate.size() > 0){
            System.debug('££££ into update !!!!!');
            Database.SaveResult[] scList = Database.update(lstServiceUpdate, false);
            System.debug('££££ updated !!!!!!!!!!!!!!!');
        }
    }

    public ServiceContract scUtility(Map<String, Decimal> mapResult, ServiceContract sc){
        System.debug('## start scUtility in NOB_Batch_UpdateEngagementServiceContrat');

        System.debug('££££ mapResult '+ mapResult);
        System.debug('££££ sc' + sc);

        ServiceContract serviceContract = new ServiceContract();
            serviceContract.Id = sc.Id;

            if (mapResult.get('updateQ1') == 1){
                serviceContract.NOB_EngagementQ1__c = getRoundedDec(mapResult.get('engagementQ1'));
                serviceContract.NOB_EngagementQ2__c = getRoundedDec(mapResult.get('engagementQ2')); 
                serviceContract.NOB_EngagementQ3__c = getRoundedDec(mapResult.get('engagementQ3'));
                serviceContract.NOB_EngagementQ4__c = getRoundedDec(mapResult.get('engagementQ4'));
            }

            
            if (mapResult.get('updateQ2') == 1){
                serviceContract.NOB_EngagementQ2__c = getRoundedDec(mapResult.get('engagementQ2')); 
                serviceContract.NOB_EngagementQ3__c = getRoundedDec(mapResult.get('engagementQ3'));
                serviceContract.NOB_EngagementQ4__c = getRoundedDec(mapResult.get('engagementQ4'));
            }

            if (mapResult.get('updateQ3') == 1){
                serviceContract.NOB_EngagementQ3__c = getRoundedDec(mapResult.get('engagementQ3'));
                serviceContract.NOB_EngagementQ4__c = getRoundedDec(mapResult.get('engagementQ4'));
            }

            if (mapResult.get('updateQ4') == 1){
                serviceContract.NOB_EngagementQ4__c = getRoundedDec(mapResult.get('engagementQ4'));
            }

            
            if (mapResult.get('eng0') == 1){
                serviceContract.NOB_EngagementQ1__c = serviceContract.NOB_EngagementQ2__c =  serviceContract.NOB_EngagementQ3__c = serviceContract.NOB_EngagementQ4__c =  getRoundedDec(mapResult.get('engMaxQuarter'));
            }

            if (mapResult.get('eng1') == 1){
                serviceContract.NOB_EngagementQ2__c =  serviceContract.NOB_EngagementQ3__c = serviceContract.NOB_EngagementQ4__c =  getRoundedDec(mapResult.get('engMaxQuarter'));
            }

            if (mapResult.get('eng2') == 1){
                serviceContract.NOB_EngagementQ3__c = serviceContract.NOB_EngagementQ4__c =  getRoundedDec(mapResult.get('engMaxQuarter'));
            }

            if (mapResult.get('eng3') == 1){
                serviceContract.NOB_EngagementQ4__c =  getRoundedDec(mapResult.get('engMaxQuarter'));
            }

            serviceContract.NOB_TechToProcess__c  = false;

        System.debug('££££ service contract builed ' + serviceContract);

        if (majHistorique){
            
            //Clone with shallow copy
            ServiceContract contractClone = sc.clone(false, false, false, false);
            System.debug('££££ contractClone '+ contractClone);

            serviceContract.NOB_EngagementQ1N1__c = contractClone?.NOB_EngagementQ1__c;
            serviceContract.NOB_EngagementQ2N1__c = contractClone?.NOB_EngagementQ2__c;
            serviceContract.NOB_EngagementQ3N1__c = contractClone?.NOB_EngagementQ3__c;
            serviceContract.NOB_EngagementQ4N1__c = contractClone?.NOB_EngagementQ4__c;
           
        }

        
        System.debug('££££ service contract builed ' + serviceContract);
        System.debug('## end scUtility in NOB_Batch_UpdateEngagementServiceContrat');
        return serviceContract;
    }

    public Decimal getRoundedDec(Decimal val){
        System.debug('## start of getRoundedDec method in NOB_Batch_UpdateEngagementServiceContrat');
        if (val > 0){
            return val.round(System.RoundingMode.HALF_EVEN); //1.1d = 1d // 1.6d = 2d
        }
        
        return 0;
    }


    public void finish(Database.BatchableContext BC){
        System.debug('## start of finish method in NOB_Batch_UpdateEngagementServiceContrat');
    }

    public Decimal getEngagementByRanking(ServiceContract sc){
        System.debug('## start getEngagementByRanking method in NOB_Batch_UpdateEngagementServiceContrat' + sc);

        Decimal engagementRanking = 0;
        if (sc.Account.NOB_Ranking__c == NOB_AP00_Constants.ACCOUNT_RANKING_BRONZE){
            engagementRanking = sc.NOB_Engagement_annuel_si_Bronze__c;
        }

        if (sc.Account.NOB_Ranking__c == NOB_AP00_Constants.ACCOUNT_RANKING_SILVER){
            engagementRanking = sc.NOB_Engagement_annuel_si_Silver__c;
        }

        if (sc.Account.NOB_Ranking__c == NOB_AP00_Constants.ACCOUNT_RANKING_GOLD){
            engagementRanking = sc.NOB_NombreMissionAnnuel__c;
        }
        System.debug('££££ engagementRanking '+ engagementRanking);

        System.debug('## end getEngagementByRanking method in NOB_Batch_UpdateEngagementServiceContrat');
        return engagementRanking;
    }


    public Integer calcNumDays(Date endOfQuarter, Date formationDate){
        System.debug('## start calcNumDays method in NOB_Batch_UpdateEngagementServiceContrat' + endOfQuarter +' '+ formationDate);

        Integer numDays = 0;

        System.debug('££££ formation date '+ formationDate);

        //formation date this year
        if (formationDate.year() >= System.today().year()){

            numDays = math.abs(formationDate.daysBetween(endOfQuarter));
        }

        System.debug('££££ numDays '+ numDays);

        System.debug('## end calcNumDays method in NOB_Batch_UpdateEngagementServiceContrat');
        return numDays;
    }
    
    public Map<String, Decimal> getEngagementVals(Integer numMonth, ServiceContract sc, Decimal engagementRep){
        System.debug('## start getEngagementVals method in NOB_Batch_UpdateEngagementServiceContrat');
        System.debug('££££ numMonth '+ numMonth);
        System.debug('££££ serviceContract '+ sc);
        System.debug('££££ engagementRep  '+ engagementRep);

        Decimal engagementQ1, engagementQ2, engagementQ3, engagementQ4, engRestant = 0;
        Integer numDays = 0;
        Decimal maxEngPerQuarter = engagementRep/4;

        Decimal updateQ1, updateQ2, updateQ3, updateQ4, eng1, eng2, eng3, eng0 = 0;
		Date df = sc.Account.NOB_TrainingDate__c;
        Boolean checkDf = false;
        
        System.debug('££££ numDays in getEngagementVals '+ numDays);

            if (numMonth > 0 && numMonth <= 3){
                System.debug('££££ in Q1');
                //HMO -- 23-09-2021
                checkDf = (df.month() > 0 && df.month() <= 3 && df.year() >= system.today().year()) ? true : false;

                //if (sc.Account.NOB_TrainingDate__c?.year() >= System.today().year()){
                if (checkDf){
                    
                    numDays = calcNumDays(calcQuarter(sc.Account.NOB_TrainingDate__c?.month()), sc.Account.NOB_TrainingDate__c);
                    System.debug('££££ numDays'+ numDays);

                    //HMO -- 05-09-2021
                    if (sc.NOB_ContexteEngagement__c == NOB_AP00_Constants.contextEG){
                        engagementQ3 = engagementQ4 = engagementQ2 = maxEngPerQuarter;
                        eng1 = 1;
                        
                    }

                    else if (sc.NOB_ContexteEngagement__c == NOB_AP00_Constants.contextRK || sc.NOB_ContexteEngagement__c == NOB_AP00_Constants.contextDF || sc.NOB_ContexteEngagement__c == NOB_AP00_Constants.contextCR){

                        engagementQ1 = (( numDays * maxEngPerQuarter )/NUMDAYS_PERQUARTER);
                        engagementQ3 = engagementQ4 = engagementQ2 = maxEngPerQuarter;
                        updateQ1 = 1;
                    }
                }

                //Date de formation in the past
                else{

                    engagementQ1 = engagementQ2 = engagementQ3 = engagementQ4 = maxEngPerQuarter;
                    eng0 = 1;
                }

            }

            if (numMonth > 3 && numMonth <= 6){
                System.debug('££££ in Q2');
				
               	checkDf = (df.month() > 3 && df.month() <= 6 && df.year() >= system.today().year()) ? true : false;
                if (checkDf){
                    numDays = calcNumDays(calcQuarter(sc.Account.NOB_TrainingDate__c?.month()), sc.Account.NOB_TrainingDate__c);
            
                    //HMO -- 05-09-2021
                    if (sc.NOB_ContexteEngagement__c == NOB_AP00_Constants.contextEG){
                        eng2 = 1;
                        engagementQ3 = engagementQ4 = maxEngPerQuarter;
                    }

                    //null => new service contract
                    else if (sc.NOB_ContexteEngagement__c == NOB_AP00_Constants.contextRK || sc.NOB_ContexteEngagement__c == NOB_AP00_Constants.contextDF || sc.NOB_ContexteEngagement__c == NOB_AP00_Constants.contextCR){

                        engagementQ2 = ((numDays * maxEngPerQuarter)/NUMDAYS_PERQUARTER);
                        engagementQ3 = engagementQ4 = maxEngPerQuarter;
                        updateQ2 = 1;
                    }

                }

                else{
                    if (sc.NOB_ContexteEngagement__c == NOB_AP00_Constants.contextEG){
                        engagementQ4 = maxEngPerQuarter;
                        eng3 = 1;
                    }
                    else{
                        engagementQ2 = engagementQ3 = engagementQ4 = maxEngPerQuarter;
                        eng1 = 1;
                    }
                }
                
            }

        if (numMonth > 6 && numMonth <= 9){
            System.debug('££££ in Q3');
			checkDf = (df.month() > 6 && df.month() <= 9 && df.year() >= system.today().year()) ? true : false;
            System.debug('££££ in check df'+ checkDf);
            
            
            if (checkDf){
                System.debug('££££ in check df');
                
                numDays = calcNumDays(calcQuarter(sc.Account.NOB_TrainingDate__c?.month()), sc.Account.NOB_TrainingDate__c);
                System.debug('££££ numDayszzz '+ numDays);

                //HMO -- 05-09-2021
                if (sc.NOB_ContexteEngagement__c == NOB_AP00_Constants.contextEG){
                    System.debug('££££ contexte engagement');
                    engagementQ4 = maxEngPerQuarter;
                    eng3 = 1;
                }
    
                else if (sc.NOB_ContexteEngagement__c == NOB_AP00_Constants.contextRK || sc.NOB_ContexteEngagement__c == NOB_AP00_Constants.contextDF || sc.NOB_ContexteEngagement__c == NOB_AP00_Constants.contextCR){
    				
                    System.debug('££££ CR, RK, DF');
                    engagementQ3 = ((numDays * maxEngPerQuarter)/NUMDAYS_PERQUARTER);
                    engagementQ4 = maxEngPerQuarter;
                    updateQ3 = 1;
                }
            }

            else{
                
                System.debug('£££££ in ELSE debug');
                if (sc.NOB_ContexteEngagement__c == NOB_AP00_Constants.contextEG){
                    System.debug('£££££ in ELSE debug EG');
                    engagementQ4 = maxEngPerQuarter;
                    eng3 = 1;
                }
                else{
                    engagementQ3 = engagementQ4 = maxEngPerQuarter;
                    System.debug('£££££ in ELSE debug RK');
                    eng2 = 1;
                }
            }
        }

        if (numMonth > 9){
            System.debug('££££ in Q4');

            engagementQ4 = maxEngPerQuarter;
            updateQ4 = 1;
        }

        Map<String, Decimal> mapEngagement = new Map<String, Decimal>{
            'engagementQ1' => engagementQ1,
            'engagementQ2' => engagementQ2, 
            'engagementQ3' => engagementQ3, 
            'engagementQ4' => engagementQ4, 
            'engMaxQuarter' => maxEngPerQuarter,
            'updateQ1' => updateQ1,
            'updateQ2' => updateQ2,
            'updateQ3' => updateQ3,
            'updateQ4' => updateQ4,
            'eng0' => eng0,
            'eng1' => eng1,
            'eng2' => eng2,
            'eng3' => eng3
        };

        System.debug('££££ mapEngagement '+ mapEngagement);
        System.debug('## end getEngagementVals method in NOB_Batch_UpdateEngagementServiceContrat');

        return mapEngagement;
    }

    //HMO -- 08-09-2021
    public Date calcQuarter(Integer month){
        Date quarter ;
        if (month > 0 && month <= 3){
            quarter = MAP_ENDQUARTER.get('quarter1');
        }

        if (month > 3 && month <= 6){
            quarter = MAP_ENDQUARTER.get('quarter2');
        }

        if (month > 6 && month <= 9){
            quarter = MAP_ENDQUARTER.get('quarter3');
        }

        if (month > 9){
            quarter = MAP_ENDQUARTER.get('quarter4');
        }

        return quarter;
    }
}