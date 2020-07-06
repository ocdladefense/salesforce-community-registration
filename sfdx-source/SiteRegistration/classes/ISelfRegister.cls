global interface ISelfRegister {
    
    void Init(Map<String,Object> params);
    
    Boolean RunBefore();
    
    Boolean RunAfter();
	
    Map<String,Object> BeforeRegister();
    
    void AfterRegister();
}