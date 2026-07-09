/**
 * Trigger on PurchaseLine__c that delegates to PurchaseTriggerHandler to keep
 * the parent Purchase__c's GrandTotal__c and TotalItems__c rollups in sync
 * after insert, update, delete, and undelete.
 * Side effects: see PurchaseTriggerHandler.updatePurchases (queries and updates
 * Purchase__c records).
 */
trigger PurchaseLineTrigger on PurchaseLine__c(
  after insert,
  after update,
  after delete,
  after undelete
) {
  PurchaseTriggerHandler.updatePurchases(
    Trigger.new,
    Trigger.old,
    Trigger.isDelete
  );
}
