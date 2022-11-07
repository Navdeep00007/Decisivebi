@IsTest
private class AccountController_Test {
    @IsTest
    static void testGetAccountsAndOrdersWithParent() {

        Account COEOAccount = new Account();
        COEOAccount.Name  = 'Coeo Solutions, LLC';
        insert COEOAccount;

        Account acc = new Account();
        acc.Name  = 'Test Account';
        acc.ParentId = COEOAccount.Id;
        insert acc;

        Order o = new Order();
        o.Status = 'New';
        o.AccountId = acc.Id;
        o.EffectiveDate = date.today();
        o.Type = 'Customer Order';
        insert o;

        Order childOrder = new Order();
        childOrder.Status = 'New';
        childOrder.AccountId = COEOAccount.Id;
        childOrder.EffectiveDate = date.today();
        childOrder.Type = 'Customer - Site Order';
        childOrder.Parent_Order__c = o.Id;
        //childOrder.Doc_MSA__c = 'N/A';//to be deleted
        //childOrder.Doc_Credit_App__c = 'N/A';//to be deleted
        //childOrder.Doc_Current_Bill_Copy__c = 'N/A';//to be deleted
        //childOrder.Doc_LOA_LD__c = 'N/A';//to be deleted
        //childOrder.Doc_LOA_TF__c = 'N/A';//to be deleted
        //childOrder.Doc_New_Number_Prefix__c = 'N/A';//to be deleted
        //childOrder.Verified_Contacts__c = 'N/A';//to be deleted
        insert childOrder;

        System.Test.startTest();
        AccountController.parentRecord result =  AccountController.getAccountsAndOrders(acc.Id);
        System.Test.stopTest();
        System.assertEquals(true, JSON.serialize(result).contains(acc.Id));
    }

    @IsTest
    static void testGetAccountsAndOrdersWithoutParent() {
        Account acc = new Account();
        acc.Name  = 'Test Account';
        insert acc;

        Order o = new Order();
        o.Status = 'New';
        o.AccountId = acc.Id;
        o.EffectiveDate = date.today();
        o.Type = 'Customer Order';
        insert o;

        System.Test.startTest();
        AccountController.parentRecord result =  AccountController.getAccountsAndOrders(acc.Id);
        System.Test.stopTest();
        System.assertEquals(true, JSON.serialize(result).contains(acc.Id));
    }

}