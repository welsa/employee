({
    checkInitialisationPA : function(component){
        var pndTarget = component.find('slds-modal__container');

        component.set("v.isOpen", false);
        var action = component.get("c.cloneAuditParent");
        
        // isExecuted
        action.setParams({
            auditId :component.get("v.recordId"),
            type : 'TEST'
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var value = response.getReturnValue();

                if(value.errorType==='NoPA' ){
                    
                    $A.get("e.force:closeQuickAction").fire();
                    component.set("v.isOpen", false);
                    $A.get("e.force:showToast").setParams({
                        mode: 'dismissible',
                        type: 'error',
                        message: $A.get("$Label.c.SVR_PasPASurAuditParent"),
                        messageTemplate: $A.get("$Label.c.SVR_PasPASurAuditParent"),
                        duration:' 10000'
                    }).fire();
                }else if(value.errorType==='Closed' ){
                    
                    $A.get("e.force:closeQuickAction").fire();
                    component.set("v.isOpen", false);
                    $A.get("e.force:showToast").setParams({
                        mode: 'dismissible',
                        type: 'error',
                        message: $A.get("$Label.c.SVR_AuditClosed"),
                        messageTemplate: $A.get("$Label.c.SVR_AuditClosed"),
                        duration:' 10000'
                    }).fire();
                }else if(value.errorType==='HasPE' ){
                    
                    $A.get("e.force:closeQuickAction").fire();
                    component.set("v.isOpen", false);
                    $A.get("e.force:showToast").setParams({
                        mode: 'dismissible',
                        type: 'error',
                        message: $A.get("$Label.c.SVR_ErreurCreationPE"),
                        messageTemplate: $A.get("$Label.c.SVR_ErreurCreationPE"),
                        duration:' 10000'
                    }).fire();
                }else{
                    component.set("v.isOpen", true);
                    $A.util.addClass(pndTarget, 'slds-show');
                    $A.util.removeClass(pndTarget, 'slds-hide');
                }
            }
        });
        $A.enqueueAction(action);
    },

    cloneAudit : function(component) {
        var action = component.get("c.cloneAuditParent");

        action.setParams({
            auditId :component.get("v.recordId"),
            type : 'NOTTEST'
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var value = response.getReturnValue();
                // component.set('v.isSuccess', true);
                console.log('##### jpi: ' + value.id);
                console.log('##### jpi: ' + value.errorType); 
                if(value.id!=undefined && value.errorType==='NONE'){
                    var url = '/lightning/r/SVR_AuditReseau__c/' + value.id + '/view';
                    window.location.href = url;
                

                    var urlsaleforce = window.location.hostname;
                    $A.get("e.force:showToast").setParams({
                        mode: 'dismissible',
                        type: 'success',
                        message: $A.get("$Label.c.SVR_SuccesPointEtapeCree"),
                        messageTemplate: $A.get("$Label.c.SVR_SuccesPointEtapeCree"),
                        messageTemplateData: [
                            {
                                url: urlsaleforce + '/lightning/r/SVR_AuditReseau__c/' + value.id + '/view',
                                label: value.Name 
                            }
                        ],
                        duration:' 10000'
                    }).fire();
                    component.set("v.isExecuted", true);
                }else if(value.errorType==='NoPA'){
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get("e.force:showToast").setParams({
                        mode: 'dismissible',
                        type: 'error',
                        message: $A.get("$Label.c.SVR_PasPASurAuditParent"),
                        messageTemplate: $A.get("$Label.c.SVR_PasPASurAuditParent"),
                        messageTemplateData: [
                            {
                                url: urlsaleforce + '/lightning/r/Audit_Plan_Action__c/' + value.id + '/view',
                                label: value.Name 
                            }
                        ],
                        duration:' 10000'
                    }).fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})