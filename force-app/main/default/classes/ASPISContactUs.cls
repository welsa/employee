/*************************************************************************************
Class Name - ASPISContactUs 
Version - 1.0
Created Date - 27 July 2017
Function - Controller for page ASPISContactUs 

Modification Log :
-----------------------------------------------------------------------------
* Developer    Date        Description
* ----------   ----------  -----------------------
* Axel       24/09/2017  Original Version (case C-001955 : ASPIS Order 2.0 : ASPISContactUs )
**************************************************************************************/
public without sharing class ASPISContactUs{


 public String language {get; set;}
  public ASPISContactUs (){
  language = String.isNotBlank(ApexPages.currentPage().getParameters().get('lang')) ? ApexPages.currentPage().getParameters().get('lang') : UserInfo.getLanguage();
  }
}