/**
 * Controller exposing CRUD and query operations on Item__c records
 * for the Item Purchase Tool Lightning Web Components.
 */
public with sharing class ItemController {
  /**
   * Retrieves all Item__c records with the fields needed for catalog display.
   *
   * @return List<Item__c> all items ordered by Name; empty list if none exist.
   *   No parameters. No DML or callouts performed.
   */
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

  /**
   * Searches Item__c records whose Name or Description__c contains the given keyword.
   *
   * @param keyword String search term to match (case-insensitive substring match
   *   via SOQL LIKE); wrapped internally as '%keyword%'.
   * @return List<Item__c> matching items ordered by Name; empty list if none match.
   *   No DML or callouts performed.
   */
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

  /**
   * Inserts a new Item__c record.
   *
   * @param item Item__c the item to create (fields populated by the caller,
   *   e.g. Name, Price__c, AvailableQuantity__c, Family__c, Type__c, Image__c).
   * @return Item__c the same item instance, populated with its new Id after insert.
   * Side effects: performs a DML insert on Item__c. Throws a DmlException if the
   *   insert violates validation rules or required-field constraints.
   */
  @AuraEnabled
  public static Item__c createItem(Item__c item) {
    insert item;

    return item;
  }

  /**
   * Retrieves the distinct, non-null Family__c values across all Item__c records,
   * for use as filter options.
   *
   * @return List<String> distinct family values (unordered, as grouped by SOQL).
   *   No parameters. No DML or callouts performed.
   */
  @AuraEnabled(cacheable=true)
  public static List<String> getFamilies() {
    List<String> families = new List<String>();

    for (AggregateResult ar : [
      SELECT Family__c
      FROM Item__c
      WHERE Family__c != NULL
      GROUP BY Family__c
    ]) {
      families.add((String) ar.get('Family__c'));
    }

    return families;
  }

  /**
   * Retrieves the distinct, non-null Type__c values across all Item__c records,
   * for use as filter options.
   *
   * @return List<String> distinct type values (unordered, as grouped by SOQL).
   *   No parameters. No DML or callouts performed.
   */
  @AuraEnabled(cacheable=true)
  public static List<String> getTypes() {
    List<String> types = new List<String>();

    for (AggregateResult ar : [
      SELECT Type__c
      FROM Item__c
      WHERE Type__c != NULL
      GROUP BY Type__c
    ]) {
      types.add((String) ar.get('Type__c'));
    }

    return types;
  }
}
