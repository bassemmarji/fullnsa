Sure, here's an example of how you could write this test. This is just a basic template and would need to be modified according to your specific requirements and the structure of your classes. The example assumes that `AsyncPatientUpdate` has one method called `updatePatients()`. 

```java
@isTest
public class AsyncPatientUpdateTest {
    static testMethod void runAllTests() {
        Test.startTest();
        
        // Instantiate your controller
        AsyncPatientUpdate controller = new AsyncPatientUpdate();

        // Call the method to be tested
        controller.updatePatients();
    
        Test.stopTest();
    }
}
```
In this test class, we first start a test by calling `Test.startTest()`. This sets up an environment for tests that mimics what would happen in production, such as using the real Salesforce API and interacting with actual data. We then create an instance of our controller (in this case AsyncPatientUpdate) and call its method to be tested (updatePatients). Finally, we stop the test by calling `Test.stopTest()`.
