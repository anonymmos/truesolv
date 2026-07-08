import { LightningElement, api } from "lwc";

export default class CartModal extends LightningElement {
  @api cartItems = [];

  get total() {
    return this.cartItems.reduce(
      (sum, line) => sum + line.Price__c * line.amount,
      0
    );
  }

  handleClose() {
    this.dispatchEvent(new CustomEvent("close"));
  }

  handleCheckout() {
    this.dispatchEvent(new CustomEvent("checkout"));
  }

  handleRemove(event) {
    this.dispatchEvent(
      new CustomEvent("remove", { detail: event.target.dataset.id })
    );
  }
}
