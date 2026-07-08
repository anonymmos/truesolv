import { LightningElement } from "lwc";

export default class CreateItemModal extends LightningElement {
  handleClose() {
    this.dispatchEvent(new CustomEvent("close"));
  }
}
