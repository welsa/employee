/*
  ----------------------------------------------------------------------
  -- - Name          : PartListTriggerHandler
  -- - Author        : VSU
  -- - Description   : Class to handle trigger on partList
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 08-JUN-2017  VSU    1.0     Initial version
  -- 14-JUL-2017  DUN    1.1     Added code for case 001966 : Manual PO Creation for Germany 
  -- 15-FEB-2018  DUN    1.2     case 2297 : Added After Insert to fill SelectedByBSPartTypes__c on assessment
  -- 22-JUL-2020  WCH    1.3     C-003846 - Selected by BS Part Types field is not updated if Part List field "selected" is updated
  -- 20-AUG-2020  KPA    1.4     C-003898 - The field Selected by BS Part Type in the Assessement object should not take parts with no reference or N/A (currently labeled as A parts) into account
  -- 21-SEP-2020  KPA    1.5     C-003947 - Exclude Part List part type values from Selected by BS Part Type field
  ----------------------------------------------------------------------
 **********************************************************************/
 public without sharing class PartListTriggerHandler {

    public void onAfterInsert(list <PartList__c> newPartList){
        System.debug('-------------------------- START METHOD PartListTriggerHandler - onAfterInsert --------------------------');
        
        map<Id,Set<String>> mapAssIdSetPartTypes = new map<Id,Set<String>>();

        for(Integer i = 0; i < newPartList.size(); i++){
            if(newPartList[i].SelectedByBS__c && newPartList[i].Type__c != null){
                if(mapAssIdSetPartTypes.containsKey(newPartList[i].Assessment__c)){
                    mapAssIdSetPartTypes.get(newPartList[i].Assessment__c).add(newPartList[i].Type__c);
                }
                else{
                    mapAssIdSetPartTypes.put(newPartList[i].Assessment__c,new set<String>{newPartList[i].Type__c});
                }
            }
        }

        system.debug('mapAssIdSetPartTypes '+ mapAssIdSetPartTypes);
        if(mapAssIdSetPartTypes.size() > 0){
            setOrdered(mapAssIdSetPartTypes);
        }   

        System.debug('-------------------------- END METHOD PartListTriggerHandler - onAfterInsert --------------------------');
    }

	public void onAfterUpdate(list <PartList__c> newPartList, list <PartList__c> oldPartList){
		system.debug('##oldPartList '+ oldPartList);
		set <Id> originalPartListIds = new set <Id> ();
		map<Id,Set<String>> mapAssIdSetPartTypes = new map<Id,Set<String>>();
		for(Integer i = 0; i < newPartList.size(); i++){
			 if(newPartList[i].TECH_OrderedCounter__c != oldPartList[i].TECH_OrderedCounter__c){
                if(newPartList[i].originalPart__c!=null){
                    originalPartListIds.add(newPartList[i].originalPart__c);
                }
                else{
                    originalPartListIds.add(newPartList[i].id);
                }
            }

			if((newPartList[i].SelectedByBS__c != oldPartList[i].SelectedByBS__c) && /*22/07/2020 WCH C-003846 commented newPartList[i].SelectedByBS__c && */ newPartList[i].Type__c != null){
		       
              if(mapAssIdSetPartTypes.containsKey(newPartList[i].Assessment__c)){
					mapAssIdSetPartTypes.get(newPartList[i].Assessment__c).add(newPartList[i].Type__c);
				}
				else{
					mapAssIdSetPartTypes.put(newPartList[i].Assessment__c,new set<String>{newPartList[i].Type__c});
				}
			}
		}

		system.debug('##OriginalPartListIds '+OriginalPartListIds);
        if(OriginalPartListIds.size() > 0){
            AP38SetOrderedOnPartList.setOrdered(OriginalPartListIds);
        }

		if(/*22/07/2020 WCH C-003846 commented ASPISConstants.manualSourcingPO == true && */ mapAssIdSetPartTypes.size() > 0){
			setOrdered(mapAssIdSetPartTypes);
		}	
	}
	//14-JUL-2017  DUN case 001966,22-JUL-2020  WCH case C-003846
	public static void setOrdered(map<Id,Set<String>> mapAssIdSetPartListTypes){
		system.debug('## Start setOrdered');
		list<Assessment__c> listAssessmentToUpdate = new list<Assessment__c>();
        Map<Id,Set<String>> mapAssToPartListTypes = new Map<Id,Set<String>>();

         //~~ KPA 20/08/2020 C-003898
        Set<ID> keys = mapAssIdSetPartListTypes.keySet();
   //~~ KPA 21/09/2020 C-003947
        String query='Select Id, Type__c,Assessment__c from PartList__c where SelectedByBS__c=true and isDeleted__c=false and Type__c!=null and Type__c!=\'\' and  RecordType.name<>\'Labour\' and Price__c >0 and Quantity__c >0  and Assessment__c in: keys and PartNumber__c NOT IN('+System.Label.FakeReferences+')';

     
        // List<PartList__c> lstPartlists = [Select Id, Type__c,Assessment__c from PartList__c where SelectedByBS__c=true and isDeleted__c=false and Type__c!=null and Type__c!='' and Assessment__c in: mapAssIdSetPartListTypes.keySet()];
        List<PartList__c> lstPartlists =Database.query(query);
        for(PartList__c currentPartList : lstPartlists){
            if(!mapAssToPartListTypes.containsKey(currentPartList.Assessment__c)){
                mapAssToPartListTypes.put(currentPartList.Assessment__c,new Set<String>{currentPartList.Type__c});
            }else{
                mapAssToPartListTypes.get(currentPartList.Assessment__c).add(currentPartList.Type__c);
            }
        }
        for(Id currentAss : mapAssToPartListTypes.keySet()){
            listAssessmentToUpdate.add(new Assessment__c(Id = currentAss, SelectedByBSPartTypes__c = (String.join((Iterable<String>)mapAssToPartListTypes.get(currentAss), ';'))));
        }

        if(listAssessmentToUpdate.size() > 0){
        	update listAssessmentToUpdate;
        }
		system.debug('## End setOrdered');
    }
}