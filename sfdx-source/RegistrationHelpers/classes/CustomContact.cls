public without sharing class CustomContact implements ISelfRegister {
    
    Map<String,Object> params;
    
    public void Init(Map<String,Object> params) {
        this.params = params;
    }
    
    public Boolean RunBefore() {
        return True;
    }
    
    // Only run the After Register method if updateNewContactInfo is true and it is not an existing user registering
    public Boolean RunAfter() {
        Boolean shouldUpdateContact = (Boolean)this.params.get('updateNewContactInfo');
        if((Boolean)this.params.get('isExistingUser')){
            return False;
        } else {
            return null != shouldUpdateContact && shouldUpdateContact;   
        }
    }
    
    
    
    
    /**
    * Check to see if the username/email the customer has submitted
    *   already matches an existing *Contact in Salesforce.
    *   If it does then we will associate any new User record with the already existing Contact.
    *   Otherwise, if we always create a new Contact we get duplicates.
    */
    public Map<String,Object> BeforeRegister() {
        String email = (String)this.params.get('email');
        Id contactId = getExistingContact(email);
        
     
        return new Map<String,Object>{'contactId' => contactId};
    }
    
    
    
	// Let's update any ad-hoc fields after the fact.
    public void AfterRegister() 
    {
        String email = (String) this.params.get('email');
        String title = (String) this.params.get('title');
        
        // 1. Scenario 1: Enabled "person accounts" -- Id of the newly created Person Account from step 1.
        // 2. Scenario 2: System Administrator (you) has selected a "default" account for all new community users (for this community)
        //   Id is the Id of the "default" account.
        // 3. Scenario 3: The customer has selected an existing Account.
        //   Id is the Id of the Account the customer selected as part of the self-registration form.
        String accountId = (String) this.params.get('accountId');
        String accountName = (String) this.params.get('accountName');
        
        Id ContactId = getExistingContact(email);
        
        Contact c = new Contact( Id = ContactId, Title = title);
                
        // Either put the selected account name OR whatever the user typed into the "Account Name" input box
        c.put('Address_Name__c',accountName);
        
        if((Boolean) this.params.get('didSelectAccount')) {
            c.AccountId = accountId;
        }
        
        update c;
    }
    
    

    public static Boolean IsExistingContact(Id contactId){
        return null != contactId;
    }
    
    private static String getExistingContact(String email){
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :email];
        
        return null != contacts && contacts.size() > 0 ? contacts[0].Id : null;
    }
    
    
    
    public class SelfRegisterException extends Exception {}
}