public with sharing class PurchaseController {
  @AuraEnabled
  public static Boolean validateStock(List<PurchaseLine__c> lines) {
    for (PurchaseLine__c line : lines) {
      Item__c item = [
        SELECT AvailableQuantity__c
        FROM Item__c
        WHERE Id = :line.Item__c
        LIMIT 1
      ];

      if (item.AvailableQuantity__c < line.Quantity__c) {
        return false;
      }
    }

    return true;
  }

  @AuraEnabled
  public static void decreaseStock(List<PurchaseLine__c> lines) {
    List<Item__c> items = new List<Item__c>();

    for (PurchaseLine__c line : lines) {
      Item__c item = [
        SELECT Id, AvailableQuantity__c
        FROM Item__c
        WHERE Id = :line.Item__c
        LIMIT 1
      ];

      item.AvailableQuantity__c -= line.Quantity__c;

      items.add(item);
    }

    update items;
  }

  @AuraEnabled
  public static Purchase__c checkout(List<PurchaseLine__c> lines) {
    if (!validateStock(lines)) {
      throw new AuraHandledException('Not enough stock');
    }

    Purchase__c purchase = new Purchase__c();

    insert purchase;

    for (PurchaseLine__c line : lines) {
      line.Purchase__c = purchase.Id;
    }

    insert lines;

    decreaseStock(lines);

    return purchase;
  }
}
