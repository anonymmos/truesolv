import { LightningElement, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import getItems from "@salesforce/apex/ItemController.getItems";

export default class ItemPurchaseTool extends LightningElement {
  accountId;
  items = [];
  cart = [];

  selectedFamily = "";
  selectedType = "";
  searchText = "";

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.accountId = currentPageReference.state.c__accountId;
    }
  }

  connectedCallback() {
    this.loadItems();
  }

  loadItems() {
    getItems()
      .then((result) => {
        this.items = result;
      })
      .catch((error) => {
        console.error("Error loading items", error);
      });
  }

  // Собираем фильтр + поиск в одном месте, чтобы они не перетирали друг друга
  get filteredItems() {
    if (!this.items) {
      return [];
    }

    const search = (this.searchText || "").toLowerCase();

    return this.items.filter((item) => {
      const matchesFamily =
        !this.selectedFamily || item.Family__c === this.selectedFamily;
      const matchesType =
        !this.selectedType || item.Type__c === this.selectedType;
      const matchesSearch =
        !search ||
        item.Name.toLowerCase().includes(search) ||
        (item.Description__c &&
          item.Description__c.toLowerCase().includes(search));

      return matchesFamily && matchesType && matchesSearch;
    });
  }

  get itemCount() {
    return this.filteredItems.length;
  }

  handleFilterChange(event) {
    this.selectedFamily = event.detail.family;
    this.selectedType = event.detail.type;
  }

  handleSearch(event) {
    this.searchText = event.detail;
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
