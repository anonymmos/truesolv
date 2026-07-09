@isTest
private class UserControllerTest {
  @isTest
  static void testIsCurrentUserManagerReturnsBoolean() {
    Test.startTest();
    Boolean result = UserController.isCurrentUserManager();
    Test.stopTest();

    System.assertNotEquals(null, result);
  }
}
