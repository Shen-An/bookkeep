export enum BillingDirection {
  IN, OUT
}

export interface BillingInfo {
  id?: number;
  type: string;
  amount: number;
  direction: BillingDirection;
  timestamp: number;
  remark?: string;
  image?: string;
}