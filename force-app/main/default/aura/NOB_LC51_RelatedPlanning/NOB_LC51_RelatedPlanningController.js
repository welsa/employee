/**
 * @description       : 
 * @author            : GBH
 * @group             : 
 * @last modified on  : 10-28-2020
 * @last modified by  : GBH
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   10-28-2020   GBH   Initial Version
**/
({
    doInit: function (component, event, helper) {
    
        var view = component.get("v.displayFormat");
        if (view == 'Disponibilité'){
            component.set('v.title',"Disponibilités");
            component.set('v.recordType',"Planning Prefikar");
            component.set('v.status',"Disponible");
            component.set('v.iconColor',"icon_dispo");

        } else if (view == 'Absences'){
            component.set('v.title',"Absences");
            component.set('v.recordType',"Planning Prefikar");
            component.set('v.status',"Absence");
            component.set('v.iconColor',"icon_absence");

        } else if (view == 'RDV hors Prefikar'){
            component.set('v.title',"RDV hors Prefikar");
            component.set('v.recordType',"Planning Hors Prefikar");
            component.set('v.status',"Réservé");
            component.set('v.iconColor',"icon_rdvHorsPrefikar");

        }
        var action = component.get("c.getPlannings");
        action.setParams({
            AccountId: component.get("v.recordId"),
            Status: component.get("v.status"),
            recordType: component.get("v.recordType")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstPlannings", response.getReturnValue());
                if (response.getReturnValue().length > 3) {
                    component.set("v.showFooter", true);
                }
            }
            else if (state === "ERROR") {
                console.log('A problem occurred: ' + JSON.stringify(response.error));
            }
        });

        $A.enqueueAction(action);

        //Get record type ID
        var getRecordTypeIdAction = component.get("c.getRecordTypeId");
        getRecordTypeIdAction.setParams({
            recordType: component.get("v.recordType")
        });
        getRecordTypeIdAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.recordTypeId", response.getReturnValue());
            }
            else if (state === "ERROR") {
                console.log('A problem occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(getRecordTypeIdAction);

        //show/hide new button
        var checkProfileRightsAction = component.get("c.checkProfileRights");
        checkProfileRightsAction.setParams({

        });
        checkProfileRightsAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showNewButton", response.getReturnValue());
                console.log(response.getReturnValue());
            }
            else if (state === "ERROR") {
                console.log('A problem occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(checkProfileRightsAction);
    },

    openModel: function (component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },

    closeModel: function (component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },

    createPlanning : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var recordtypeid = component.get("v.recordTypeId");
        var status = component.get("v.status");
        var AccountId = component.get("v.recordId")
        console.log(recordtypeid);
        createRecordEvent.setParams({
            "entityApiName": "NOB_Planning__c",
            "recordTypeId": recordtypeid,
            "defaultFieldValues": {
                'NOB_Status__c' : status,
                'NOB_BodyShop__c' : AccountId
            }
        });
        createRecordEvent.fire();
    }
})