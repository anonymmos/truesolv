import { LightningElement, api } from "lwc";

/**
 * Modal displaying the current shopping cart's line items, grand total, and
 * actions to remove a line, close the modal, or proceed to checkout.
 */
export default class CartModal extends LightningElement {
  /** @type {Array<Object>} cart line items; each expected to have Id, Name, Price__c, and amount. */
  @api cartItems = [];

  /** @returns {number} sum of Price__c * amount across all cart line items. */
  get total() {
    return this.cartItems.reduce(
      (sum, line) => sum + line.Price__c * line.amount,
      0
    );
  }

  /** Dispatches a "close" CustomEvent to signal the parent to dismiss this modal. No parameters/return value. */
  handleClose() {
    this.dispatchEvent(new CustomEvent("close"));
  }

  /** Dispatches a "checkout" CustomEvent requesting the parent begin checkout. No parameters/return value. */
  handleCheckout() {
    this.dispatchEvent(new CustomEvent("checkout"));
  }

  /**
   * Dispatches a "remove" CustomEvent for the clicked line's item Id, read
   * from the triggering element's data-id attribute.
   * @param {Event} event click event from the line's Remove button.
   */
  handleRemove(event) {
    this.dispatchEvent(
      new CustomEvent("remove", { detail: event.target.dataset.id })
    );
  }
}
