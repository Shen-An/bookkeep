import { LineSeries } from './ChartModels';

@Component
export struct LineChart {
  @Prop series: LineSeries[] = [];
  @Prop chartHeight: number = 200;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  private lastWidth: number = 0;
  private lastHeight: number = 0;

  private draw(width: number, height: number): void {
    if (width <= 0 || height <= 0) {
      return;
    }

    this.ctx.clearRect(0, 0, width, height);

    const paddingLeft = 44;
    const paddingRight = 18;
    const paddingTop = 14;
    const paddingBottom = 26;

    const chartW = Math.max(1, width - paddingLeft - paddingRight);
    const chartH = Math.max(1, height - paddingTop - paddingBottom);

    const maxLen = this.series.reduce((m, s) => Math.max(m, s.values.length), 0);
    if (maxLen <= 1) {
      this.ctx.fillStyle = '#9aa4b2';
      this.ctx.font = '13px sans-serif';
      this.ctx.fillText('暂无趋势数据', paddingLeft, paddingTop + 18);
      return;
    }

    let maxValue = 0;
    this.series.forEach(s => s.values.forEach(v => maxValue = Math.max(maxValue, v)));
    if (maxValue <= 0) {
      maxValue = 1;
    }

    // axes
    this.ctx.strokeStyle = '#d9e2ec';
    this.ctx.lineWidth = 1;
    this.ctx.beginPath();
    this.ctx.moveTo(paddingLeft, paddingTop);
    this.ctx.lineTo(paddingLeft, paddingTop + chartH);
    this.ctx.lineTo(paddingLeft + chartW, paddingTop + chartH);
    this.ctx.stroke();

    // y labels (0 and max)
    this.ctx.fillStyle = '#7b8798';
    this.ctx.font = '10px sans-serif';
    this.ctx.fillText(maxValue.toFixed(0), 4, paddingTop + 10);
    this.ctx.fillText('0', 16, paddingTop + chartH + 4);

    const dx = chartW / (maxLen - 1);

    this.series.forEach((s, idx) => {
      const color = s.color ?? (idx === 0 ? '#1FA1FF' : '#2CC4E1');
      this.ctx.strokeStyle = color;
      this.ctx.lineWidth = 2;
      this.ctx.beginPath();
      for (let i = 0; i < maxLen; i++) {
        const v = s.values[i] ?? 0;
        const x = paddingLeft + dx * i;
        const y = paddingTop + chartH * (1 - v / maxValue);
        if (i === 0) {
          this.ctx.moveTo(x, y);
        } else {
          this.ctx.lineTo(x, y);
        }
      }
      this.ctx.stroke();

      // points
      this.ctx.fillStyle = color;
      for (let i = 0; i < maxLen; i += Math.max(1, Math.floor(maxLen / 6))) {
        const v = s.values[i] ?? 0;
        const x = paddingLeft + dx * i;
        const y = paddingTop + chartH * (1 - v / maxValue);
        this.ctx.beginPath();
        this.ctx.arc(x, y, 2.5, 0, Math.PI * 2);
        this.ctx.fill();
      }
    });
  }

  build() {
    Column() {
      Canvas(this.ctx)
        .width('100%')
        .height(this.chartHeight)
        .onReady(() => {
          // 初次渲染时，用一个保守尺寸绘制，实际尺寸变化后会在 onAreaChange 里重绘。
          this.lastWidth = 360;
          this.lastHeight = this.chartHeight;
          this.draw(this.lastWidth, this.lastHeight);
        })
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          // Area 的 width/height 在不同 SDK 上类型可能不同，这里做最简单的 number 处理。
          const w: number = Number(newValue.width);
          const h: number = Number(newValue.height);
          this.lastWidth = w;
          this.lastHeight = h;
          this.draw(this.lastWidth, this.lastHeight);
        })
    }
  }
}
