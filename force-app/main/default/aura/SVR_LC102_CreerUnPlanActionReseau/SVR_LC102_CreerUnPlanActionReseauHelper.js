({
    messageSuccess : function(component, id) {

        var url = '/lightning/r/Audit_Plan_Action__c/' + id + '/view';
        window.location.href = url;

        var type = '';
        if(component.get("v.isCM")==true){
            type = 'Plan d\'action coût moyen';
        }else  if(component.get("v.isCM")==false){
            type = 'Plan d\'action qualité';
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
        var action = component.get("c.getPlanActionRecordTypeIdRS");
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

    checkRecordTypeName : function (component) {
        var action = component.get("c.getPlanActionRecordTypeNameRS");
        action.setParams({
            Id :component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var value = response.getReturnValue();
                if(value==='CM'){
                    component.set("v.isCM", true);
                }
            }
        });
        $A.enqueueAction(action);
    },

    getResponsableSecteur : function (component) {
        var action = component.get("c.retrieveResponsableSecteur");
        action.setParams({
            Id :component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var value = response.getReturnValue();
                component.set("v.responsableSecteur", value);
                console.log('###### Nom du gestionnaire: ' + component.get("v.responsableSecteur"));
            }
        });
        $A.enqueueAction(action);
    }
})