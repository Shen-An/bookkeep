import { BillingType } from './BillingType';
export enum BillingDirection {
  IN, OUT
}

export interface BillingInfo {
  id?: number;
  type: BillingType;
  amount: number;
  direction: BillingDirection;
  timestamp: number;
  remark?: string;
  image?: string;
}