import { LightningElement, wire } from "lwc";
import getFamilies from "@salesforce/apex/ItemController.getFamilies";
import getTypes from "@salesforce/apex/ItemController.getTypes";

/**
 * Panel providing search text input and Family/Type dropdown filters for the
 * item catalog, notifying its parent of changes via CustomEvents.
 */
export default class FilterPanel extends LightningElement {
  family = "";
  type = "";

  /** @type {Array<{label: string, value: string}>} Family combobox options, always including an "All" option. */
  familyOptions = [{ label: "All", value: "" }];
  /** @type {Array<{label: string, value: string}>} Type combobox options, always including an "All" option. */
  typeOptions = [{ label: "All", value: "" }];

  /**
   * Wire adapter callback populating familyOptions from ItemController.getFamilies.
   * @param {Object} result
   * @param {Array<string>} [result.data] distinct family values.
   */
  @wire(getFamilies)
  wiredFamilies({ data }) {
    if (data) {
      this.familyOptions = [
        { label: "All", value: "" },
        ...data.map((f) => ({ label: f, value: f }))
      ];
    }
  }

  /**
   * Wire adapter callback populating typeOptions from ItemController.getTypes.
   * @param {Object} result
   * @param {Array<string>} [result.data] distinct type values.
   */
  @wire(getTypes)
  wiredTypes({ data }) {
    if (data) {
      this.typeOptions = [
        { label: "All", value: "" },
        ...data.map((t) => ({ label: t, value: t }))
      ];
    }
  }

  /**
   * Updates the selected family from the combobox and notifies the parent.
   * @param {CustomEvent} event combobox onchange event; event.detail.value is the selected family.
   */
  handleFamily(event) {
    this.family = event.detail.value;
    this.sendFilter();
  }

  /**
   * Updates the selected type from the combobox and notifies the parent.
   * @param {CustomEvent} event combobox onchange event; event.detail.value is the selected type.
   */
  handleType(event) {
    this.type = event.detail.value;
    this.sendFilter();
  }

  /** Dispatches a "filterchange" CustomEvent with the current family/type selection. No parameters/return value. */
  sendFilter() {
    this.dispatchEvent(
      new CustomEvent("filterchange", {
        detail: { family: this.family, type: this.type }
      })
    );
  }

  /**
   * Dispatches a "search" CustomEvent with the current search input value.
   * @param {Event} event input onchange event; event.target.value is the search text.
   */
  handleSearch(event) {
    this.dispatchEvent(
      new CustomEvent("search", {
        detail: event.target.value
      })
    );
  }
}
