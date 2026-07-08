import { LightningElement, wire } from "lwc";

import { CurrentPageReference } from "lightning/navigation";

import getItems from "@salesforce/apex/ItemController.getItems";

export default class ItemPurchaseTool extends LightningElement {
  //@api recordId;

  items = [];

  cart = [];

  selectedFamily;

  selectedType;

  searchText;

  connectedCallback() {
    this.loadItems();
    console.log("Account Id:", this.recordId);
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.accountId = currentPageReference.state.c__accountId;

      console.log("Account Id from URL:", this.accountId);
    }
  }

  loadItems() {
    getItems()
      .then((result) => {
        console.log("Items loaded:", result);

        this.items = result;
      })

      .catch((error) => {
        console.error("Error loading items", error);
      });
  }

  handleFilterChange(event) {
    this.selectedFamily = event.detail.family;

    this.selectedType = event.detail.type;

    console.log("Filter:", this.selectedFamily, this.selectedType);
  }

  handleSearch(event) {
    this.searchText = event.detail;

    console.log("Search:", this.searchText);
  }

  handleAddToCart(event) {
    const item = event.detail;

    this.cart = [...this.cart, item];

    console.log("Cart:", this.cart);
  }

  handleDetails(event) {
    console.log("Open details:", event.detail);
  }

  openCart() {
    console.log("Cart opened", this.cart);
  }
}
