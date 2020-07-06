public without sharing class customLookUpController{
    @AuraEnabled
    public static List<SObject> fetchLookUpValues(String searchKeyword, String ObjectName, Integer SObjectRecordLimit) {
        system.debug('ObjectName-->' + ObjectName);

		Integer theLimit = 5;
        
        List<SObject> returnList = new List <SObject>();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5  
        Object[] params = new Object[]{ObjectName,searchKeyword,SObjectRecordLimit}; 
        String format =  'SELECT Id, Name FROM {0} WHERE Name LIKE \'\'%{1}%\'\' ORDER BY Name LIMIT {2}';
        String theQuery = String.format(format,params);
        
        List<SObject> lstOfRecords = Database.query(theQuery);
        
        for(SObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        
        return returnList;
    }
}