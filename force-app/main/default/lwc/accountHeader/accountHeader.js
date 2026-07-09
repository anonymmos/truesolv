import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";

import NAME_FIELD from "@salesforce/schema/Account.Name";
import ACCOUNT_NUMBER_FIELD from "@salesforce/schema/Account.AccountNumber";
import INDUSTRY_FIELD from "@salesforce/schema/Account.Industry";

const FIELDS = [NAME_FIELD, ACCOUNT_NUMBER_FIELD, INDUSTRY_FIELD];

/**
 * Displays basic Account information (Name, Account Number, Industry) for a
 * given record Id, sourced via the UI Record API wire adapter.
 */
export default class AccountHeader extends LightningElement {
  /** @type {string} Id of the Account record to display. */
  @api recordId;

  accountName;
  accountNumber;
  industry;

  /**
   * Wire adapter callback populating accountName/accountNumber/industry
   * whenever the Account record for recordId is (re)loaded.
   *
   * @param {Object} result
   * @param {Object} [result.data] the loaded Account record data, keyed by field.
   * @param {Object} [result.error] error info if the record load failed.
   * Side effects: logs errors to the console; no return value.
   */
  @wire(getRecord, {
    recordId: "$recordId",
    fields: FIELDS
  })
  wiredAccount({ data, error }) {
    if (data) {
      this.accountName = data.fields.Name.value;
      this.accountNumber = data.fields.AccountNumber.value;
      this.industry = data.fields.Industry.value;
    }

    if (error) {
      console.error(error);
    }
  }
}
