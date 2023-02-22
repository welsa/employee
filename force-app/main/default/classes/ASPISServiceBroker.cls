/*************************************************************************************
Class Name - ASPISServiceBroker
Version - 1.0
Created Date - 27 MAR 2015
Function - Class to provide APEX calls either by trigger handler or process builder ApexCode

Modification Log :
-----------------------------------------------------------------------------
* Developer  			Date       	Description
* ---------- 			----------  -----------------------
* Joao Dias			 	27/03/2015 	Original Version
* Shamina M     		16/02/2016  C-001518: Removed unnecessary debug logs
* Dourga U      		30/06/2016  C-001652: Remove ServiceBroker + Bulkify ASPISService...
**************************************************************************************/
public  class ASPISServiceBroker {

/*public static Map<String, ASPISService> mapStatusASPISService;//map with all services instances
		 


	//Initialization of services map with instances of implemented classes
	static{
		mapStatusASPISService = new Map<String, ASPISService>();
		for(String key:GlobalVariables__c.getAll().KeySet()){
			if(GlobalVariables__c.getAll().get(key).type__c=='Process'){
				mapStatusASPISService.put(key,
				(ASPISService)Type.forName('ASPISService' + GlobalVariables__c.getAll().get(key).value__c)
				.newInstance());
			}//endIf
		}//endFor
		system.debug('mapStatusASPISService: ' + mapStatusASPISService);
	}//endBlock
	


	private ASPISService processService;
	
	//Initialization of ASPISService with the right class instance to process the service required
	public ASPISServiceBroker(String status){
		processService = mapStatusASPISService.get(status);
        system.debug('processService: ' + processService + ' ,sBrokerstatus: ' + status);
    }
	
	//Delivery of the requested procecc to ASPISService
	public void executeProcess(SObject obj){
		system.debug('Object in ServiceBroker = ' + obj);
		
		//Ignore status that are not treated in processes
		if(processService != null)
			processService.executeProcess(obj);
	}*/
}//endClass