import { LightningElement } from "lwc";
import searchImage from "@salesforce/apex/UnsplashService.searchImage";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

/**
 * Modal wrapping a record-edit-form for creating a new Item__c. Before
 * submitting, it fetches a matching image from Unsplash (via UnsplashService)
 * and populates it onto the Image__c field.
 */
export default class CreateItemModal extends LightningElement {
  /** @type {boolean} true while the Unsplash image lookup is in progress. */
  isLoadingImage = false;

  /** Dispatches a "close" CustomEvent to signal the parent to dismiss this modal. No parameters/return value. */
  handleClose() {
    this.dispatchEvent(new CustomEvent("close"));
  }

  /**
   * Handles successful record creation from the record-edit-form: notifies
   * the parent via a "success" CustomEvent, then closes this modal.
   * No parameters/return value.
   */
  handleSuccess() {
    this.dispatchEvent(new CustomEvent("success"));
    this.handleClose();
  }

  /**
   * Intercepts the record-edit-form submit, looks up an Unsplash image for
   * the item's Name, attaches it to Image__c if found, then manually submits
   * the form fields.
   *
   * @param {CustomEvent} event record-edit-form onsubmit event; event.detail.fields
   *   holds the form's field values (mutated in place with Image__c).
   * @returns {Promise<void>}
   * Side effects: performs an Apex callout (UnsplashService.searchImage) and
   *   submits the lightning-record-edit-form (which performs the Item__c DML
   *   insert). On failure, shows an error toast and clears isLoadingImage.
   */
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

  /**
   * Dispatches a ShowToastEvent with the given parameters.
   * @param {string} title toast title.
   * @param {string} message toast message body.
   * @param {string} variant toast variant (e.g. "success", "error").
   */
  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
