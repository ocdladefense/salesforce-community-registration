/**
 * Alternative to the standard Salesforce selfRegistration controller.
 * 
 * Imagine the Registration process as consisting of a set of "before-registration" and "after-registration" actions
 *  that can take additional steps depending on the value of params (the registration parameters);
 *   Before and after classes can also modify the parameters and affect the behavior of subsequent execution.
 */
global class ClickpdxRegisterController {
    
    
    // Default (empty) constructor.
    public ClickpdxRegisterController() {}
    

    @AuraEnabled
    public static String selfRegister(String firstname, String lastname, String email, String accountId, String accountName, String title,
                                      Boolean includePassword, String password, String confirmPassword, String regConfirmUrl,
                                      String extraFields, String startUrl, String registrationClasses, Boolean updateNewContactInfo,
                                      Boolean createAccountFromAccountName, Boolean didSelectAccount, Boolean requireAccountName, String regIsExistingUserUrl) 
    {
        
        // Prepare a database transaction to update/create the User.
        Savepoint sp;
        
        // User object to be populated/inserted as necessary.
        User u;
        
        // UserId for any existing User or new User.
        Id userId;
        
        // AccountId to be associated with any created User.
        Id theAccountId = null;
        
        // Registration helpers are classes implementing the ISelfRegistration
        //  interface. Use the standard one by default to enforce sanity values,
        //    matching passwords, etc.
        String[] registrationHelpers = new String[]{'StandardUserRegistration'};
              
		// Once successfully registered send them on the way.
        ApexPages.PageReference theRedirect;
        
        
        // Environment variables.
        //   These are passed to the before and after registration helpers;
        //    In turn, the helpers can update the values.
        Map<String,Object> params = new Map<String,Object>{
            'userId' => null,
            'accountId' => accountId, 
            'isExistingUser' => false,
            'firstname' => firstname,
            'lastname' => lastname,
            'email' => email,
            'accountName' => accountName,
            'title' => title,
            'includePassword' => includePassword,
            'password' => password,
            'confirmPassword' => confirmPassword,
            'regConfirmUrl' => regConfirmUrl,
            'extraFields' => extraFields,
            'startUrl' => startUrl,
            'updateNewContactInfo' => updateNewContactInfo,
            'createAccountFromAccountName' => createAccountFromAccountName,
            'didSelectAccount' => didSelectAccount,
            'requireAccountName' => requireAccountName
        };
                    

        // Use other helpers defined for this instance of the component. 
        //  Different instances of this component can specify different helpers,
        //    depending on the use-case.     
        if(String.isNotBlank(registrationClasses)) {
            String[] tmp = registrationClasses.split(',');
            registrationHelpers.addAll(tmp);
        }
        
        
        
        try {
            
            sp = Database.setSavepoint();
            
            // Actions to run *before the User, Account and Contact have been assigned.
            RunActions('before', registrationHelpers, params);
            
            // Will return false if no helpers are modifying params['userId'].
            // Don't hold existing users hostage; send them a password reset email and
            //   redirect accordingly.
            if(IsExistingUser(params)) {
                
                params.put('isExistingUser', True);
                Site.forgotPassword(email);
                theRedirect = new PageReference(regIsExistingUserUrl);
                
            } else {

                u = CreateUser(params);

                
                if (includePassword) {    
                    validatePassword(u, password, confirmPassword);
                }
                
                // Give ISelfRegister classes one final chance to update the accountId to be associated with any new Contact/User.
                //  Otherwise the default Salesforce behavior is enforced.  
                //  NOTE: if neither a default Account nor Person accounts are enabled the default Salesforce behavior is to throw a very
                //   generic error message.
		        theAccountId = (String)params.get('accountId');
                
                // Consult params['contactId'] to see if we're dealing with an existing Contact.
                // Code here prevents duplicate Contacts with the same email from being inserted into the database.
                //  (We want to avoid these kinds of duplicates.)
                u.ContactId = null != params.get('contactId') ? (String)params.get('contactId') : null;

                // Standard Salesforce call.
                userId = Site.createPortalUser(u, theAccountId, password);
                params.put('userId',userId);

                theRedirect = password != null && password.length() > 1 ? Site.login(email, password, startUrl) : new PageReference(regConfirmUrl); 
            }

            // Actions to run *after the User, Account and Contact have been assigned.
            //  Do this before we navigate away.
            RunActions('after', registrationHelpers, params);
            
            
            // Bye.
            if(!Test.isRunningTest() && theRedirect != null) {
                aura.redirect(theRedirect);
            }
            
        } catch (Exception ex) {
            Database.rollback(sp);
            return ex.getMessage();            
        }
        
        
        return null;
    }
    
    
	/**
	 * Some custom classes implementing the ISelfRegister interface
	 *   can update the userId param, essentially notifying the controller
	 *   that this user already exists.  
	 *   Otherwise this will return False.
	 */
    public static Boolean IsExistingUser(Map<String,Object> params){
        return null != params.get('userId');
    }
    
    
    // Default Salesforce functionality.
    public static User CreateUser(Map<String,Object> params){
        String lastname = (String)params.get('lastname');
        String firstname = (String)params.get('firstname');
        String title = (String)params.get('title');
        String extraFields = (String)params.get('extraFields');
        String userId = (String)params.get('userId');
        String accountId = (String)params.get('accountId');
        String password = (String)params.get('password');
        String email = (String)params.get('email');
        String startUrl = (String)params.get('startUrl');
        String regConfirmUrl = (String)params.get('regConfirmUrl');
        Boolean includePassword = (Boolean)params.get('includePassword');
        String confirmPassword = (String)params.get('confirmPassword');
        
        User u = new User();
        u.Username = (String)params.get('email');
        u.put('Email',(String)params.get('email'));
        u.FirstName = firstname;
        u.LastName = lastname;
        u.Title = title;
        
        
        
        String networkId = Network.getNetworkId();
        
        // If using site to host the community the user should not hit s1 after logging in from mobile.
        if(networkId != null && siteAsContainerEnabled(Network.getLoginUrl(networkId))) {
            u.put('UserPreferencesHideS1BrowserUI',true);
        }
        
        String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0,1) : '' ) + lastname.substring(0,1);
        nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
        u.put('CommunityNickname', nickname);
        
        if (extraFields != null) {
            List<Object> extraFieldsList = (List<Object>) JSON.deserializeUntyped(extraFields);        
            for (Object thisFieldObject : extraFieldsList) {
                Map<String,Object> thisField = (Map<String,Object>) thisFieldObject;
                Schema.SObjectField sof = Schema.SObjectType.User.fields.getMap().get((String) thisField.get('fieldPath'));
                u.put(sof, thisField.get('value'));
            }
        }

        
		return u;
    }
    
    
    
    // Reflection;
    //   runs before and after classes, passing along params to each instance.
    public static void RunActions(String actionType, String[] classes, Map<String,Object> params) {

        for(String className : classes) {
            Type t = Type.forName(className);
            
            if(t == null) {
                throw new RegisterException('CLASS_NOT_FOUND_ERROR: No matching type for ' + className);
            }
            
            ISelfRegister action = (ISelfRegister) t.newInstance();
            action.Init(params);

            if(actionType == 'before' && action.RunBefore()) {
                
                Map<String,Object> data = action.BeforeRegister();
                
                if(data != null) {
                    params.putAll(data);
                }
            }

            if(actionType == 'after' && action.RunAfter()) {
                
                action.AfterRegister();
            }
            
        }
    }
    
    
    
    
    
    @AuraEnabled
    public static List<Map<String,Object>> getExtraFields(String extraFieldsFieldSet) { 
        List<Map<String,Object>> extraFields = new List<Map<String,Object>>();
        Schema.FieldSet fieldSet = Schema.SObjectType.User.fieldSets.getMap().get(extraFieldsFieldSet);
        if(!Test.isRunningTest()) {
            if (fieldSet != null) {
                for (Schema.FieldSetMember f : fieldSet.getFields()) {
                    Map<String, Object> fieldDetail = new Map<String, Object>();
                    fieldDetail.put('dbRequired', f.getDBRequired());
                    fieldDetail.put('fieldPath', f.getFieldPath());
                    fieldDetail.put('label', f.getLabel());
                    fieldDetail.put('required', f.getRequired());
                    fieldDetail.put('type', f.getType());
                    fieldDetail.put('value', '');   // client will populate
                    extraFields.add(fieldDetail);
                }}}
        return extraFields;
    }
    
    
    @TestVisible 
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    
    @TestVisible 
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
            Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }
    
    
    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);   
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }        
    }  
    
    public class RegisterException extends Exception{}
}