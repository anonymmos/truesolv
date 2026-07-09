/**
 * Test class for PurchaseLineTrigger / PurchaseTriggerHandler, covering
 * Purchase__c rollup recalculation (GrandTotal__c, TotalItems__c) on
 * PurchaseLine__c insert, update, and delete.
 */
@isTest
private class PurchaseTriggerTest {
  /**
   * Scenario: two PurchaseLine__c records (amounts 2 and 3, unit cost 500)
   * are inserted for the same Purchase__c in one bulk DML operation.
   * Expected outcome: the purchase's TotalItems__c is 5 and GrandTotal__c is
   * 2500 (sum of Amount__c * UnitCost__c across both lines).
   */
  @isTest
  static void testTotalsCalculatedOnInsert() {
    Item__c item = new Item__c(
      Name = 'Laptop',
      Price__c = 500,
      AvailableQuantity__c = 10,
      Family__c = 'Family 1',
      Type__c = 'Type 1'
    );
    insert item;

    Purchase__c purchase = new Purchase__c();
    insert purchase;

    PurchaseLine__c line1 = new PurchaseLine__c(
      PurchaseId__c = purchase.Id,
      ItemId__c = item.Id,
      Amount__c = 2,
      UnitCost__c = 500
    );

    PurchaseLine__c line2 = new PurchaseLine__c(
      PurchaseId__c = purchase.Id,
      ItemId__c = item.Id,
      Amount__c = 3,
      UnitCost__c = 500
    );

    Test.startTest();
    insert new List<PurchaseLine__c>{ line1, line2 };
    Test.stopTest();

    Purchase__c updated = [
      SELECT TotalItems__c, GrandTotal__c
      FROM Purchase__c
      WHERE Id = :purchase.Id
    ];

    System.assertEquals(5, updated.TotalItems__c);
    System.assertEquals(2500, updated.GrandTotal__c);
  }

  /**
   * Scenario: an existing PurchaseLine__c (amount 4, unit cost 100) has its
   * Amount__c updated to 10, using a bare sObject with only Id and Amount__c
   * set (to avoid touching the master-detail fields).
   * Expected outcome: the purchase's TotalItems__c becomes 10 and
   * GrandTotal__c becomes 1000, reflecting the updated amount.
   */
  @isTest
  static void testTotalsRecalculatedOnUpdate() {
    Item__c item = new Item__c(
      Name = 'Chair',
      Price__c = 100,
      AvailableQuantity__c = 10,
      Family__c = 'Family 2',
      Type__c = 'Type 2'
    );
    insert item;

    Purchase__c purchase = new Purchase__c();
    insert purchase;

    PurchaseLine__c line = new PurchaseLine__c(
      PurchaseId__c = purchase.Id,
      ItemId__c = item.Id,
      Amount__c = 4,
      UnitCost__c = 100
    );
    insert line;

    // Обновляем через "чистый" sObject только с Id и изменяемым полем,
    // чтобы не задевать Master-Detail поля ItemId__c / PurchaseId__c
    PurchaseLine__c lineToUpdate = new PurchaseLine__c(
      Id = line.Id,
      Amount__c = 10
    );

    Test.startTest();
    update lineToUpdate;
    Test.stopTest();

    Purchase__c updated = [
      SELECT TotalItems__c, GrandTotal__c
      FROM Purchase__c
      WHERE Id = :purchase.Id
    ];

    System.assertEquals(10, updated.TotalItems__c);
    System.assertEquals(1000, updated.GrandTotal__c);
  }

  /**
   * Scenario: the sole PurchaseLine__c on a purchase (amount 4, unit cost 300)
   * is deleted.
   * Expected outcome: the purchase's TotalItems__c and GrandTotal__c both
   * reset to 0, since no lines remain.
   */
  @isTest
  static void testTotalsRecalculatedOnDelete() {
    Item__c item = new Item__c(
      Name = 'Desk',
      Price__c = 300,
      AvailableQuantity__c = 10,
      Family__c = 'Family 3',
      Type__c = 'Type 3'
    );
    insert item;

    Purchase__c purchase = new Purchase__c();
    insert purchase;

    PurchaseLine__c line = new PurchaseLine__c(
      PurchaseId__c = purchase.Id,
      ItemId__c = item.Id,
      Amount__c = 4,
      UnitCost__c = 300
    );
    insert line;

    Test.startTest();
    delete line;
    Test.stopTest();

    Purchase__c updated = [
      SELECT TotalItems__c, GrandTotal__c
      FROM Purchase__c
      WHERE Id = :purchase.Id
    ];

    System.assertEquals(0, updated.TotalItems__c);
    System.assertEquals(0, updated.GrandTotal__c);
  }
}
