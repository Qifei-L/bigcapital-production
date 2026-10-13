import { Account } from '@/modules/Accounts/models/Account.model';
import { ACCOUNT_TYPE } from '@/constants/accounts';
import { BankTransaction } from '../models/BankTransaction';
import { CASHFLOW_TRANSACTION_TYPE } from '../constants';
import { CommandBankTransactionValidator } from './CommandCasflowValidator.service';
import { BankTransactionGL } from './BankTransactionGL';

const account = (id: number, accountType: string) =>
  Object.assign(new Account(), { id, accountType, currencyCode: 'USD' });

describe('Suspense receipts in Equity', () => {
  const validator = new CommandBankTransactionValidator();
  const type = CASHFLOW_TRANSACTION_TYPE.SUSPENSE_RECEIPT;

  it('accepts Equity and rejects income and liability counterpart accounts', () => {
    expect(() =>
      validator.validateCreditAccountWithCashflowType(
        account(2, ACCOUNT_TYPE.EQUITY),
        type,
      ),
    ).not.toThrow();
    for (const invalid of [
      ACCOUNT_TYPE.INCOME,
      ACCOUNT_TYPE.OTHER_CURRENT_LIABILITY,
      ACCOUNT_TYPE.BANK,
    ]) {
      expect(() =>
        validator.validateCreditAccountWithCashflowType(
          account(2, invalid),
          type,
        ),
      ).toThrow();
    }
  });

  it('rejects nonpositive receipts and noncash deposit accounts', () => {
    for (const amount of [0, -10, NaN, Infinity]) {
      expect(() =>
        validator.validateSuspenseReceipt(
          amount,
          account(1, ACCOUNT_TYPE.BANK),
        ),
      ).toThrow();
    }
    expect(() =>
      validator.validateSuspenseReceipt(100, account(1, ACCOUNT_TYPE.INCOME)),
    ).toThrow();
    expect(() =>
      validator.validateSuspenseReceipt(100, account(1, ACCOUNT_TYPE.CASH)),
    ).not.toThrow();
  });

  it('debits the bank and credits Suspense with balanced converted amounts', () => {
    const bank = account(1, ACCOUNT_TYPE.BANK);
    const suspense = account(2, ACCOUNT_TYPE.EQUITY);
    const transaction = Object.assign(new BankTransaction(), {
      id: 10,
      transactionType: type,
      amount: 100,
      exchangeRate: 1.25,
      cashflowAccountId: bank.id,
      creditAccountId: suspense.id,
      cashflowAccount: bank,
      creditAccount: suspense,
      currencyCode: 'USD',
      date: new Date('2026-10-13'),
    });
    const entries = new BankTransactionGL(transaction)
      .getCashflowLedger()
      .getEntries();
    expect(entries).toHaveLength(2);
    expect(entries[0]).toMatchObject({
      accountId: bank.id,
      debit: 125,
      credit: 0,
    });
    expect(entries[1]).toMatchObject({
      accountId: suspense.id,
      debit: 0,
      credit: 125,
    });
    expect(
      entries.reduce((sum, entry) => sum + entry.debit - entry.credit, 0),
    ).toBe(0);
    expect(suspense.isPLSheet).toBe(false);
  });
});
