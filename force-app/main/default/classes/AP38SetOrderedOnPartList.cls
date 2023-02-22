/*
  ----------------------------------------------------------------------
  -- - Name          : AP38SetOrderedOnPartList
  -- - Author        : VSU
  -- - Description   : Class to set ordered on Part List when TECH_CounterOrdered is changed on part list
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 08-JUN-2017  VSU    1.0     Initial version
  ----------------------------------------------------------------------
 **********************************************************************
*/public without sharing class AP38SetOrderedOnPartList{ 
	
	public static void setOrdered(Set <Id> setOriginalPartIds){
		list <PartList__c> partListToUpdate = new list <PartList__c> ();
		Decimal counterPerGroup = 0;
		
		list <PartList__c> OriginalPartList =  [SELECT id,name,TECH_OrderedCounter__c,
														(select id,name,TECH_OrderedCounter__c from Parts_Lists__r where originalPart__c IN: setOriginalPartIds) 
												FROM PartList__c where (id IN: setOriginalPartIds 
												and originalPart__c = null)];//retrieve all original parts in set or whose children are in set

		system.debug('##OriginalPartList '+OriginalPartList);
		for(PartList__c pl : OriginalPartList){
			system.debug('##pl.TECH_OrderedCounter__c '+pl.TECH_OrderedCounter__c);
			if(pl.TECH_OrderedCounter__c!=null){
				counterPerGroup += pl.TECH_OrderedCounter__c;
			}
			system.debug('##pl.Parts_Lists__r'+pl.Parts_Lists__r);
			for(PartList__c plChild : pl.Parts_Lists__r){
				system.debug('##pl.Parts_Lists__r'+pl.Parts_Lists__r);
				if(plChild.TECH_OrderedCounter__c!=null){
					counterPerGroup += plChild.TECH_OrderedCounter__c;
				}
			}
			if(counterPerGroup > 0){
				pl.ordered__c = true;
				partListToUpdate.add(pl);
				for(PartList__c plChild : pl.Parts_Lists__r){
					plChild.ordered__c = true;
					partListToUpdate.add(plChild);
				}
			}
			else{
				pl.ordered__c = false;
				partListToUpdate.add(pl);
				for(PartList__c plChild : pl.Parts_Lists__r){
					plChild.ordered__c = false;
					partListToUpdate.add(plChild);
				}
			}
		}
		
		system.debug('##partListToUpdate '+partListToUpdate);
		if(partListToUpdate.size()>0){
			update partListToUpdate;
		}
		
	}			

}