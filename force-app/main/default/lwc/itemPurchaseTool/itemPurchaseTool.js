import { LightningElement, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getItems from "@salesforce/apex/ItemController.getItems";
import checkout from "@salesforce/apex/PurchaseController.checkout";
import isCurrentUserManager from "@salesforce/apex/UserController.isCurrentUserManager";

export default class ItemPurchaseTool extends NavigationMixin(
  LightningElement
) {
  accountId;
  items = [];
  cart = [];

  selectedFamily = "";
  selectedType = "";
  searchText = "";

  selectedItem;
  isDetailsModalOpen = false;
  isCartModalOpen = false;

  isManager = false;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.accountId = currentPageReference.state.c__accountId;
    }
  }

  connectedCallback() {
    this.loadItems();
    this.loadUserRole();
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

  loadUserRole() {
    isCurrentUserManager()
      .then((result) => {
        this.isManager = result;
      })
      .catch((error) => console.error(error));
  }

  get filteredItems() {
    if (!this.items) return [];

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

  get cartCount() {
    return this.cart.length;
  }

  handleFilterChange(event) {
    this.selectedFamily = event.detail.family;
    this.selectedType = event.detail.type;
  }

  handleSearch(event) {
    this.searchText = event.detail;
  }

  // ---------- Details ----------

  handleDetails(event) {
    const itemId = event.detail;
    this.selectedItem = this.items.find((i) => i.Id === itemId);
    this.isDetailsModalOpen = true;
  }

  handleCloseDetails() {
    this.isDetailsModalOpen = false;
  }

  // ---------- Cart ----------

  handleAddToCart(event) {
    const item = event.detail;
    const existingLine = this.cart.find((line) => line.Id === item.Id);

    if (existingLine) {
      if (existingLine.amount >= item.AvailableQuantity__c) {
        this.showToast("Error", "Not enough stock available", "error");
        return;
      }
      existingLine.amount += 1;
      existingLine.lineTotal = existingLine.amount * existingLine.Price__c;
      this.cart = [...this.cart];
    } else {
      this.cart = [
        ...this.cart,
        {
          Id: item.Id,
          Name: item.Name,
          Price__c: item.Price__c,
          AvailableQuantity__c: item.AvailableQuantity__c,
          amount: 1,
          lineTotal: item.Price__c
        }
      ];
    }

    this.showToast("Success", `${item.Name} added to cart`, "success");
  }

  handleRemoveFromCart(event) {
    this.cart = this.cart.filter((line) => line.Id !== event.detail);
  }

  openCart() {
    this.isCartModalOpen = true;
  }

  handleCloseCart() {
    this.isCartModalOpen = false;
  }

  handleCheckout() {
    const lines = this.cart.map((line) => ({
      ItemId__c: line.Id,
      Amount__c: line.amount,
      UnitCost__c: line.Price__c
    }));

    checkout({ accountId: this.accountId, lines: lines })
      .then((purchase) => {
        this.showToast("Success", "Purchase created successfully", "success");
        this.cart = [];
        this.isCartModalOpen = false;
        this.loadItems();

        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: purchase.Id,
            objectApiName: "Purchase__c",
            actionName: "view"
          }
        });
      })
      .catch((error) => {
        this.showToast(
          "Error",
          error.body?.message || "Checkout failed",
          "error"
        );
      });
  }

  // ---------- Create Item ----------

  isCreateItemModalOpen = false;

  handleOpenCreateItem() {
    this.isCreateItemModalOpen = true;
  }

  handleCloseCreateItem() {
    this.isCreateItemModalOpen = false;
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
