/**
 * Perform custom actions either 
 *   before or after registration.
 * 
 *  Here we are updating some fields on the User object.
 */
public without sharing class CustomUser implements ISelfRegister {
	
    
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
    

    // Optionally, make any other updates to the User object; either existing or new.
    public void AfterRegister() {
        Id userId = (Id)this.params.get('userId');

        UpdateUser(userId);
    }
    
    
	/**
	 * Check to see if the username/email the customer has submitted
	 *   already matches an existing *User in Salesforce.
	 *   If so update params accordingly.
	 */
    public Map<String,Object> BeforeRegister() {
        
		String email = (String)this.params.get('email');
        Id userId = getExistingUser(email);

        return new Map<String,Object>{'userId' => userId};
    }
    
    private void UpdateUser(Id userId){
        User u = new User(Id = userId, Title = (String)this.params.get('title'));
        update u;
    }
    

    private static String getExistingUser(String email){
        List<User> users = [SELECT Id FROM User WHERE Username = :email AND IsActive = True];
        
        return null != users && users.size() > 0 ? users[0].Id : null;
    }
    
    public static Boolean IsExistingUser(Id userId){
        return null != userId;
    }
    

}