/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_AP50_ObjectifsReparateur
  -- - Author        : DUN
  -- - Description   : Class to perform ranking of bodyshop
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 20-AUG-2020    DUN     1.0     Initial version
  -- 03-NOV-2020    ASE     1.0     RSIW-2868: Alignement des notes de critère du rule engine
  **********************************************************************
*/
public without sharing class NOB_AP50_ObjectifsReparateur {
	
	public static List<Account> getSortedReparateur(List<Account> listReparateur, List<NOB_Objective__c> listObjectifs){
		System.debug('## Start NOB_AP50_SelectionReparateur.getSortedReparateur');
		Map<Double,Account> mapScoreAccount = new Map<Double,Account>();
		map<String,NOB_ObjectifsValues__c> objectifCSValues = NOB_ObjectifsValues__c.getAll();
		system.debug('## objectifCSValues '+ objectifCSValues);

		for(Account reparateur : listReparateur){
			mapScoreAccount.put(getReparateurScore(reparateur, listObjectifs, objectifCSValues),reparateur);
		}
		system.debug('## mapScoreAccount '+ mapScoreAccount);
		system.debug('## listSorted '+ getSortedList(mapScoreAccount));
		return getSortedList(mapScoreAccount);
	}

	public static list<Account> getSortedList(map<Double,Account> mapReparateur){
		System.debug('## Start NOB_AP50_SelectionReparateur.getSortedList');
		List<double> listScores = new List<double>();
		listScores.addAll(mapReparateur.keySet());
		List<Account> listSortedAccount = new List<Account>();
        //reverse ordering bigger value first
		for(Integer i = 0 ; i < listScores.size() ; i ++) {
			for(integer j = i+1 ; j <= listScores.size() -1 ; j ++ ){
				double val = 0 ;
				//if(listScores[i] >  listScores[j]){
				if(listScores[i] <  listScores[j]){
					val = listScores[i]  ;
					listScores[i] = listScores[j]  ;
					listScores[j]  = val;
					
				}
			}
		}
		System.debug('## listScores ' + listScores);
		for(double score : listScores){
			listSortedAccount.add(mapReparateur.get(score));
		}
		System.debug('## listSortedAccount ' + listSortedAccount);
		return listSortedAccount;
	}

	public static Double getReparateurScore(Account reparateur, List<NOB_Objective__c> listObjectifs, map<String,NOB_ObjectifsValues__c> objectifCSValues){
		System.debug('## Start NOB_AP50_SelectionReparateur.getReparateurScore');
		Double score = 0;
		for(NOB_Objective__c obj : listObjectifs){
			if(obj.NOB_ValueFrom__c == 'SOBJECT'){
				score += getObjectifScore(reparateur, obj, objectifCSValues);
			}
			else if(obj.NOB_ValueFrom__c == 'CHILD' && reparateur.getSObjects(obj.NOB_Object__c) != null && reparateur.getSObjects(obj.NOB_Object__c).size() > 0 ){
				score += getObjectifScore(reparateur.getSObjects(obj.NOB_Object__c)[0], obj, objectifCSValues);
			}
			else if(obj.NOB_ValueFrom__c == 'CHILD' && (reparateur.getSObjects(obj.NOB_Object__c) == null || reparateur.getSObjects(obj.NOB_Object__c).size() == 0) && obj.NOB_ValueType__c == 'DATE/TIME'){
				score += 1;
			}
		}
		System.debug('## reparateur' + reparateur.Name);
		System.debug('## score' + score);
		return score;
	}

	public static Double getObjectifScore(sObject sObj, NOB_Objective__c objectif, map<String,NOB_ObjectifsValues__c> objectifCSValues){
		System.debug('## Start NOB_AP50_SelectionReparateur.getObjectifScore');
		Double score, value = 0;

		if(objectif.NOB_ValueType__c == 'CUSTOM SETTING' && objectifCSValues.get(String.valueOf(sObj.get(objectif.NOB_Field__c))) != null){
			value = Double.valueOf(objectifCSValues.get(String.valueOf(sObj.get(objectif.NOB_Field__c))).Score__c);
		}
        //calculate value using limit (value/limit)*100
		else if(objectif.NOB_ValueType__c == 'DATE/TIME'){
			Datetime currentDateTime = datetime.now();
			value = ((Datetime.valueOf(sObj.get(objectif.NOB_Field__c)).getTime() - currentDateTime.getTime())/1000/60);
		}
        //calculate value using limit (value/limit)*100
		else{
			value = Double.valueOf(sObj.get(objectif.NOB_Field__c));
		}
		if(value == 0 || value == null){
			value = 1;
		}

		System.debug('## value before ' + value);
		Integer scorelimit = objectif.NOB_Limit__c !=null ? Integer.valueOf(objectif.NOB_Limit__c) : null;
		System.debug('## scorelimit ' + scorelimit);
		value = scorelimit != null ? (value / scorelimit) * 100 : value;
		System.debug('## value scorelimit' + value);

        //inverse min => max
		if(objectif.NOB_Function__c == 'MIN'){
			score = (100-value) * objectif.NOB_Weightage__c;
		}
		else if(objectif.NOB_Function__c == 'MAX'){
			score = value * objectif.NOB_Weightage__c;
		}
		System.debug('## objectif.NOB_Field__c' + objectif.NOB_Field__c + '## value' + value + '## scorelimit' + scorelimit + '## objectif.NOB_Weightage__c' + objectif.NOB_Weightage__c +'## score' + score );
		//System.debug('## value' + value);
		//System.debug('## scorelimit' + scorelimit);
		//System.debug('## objectif.NOB_Weightage__c' + objectif.NOB_Weightage__c);
		//System.debug('## score' + score);
		return score;
	}

}