/**
 * Controller exposing information about the current running user for the
 * Item Purchase Tool Lightning Web Components.
 */
public with sharing class UserController {
  /**
   * Determines whether the current running user is flagged as a manager.
   *
   * @return Boolean the value of the current User's IsManager__c custom field.
   *   No parameters. No DML or callouts performed.
   */
  @AuraEnabled(cacheable=true)
  public static Boolean isCurrentUserManager() {
    User currentUser = [
      SELECT IsManager__c
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    return currentUser.IsManager__c;
  }
}
