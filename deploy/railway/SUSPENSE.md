# Suspense receipts

Money In now offers **Suspense receipt (pending review)**. Create or choose a dedicated **Suspense** account whose type is **Equity**. Save & Publish uses the existing cashflow transaction and ledger pipeline: debit the chosen bank/cash account, credit Suspense. It does not count as income and requires no schema migration.

The API accepts `transaction_type: "suspense_receipt"` through the existing banking transactions endpoint, with `credit_account_id` pointing to the Equity suspense account. Positive amounts and a bank/cash deposit account are required. Existing transaction types are unchanged.

Once the receipt is identified, create a manual journal referencing its original transaction number: debit Suspense and credit the appropriate final account. Do not record another bank receipt. This first version adds a manual Money In option; it does not add automated recognition or a one-click resolution workflow. Imported transactions can retain their existing uncategorized workflow, and bank rules do not automatically choose Suspense.

The production demo was restarted at the owner's request. Server and Webapp are pinned to `141b38c2c069f65fcc5dfb2d3deb0c1feccf3e3f`. CI accounting tests and both builds passed. A live fictional 1,000 USD receipt was verified: the demonstration bank and Equity Suspense both show 1,000 USD, while net income remains zero. Credentials and database contents are kept out of the repository.
