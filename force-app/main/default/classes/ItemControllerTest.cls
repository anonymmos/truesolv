@isTest
private class ItemControllerTest {
  @TestSetup
  static void setup() {
    insert new List<Item__c>{
      new Item__c(
        Name = 'Laptop',
        Description__c = 'Fast laptop',
        Price__c = 1000,
        AvailableQuantity__c = 5,
        Family__c = 'Electronics',
        Type__c = 'New'
      ),
      new Item__c(
        Name = 'Chair',
        Description__c = 'Office chair',
        Price__c = 100,
        AvailableQuantity__c = 0,
        Family__c = 'Furniture',
        Type__c = 'Used'
      )
    };
  }

  @isTest
  static void testGetItems() {
    Test.startTest();
    List<Item__c> items = ItemController.getItems();
    Test.stopTest();

    System.assertEquals(2, items.size());
  }

  @isTest
  static void testSearchItemsByName() {
    Test.startTest();
    List<Item__c> results = ItemController.searchItems('Laptop');
    Test.stopTest();

    System.assertEquals(1, results.size());
    System.assertEquals('Laptop', results[0].Name);
  }

  @isTest
  static void testSearchItemsByDescription() {
    Test.startTest();
    List<Item__c> results = ItemController.searchItems('Office');
    Test.stopTest();

    System.assertEquals(1, results.size());
    System.assertEquals('Chair', results[0].Name);
  }

  @isTest
  static void testCreateItem() {
    Item__c newItem = new Item__c(
      Name = 'Monitor',
      Price__c = 200,
      AvailableQuantity__c = 10,
      Family__c = 'Electronics',
      Type__c = 'New'
    );

    Test.startTest();
    Item__c created = ItemController.createItem(newItem);
    Test.stopTest();

    System.assertNotEquals(null, created.Id);

    Item__c fromDb = [SELECT Name FROM Item__c WHERE Id = :created.Id];
    System.assertEquals('Monitor', fromDb.Name);
  }

  @isTest
  static void testGetFamilies() {
    Test.startTest();
    List<String> families = ItemController.getFamilies();
    Test.stopTest();

    System.assert(families.contains('Electronics'));
    System.assert(families.contains('Furniture'));
  }

  @isTest
  static void testGetTypes() {
    Test.startTest();
    List<String> types = ItemController.getTypes();
    Test.stopTest();

    System.assert(types.contains('New'));
    System.assert(types.contains('Used'));
  }
}
