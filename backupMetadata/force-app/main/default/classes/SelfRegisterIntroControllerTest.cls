@isTest
public class SelfRegisterIntroControllerTest {
    @IsTest
    static void userTest() {
        
        Test.startTest();
        List<User> users = SelfRegisterIntroController.getUser();
        users[0].LastName = 'Test';
        SelfRegisterIntroController.updateUser(users[0]);
        Test.stopTest();
    }
}