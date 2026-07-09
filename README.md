# Item Purchase Tool

A Salesforce Lightning Web Components app for browsing an item catalog and creating purchases against an Account, built as an `itemPurchaseTool` Lightning App Page.

## What it does

- Displays the Account the purchase is being made for (name, account number, industry).
- Lists items with search and Family/Type filtering.
- Lets users view item details, add items to a cart, and check out.
- Validates stock availability at checkout and decrements it after purchase.
- Auto-calculates purchase totals (`GrandTotal__c`, `TotalItems__c`) via a trigger whenever purchase lines change.
- Lets managers (`User.IsManager__c`) create new items, auto-fetching a matching product image from the Unsplash API.

## Data model

| Object              | Purpose                                                                                                       |
| ------------------- | ------------------------------------------------------------------------------------------------------------- |
| `Item__c`           | Catalog item — Name, `Description__c`, `Price__c`, `AvailableQuantity__c`, `Family__c`, `Type__c`, `Image__c` |
| `Purchase__c`       | A checkout — `ClientId__c` (Account), `GrandTotal__c`, `TotalItems__c` (both rollup via trigger)              |
| `PurchaseLine__c`   | Line item on a purchase — `ItemId__c`, `PurchaseId__c`, `Amount__c`, `UnitCost__c`                            |
| `User.IsManager__c` | Custom field gating item-creation access                                                                      |

## Architecture

```
itemPurchaseTool (container: loads items/role, owns cart & filter state)
├── accountHeader        — Account summary via UI Record API
├── filterPanel           — search input + Family/Type comboboxes
├── itemList → itemTile   — catalog grid, add-to-cart / view-details actions
├── itemDetailsModal      — full item detail view
├── cartModal             — cart review + checkout
└── createItemModal       — item creation form (manager-only), Unsplash image lookup
```

### Apex

| Class                    | Responsibility                                                                          |
| ------------------------ | --------------------------------------------------------------------------------------- |
| `ItemController`         | Item CRUD, keyword search, distinct Family/Type lookups                                 |
| `PurchaseController`     | Stock validation, stock decrement, checkout (creates `Purchase__c` + `PurchaseLine__c`) |
| `PurchaseTriggerHandler` | Recalculates `Purchase__c` rollups on `PurchaseLine__c` insert/update/delete/undelete   |
| `UnsplashService`        | Callout to the Unsplash API to fetch a product image by item name                       |
| `UserController`         | Exposes the current user's manager flag                                                 |

`PurchaseLineTrigger` on `PurchaseLine__c` delegates to `PurchaseTriggerHandler`.

## Tests

Apex test classes cover each controller, the trigger handler (insert/update/delete rollup scenarios), and the Unsplash callout (success, empty-results, and error-response mocks): `ItemControllerTest`, `PurchaseControllerTest`, `PurchaseTriggerTest`, `UnsplashServiceTest`, `UserControllerTest`.

All Apex classes/methods and LWC components now carry ApexDoc/JSDoc-style documentation describing behavior, parameters, return values, and side effects (DML/callouts/exceptions).
