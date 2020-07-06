public class CustomAccount implements ISelfRegister {
    
    public Map<String,Object> params;
    
    public void Init(Map<String,Object> params) {
        this.params = params;
    }
    
    public Boolean RunBefore() {
        
        Boolean shouldRun = (Boolean) this.params.get('createAccountFromAccountName');
        
        return shouldRun;
    }
    
    
    public Boolean RunAfter() {
         return !(Boolean)this.params.get('isExistingUser');
    }
    
    public String CreateAccount(String accountName) {
        Account a = new Account();
        a.Name = accountName;
        insert a;
        
        return a.Id;
    } 
    

    
    //(String firstname ,String lastname, String email, String password, String confirmPassword, String accountId, String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword)
    public Map<String,Object> BeforeRegister() 
    {
        String accountName = (String) this.params.get('accountName');
        String accountId = (String) this.params.get('accountId');
        accountId = accountName == null || String.isEmpty(accountName) ? accountId : CreateAccount(accountName);
        
        return new Map<String,Object>{'accountId' => accountId}; 
    }
    
    public void AfterRegister() {
        
    }
}