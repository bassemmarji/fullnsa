Sure, I can provide an example of how this might look. Please note that the actual implementation could be different based on your exact requirements and the structure of your `AdvancedEOBController` class. Here's a basic test case for you to get started with:

```Apex
@isTest
public class AdvancedEOBControllerTest {
    static testMethod void runTests() {
        // Arrange by creating some test data
        Account acc = new Account(Name='Test Account', BillingCity='Tacoma');
        insert acc;
        
        Contact con = new Contact(FirstName='John', LastName='Smith', Email='john.smith@example.com', AccountId=acc.Id);
        insert con;
        
        // Act by calling the method under test
        AdvancedEOBController eobController = new AdvancedEOBController();
        System.assertEquals('Tacoma', eobController.getCity(con));
    }
}
```
This example assumes that your `AdvancedEOBController` class has a method named `getCity()`, and it takes a Contact as an argument, returning the Billing City of its associated Account. This test case sets up some test data (an account with a contact), then calls the `getCity()` method on this contact, expecting to get back 'Tacoma' from the account.

Please adjust this example according to your exact requirements and class structure. If you have any specific scenarios in mind for testing, those would be a good place to start.
