import { LightningElement, api } from "lwc";

export default class ItemTile extends LightningElement {
  @api item;

  get isDisabled() {
    return !this.item || this.item.AvailableQuantity__c <= 0;
  }

  handleDetailsClick() {
    this.dispatchEvent(
      new CustomEvent("details", {
        detail: this.item.Id,
        bubbles: true,
        composed: true
      })
    );
  }

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
