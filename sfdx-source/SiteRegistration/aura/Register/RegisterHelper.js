({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleSelfRegister: function (component, event, helpler) {
        //var accountId = component.get("v.accountId");
		var registrationClasses = component.get("v.registrationClasses");
        var firstname = component.find("firstname").get("v.value");
        var lastname = component.find("lastname").get("v.value");
        var email = component.find("email").get("v.value");
        var didSelectAccount = component.get("v.selectedAccount").Name != null;
        var accountId = null != component.get("v.selectedAccount").Id ? component.get("v.selectedAccount").Id : component.get("v.accountId");
        var accountName = component.get("v.selectedAccount").Name || component.get("v.accountSearchWord");
        var title = component.find("title").get("v.value");
        var includePassword = component.get("v.includePasswordField");
        var password = component.find("password").get("v.value");
        var confirmPassword = component.find("confirmPassword").get("v.value");
        var regConfirmUrl = component.get("v.regConfirmUrl");
        var regIsExistingUserUrl = component.get("v.regIsExistingUserUrl");
        var extraFields = JSON.stringify(component.get("v.extraFields"));   // somehow apex controllers refuse to deal with list of maps
        var startUrl = component.get("v.startUrl"); 
        var createAccountFromAccountName = component.get("v.createAccountFromAccountName");
        var updateNewContactInfo = component.get("v.updateNewContactInfo");
        var requireAccountName = component.get("v.requireAccountName");
        
        var action = component.get("c.selfRegister");
        
        startUrl = decodeURIComponent(startUrl);
        
        var params = {
            firstname:firstname,
            lastname:lastname,
            email:email,
            accountId:accountId,
            accountName:accountName,
            title:title,
            includePassword:includePassword,
            password:password,
            confirmPassword:confirmPassword,
            regConfirmUrl:regConfirmUrl,
            regIsExistingUserUrl:regIsExistingUserUrl,
            extraFields:extraFields,
            startUrl:startUrl,
            registrationClasses: registrationClasses,
            didSelectAccount:didSelectAccount,
            createAccountFromAccountName:createAccountFromAccountName,
            updateNewContactInfo:updateNewContactInfo,
            requireAccountName:requireAccountName
        };
        
        
        console.log(params);
        
        action.setParams(params);
          action.setCallback(this, function(a){
          var rtnValue = a.getReturnValue();
          if (rtnValue !== null) {
             component.set("v.errorMessage",rtnValue);
             component.set("v.showError",true);
          }
       });
    $A.enqueueAction(action);
    },
    
    getExtraFields : function (component, event, helpler) {
        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.extraFields',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    setBrandingCookie: function (component, event, helpler) {        
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    }    
})