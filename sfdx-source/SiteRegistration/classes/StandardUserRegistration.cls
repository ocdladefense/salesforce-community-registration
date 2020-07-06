/**
 * Perform standard validation on Self Registration data.
 * 
 * Thrown exceptions will pass error messages back to the component.
 */
public without sharing class StandardUserRegistration implements ISelfRegister {
	
    
    Map<String,Object> params;
    
    
    
    public void Init(Map<String,Object> params) {
        this.params = params;
    }
    
    
    public Boolean RunBefore() {
        return True;
    }
    
    
    public Boolean RunAfter() {
        return False;
    }
    

    public void AfterRegister(){}
    
    
	/**
	 * Check to see if the username/email the customer has submitted
	 *   already matches an existing *User in Salesforce.
	 */
    public Map<String,Object> BeforeRegister() {
        Validate();

        return null;
    }
    

    
    private void Validate(){
        String lastname = (String)params.get('lastname');
        String firstname = (String)params.get('firstname');
        String email = (String)params.get('email');
        String accountName = (String)params.get('accountName');
        Boolean includePassword = (Boolean)params.get('includePassword');
        String password = (String)params.get('password');
        String confirmPassword = (String)params.get('confirmPassword');
        Boolean requireAccountName = (Boolean)params.get('requireAccountName');
        
        
        if (lastname == null || String.isEmpty(lastname)) {
            throw new RegistrationException(Label.Site.lastname_is_required);
        }
        
        if (email == null || String.isEmpty(email)) {
            throw new RegistrationException(Label.Site.email_is_required);
        }
        
        if ((accountName == null || String.isEmpty(accountName)) && requireAccountName) {
            throw new RegistrationException('Account Name is required');
        }
        
        if (includePassword) {    
            
            if (!isValidPassword(password, confirmPassword)) {
                
                throw new RegistrationException(Label.site.passwords_dont_match);
            }
        } else {
            
            password = null;
        }
    }
    
    @TestVisible 
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }

}