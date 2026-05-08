export interface LineSeries {
  name: string;
  values: number[];
  color?: string;
}

export interface PieSlice {
  label: string;
  value: number;
  percent?: number; // 0-100
  color?: string;
}
