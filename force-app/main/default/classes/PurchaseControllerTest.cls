@isTest
private class PurchaseControllerTest {
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
