import { LightningElement } from "lwc";
import searchImage from "@salesforce/apex/UnsplashService.searchImage";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CreateItemModal extends LightningElement {
  isLoadingImage = false;

  handleClose() {
    this.dispatchEvent(new CustomEvent("close"));
  }

  handleSuccess() {
    this.dispatchEvent(new CustomEvent("success"));
    this.handleClose();
  }

  async handleSubmit(event) {
    event.preventDefault(); // не даём форме уйти сразу

    const fields = event.detail.fields;
    this.isLoadingImage = true;

    try {
      const imageUrl = await searchImage({ itemName: fields.Name });

      if (imageUrl) {
        fields.Image__c = imageUrl;
      }

      this.template.querySelector("lightning-record-edit-form").submit(fields);
    } catch (error) {
      this.showToast(
        "Error",
        error.body?.message || "Failed to fetch image",
        "error"
      );
      this.isLoadingImage = false;
    }
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
