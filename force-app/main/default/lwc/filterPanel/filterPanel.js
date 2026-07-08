import { LightningElement, wire } from "lwc";
import getFamilies from "@salesforce/apex/ItemController.getFamilies";
import getTypes from "@salesforce/apex/ItemController.getTypes";

export default class FilterPanel extends LightningElement {
  family = "";
  type = "";

  familyOptions = [{ label: "All", value: "" }];
  typeOptions = [{ label: "All", value: "" }];

  @wire(getFamilies)
  wiredFamilies({ data }) {
    if (data) {
      this.familyOptions = [
        { label: "All", value: "" },
        ...data.map((f) => ({ label: f, value: f }))
      ];
    }
  }

  @wire(getTypes)
  wiredTypes({ data }) {
    if (data) {
      this.typeOptions = [
        { label: "All", value: "" },
        ...data.map((t) => ({ label: t, value: t }))
      ];
    }
  }

  handleFamily(event) {
    this.family = event.detail.value;
    this.sendFilter();
  }

  handleType(event) {
    this.type = event.detail.value;
    this.sendFilter();
  }

  sendFilter() {
    this.dispatchEvent(
      new CustomEvent("filterchange", {
        detail: { family: this.family, type: this.type }
      })
    );
  }

  handleSearch(event) {
    this.dispatchEvent(
      new CustomEvent("search", {
        detail: event.target.value
      })
    );
  }
}
