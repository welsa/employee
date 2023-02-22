/*
  ----------------------------------------------------------------------
  -- - Name          : AP36AssessmentPurge
  -- - Author        : ABT
  -- - Description   : Class that contains code of how to add or remove Deletion Date on Assessment
  --
  -- Maintenance History:
  --
  -- Date           Name  Version    Remarks
  -- -----------    ----  -------    ---------------------------------------
  -- 24-APR-2017  ABT    1.0      Initial version
  -- 30-MAR-2018    RLA     1.2     Case 2002: Data Purge Long
  ----------------------------------------------------------------------
  **********************************************************************
*/
public with sharing class AP36AssessmentPurge 
{
  private static Map<String, CountryCodeInformationsMapping__c> mapCountryCodeMappings;

  /**
   * Function to set the short term deletion date on the Shopping List Claim Assessment
   * @param  currentAssessment The current shopping list assessment on which the deletion date should be set
   */
  public static void setShoppingListDeletionDate(Assessment__c currentAssessment)
  {
    populateCountryCodeMappings();

    CountryCodeInformationsMapping__c currentCountryCodeMapping = (mapCountryCodeMappings.containsKey(currentAssessment.TECH_EntityCountryCode__c)) ? mapCountryCodeMappings.get(currentAssessment.TECH_EntityCountryCode__c) : mapCountryCodeMappings.get('DEFAULT');
    
    Integer noOfHours = (currentCountryCodeMapping != null && currentCountryCodeMapping.ValidityOfClaimShoppingList__c != null) ? Integer.valueOf(currentCountryCodeMapping.ValidityOfClaimShoppingList__c) : 1;

    // Shopping List if defined for only 24 hours
    currentAssessment.ShortTermDeletionDate__c = System.now().addHours(noOfHours);
  }

  /**
   * Function to set the short term deletion date on the Claim Order Assessment
   * @param  currentAssessment The current assessment on which the deletion date should be set
   */
  public static void setClaimOrderDeletionDate(Assessment__c currentAssessment)
  {
    populateCountryCodeMappings();

    CountryCodeInformationsMapping__c currentCountryCodeMapping = (mapCountryCodeMappings.containsKey(currentAssessment.TECH_EntityCountryCode__c)) ? mapCountryCodeMappings.get(currentAssessment.TECH_EntityCountryCode__c) : mapCountryCodeMappings.get('DEFAULT');

    Integer noOfHours = (currentCountryCodeMapping != null && currentCountryCodeMapping.ValidityOfClaimOrders__c != null) ? Integer.valueOf(currentCountryCodeMapping.ValidityOfClaimOrders__c) : 1;
    
    currentAssessment.ShortTermDeletionDate__c = System.now().addHours(noOfHours);
  }

  
  /**
   * Asynchronous Function to clear the short term deletion date of the claim shopping list and its crash
   * @param  claimAssessmentSet Set of claim assessment ids
   */
  @future
  public static void clearCrashShortTermDeletionDateAsync(Set<Id> claimAssessmentSet)
  {
    clearCrashShortTermDeletionDate(claimAssessmentSet);
  }

  /**
   * Function to clear the short term deletion date of the claim shopping list and its crash
   * @param  claimAssessmentSet Set of claim assessment ids
   */
  public static void clearCrashShortTermDeletionDate(Set<Id> claimAssessmentSet)
  {
    List<Assessment__c> assessmentToUpdateList = new List<Assessment__c>();

    // Retieve the Claim Shopping List Assessment that needs to have their short term deletion date cleared
    for(Assessment__c crashAssessment : [SELECT Id
                       FROM  Assessment__c
                       WHERE  ParentAssessment__c IN: claimAssessmentSet
                       AND  RecordType.DeveloperName = 'Crash'])
    {
      crashAssessment.ShortTermDeletionDate__c = null;

      assessmentToUpdateList.add(crashAssessment);
    }

    if(assessmentToUpdateList.size() > 0)
    {
      update assessmentToUpdateList;
    }
  }

   ///**
   // * Function to set the long term deletion date on Eligible Assessment when closed
   // * @param  currentAssessment The current assessment on which the long term deletion date should be set
   // */
   //public static void setEligibleAssessmentDeletionDate(Assessment__c currentAssessment)
   //{
   //  populateCountryCodeMappings();

   //  CountryCodeInformationsMapping__c currentCountryCodeMapping = (mapCountryCodeMappings.containsKey(currentAssessment.TECH_EntityCountryCode__c)) ? mapCountryCodeMappings.get(currentAssessment.TECH_EntityCountryCode__c) : mapCountryCodeMappings.get('DEFAULT');
    
   //  Integer noOfMonths = (currentCountryCodeMapping != null && currentCountryCodeMapping.ValidityOfEligibleAssessment__c != null) ? Integer.valueOf(currentCountryCodeMapping.ValidityOfEligibleAssessment__c) : 24;

   //  currentAssessment.LongTermDeletionDate__c = System.now().addMonths(noOfMonths);
   //}

   ///**
   // * Function to set the long term deletion date on Non-Eligible Assessment when closed
   // * @param  currentAssessment The current assessment on which the long term deletion date should be set
   // */
   //public static void setNonEligibleAssessmentDeletionDate(Assessment__c currentAssessment)
   //{
   //  populateCountryCodeMappings();

   //  CountryCodeInformationsMapping__c currentCountryCodeMapping = (mapCountryCodeMappings.containsKey(currentAssessment.TECH_EntityCountryCode__c)) ? mapCountryCodeMappings.get(currentAssessment.TECH_EntityCountryCode__c) : mapCountryCodeMappings.get('DEFAULT');
    
   //  Integer noOfMonths = (currentCountryCodeMapping != null && currentCountryCodeMapping.ValidityOfNonEligibleAssessement__c != null) ? Integer.valueOf(currentCountryCodeMapping.ValidityOfNonEligibleAssessement__c) : 24;

   //  currentAssessment.LongTermDeletionDate__c = System.now().addMonths(noOfMonths);
   //}

  /**
   * Function to populate the static map of the delays
   */
  public static void populateCountryCodeMappings()
  {
    // to prevent retrieval of the custom setting on each call of the trigger
    if(mapCountryCodeMappings == null)
    {
      mapCountryCodeMappings = CountryCodeInformationsMapping__c.getAll();
    }
  }

  /**Rework RLA C-2002 30 05 2018
    * Function to set the long term deletion date on Eligible Assessment when closed
    * @param  currentAssessment The current assessment on which the long term deletion date should be set
    */
   public static Datetime setEligibleAsmntDeletionDate(Datetime dateReq, String countryCode)
   {
     //populateCountryCodeMappings();

     CountryCodeInformationsMapping__c currentCountryCodeMapping = (mapCountryCodeMappings.containsKey(countryCode)) ? mapCountryCodeMappings.get(countryCode) : mapCountryCodeMappings.get('DEFAULT');
    
     Integer noOfMonths = (currentCountryCodeMapping != null && currentCountryCodeMapping.ValidityOfEligibleAssessment__c != null) ? Integer.valueOf(currentCountryCodeMapping.ValidityOfEligibleAssessment__c) : 24;
     System.debug(' ### noOfMonths Eligible: '+noOfMonths);
     return dateReq.addMonths(noOfMonths);
     
   }

   /**Rework RLA C-2002 30/05/2018
    * Function to set the long term deletion date on Non-Eligible Assessment when closed
    * @param  currentAssessment The current assessment on which the long term deletion date should be set
    */
   public static Datetime setNonEligibleAsmntDeletionDate(Datetime dateReq, String countryCode)
   {
     //populateCountryCodeMappings();

     CountryCodeInformationsMapping__c currentCountryCodeMapping = (mapCountryCodeMappings.containsKey(countryCode)) ? mapCountryCodeMappings.get(countryCode) : mapCountryCodeMappings.get('DEFAULT');
    
     Integer noOfMonths = (currentCountryCodeMapping != null && currentCountryCodeMapping.ValidityOfNonEligibleAssessement__c != null) ? Integer.valueOf(currentCountryCodeMapping.ValidityOfNonEligibleAssessement__c) : 24;
     System.debug(' ### noOfMonths Non-Eligible: '+noOfMonths);

     return dateReq.addMonths(noOfMonths);
   }

    // RLA 30/05/2018 C-2002 Data purge LONG 
  public static void checkAsmntStatus(List<Assessment__c> lstAsmnt){
    populateCountryCodeMappings();

    map<Id, Assessment__c> mapAssessmentToUpdate = new map<Id, Assessment__c>();
    for (Assessment__c asmnt: lstAsmnt){
      Datetime dateToSend;
      if (asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId()){
        asmnt.LastUpdateDate__c = System.now(); 
        //dateToSend = asmnt.LastUpdateDate__c;  
      }
      //else if(asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId() ){
      //  dateToSend = asmnt.CreatedDate;  
      //}else if(asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId()){
      //  dateToSend = asmnt.LastModifiedDate;  
      //}
      dateToSend = System.now();

      if (dateToSend != null){
        if (asmnt.Status__c == ASPISConstants.ASSESS_STATUS_REJECTED || asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId()){
          asmnt.LongTermDeletionDate__c = setNonEligibleAsmntDeletionDate(dateToSend, asmnt.TECH_EntityCountryCode__c );
        }
        else{
          asmnt.LongTermDeletionDate__c = setEligibleAsmntDeletionDate(dateToSend, asmnt.TECH_EntityCountryCode__c);
        }
      } 
      
      mapAssessmentToUpdate.put(asmnt.Id, asmnt);

    }//endfor
    System.debug('### mapAssessmentToUpdate checkAsmntStatus:'+mapAssessmentToUpdate);
    //if (mapAssessmentToUpdate.size() > 0){
    //  //update mapAssessmentToUpdate.values();
    //}
  }

}