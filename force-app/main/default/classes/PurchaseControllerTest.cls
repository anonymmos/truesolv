/**
 * Test class for PurchaseController, covering stock validation, stock
 * decrementing, and the end-to-end checkout flow.
 */
@isTest
private class PurchaseControllerTest {
  /**
   * Test data setup: inserts one Item__c ("Laptop", stock 5) and one Account
   * ("Test Account"), shared across all test methods in this class.
   */
  @TestSetup
  static void setup() {
    insert new Item__c(
      Name = 'Laptop',
      Price__c = 1000,
      AvailableQuantity__c = 5,
      Family__c = 'Family 1',
      Type__c = 'Type 1'
    );

    insert new Account(Name = 'Test Account');
  }

  /**
   * Scenario: validateStock() is called with a line requesting an amount (2)
   * within the item's available stock (5).
   * Expected outcome: returns true.
   */
  @isTest
  static void testValidateStockSuccess() {
    Item__c item = [SELECT Id FROM Item__c LIMIT 1];

    PurchaseLine__c line = new PurchaseLine__c(
      ItemId__c = item.Id,
      Amount__c = 2,
      UnitCost__c = 1000
    );

    Test.startTest();
    Boolean result = PurchaseController.validateStock(
      new List<PurchaseLine__c>{ line }
    );
    Test.stopTest();

    System.assertEquals(true, result);
  }

  /**
   * Scenario: validateStock() is called with a line requesting an amount (999)
   * that exceeds the item's available stock (5).
   * Expected outcome: returns false.
   */
  @isTest
  static void testValidateStockFailure() {
    Item__c item = [SELECT Id FROM Item__c LIMIT 1];

    PurchaseLine__c line = new PurchaseLine__c(
      ItemId__c = item.Id,
      Amount__c = 999,
      UnitCost__c = 1000
    );

    Test.startTest();
    Boolean result = PurchaseController.validateStock(
      new List<PurchaseLine__c>{ line }
    );
    Test.stopTest();

    System.assertEquals(false, result);
  }

  /**
   * Scenario: decreaseStock() is called with a line purchasing 2 units of the
   * item, which starts at 5 units of AvailableQuantity__c.
   * Expected outcome: the item's AvailableQuantity__c is updated to 3.
   */
  @isTest
  static void testDecreaseStock() {
    Item__c item = [SELECT Id, AvailableQuantity__c FROM Item__c LIMIT 1];

    PurchaseLine__c line = new PurchaseLine__c(
      ItemId__c = item.Id,
      Amount__c = 2,
      UnitCost__c = 1000
    );

    Test.startTest();
    PurchaseController.decreaseStock(new List<PurchaseLine__c>{ line });
    Test.stopTest();

    Item__c updated = [
      SELECT AvailableQuantity__c
      FROM Item__c
      WHERE Id = :item.Id
    ];
    System.assertEquals(3, updated.AvailableQuantity__c);
  }

  /**
   * Scenario: checkout() is called with a valid account and a line whose
   * amount (2) is within available stock (5).
   * Expected outcome: a Purchase__c is created and linked to the account via
   * ClientId__c, the item's stock is decremented to 3, and exactly one
   * PurchaseLine__c is created and linked to the purchase.
   */
  @isTest
  static void testCheckoutSuccess() {
    Item__c item = [SELECT Id FROM Item__c LIMIT 1];
    Account acc = [SELECT Id FROM Account LIMIT 1];

    PurchaseLine__c line = new PurchaseLine__c(
      ItemId__c = item.Id,
      Amount__c = 2,
      UnitCost__c = 1000
    );

    Test.startTest();
    Purchase__c purchase = PurchaseController.checkout(
      acc.Id,
      new List<PurchaseLine__c>{ line }
    );
    Test.stopTest();

    System.assertNotEquals(null, purchase.Id);

    Purchase__c fromDb = [
      SELECT ClientId__c
      FROM Purchase__c
      WHERE Id = :purchase.Id
    ];
    System.assertEquals(acc.Id, fromDb.ClientId__c);

    Item__c updatedItem = [
      SELECT AvailableQuantity__c
      FROM Item__c
      WHERE Id = :item.Id
    ];
    System.assertEquals(3, updatedItem.AvailableQuantity__c);

    List<PurchaseLine__c> lines = [
      SELECT Id
      FROM PurchaseLine__c
      WHERE PurchaseId__c = :purchase.Id
    ];
    System.assertEquals(1, lines.size());
  }

  /**
   * Scenario: checkout() is called with a line whose amount (999) exceeds the
   * item's available stock (5).
   * Expected outcome: an AuraHandledException is thrown (caught and flagged),
   * and no Purchase__c record is created as a result.
   */
  @isTest
  static void testCheckoutFailsNotEnoughStock() {
    Item__c item = [SELECT Id FROM Item__c LIMIT 1];
    Account acc = [SELECT Id FROM Account LIMIT 1];

    PurchaseLine__c line = new PurchaseLine__c(
      ItemId__c = item.Id,
      Amount__c = 999,
      UnitCost__c = 1000
    );

    Boolean exceptionThrown = false;

    Test.startTest();
    try {
      PurchaseController.checkout(acc.Id, new List<PurchaseLine__c>{ line });
    } catch (AuraHandledException e) {
      exceptionThrown = true;
    }
    Test.stopTest();

    System.assertEquals(true, exceptionThrown);

    List<Purchase__c> purchases = [SELECT Id FROM Purchase__c];
    System.assertEquals(0, purchases.size());
  }
}
