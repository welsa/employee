({
	
    init: function(component, event, helper) {
    	console.log('init');
    	helper.getBrandsValues(component, event, helper);

    },


	checkLength : function(component, event, helper) {
		component.set("v.oemLimit",null);
		component.set("v.error",false);
		component.set("v.displayButton",false);
		var oem = component.get("v.oemVal").length;
		console.log('OEM Length: ',oem);
		console.log('OEM : ',component.get("v.oemVal"));

		var lstOEM = component.get("v.oemVal").split(';');
		console.log(lstOEM);

		console.log('List OEM: ',lstOEM);
		console.log('List OEM size: ',lstOEM.length);

		if(lstOEM.length >150){
			component.set("v.oemLimit",component.get("v.oemVal").length);
                    console.log("## Limit reached ");   
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "error",
                        "title": $A.get("$Label.c.ErrorJS"),
                        "message":$A.get("$Label.c.Limit_Reached"),
                        "mode" : "sticky"
                    });
                    toastEvent.fire();  
			component.set("v.error",true);
			component.set("v.displayButton",true);
		}
	},
	manageDisplay : function(component, event, helper) {

		console.log('manageDisplay');
        var isShow = component.get("v.showTable");
        if(isShow){
            component.set("v.showTable", false);
        }else{
            component.set("v.showTable", true);
        }
	},
	showResult : function(component, event, helper) {
		 var selectedOptionValue = component.get("v.Brand");
        if( (selectedOptionValue == null ||  selectedOptionValue == 'None' || selectedOptionValue == undefined) || (component.get("v.oemVal").length==0)) {
                    console.log("## Field(s) Empty ");   
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "error",
                        "title": $A.get("$Label.c.ErrorJS"),
                        "message": $A.get("$Label.c.FillInBrand"),
                        "mode" : "sticky"
                    });
                    toastEvent.fire();     
        }else{
        	component.set("v.showResults", true);
        	helper.getOEMs(component, event, helper);
        }
	},
	hideResult : function(component, event, helper) {
        component.set("v.showResults", false);
	},
	chnageResult : function(component, event, helper) {
		
		component.set("v.showResults", false);
        component.set("v.oemVal", '');
        var brand = component.find("brandSelect").get("v.value");
        console.log("## selectOpt : ",brand);   
        component.find("brandSelect").set("v.value","None");
	},
    handleChangeBrand: function (component, event) {
        component.set("v.displayButton",false);
        //var selectedOptionValue = event.getParam("value");
        var brand = component.find("brandSelect").get("v.value");
        var brandNameLabel = brand.split(';');
        component.set("v.Brand", brandNameLabel[0]);
        component.set("v.BrandLabel", brandNameLabel[1]);
        console.log('selectedbrand :', brandNameLabel[0]);
        console.log('selectedbrandLabel :', brandNameLabel[1]);


    },
	// ## function call on Click on the "Download As CSV" Button. 
    downloadCsv : function(component,event,helper){
        helper.checkBrowser(component);
        //retrieve csv Values
       //get the Records list from 'OEMs' attribute 
        var stockData = JSON.parse(JSON.stringify(component.get("v.csvValues")));
        console.log('stockData:',stockData);
        console.log('isIE?:',component.get("v.isIE"));
      if( component.get("v.isIE")==false) {
         //////NOT Internet Explorer////////////////
         // call the helper function which "return" the CSV data as a String   
            var csv = helper.convertArrayOfObjectsToCSV(component,stockData);   
             if (csv == null){return;} 
            
            var today = new Date();
            var date  = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
            var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();

            // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
           var hiddenElement = document.createElement('a');
              hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
              hiddenElement.target = '_self'; // 
              hiddenElement.download = 'CrossReferences_' +date + '_' + time +'.csv';  // CSV file Name* you can change it.[only name not .csv] 
              document.body.appendChild(hiddenElement); // Required for FireFox browser
            hiddenElement.click(); // using click() js function to download csv file

      }else{
          
       /////Internet Explorer////////////////////

          var today = new Date();
          var date  = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
          var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
          var fileName = 'CrossReferences_' +date + '_' + time +'.csv';

        var csv = helper.convertArrayOfObjectsToCSV(component,stockData);              
        var blob = new Blob([csv],{type: "text/csv;charset=utf-8;"});
        if (navigator.msSaveBlob) { // IE 10+
          navigator.msSaveBlob(blob, fileName)
        }
        
          // var stockData = JSON.parse(JSON.stringify(component.get("v.csvValues")));
          // console.log('stockData:',stockData);

          // alasql('SELECT * INTO CSV("' + fileName + '",{headers:true}) FROM ?', [stockData]);
      }
    
    },
})