({

    getOEMs: function(component, event, helper) {
    	component.set("v.showSmall",true);
    	console.log('init -- getOEMs');
        var action = component.get("c.getCrossRef");
        action.setParams({
            "brand": component.get("v.Brand"),
            "oem":component.get("v.oemVal")
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var OEMS = response.getReturnValue();

            	console.log('allOEMS:',OEMS);
                this.buildGrouping(component,OEMS.lstCrossRef,OEMS.setOEM,OEMS.userSubGain);

                    

            }component.set("v.showSmall",false);
        });
        $A.enqueueAction(action);
    },
    getBrandsValues: function(component, event, helper) {
    	console.log('init -- getBrandsValues');
    	component.set("v.showSmall",true);
    	console.log('init -- Fecth picklist values');
        var action = component.get("c.getBrands");
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                if (allValues != undefined && allValues.length > 0) {
                	console.log('allBrands:',allValues);
                    component.set("v.lstBrand",allValues);

                    
                }
            }component.set("v.showSmall",false);
        });
        $A.enqueueAction(action);
    },
	buildGrouping : function(component,oems,keys,userSubGain) {
		console.log("## starting method buildGrouping");		
		var groups = [];

		console.log("## oems",oems);	
    console.log("## groupLabel",keys);  

		for(var i = 0; i < keys.length ;i++){
			var group = [];
			group.label = keys[i];
			group.id = i;
			group.records = [];
			groups.push(group);

		}

		console.log("## groups",groups);
		for(i in oems){
			var obj = oems[i];
			var cf = {};
			cf.id = obj.Id;
			cf.Manu = (obj.hasOwnProperty("IAMManufacturer__c") ?obj.IAMManufacturer__c : null) ;
			cf.Part = (obj.hasOwnProperty("IAMPartNumber__c") ?obj.IAMPartNumber__c : null) ;
			cf.Desc = (obj.hasOwnProperty("IAMPartDescription__c") ?obj.IAMPartDescription__c : null) ;
			cf.Class = (obj.hasOwnProperty("IAMPartClass__c") ?obj.IAMPartClass__c : null) ;
			cf.Cert = (obj.hasOwnProperty("IAMCertifyingOrganization__c") ?obj.IAMCertifyingOrganization__c : null) ;
      cf.CleanOEMPartNum = (obj.hasOwnProperty("OEMCleanPartNumber__c") ?obj.OEMCleanPartNumber__c : null) ;

			cf.AsPublicPrice = (obj.hasOwnProperty("ASPublicPrice__c") ?obj.ASPublicPrice__c : null) ;
			cf.OEMPublicPrice = (obj.hasOwnProperty("OEMPublicPrice__c") ?obj.OEMPublicPrice__c : null) ;
			cf.Price = (userSubGain !=null ? cf.AsPublicPrice + (userSubGain/100) * (cf.OEMPublicPrice - cf.AsPublicPrice): cf.AsPublicPrice + (cf.OEMPublicPrice - cf.AsPublicPrice)) ;
			cf.Price = cf.Price.toFixed(2);


			//find which group, this cf correspond
			var index = groups.findIndex(function(g){				
				return g.label == obj.OEMCleanPartNumber__c;
			});
			if(index >= 0){
				groups[index].records.push(cf);				
			}
			else {
				console.log("## this Cross Ref do not belong to any group. Its group is ",obj.OEMCleanPartNumber__c);
			}
		}
		console.log("## groups",groups);	
		component.set("v.OEMs",groups);
		this.prepareCSVValues(component,groups);
	},
   convertArrayOfObjectsToCSV : function(component,objectRecords){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
       
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
 
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        keys = ['Brand','OEM','IAMManufacturer','IAMPartNumber','IAMDescription','Class','Certification','YourPrice' ];
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
               
               csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 
       
       // return the CSV formate String 
        return csvStringResult;        
    },
   prepareCSVValues : function(component,objectRecords){
   	console.log("## prepareCSVValues");
   	
   	var allLines = [];
	   	
    (objectRecords).forEach(function(record){
	

    	if(record.records.length >0){
	        record.records.forEach(function(r){
	       		var l= {};
		        l.Brand = component.get("v.Brand");
		        l.OEM = record.label;
		        l.IAMManufacturer = r.Manu;
		        l.IAMPartNumber = r.Part;
		        l.IAMDescription = r.Desc;
		        l.Class = r.Class;
		        l.Certification = r.Cert;
		        l.YourPrice = r.Price;
		        allLines.push(l);        
	        });	   	

    	}else{
    		var line= {};
	        line.Brand = component.get("v.Brand");
	        line.OEM = record.label;
	        line.IAMManufacturer = '';
	        line.IAMPartNumber = '';
	        line.IAMDescription = '';
	        line.Class = '';
	        line.Certification = '';
	        line.YourPrice = '';
	        allLines.push(line);
    	}
        
   });
    	console.log("## allLines:",allLines);
    	component.set("v.csvValues",allLines);
	      
    },
  checkBrowser: function (component) {

      var browserType = navigator.sayswho= (function(){
          var ua= navigator.userAgent, tem,
              M= ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
          if(/trident/i.test(M[1])){
              tem=  /\brv[ :]+(\d+)/g.exec(ua) || [];
              return 'IE '+(tem[1] || '');
          }
          if(M[1]=== 'Chrome'){
              tem= ua.match(/\b(OPR|Edge)\/(\d+)/);
              if(tem!= null) return tem.slice(1).join(' ').replace('OPR', 'Opera');
          }
          M= M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];
          if((tem= ua.match(/version\/(\d+)/i))!= null) M.splice(1, 1, tem[1]);
          return M.join(' ');
      })();
      if (browserType.startsWith("IE")) {
          component.set("v.isIE", true);
      }
  },
})