/*
----------------------------------------------------------------------
-- - Name          : AP43LinkBSExpert
-- - Author        : DUN
-- - Description   : Class to link Standard BS with expert BS
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 17-OCT-2017  DUN   1.0      Initial version
-- 01-MAR-2018  ASE   1.1      C-002311 - Substitution expert - lien expert
-- 02-AUG-2018  ASE   1.2      C-002600 - Define bodyshop / expert granular level substitution rules
-- 09-FEB-2021  RLA   1.3      C-004100: FR - Source Expert Assessment as Bodyshop
----------------------------------------------------------------------*/
public without sharing class AP43LinkBSExpert {
    
    public static void linkBSExpert(map <String,Assessment__c> mapClaimPlateAssessmentClaim, set<Id> setBodyShopId){
        system.debug('#### AP43LinkBSExpert.linkBSExpert START:');
        map<String,Assessment__c> mapAssessmentToUpdate = new map<String,Assessment__c>();
        map<Id,Account> mapAccountToUpdate = new map<Id,Account>();
        map <String,Assessment__c> mapClaimPlateExpertAssessmentClaim = new map <String,Assessment__c>();
        //RLA C-004481: Un chiffrage expert d'un Assureur ne doit pas ?tre li? ? un chiffrage garage d'un autre assureur.
        Set<String> setEntity = new Set<String>();
        Set<String> setPlate = new Set<String>();

        map<Id,Account> mapBodyShopExpert = new map<Id,Account>([Select Id, ExpertSubstitutionMethod__c, SubstitutionMethod2__c, ShippingCountryCode from Account where Id in: setBodyShopId and Type = 'Expert' and ShippingCountryCode = 'FR']);
        system.debug('## mapBodyShopExpert:'+mapBodyShopExpert);

        if(mapBodyShopExpert.size() > 0){
            for(String claimPlate : mapClaimPlateAssessmentClaim.keySet()){
                Id BSId = mapClaimPlateAssessmentClaim.get(claimPlate).BodyShop__c;
                if(mapBodyShopExpert.keySet().contains(BSId)){
                    mapClaimPlateExpertAssessmentClaim.put(claimPlate,mapClaimPlateAssessmentClaim.get(claimPlate));
                    //RLA C-004481: Un chiffrage expert d'un Assureur ne doit pas ?tre li? ? un chiffrage garage d'un autre assureur.
                    setEntity.add(mapClaimPlateAssessmentClaim.get(claimPlate).EntityCode__c);
                    setPlate.add(claimPlate);
                }
            }
            system.debug('## mapClaimPlateExpertAssessmentClaim' + mapClaimPlateExpertAssessmentClaim);

            //RLA C-004481: Un chiffrage expert d'un Assureur ne doit pas ?tre li? ? un chiffrage garage d'un autre assureur.
            String query = getQueryBSExpert( new map<String,Object> {'setPlate' => setPlate, 'setEntityCode' => setEntity});
            system.debug('## query' + query);

            List<Assessment__c> assList = Database.query(query);

            // List<Assessment__c> assList = [select Id, CrossReferences__c, ClaimReference__c, PlateNumber2__c, Manufacturer__c, NumASPParts__c,
            //                        CreatedDate, BodyShop__r.isEligibleSubstitution__c, BodyShop__r.CarBrandExcluded__c,BodyShop__r.ExpertSubstitutionMethod__c,EntityCode__c,
            //                               (select Id, SelectedByBS__c
            //                               from PartsLists__r
            //                               where SelectedByBS__c = true)
            //                        from Assessment__c
            //                        where BodyShop__r.Type = 'Standard'
            //                        // ASE: 01/03/2018 - C-002311
            //                        //and ClaimReference__c in: setClaim
            //                        and PlateNumber2__c in: mapClaimPlateAssessmentClaim.keySet()
            //                        and BodyShop__r.ShippingCountryCode = 'FR'
            //                        and RecordTypeId =: Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId()
            //                        and CreatedDate >=: System.today().addMonths(-Integer.valueOf(System.label.AssessementCreatedmonth)) 
            //                        and isShoppingList__c = false
            //                         //RLA 23/02/2021 Do not link Expert Assessment to BS if from createToUpsert
            //                        and isFromR3__c = false
            //                        order by CreatedDate DESC]; 

            if(assList.size() > 0){
                for(Assessment__c ass: assList){
                    system.debug('## ass' + ass); 
                    //Account expert = mapBodyShopExpert.get(mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).BodyShop__c);               
                    if(mapClaimPlateExpertAssessmentClaim.containsKey(ass.PlateNumber2__c)){

                        //RLA C-004481: Un chiffrage expert d'un Assureur ne doit pas ?tre li? ? un chiffrage garage d'un autre assureur.
                        if (mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).EntityCode__c == ass.EntityCode__c ){
                        Account expert = mapBodyShopExpert.get(mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).BodyShop__c);
                    
                        //RLA 21/01/2021 C-004100: FR - Source Expert Assessment as Bodyshop
                        Account BS = ass.Bodyshop__r;
                        system.debug('## BS' + BS);

                        if(BS.ExpertSubstitutionMethod__c == 'FORCED'){
                                mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).ExpertSubstitutionMethod__c = 'FORCED';                            
                            }
                            // Expert Account : (PROPOSED) 
                        else if(BS.ExpertSubstitutionMethod__c == 'PROPOSED'){
                                mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).ExpertSubstitutionMethod__c = 'PROPOSED';
                            }
                        // Expert Account : (PROPOSED) 
                        else if(BS.ExpertSubstitutionMethod__c == 'FORCED NO A\''){
                            mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).ExpertSubstitutionMethod__c = 'FORCED NO A\'';
                                system.debug('@@ ExpertSubstitutionMethod__c ' +mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).ExpertSubstitutionMethod__c);
                        } 


                        // //Expert algo has found a B/S with substitution                    
                        // if(((ass.CrossReferences__c != null && ass.CrossReferences__c != '' && ass.CrossReferences__c != 'NONE') || (ass.NumASPParts__c > 0))&& 
                        //     ass.PartsLists__r != null && 
                        //     ass.PartsLists__r.size() > 0){
                        //     RESTUpsertAssessmentV2.traceVariables += ' #AP34: Has Assessment, has Subs, ' + expert.ExpertSubstitutionMethod__c +'#';
                        //     // C-002600: Expert Account : (FORCED NO A') 
                        //     //if(expert.ExpertSubstitutionMethod__c == 'FORCED' || expert.ExpertSubstitutionMethod__c == 'FORCED, EXCLUDE A\' NENA'){
                        //     if(expert.ExpertSubstitutionMethod__c == 'FORCED'){
                        //         mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).ExpertSubstitutionMethod__c = 'FORCED';                            
                        //     }
                        //     // Expert Account : (PROPOSED) 
                        //     else if(expert.ExpertSubstitutionMethod__c == 'PROPOSED'){
                        //         mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).ExpertSubstitutionMethod__c = 'PROPOSED';
                        //     }
                        // } 
                        // // BS assessment found but with no substitution
                        // else{
                        //     system.debug('## FORCED NO A');
                        //     if(expert.SubstitutionMethod2__c == 'FORCED NO A\''){
                        //         mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).ExpertSubstitutionMethod__c = 'FORCED NO A\'';                            
                        //     }
                        //     // Expert Account : (PROPOSED) 
                        //     else if(expert.SubstitutionMethod2__c == 'PROPOSED'){
                        //         system.debug('## PROPOSED');
                        //         mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).ExpertSubstitutionMethod__c = 'PROPOSED';
                        //     }
                        // }                 
                        // C-002600
                        //If the bodyshop is eligible for substitution && brand not excluded for substitution for bodyshop but bodyshop has not substituted, set picklist field Expert Substitution Method to 'Proposed' 
                        //else if(ass.BodyShop__r.isEligibleSubstitution__c &&
                        //        (ass.BodyShop__r.CarBrandExcluded__c == null || (ass.BodyShop__r.CarBrandExcluded__c != null && !ass.BodyShop__r.CarBrandExcluded__c.contains(ass.Manufacturer__c))) &&
                        //        ((ass.CrossReferences__c == null || ass.CrossReferences__c == '' || ass.CrossReferences__c == 'NONE') || (ass.NumASPParts__c == 0))){
                        //    mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).ExpertSubstitutionMethod__c = 'PROPOSED';
                        //}
                        //// If the bodyshop is not eligible or (iseligible and brand is excluded), set picklist field Expert Substitution Method to 'None' 
                        //else if(!ass.BodyShop__r.isEligibleSubstitution__c || (ass.BodyShop__r.isEligibleSubstitution__c && (ass.BodyShop__r.CarBrandExcluded__c != null && ass.BodyShop__r.CarBrandExcluded__c.contains(ass.Manufacturer__c)))){
                        //    // ASE : 21/03/18 :mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).ExpertSubstitutionMethod__c = 'NONE';
                        //    mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).ExpertSubstitutionMethod__c = 'PROPOSED';
                        //}


                        if(!mapAssessmentToUpdate.containsKey(ass.PlateNumber2__c)){
                            Assessment__c assParentExpert = new Assessment__c (AssessmentID__c = mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).AssessmentID__c);
                            mapAssessmentToUpdate.put(ass.PlateNumber2__c,new Assessment__c(Id = ass.Id, 
                                                                                                                      ParentAssessment__r = assParentExpert));
                        }  
                        if(!mapAccountToUpdate.containsKey(ass.BodyShop__c)){
                            mapAccountToUpdate.put(ass.BodyShop__c,new Account(Id = ass.BodyShop__c, 
                                                                               CurrentExpert__c = mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).BodyShop__c));
                        }
                        // ase: 07/03/18 : assign expertSubstitutionMethod to RESTUpsertAssessmentV2.expertSubstitutionMethod
                        RESTUpsertAssessmentV2.expertSubstitutionMethod = mapClaimPlateExpertAssessmentClaim.get(ass.PlateNumber2__c).ExpertSubstitutionMethod__c;
                            system.debug('@@RESTUpsertAssessmentV2.expertSubstitutionMethod: '+RESTUpsertAssessmentV2.expertSubstitutionMethod);
                            mapClaimPlateExpertAssessmentClaim.remove(ass.PlateNumber2__c);
                        }    
                    
                    }
                }
            } 
            else{
                for(String expertPlate : mapClaimPlateAssessmentClaim.keySet()){

                    if (mapClaimPlateAssessmentClaim.containskey(expertPlate) && mapBodyShopExpert.containskey(mapClaimPlateAssessmentClaim.get(expertPlate).BodyShop__c)){
                    Account expert = mapBodyShopExpert.get(mapClaimPlateAssessmentClaim.get(expertPlate).BodyShop__c);
                       
                    RESTUpsertAssessmentV2.traceVariables += ' #AP34: Has No Assessment, ' + expert.SubstitutionMethod2__c;
                    
                    if(expert.SubstitutionMethod2__c == 'FORCED NO A\''){
                        RESTUpsertAssessmentV2.expertSubstitutionMethod = 'FORCED NO A\'';                            
                    }
                    // Expert Account : (PROPOSED) 
                    else if(expert.SubstitutionMethod2__c == 'PROPOSED'){
                       RESTUpsertAssessmentV2.expertSubstitutionMethod = 'PROPOSED';
                    }
                }

            }        

            }        
            RESTUpsertAssessmentV2.traceVariables += ' #AP34: final value for expertSubstitutionMethod of Assess:  ' + RESTUpsertAssessmentV2.expertSubstitutionMethod;
            
            system.debug('## mapAssessmentToUpdate' + mapAssessmentToUpdate);
            system.debug('## mapAccountToUpdate' + mapAccountToUpdate);
            system.debug('## RESTUpsertAssessmentV2.expertSubstitutionMethod:'+RESTUpsertAssessmentV2.expertSubstitutionMethod);

            if(mapAssessmentToUpdate.size() > 0 && mapAccountToUpdate.size() > 0){
                System.enqueueJob(new AP43LinkBSExpertQueueable(mapAssessmentToUpdate,mapAccountToUpdate));
            }
        }
        system.debug('#### AP43LinkBSExpert.linkBSExpert END:');
    }

    public static void updateAssBS(map<String,Assessment__c> mapAssessmentToUpdate, map<Id,Account> mapAccountToUpdate){
        system.debug('#### AP43LinkBSExpert.updateAssBS START:');

        if(mapAssessmentToUpdate.size() > 0){
            update mapAssessmentToUpdate.values();
        }

        if(mapAccountToUpdate.size() > 0){
            update mapAccountToUpdate.values();
        }
        system.debug('#### AP43LinkBSExpert.updateAssBS END:');
    }

    //RLA 16/11/2021 C-004481: Un chiffrage expert d'un Assureur ne doit pas ?tre li? ? un chiffrage garage d'un autre assureur.
    public static String getQueryBSExpert(Map<String,Object> mapInputParams){

        Set<String> setPlate = mapInputParams.containskey('setPlate') ? (Set<string>)mapInputParams.get('setPlate') : new set<String>();
        Set<String> setEntityCodeNew = mapInputParams.containskey('setPlate') ? (Set<string>)mapInputParams.get('setPlate') : new set<String>();
        Set<String> setEntityCode = mapInputParams.containskey('setEntityCode') ? (Set<string>)mapInputParams.get('setEntityCode') : new set<String>();
        DateTime todaysDate = !Test.isrunningtest() ? System.now().addMonths(-Integer.valueOf(System.label.AssessementCreatedmonth)) : System.now();
        String todaysDateStr = todaysDate.format('yyyy-MM-dd');
            system.debug('## setPlate' + setPlate);
            system.debug('## setEntityCode' + setEntityCode);
            system.debug('## todaysDateStr' + todaysDateStr);
        
        String strEntityCode = quoteKeySet(setEntityCode);
        // system.debug('## lstEntityCodeNew' + lstEntityCodeNew);


        
        String query = ' Select CreatedDate, CrossReferences__c, NumASPParts__c, AssessmentId__c, ClaimReference__c, PlateNumber2__c, BodyShop__r.CarBrandExcluded__c,  ' +
                        'ParentAssessment__c , BodyShop__r.AXA_Partner__c,Manufacturer__c,EntityCode__c,  ' +
                        'BodyShop__r.DistributorConnected__c, BodyShop__r.AXAPartner__c, BodyShop__r.PreferredPartType__c, ' +
                        'BodyShop__r.ReferenceNumber__c, BodyShop__r.ExpertSubstitutionMethod__c, ' +
                        'BodyShop__r.Categories__c, BodyShop__r.Name, BodyShop__r.VATNumber__c, BodyShop__r.Feature__c, ' +
                        'BodyShop__r.CarBrandsSuppliedAgency__c, BodyShop__r.Id,TECH_EntityCountryCode__c,  ' +
                        ' BodyShop__r.isEligibleSubstitution__c,BodyShop__r.ShippingCountryCode,BodyShop__r.ContactUser__c, ' +
                        'BodyShop__r.ContactUser__r.Email, BodyShop__r.ContactEmail__c,  ' +
                        'BodyShop__r.Type,BodyShop__r.ShippingCountry,BodyShop__r.ShippingPostalCodeLeft2__c, ' +
                        'BodyShop__r.BillingStateCode__c,BodyShop__r.isEligible__c,BodyShop__r.DirectOrderingProcess__c, ' +
                        'BodyShop__r.Non_AXA_Authorised__c,BodyShop__r.TotalLoss__c,BodyShop__r.SubstitutionMethod2__c, BodyShop__r.KeepNonAXA__c, BodyShop__r.keepAXA__c, ' +
                        'BodyShop__r.Pilote_BdG__c, ' +
                        'BodyShop__r.Brand_Rejected_on_Non_Partner__c,' + //RLA 28/02/2022 C-004565:
                        '(select Id, SelectedByBS__c from PartsLists__r where SelectedByBS__c = true) ' +
                        ' from Assessment__c ' +
                        'where (EntityCode__c IN ' + strEntityCode +  ') and (PlateNumber2__c in :setPlate) and BodyShop__r.Type = \'Standard\' ' +
                        'and BodyShop__r.ShippingCountryCode = \'FR\' ' +
                        'and RecordTypeId = \'' + Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId() + '\' ' +
                        'and isShoppingList__c = false ' +
                        'and isFromR3__c = false ' +
                        'and DAY_ONLY(CreatedDate) >= '+ todaysDateStr  +                       
                        ' order by CreatedDate DESC ' ; 

        return query;

    }
    private static String quoteKeySet(Set<String> mapKeySet)
    {
        String newSetStr = '' ;
        for(String str : mapKeySet)
            newSetStr += '\'' + str + '\',';

        newSetStr = newSetStr.lastIndexOf(',') > 0 ? '(' + newSetStr.substring(0,newSetStr.lastIndexOf(',')) + ')' : newSetStr ;
        System.debug('quoteKeySet() :  newSetStr ============ ' + newSetStr);   

        return newSetStr;

    }

}