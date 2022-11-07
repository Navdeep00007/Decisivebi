public with sharing class AccountController {

    @AuraEnabled(cacheable=true)
    public static parentRecord getAccountsAndOrders(String accountId) {
    //public static List<Account> getAccountsAndOrders(String accountId) {
        Set<String> setIds = new Set<String>();
        List<Account> accList = [SELECT Id, Name, ParentId, ShippingCity, ShippingState FROM Account WHERE Id =: accountId OR ParentId =: accountId];
        List<Order> ordersList = new List<Order>();
        if(!accList.isEmpty()){
            setIds.add(accList[0].Id);
            if(String.isNotBlank(accList[0].ParentId)) setIds.add(accList[0].ParentId);
            accList = [SELECT Id, Name, ParentId, ShippingCity, ShippingState FROM Account WHERE Id IN : setIds OR ParentId IN : setIds];
            ordersList= [SELECT Id, OrderNumber, Customer_Total_Revenue__c, Status, Type, AccountId FROM Order WHERE AccountId IN : accList AND (NOT Status LIKE '%Closed%')];
        }
        return prepareResult(accList, ordersList);
        //return accList;
    }

    private static parentRecord prepareResult(List<Account> accountsList, List<Order> ordersList){
        parentRecord parentRec;
        List<childRecord> childList = new List<childRecord>();
        String parentId = '';

        for(Account account : accountsList) {
            if (String.isNotBlank(account.ParentId))parentId = account.ParentId;
        }

        if(String.isNotBlank(parentId)) {
            for (Account account : accountsList) {
                if (account.Id != parentId) {
                    List<Order> accOrders = new List<Order>();
                    for (Order order : ordersList) {
                        if (account.Id == order.AccountId) {
                            accOrders.add(order);
                        }
                    }
                    childList.add(new childRecord(account, accOrders));
                }
            }
            for (Account account : accountsList) {
                if (account.Id == parentId) {
                    List<Order> accOrders = new List<Order>();
                    for (Order order : ordersList) {
                        if (account.Id == order.AccountId) {
                            accOrders.add(order);
                        }
                    }
                    parentRec = new parentRecord(account, accOrders, childList);
                }
            }
        }else{
            for (Account account : accountsList) {
                List<Order> accOrders = new List<Order>();
                for (Order order : ordersList) {
                    if (account.Id == order.AccountId) {
                        accOrders.add(order);
                    }
                }
                parentRec = new parentRecord(account, accOrders, childList);
            }
        }

        System.debug(parentRec);

        return parentRec;
    }

    public class parentRecord{
        @AuraEnabled
        public Account account;
        @AuraEnabled
        public List<Order> orders;
        @AuraEnabled
        public List<childRecord> childRecordList;
        parentRecord(Account account, List<Order> orders, List<childRecord> childRecordList){
            this.account = account;
            this.orders = orders;
            this.childRecordList = childRecordList;
        }
    }

    public class childRecord{
        @AuraEnabled
        public Account account;
        @AuraEnabled
        public List<Order> orders;
        childRecord(Account account, List<Order> orders){
            this.account = account;
            this.orders = orders;
        }
    }

}