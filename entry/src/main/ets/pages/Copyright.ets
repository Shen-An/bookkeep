@Entry
@Component
struct Copyright {
  build(){
    Row(){
      Column(){
        Image($r("app.media.authorAvatar")).width(128).height(128).border({
          width: 2,
          color: 'white',
          radius: 64
        })
        Text("肥肥梨猫")
          .fontSize(24)
          .margin(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('white')
        Text("Email: dev@peercat.cn")
          .fontColor('white')
          .margin(12)
          .fontColor('white')
      }.width('100%')
    }.height('100%').linearGradient({
      angle: 180,
      colors: [
        ["#255BFF", 0],
        ["#ffffff", 1]
      ],
      repeating: false
    })
  }
}