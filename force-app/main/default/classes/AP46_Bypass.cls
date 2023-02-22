/*************************************************************************************
Class Name - AP46_Bypass
Version - 1.0
Created Date - 06 Septembre 2022
Function - class use to bypass process builder
Modification Log :
-----------------------------------------------------------------------------
* Developer    Date        Description
* ----------   ----------  -----------------------
* Rojo       06/09/2022  Original Version (C-004790 : Add bypass to Valiation Rules, Workflow Rules and Processes )

**************************************************************************************/ 
public class AP46_Bypass {
	@InvocableMethod
    public static void doNothing(){
        system.debug('Do not execute process builder');
    }
}