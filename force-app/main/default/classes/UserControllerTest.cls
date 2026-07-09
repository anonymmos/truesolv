/**
 * Test class for UserController.isCurrentUserManager.
 */
@isTest
private class UserControllerTest {
  /**
   * Scenario: isCurrentUserManager() is called for the running test user,
   * with no specific IsManager__c value set up beforehand.
   * Expected outcome: a non-null Boolean is returned (verifies the method
   * executes without error and the field is queryable), regardless of its
   * true/false value.
   */
  @isTest
  static void testIsCurrentUserManagerReturnsBoolean() {
    Test.startTest();
    Boolean result = UserController.isCurrentUserManager();
    Test.stopTest();

    System.assertNotEquals(null, result);
  }
}
