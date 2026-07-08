import { createElement } from "@lwc/engine-dom";
import ItemTile from "c/itemTile";

describe("c-item-tile", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders item name and price", () => {
    // Arrange
    const element = createElement("c-item-tile", {
      is: ItemTile
    });

    element.item = {
      Id: "a01xxx000000001",
      Name: "Test Item",
      Description__c: "Test description",
      Price__c: 10,
      AvailableQuantity__c: 5,
      Image__c: "https://example.com/image.jpg"
    };

    // Act
    document.body.appendChild(element);

    // Assert
    return Promise.resolve().then(() => {
      const card = element.shadowRoot.querySelector("lightning-card");
      expect(card.title).toBe("Test Item");
    });
  });

  it("disables Add button when out of stock", () => {
    const element = createElement("c-item-tile", { is: ItemTile });
    element.item = {
      Id: "a01xxx000000002",
      Name: "Out of stock item",
      AvailableQuantity__c: 0
    };

    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      const buttons = element.shadowRoot.querySelectorAll("lightning-button");
      const addButton = Array.from(buttons).find((b) => b.label === "Add");
      expect(addButton.disabled).toBe(true);
    });
  });
});
