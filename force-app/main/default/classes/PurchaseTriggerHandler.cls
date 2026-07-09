/**
 * Trigger handler for PurchaseLine__c that keeps the parent Purchase__c's
 * rollup fields (GrandTotal__c, TotalItems__c) in sync. Invoked by
 * PurchaseLineTrigger on insert, update, delete, and undelete.
 */
public class PurchaseTriggerHandler {
  /**
   * Recalculates and updates GrandTotal__c and TotalItems__c on every
   * Purchase__c referenced by the given trigger line records, based on the
   * current set of PurchaseLine__c rows for each purchase (re-queried fresh,
   * not derived solely from newList/oldList).
   *
   * @param newList List<PurchaseLine__c> Trigger.new; the changed/inserted lines
   *   (used to determine affected PurchaseId__c values when isDelete is false).
   * @param oldList List<PurchaseLine__c> Trigger.old; the prior-state lines
   *   (used to determine affected PurchaseId__c values when isDelete is true).
   * @param isDelete Boolean true for a delete trigger context (uses oldList to
   *   gather affected purchase Ids), false otherwise (uses newList).
   * No return value.
   * Side effects: queries PurchaseLine__c and Purchase__c, then performs a
   *   single bulk DML update on the affected Purchase__c records. No-op (returns
   *   early) if no purchase Ids are found.
   */
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
    }  // DELETE
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
