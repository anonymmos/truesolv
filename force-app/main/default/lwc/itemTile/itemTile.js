import { LightningElement, api } from "lwc";

/**
 * Card representing a single Item__c in the catalog grid, with actions to
 * view details or add the item to the cart.
 */
export default class ItemTile extends LightningElement {
  /** @type {Object} the Item__c record this tile represents. */
  @api item;

  /** @returns {boolean} true if there is no item or its AvailableQuantity__c is zero/negative, disabling the Add button. */
  get isDisabled() {
    return !this.item || this.item.AvailableQuantity__c <= 0;
  }

  /**
   * Dispatches a bubbling, composed "details" CustomEvent carrying this item's Id,
   * requesting the details modal be opened for it. No parameters/return value.
   */
  handleDetailsClick() {
    this.dispatchEvent(
      new CustomEvent("details", {
        detail: this.item.Id,
        bubbles: true,
        composed: true
      })
    );
  }

  /**
   * Dispatches a bubbling, composed "addtocart" CustomEvent carrying this item,
   * requesting it be added to the cart. No parameters/return value.
   */
  handleAddClick() {
    this.dispatchEvent(
      new CustomEvent("addtocart", {
        detail: this.item,
        bubbles: true,
        composed: true
      })
    );
  }
}
