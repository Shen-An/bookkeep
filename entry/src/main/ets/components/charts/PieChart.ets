import { PieSlice } from './ChartModels';

@Component
export struct PieChart {
  @Prop slices: PieSlice[] = [];
  @Prop chartHeight: number = 220;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  private palette: string[] = ['#3B82F6', '#22C55E', '#EF4444', '#F59E0B', '#8B5CF6', '#EC4899', '#06B6D4', '#84CC16'];

  private draw(width: number, height: number): void {
    if (width <= 0 || height <= 0) {
      return;
    }

    this.ctx.clearRect(0, 0, width, height);

    const total = this.slices.reduce((sum, s) => sum + (s.value ?? 0), 0);
    if (total <= 0 || this.slices.length === 0) {
      this.ctx.fillStyle = '#94A3B8';
      this.ctx.font = '13px sans-serif';
      this.ctx.textAlign = 'center';
      this.ctx.fillText('暂无占比数据', width / 2, height / 2 + 5);
      return;
    }

    const cx = width / 2;
    const cy = height / 2;
    const radius = Math.max(12, Math.min(width, height) / 2 - 12);

    let startAngle = -Math.PI / 2;
    this.slices.forEach((slice, idx) => {
      const v = slice.value ?? 0;
      const angle = v / total * Math.PI * 2;

      const color = slice.color ?? this.palette[idx % this.palette.length];
      this.ctx.fillStyle = color;
      this.ctx.beginPath();
      this.ctx.moveTo(cx, cy);
      this.ctx.arc(cx, cy, radius, startAngle, startAngle + angle);
      this.ctx.closePath();
      this.ctx.fill();

      // percentage label on slices >= 5%
      if (angle >= Math.PI * 2 * 0.05) {
        const labelAngle = startAngle + angle / 2;
        const labelRadius = radius * 0.7;
        const lx = cx + Math.cos(labelAngle) * labelRadius;
        const ly = cy + Math.sin(labelAngle) * labelRadius;
        this.ctx.fillStyle = '#ffffff';
        this.ctx.font = 'bold 13px sans-serif';
        this.ctx.textAlign = 'center';
        this.ctx.textBaseline = 'middle';
        // semi-transparent background for readability
        this.ctx.shadowColor = '#80000000';
        this.ctx.shadowBlur = 4;
        this.ctx.fillText(`${(v / total * 100).toFixed(1)}%`, lx, ly);
        this.ctx.shadowBlur = 0;
      }

      startAngle = startAngle + angle;
    });

    // donut hole
    this.ctx.fillStyle = '#ffffff';
    this.ctx.beginPath();
    this.ctx.arc(cx, cy, radius * 0.55, 0, Math.PI * 2);
    this.ctx.fill();

    // inner ring border for cleaner donut look
    this.ctx.strokeStyle = '#F1F5F9';
    this.ctx.lineWidth = 1;
    this.ctx.beginPath();
    this.ctx.arc(cx, cy, radius * 0.55, 0, Math.PI * 2);
    this.ctx.stroke();
  }

  build() {
    Column() {
      Canvas(this.ctx)
        .width('100%')
        .height(this.chartHeight)
        .onReady(() => {
          this.draw(320, this.chartHeight);
        })
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          const w: number = Number(newValue.width);
          const h: number = Number(newValue.height);
          if (w > 0 && h > 0) {
            this.draw(w, h);
          }
        })
    }
  }
}
