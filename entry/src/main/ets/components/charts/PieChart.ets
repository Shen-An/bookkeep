import { PieSlice } from './ChartModels';

@Component
export struct PieChart {
  @Prop slices: PieSlice[] = [];
  @Prop chartHeight: number = 220;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  private lastWidth: number = 0;
  private lastHeight: number = 0;

  private palette: string[] = ['#1FA1FF', '#2CC4E1', '#FF7A7A', '#4CD97B', '#8B7CF6', '#FFB020', '#F46BA5', '#22C7A9'];

  private draw(width: number, height: number): void {
    if (width <= 0 || height <= 0) {
      return;
    }

    this.ctx.clearRect(0, 0, width, height);

    const total = this.slices.reduce((sum, s) => sum + (s.value ?? 0), 0);
    if (total <= 0 || this.slices.length === 0) {
      this.ctx.fillStyle = '#9aa4b2';
      this.ctx.font = '13px sans-serif';
      this.ctx.fillText('暂无占比数据', 16, 26);
      return;
    }

    const cx = width / 2;
    const cy = height / 2;
    const radius = Math.max(12, Math.min(width, height) / 2 - 12);

    let startAngle = -Math.PI / 2;
    this.slices.forEach((slice, idx) => {
      const v = slice.value ?? 0;
      const angle = v / total * Math.PI * 2;
      const endAngle = startAngle + angle;

      const color = slice.color ?? this.palette[idx % this.palette.length];
      this.ctx.fillStyle = color;
      this.ctx.beginPath();
      this.ctx.moveTo(cx, cy);
      this.ctx.arc(cx, cy, radius, startAngle, endAngle);
      this.ctx.closePath();
      this.ctx.fill();

      startAngle = endAngle;
    });

    // donut hole (视觉更清晰)
    this.ctx.fillStyle = '#ffffff';
    this.ctx.beginPath();
    this.ctx.arc(cx, cy, radius * 0.55, 0, Math.PI * 2);
    this.ctx.fill();
  }

  build() {
    Column() {
      Canvas(this.ctx)
        .width('100%')
        .height(this.chartHeight)
        .onReady(() => {
          this.lastWidth = 320;
          this.lastHeight = this.chartHeight;
          this.draw(this.lastWidth, this.lastHeight);
        })
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          const w: number = Number(newValue.width);
          const h: number = Number(newValue.height);
          this.lastWidth = w;
          this.lastHeight = h;
          this.draw(this.lastWidth, this.lastHeight);
        })
    }
  }
}
