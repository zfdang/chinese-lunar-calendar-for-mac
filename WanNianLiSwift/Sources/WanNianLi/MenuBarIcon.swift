import AppKit

/// 菜单栏图标：一个小日历，中间显示今天的日期。
/// 使用模板图片，系统会自动适配浅色 / 深色菜单栏以及高亮状态。
enum MenuBarIcon {
    static func image(day: Int) -> NSImage {
        let size = NSSize(width: 20, height: 18)
        let image = NSImage(size: size, flipped: false) { _ in
            let body = NSRect(x: 1.5, y: 0.75, width: 17, height: 15.5)
            let topRadius: CGFloat = 2.5
            let bottomRadius: CGFloat = 1.5
            let headerHeight: CGFloat = 3
            let outline = NSBezierPath()
            outline.move(to: NSPoint(x: body.minX + bottomRadius, y: body.minY))
            outline.line(to: NSPoint(x: body.maxX - bottomRadius, y: body.minY))
            outline.appendArc(withCenter: NSPoint(x: body.maxX - bottomRadius, y: body.minY + bottomRadius),
                              radius: bottomRadius, startAngle: 270, endAngle: 360)
            outline.line(to: NSPoint(x: body.maxX, y: body.maxY - topRadius))
            outline.appendArc(withCenter: NSPoint(x: body.maxX - topRadius, y: body.maxY - topRadius),
                              radius: topRadius, startAngle: 0, endAngle: 90)
            outline.line(to: NSPoint(x: body.minX + topRadius, y: body.maxY))
            outline.appendArc(withCenter: NSPoint(x: body.minX + topRadius, y: body.maxY - topRadius),
                              radius: topRadius, startAngle: 90, endAngle: 180)
            outline.line(to: NSPoint(x: body.minX, y: body.minY + bottomRadius))
            outline.appendArc(withCenter: NSPoint(x: body.minX + bottomRadius, y: body.minY + bottomRadius),
                              radius: bottomRadius, startAngle: 180, endAngle: 270)
            outline.close()
            outline.lineWidth = 1.3
            NSColor.black.setStroke()
            outline.stroke()

            // 顶部的色条
            NSGraphicsContext.saveGraphicsState()
            outline.addClip()
            NSColor.black.setFill()
            NSRect(x: body.minX, y: body.maxY - headerHeight, width: body.width, height: headerHeight).fill()
            NSGraphicsContext.restoreGraphicsState()

            // 日期数字
            let text = String(format: "%02d", day) as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .semibold),
                .foregroundColor: NSColor.black,
            ]
            let textSize = text.size(withAttributes: attributes)
            // 按边框内侧居中，并稍微上移，给数字底部留出呼吸空间。
            let inset = outline.lineWidth / 2
            let area = NSRect(x: body.minX + inset, y: body.minY + inset,
                              width: body.width - inset * 2, height: body.height - headerHeight - inset)
            text.draw(at: NSPoint(x: area.midX - textSize.width / 2, y: area.midY - textSize.height / 2 + 0.15),
                      withAttributes: attributes)
            return true
        }
        image.isTemplate = true
        return image
    }
}
