/**
 * Test class for ItemController, covering item retrieval, search,
 * creation, and family/type filter option queries.
 */
@isTest
private class ItemControllerTest {
  /**
   * Test data setup: inserts two Item__c records ("Laptop" with stock 5,
   * "Chair" with stock 0) spanning two distinct Family__c/Type__c values,
   * shared across all test methods in this class.
   */
  @TestSetup
  static void setup() {
    insert new List<Item__c>{
      new Item__c(
        Name = 'Laptop',
        Description__c = 'Fast laptop',
        Price__c = 1000,
        AvailableQuantity__c = 5,
        Family__c = 'Family 1',
        Type__c = 'Type 1'
      ),
      new Item__c(
        Name = 'Chair',
        Description__c = 'Office chair',
        Price__c = 100,
        AvailableQuantity__c = 0,
        Family__c = 'Family 2',
        Type__c = 'Type 2'
      )
    };
  }

  /**
   * Scenario: getItems() is called with the two @TestSetup items present.
   * Expected outcome: both items are returned (asserts a size of 2).
   */
  @isTest
  static void testGetItems() {
    Test.startTest();
    List<Item__c> items = ItemController.getItems();
    Test.stopTest();

    System.assertEquals(2, items.size());
  }

  /**
   * Scenario: searchItems() is called with a keyword ("Laptop") matching an
   * item's Name field.
   * Expected outcome: exactly one result is returned and its Name is "Laptop".
   */
  @isTest
  static void testSearchItemsByName() {
    Test.startTest();
    List<Item__c> results = ItemController.searchItems('Laptop');
    Test.stopTest();

    System.assertEquals(1, results.size());
    System.assertEquals('Laptop', results[0].Name);
  }

  /**
   * Scenario: searchItems() is called with a keyword ("Office") matching an
   * item's Description__c field rather than its Name.
   * Expected outcome: exactly one result is returned and its Name is "Chair".
   */
  @isTest
  static void testSearchItemsByDescription() {
    Test.startTest();
    List<Item__c> results = ItemController.searchItems('Office');
    Test.stopTest();

    System.assertEquals(1, results.size());
    System.assertEquals('Chair', results[0].Name);
  }

  /**
   * Scenario: createItem() is called with a new, unsaved Item__c ("Monitor").
   * Expected outcome: the returned record has a populated Id, and a
   * subsequent query confirms the record was persisted with the correct Name.
   */
  @isTest
  static void testCreateItem() {
    Item__c newItem = new Item__c(
      Name = 'Monitor',
      Price__c = 200,
      AvailableQuantity__c = 10,
      Family__c = 'Family 1',
      Type__c = 'Type 1'
    );

    Test.startTest();
    Item__c created = ItemController.createItem(newItem);
    Test.stopTest();

    System.assertNotEquals(null, created.Id);

    Item__c fromDb = [SELECT Name FROM Item__c WHERE Id = :created.Id];
    System.assertEquals('Monitor', fromDb.Name);
  }

  /**
   * Scenario: getFamilies() is called with the two @TestSetup items, each
   * having a distinct Family__c value.
   * Expected outcome: the returned list contains both "Family 1" and "Family 2".
   */
  @isTest
  static void testGetFamilies() {
    Test.startTest();
    List<String> families = ItemController.getFamilies();
    Test.stopTest();

    System.assert(families.contains('Family 1'));
    System.assert(families.contains('Family 2'));
  }

  /**
   * Scenario: getTypes() is called with the two @TestSetup items, each
   * having a distinct Type__c value.
   * Expected outcome: the returned list contains both "Type 1" and "Type 2".
   */
  @isTest
  static void testGetTypes() {
    Test.startTest();
    List<String> types = ItemController.getTypes();
    Test.stopTest();

    System.assert(types.contains('Type 1'));
    System.assert(types.contains('Type 2'));
  }
}
