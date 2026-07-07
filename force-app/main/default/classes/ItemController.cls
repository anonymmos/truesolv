public with sharing class ItemController {
  @AuraEnabled(cacheable=true)
  public static List<Item__c> getItems() {
    return [
      SELECT
        Id,
        Name,
        Description__c,
        Price__c,
        AvailableQuantity__c,
        Family__c,
        Type__c,
        Image__c
      FROM Item__c
      ORDER BY Name
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<Item__c> searchItems(String keyword) {
    String searchValue = '%' + keyword + '%';

    return [
      SELECT
        Id,
        Name,
        Description__c,
        Price__c,
        AvailableQuantity__c,
        Family__c,
        Type__c,
        Image__c
      FROM Item__c
      WHERE Name LIKE :searchValue OR Description__c LIKE :searchValue
      ORDER BY Name
    ];
  }

  @AuraEnabled
  public static Item__c createItem(Item__c item) {
    insert item;

    return item;
  }

  @AuraEnabled(cacheable=true)
  public static List<String> getFamilies() {
    List<String> families = new List<String>();

    for (Item__c item : [
      SELECT Family__c
      FROM Item__c
      WHERE Family__c != NULL
      GROUP BY Family__c
    ]) {
      families.add(item.Family__c);
    }

    return families;
  }

  @AuraEnabled(cacheable=true)
  public static List<String> getTypes() {
    List<String> types = new List<String>();

    for (Item__c item : [
      SELECT Type__c
      FROM Item__c
      WHERE Type__c != NULL
      GROUP BY Type__c
    ]) {
      types.add(item.Type__c);
    }

    return types;
  }
}
