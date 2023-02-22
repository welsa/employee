/*************************************************************************************
Class Name - ASPISParser
Version - 1.0
Created Date - 12 MAY 2015
Function - Class Parser

Modification Log :
-----------------------------------------------------------------------------
* Developer  			Date       	Description
* ---------- 			----------  -----------------------
* Dourga Unmole			12/05/2015  Original Version
*************************************************************************************/
public class ASPISParser {
	
	//Method to evaluate a string containing two numbers and one operator and then returning an integer value
	public Double evalDouble(String evalApex){
		Double value = 0;
		list <String> listVariables = new list <String>();
		
		if(evalApex.contains('/')){
			listVariables = evalApex.split('/',2);
			//system.debug('## listVariables '+listVariables);
			value = (Double.valueOf(listVariables[0]))/(Double.valueOf(listVariables[1]));
		}
		else if(evalApex.contains('*')){
			listVariables = evalApex.split('\\*',2);
			value = (Double.valueOf(listVariables[0]))*(Double.valueOf(listVariables[1]));
		}
		else if(evalApex.contains('+')){
			listVariables = evalApex.split('\\+',2);
			value = (Double.valueOf(listVariables[0]))+(Double.valueOf(listVariables[1]));
		}
		else if(evalApex.contains('-')){
			listVariables = evalApex.split('-',2);
			value = (Double.valueOf(listVariables[0]))-(Double.valueOf(listVariables[1]));
		}
		return value;
	}
}