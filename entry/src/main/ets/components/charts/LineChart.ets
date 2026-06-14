import { LineSeries } from './ChartModels';

interface ChartPoint {
  x: number;
  y: number;
}

@Component
export struct LineChart {
  @Prop series: LineSeries[] = [];
  @Prop chartHeight: number = 200;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  private draw(width: number, height: number): void {
    if (width <= 0 || height <= 0) {
      return;
    }

    this.ctx.clearRect(0, 0, width, height);

    const paddingLeft = 48;
    const paddingRight = 18;
    const paddingTop = 18;
    const paddingBottom = 28;

    const chartW = Math.max(1, width - paddingLeft - paddingRight);
    const chartH = Math.max(1, height - paddingTop - paddingBottom);

    const maxLen = this.series.reduce((m, s) => Math.max(m, s.values.length), 0);
    if (maxLen <= 1) {
      this.ctx.fillStyle = '#94A3B8';
      this.ctx.font = '13px sans-serif';
      this.ctx.textAlign = 'center';
      this.ctx.fillText('暂无趋势数据', width / 2, paddingTop + 18);
      return;
    }

    let maxValue = 0;
    this.series.forEach(s => s.values.forEach(v => maxValue = Math.max(maxValue, v)));
    if (maxValue <= 0) {
      maxValue = 1;
    }

    // horizontal grid lines
    const gridCount = 4;
    this.ctx.strokeStyle = '#F1F5F9';
    this.ctx.lineWidth = 1;
    for (let g = 0; g <= gridCount; g++) {
      const gy = paddingTop + chartH * (1 - g / gridCount);
      this.ctx.beginPath();
      this.ctx.moveTo(paddingLeft, gy);
      this.ctx.lineTo(paddingLeft + chartW, gy);
      this.ctx.stroke();

      // Y labels
      this.ctx.fillStyle = '#94A3B8';
      this.ctx.font = '10px sans-serif';
      this.ctx.textAlign = 'right';
      this.ctx.fillText((maxValue * g / gridCount).toFixed(0), paddingLeft - 6, gy + 3);
    }

    const dx = chartW / Math.max(1, maxLen - 1);

    this.series.forEach((s, idx) => {
      const color = s.color ?? (idx === 0 ? '#3B82F6' : '#22C55E');
      this.ctx.strokeStyle = color;
      this.ctx.lineWidth = 2.5;
      this.ctx.lineJoin = 'round';
      this.ctx.lineCap = 'round';

      // build point array
      let pts: ChartPoint[] = [];
      for (let i = 0; i < maxLen; i++) {
        const v = s.values[i] ?? 0;
        pts.push({
          x: paddingLeft + dx * i,
          y: paddingTop + chartH * (1 - v / maxValue)
        });
      }

      // draw smooth bezier curve
      this.ctx.beginPath();
      this.ctx.moveTo(pts[0].x, pts[0].y);
      for (let i = 0; i < pts.length - 1; i++) {
        const p0 = pts[i];
        const p1 = pts[i + 1];
        const cp1x = p0.x + (p1.x - p0.x) / 2;
        const cp1y = p0.y;
        const cp2x = p0.x + (p1.x - p0.x) / 2;
        const cp2y = p1.y;
        this.ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, p1.x, p1.y);
      }
      this.ctx.stroke();

      // scatter dots (at each point)
      this.ctx.fillStyle = color;
      for (let i = 0; i < pts.length; i++) {
        this.ctx.beginPath();
        this.ctx.arc(pts[i].x, pts[i].y, 3.5, 0, Math.PI * 2);
        this.ctx.fill();
        // white border dot
        this.ctx.strokeStyle = '#ffffff';
        this.ctx.lineWidth = 1.5;
        this.ctx.beginPath();
        this.ctx.arc(pts[i].x, pts[i].y, 3.5, 0, Math.PI * 2);
        this.ctx.stroke();
      }
    });
  }

  build() {
    Column() {
      Canvas(this.ctx)
        .width('100%')
        .height(this.chartHeight)
        .onReady(() => {
          this.draw(360, this.chartHeight);
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
