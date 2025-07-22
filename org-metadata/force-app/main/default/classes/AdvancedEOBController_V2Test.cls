Sure, here is an example of how you could write a test class for the `AdvancedEOBController_V2` class in Salesforce Apex. I'm going to assume that your controller has methods like `processPayment()`, `sendEmailNotification()` etc., which we will try to cover with our tests.

```java
@isTest
public class AdvancedEOBController_V2Test {
    static testMethod void runAllTests(){
        // Run all other tests in the class.
        System.runTestMethod(AdvancedEOBController_V2Test.class); 
    }  
    
    @isTest
    public static void testProcessPayment() {
        Test.startTest();
        
        // Setup - Create a new instance of the class to test.
        AdvancedEOBController_V2 controller = new AdvancedEOBController_V2();
        
        // Action - Call the method we are testing.
        String result = controller.processPayment('paymentId');
        
        // Assertion - Check if our method behaved as expected.
        System.assertEquals(result, 'Expected Result'); 
        
        Test.stopTest();
    }  
    
    @isTest
    public static void testSendEmailNotification() {
        Test.startTest();
        
        // Setup - Create a new instance of the class to test.
        AdvancedEOBController_V2 controller = new AdvancedEOBController_V2();
        
        // Action - Call the method we are testing.
        String result = controller.sendEmailNotification('recipientId');
        
        // Assertion - Check if our method behaved as expected.
        System.assertEquals(result, 'Expected Result'); 
        
        Test.stopTest();
    }  
    
    // Add more tests for other methods in your controller class here...
}
```
Please replace `'paymentId'` and `'recipientId'` with the actual values you expect to pass into these methods, and replace `'Expected Result'` with what you expect the method to return. 

This is a basic example and may not cover all possible edge cases or situations that your code could encounter in a real-world scenario. You would need to write additional tests based on your specific requirements.
