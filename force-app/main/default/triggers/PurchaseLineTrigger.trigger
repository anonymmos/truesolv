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
