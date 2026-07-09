import { LightningElement, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getItems from "@salesforce/apex/ItemController.getItems";
import checkout from "@salesforce/apex/PurchaseController.checkout";
import isCurrentUserManager from "@salesforce/apex/UserController.isCurrentUserManager";

/**
 * Root component for the Item Purchase Tool: loads the item catalog and
 * current user's manager status, applies search/filter criteria, manages the
 * shopping cart, and drives the details/cart/create-item modals through to
 * checkout.
 */
export default class ItemPurchaseTool extends NavigationMixin(
  LightningElement
) {
  /** @type {string} Id of the Account this tool is running in the context of, from the page reference state. */
  accountId;
  /** @type {Array<Object>} full unfiltered list of Item__c records loaded from the server. */
  items = [];
  /** @type {Array<Object>} cart line entries, each with Id, Name, Price__c, AvailableQuantity__c, amount, and lineTotal. */
  cart = [];

  selectedFamily = "";
  selectedType = "";
  searchText = "";

  selectedItem;
  isDetailsModalOpen = false;
  isCartModalOpen = false;

  isManager = false;

  /**
   * Wire adapter callback reading the c__accountId state parameter from the
   * current page reference (e.g. a Visualforce/Community page URL) into accountId.
   * @param {Object} currentPageReference the current page reference, if available.
   */
  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.accountId = currentPageReference.state.c__accountId;
    }
  }

  /** Lifecycle hook: kicks off the initial item catalog and user-role loads. */
  connectedCallback() {
    this.loadItems();
    this.loadUserRole();
  }

  /**
   * Loads the item catalog from ItemController.getItems into this.items.
   * Side effects: performs an Apex call; logs to console on failure.
   */
  loadItems() {
    getItems()
      .then((result) => {
        this.items = result;
      })
      .catch((error) => {
        console.error("Error loading items", error);
      });
  }

  /**
   * Loads the current user's manager flag from UserController.isCurrentUserManager
   * into this.isManager.
   * Side effects: performs an Apex call; logs to console on failure.
   */
  loadUserRole() {
    isCurrentUserManager()
      .then((result) => {
        this.isManager = result;
      })
      .catch((error) => console.error(error));
  }

  /**
   * @returns {Array<Object>} this.items filtered by selectedFamily, selectedType,
   *   and a case-insensitive match of searchText against Name/Description__c.
   */
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

  /** @returns {number} count of items matching the current filters/search. */
  get itemCount() {
    return this.filteredItems.length;
  }

  /** @returns {number} number of distinct line entries currently in the cart. */
  get cartCount() {
    return this.cart.length;
  }

  /**
   * Updates the selected family/type filters from the filter panel.
   * @param {CustomEvent} event filterchange event; event.detail has family and type.
   */
  handleFilterChange(event) {
    this.selectedFamily = event.detail.family;
    this.selectedType = event.detail.type;
  }

  /**
   * Updates the free-text search filter from the filter panel.
   * @param {CustomEvent} event search event; event.detail is the search text.
   */
  handleSearch(event) {
    this.searchText = event.detail;
  }

  // ---------- Details ----------

  /**
   * Opens the details modal for the item whose Id was included in the event.
   * @param {CustomEvent} event details event; event.detail is the item's Id.
   */
  handleDetails(event) {
    const itemId = event.detail;
    this.selectedItem = this.items.find((i) => i.Id === itemId);
    this.isDetailsModalOpen = true;
  }

  /** Closes the item details modal. No parameters/return value. */
  handleCloseDetails() {
    this.isDetailsModalOpen = false;
  }

  // ---------- Cart ----------

  /**
   * Adds the given item to the cart, or increments its quantity by 1 if
   * already present. Rejects the increment (with an error toast) if it would
   * exceed the item's AvailableQuantity__c.
   * @param {CustomEvent} event addtocart event; event.detail is the Item__c record.
   * Side effects: mutates this.cart; shows a success or error toast.
   */
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

  /**
   * Removes the cart line matching the given item Id.
   * @param {CustomEvent} event remove event; event.detail is the item's Id to remove.
   */
  handleRemoveFromCart(event) {
    this.cart = this.cart.filter((line) => line.Id !== event.detail);
  }

  /** Opens the cart modal. No parameters/return value. */
  openCart() {
    this.isCartModalOpen = true;
  }

  /** Closes the cart modal. No parameters/return value. */
  handleCloseCart() {
    this.isCartModalOpen = false;
  }

  /**
   * Submits the current cart as a purchase via PurchaseController.checkout,
   * then clears the cart, closes the cart modal, refreshes the item list, and
   * navigates to the newly created Purchase__c record.
   * No parameters.
   * Side effects: performs an Apex callout/DML (via checkout); on success,
   *   mutates this.cart/isCartModalOpen, reloads items, shows a success toast,
   *   and navigates away; on failure, shows an error toast only.
   */
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

  /** @type {boolean} whether the create-item modal is currently open. */
  isCreateItemModalOpen = false;

  /** Opens the create-item modal. No parameters/return value. */
  handleOpenCreateItem() {
    this.isCreateItemModalOpen = true;
  }

  /** Closes the create-item modal. No parameters/return value. */
  handleCloseCreateItem() {
    this.isCreateItemModalOpen = false;
  }

  /**
   * Handles successful item creation: closes the create-item modal, reloads
   * the item catalog, and shows a success toast. No parameters/return value.
   */
  handleItemCreated() {
    this.isCreateItemModalOpen = false;
    this.loadItems();

    this.showToast("Success", "Item created successfully", "success");
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
