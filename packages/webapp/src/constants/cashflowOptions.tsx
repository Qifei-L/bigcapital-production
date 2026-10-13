import intl from 'react-intl-universal';
import type { MenuItemOption } from './types';

export const getAddMoneyInOptions = (
  includeSuspense = false,
): MenuItemOption[] => [
  ...(includeSuspense
    ? [
        {
          name: intl.get('banking.suspense_receipt'),
          value: 'suspense_receipt',
        },
      ]
    : []),
  {
    name: intl.get('banking.owner_contribution'),
    value: 'owner_contribution',
  },
  {
    name: intl.get('banking.other_income'),
    value: 'other_income',
  },
  {
    name: intl.get('banking.transfer_form_account'),
    value: 'transfer_from_account',
  },
];

export const getAddMoneyOutOptions = (): MenuItemOption[] => [
  {
    name: intl.get('banking.owner_drawings'),
    value: 'owner_drawing',
  },
  {
    name: intl.get('banking.expenses'),
    value: 'other_expense',
  },
  {
    name: intl.get('banking.transfer_to_account'),
    value: 'transfer_to_account',
  },
];

export const TRANSACTIONS_TYPE: string[] = [
  'OwnerContribution',
  'OtherIncome',
  'SuspenseReceipt',
  'TransferFromAccount',
  'OwnerDrawing',
  'OtherExpense',
  'TransferToAccount',
];

export const MoneyCategoryPerCreditAccountRootType: Record<string, string[]> = {
  OwnerContribution: ['equity'],
  OtherIncome: ['income'],
  SuspenseReceipt: ['equity'],
  OwnerDrawing: ['equity'],
  OtherExpense: ['expense'],
  TransferToAccount: ['asset'],
  TransferFromAccount: ['asset'],
};
