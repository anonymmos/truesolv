import { LightningElement, api } from "lwc";

/**
 * Presentational component rendering a grid of c-item-tile components for the
 * given list of items.
 */
export default class ItemList extends LightningElement {
  /** @type {Array<Object>} items to render as tiles; nothing renders while falsy/empty. */
  @api items;
}
