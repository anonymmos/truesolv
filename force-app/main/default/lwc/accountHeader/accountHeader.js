import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";

import NAME_FIELD from "@salesforce/schema/Account.Name";
import ACCOUNT_NUMBER_FIELD from "@salesforce/schema/Account.AccountNumber";
import INDUSTRY_FIELD from "@salesforce/schema/Account.Industry";

const FIELDS = [NAME_FIELD, ACCOUNT_NUMBER_FIELD, INDUSTRY_FIELD];

export default class AccountHeader extends LightningElement {
  @api recordId;

  accountName;
  accountNumber;
  industry;

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
