({
    messageSuccess : function(component, id) {

        var url = '/lightning/r/Audit_Plan_Action__c/' + id + '/view';
        window.location.href = url;

        var type = '';
        if(component.get("v.isAdmin")==true){
            type = 'Plan d\'action Opérationnel - BO Admin';
        }else  if(component.get("v.isFactu")==true){
            type = 'Plan d\'action Opérationnel - BO Factu';
        }else  if(component.get("v.isQualite")==true){
            type = 'Plan d\'action Opérationnel - Qualité';
        }else  if(component.get("v.isGroChoc")==true){
            type = 'Plan d\'action opérationnel - Gros chocs';
        }else  if(component.get("v.isAppel")==true){
            type = 'Plan d\'action opérationnel - FO Appel';
        }

        var urlsaleforce = window.location.hostname;
        $A.get("e.force:showToast").setParams({
            mode: 'dismissible',
            type: 'success',
            message: type + ' a été crée.',
            messageTemplate: type + ' a été crée.',
            messageTemplateData: [
                {
                    url: urlsaleforce + '/lightning/r/Audit_Plan_Action__c/' + id + '/view'
                }
            ],
            duration:' 10000'
        }).fire();
    },

    assignRecordTypeId : function (component) {
        var action = component.get("c.getPlanActionRecordTypeIdOP");
        action.setParams({
            Id :component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var value = response.getReturnValue();
                component.set("v.recordTypeId", value);
                console.log('###### id: ' + component.get("v.recordTypeId"));
            }
        });
        $A.enqueueAction(action);
    },

    getNomDuGestionnaire : function (component) {
        var action = component.get("c.retrieveNomDuGestionnaire");
        action.setParams({
            Id :component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var value = response.getReturnValue();
                component.set("v.nomDuGestionnaire", value);
                console.log('###### Nom du gestionnaire: ' + component.get("v.nomDuGestionnaire"));
            }
        });
        $A.enqueueAction(action);
    },

    checkRecordTypeName : function (component) {
        var action = component.get("c.getPlanActionRecordTypeNameOP");
        action.setParams({
            Id :component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var value = response.getReturnValue();
                if(value==='Admin'){
                    component.set("v.isAdmin", true);
                }
                if(value==='Factu'){
                    component.set("v.isFactu", true);
                }
                if(value==='GrosChoc'){
                    component.set("v.isGroChoc", true);
                }
                if(value==='Appel'){
                    component.set("v.isAppel", true);
                }
                if(value==='Qualite'){
                    component.set("v.isQualite", true);
                }
            }
        });
        $A.enqueueAction(action);
    }
})