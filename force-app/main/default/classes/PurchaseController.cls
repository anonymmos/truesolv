/**
 * Controller handling purchase checkout logic: stock validation, stock
 * decrementing, and creation of Purchase__c / PurchaseLine__c records.
 */
public with sharing class PurchaseController {
  /**
   * Checks whether each proposed PurchaseLine__c has enough AvailableQuantity__c
   * on its related Item__c to satisfy the requested amount.
   *
   * @param lines List<PurchaseLine__c> proposed lines; each must have ItemId__c
   *   and Amount__c populated. Note: PurchaseId__c/UnitCost__c are not required
   *   for this check.
   * @return Boolean true if every line's item has sufficient stock; false as soon
   *   as any line's Amount__c exceeds the item's AvailableQuantity__c.
   * Side effects: performs a SOQL query per line (no DML or callouts).
   */
  @AuraEnabled
  public static Boolean validateStock(List<PurchaseLine__c> lines) {
    for (PurchaseLine__c line : lines) {
      Item__c item = [
        SELECT Id, AvailableQuantity__c
        FROM Item__c
        WHERE Id = :line.ItemId__c
        LIMIT 1
      ];

      if (item.AvailableQuantity__c < line.Amount__c) {
        return false;
      }
    }

    return true;
  }

  /**
   * Decrements AvailableQuantity__c on each line's related Item__c by the
   * purchased Amount__c. Does not itself verify sufficient stock; callers
   * should invoke validateStock beforehand (see checkout).
   *
   * @param lines List<PurchaseLine__c> purchased lines; each must have ItemId__c
   *   and Amount__c populated. No return value.
   * Side effects: performs a SOQL query per line, then a single bulk DML update
   *   of the affected Item__c records. Can go negative if stock was not validated
   *   first. Throws a DmlException if the update fails.
   */
  @AuraEnabled
  public static void decreaseStock(List<PurchaseLine__c> lines) {
    List<Item__c> items = new List<Item__c>();

    for (PurchaseLine__c line : lines) {
      Item__c item = [
        SELECT Id, AvailableQuantity__c
        FROM Item__c
        WHERE Id = :line.ItemId__c
        LIMIT 1
      ];

      item.AvailableQuantity__c -= line.Amount__c;

      items.add(item);
    }

    update items;
  }

  /*@AuraEnabled
  public static Purchase__c checkout(List<PurchaseLine__c> lines) {
    if (!validateStock(lines)) {
      throw new AuraHandledException('Not enough stock');
    }

    Purchase__c purchase = new Purchase__c();

    insert purchase;

    for (PurchaseLine__c line : lines) {
      line.PurchaseId__c = purchase.Id;
    }

    insert lines;

    decreaseStock(lines);

    return purchase;
  }*/

  /**
   * Validates stock, then creates a Purchase__c for the given account with its
   * associated PurchaseLine__c records, and decrements item stock accordingly.
   *
   * @param accountId String Id of the Account (client) placing the purchase;
   *   stored on Purchase__c.ClientId__c.
   * @param lines List<PurchaseLine__c> lines to purchase; each must have
   *   ItemId__c, Amount__c, and UnitCost__c populated. PurchaseId__c is set
   *   internally once the Purchase__c is created.
   * @return Purchase__c the newly created purchase record, populated with its Id.
   * Side effects: inserts one Purchase__c record, inserts the PurchaseLine__c
   *   records (linked via PurchaseId__c), and updates Item__c stock via
   *   decreaseStock. Throws AuraHandledException("Not enough stock") if
   *   validateStock fails, before any DML occurs.
   */
  @AuraEnabled
  public static Purchase__c checkout(
    String accountId,
    List<PurchaseLine__c> lines
  ) {
    if (!validateStock(lines)) {
      throw new AuraHandledException('Not enough stock');
    }

    Purchase__c purchase = new Purchase__c(ClientId__c = accountId);

    insert purchase;

    for (PurchaseLine__c line : lines) {
      line.PurchaseId__c = purchase.Id;
    }

    insert lines;

    decreaseStock(lines);

    return purchase;
  }
}
