public class PurchaseTriggerHandler {
  public static void updatePurchases(
    List<PurchaseLine__c> newList,
    List<PurchaseLine__c> oldList,
    Boolean isDelete
  ) {
    Set<Id> purchaseIds = new Set<Id>();

    // INSERT / UPDATE / UNDELETE
    if (!isDelete) {
      for (PurchaseLine__c line : newList) {
        purchaseIds.add(line.PurchaseId__c);
      }
    } // DELETE
    else {
      for (PurchaseLine__c line : oldList) {
        purchaseIds.add(line.PurchaseId__c);
      }
    }

    if (purchaseIds.isEmpty()) {
      return;
    }

    Map<Id, Decimal> totals = new Map<Id, Decimal>();

    Map<Id, Integer> items = new Map<Id, Integer>();

    List<PurchaseLine__c> lines = [
      SELECT PurchaseId__c, Amount__c, UnitCost__c
      FROM PurchaseLine__c
      WHERE PurchaseId__c IN :purchaseIds
    ];

    for (PurchaseLine__c line : lines) {
      if (!totals.containsKey(line.PurchaseId__c)) {
        totals.put(line.PurchaseId__c, 0);

        items.put(line.PurchaseId__c, 0);
      }

      Decimal lineTotal = line.Amount__c * line.UnitCost__c;

      totals.put(
        line.PurchaseId__c,
        totals.get(line.PurchaseId__c) + lineTotal
      );

      items.put(
        line.PurchaseId__c,
        items.get(line.PurchaseId__c) + Integer.valueOf(line.Amount__c)
      );
    }

    List<Purchase__c> purchases = [
      SELECT Id, GrandTotal__c, TotalItems__c
      FROM Purchase__c
      WHERE Id IN :purchaseIds
    ];

    for (Purchase__c purchase : purchases) {
      purchase.GrandTotal__c = totals.containsKey(purchase.Id)
        ? totals.get(purchase.Id)
        : 0;

      purchase.TotalItems__c = items.containsKey(purchase.Id)
        ? items.get(purchase.Id)
        : 0;
    }

    update purchases;
  }
}
