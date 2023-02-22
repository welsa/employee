({
    clonePlanAction : function(component) {
        var action = component.get("c.reprendrePlanAction");

        action.setParams({
            Id :component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var value = response.getReturnValue();
                console.log('### value: ' + value.id);
                var urlsaleforce = window.location.hostname;
                if(value.id!=undefined && value.errorType==='NONE'){
                    $A.get("e.force:showToast").setParams({
                        mode: 'dismissible',
                        type: 'success',
                        message: $A.get("$Label.c.SVR_SuccesPlanActionCree"),
                        messageTemplate: $A.get("$Label.c.SVR_SuccesPlanActionCree"),
                        messageTemplateData: [
                            {
                                url: urlsaleforce + '/lightning/r/Audit_Plan_Action__c/' + value.id + '/view',
                                label: value.Name 
                            }
                        ],
                        duration:' 5000'
                    }).fire();

                    var url = '/lightning/r/Audit_Plan_Action__c/' + value.id + '/view';
                    window.location.href = url;

                }else if(value.errorType === 'NoPA'){
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get("e.force:showToast").setParams({
                        mode: 'dismissible',
                        type: 'error',
                        message: $A.get("$Label.c.SVR_PasPASurAuditRecent"),
                        messageTemplate: $A.get("$Label.c.SVR_PasPASurAuditRecent"),
                        messageTemplateData: [
                            {
                                url: urlsaleforce + '/lightning/r/Audit_Plan_Action__c/' + value.id + '/view',
                                label: value.Name 
                            }
                        ],
                        duration:' 5000'
                    }).fire();

                }else if(value.errorType === 'PAEXIST'){
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get("e.force:showToast").setParams({
                        mode: 'dismissible',
                        type: 'error',
                        message: $A.get("$Label.c.SVR_PAExsitDejaSurPointEtape"),
                        messageTemplate: $A.get("$Label.c.SVR_PAExsitDejaSurPointEtape"),
                        messageTemplateData: [
                            {
                                url: urlsaleforce + '/lightning/r/Audit_Plan_Action__c/' + value.id + '/view',
                                label: value.Name 
                            }
                        ],
                        duration:' 5000'
                    }).fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})