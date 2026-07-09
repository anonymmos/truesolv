import { LightningElement, api } from "lwc";

/**
 * Modal displaying full details (image, description, price, family, type)
 * for a single selected Item__c.
 */
export default class ItemDetailsModal extends LightningElement {
  /** @type {Object} the Item__c record to display; modal renders only when set. */
  @api item;

  /** Dispatches a "close" CustomEvent to signal the parent to dismiss this modal. No parameters/return value. */
  handleClose() {
    this.dispatchEvent(new CustomEvent("close"));
  }
}
