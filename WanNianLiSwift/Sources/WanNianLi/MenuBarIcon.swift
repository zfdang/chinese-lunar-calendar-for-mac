import AppKit

/// 菜单栏图标：一个小日历，中间显示今天的日期。
/// 使用模板图片，系统会自动适配浅色 / 深色菜单栏以及高亮状态。
enum MenuBarIcon {
    static func image(day: Int) -> NSImage {
        let size = NSSize(width: 20, height: 18)
        let image = NSImage(size: size, flipped: false) { _ in
            let body = NSRect(x: 1.5, y: 0.75, width: 17, height: 15.5)
            let outline = NSBezierPath(roundedRect: body, xRadius: 3, yRadius: 3)
            outline.lineWidth = 1.3
            NSColor.black.setStroke()
            outline.stroke()

            // 顶部的色条
            NSGraphicsContext.saveGraphicsState()
            outline.addClip()
            NSColor.black.setFill()
            NSRect(x: body.minX, y: body.maxY - 3.5, width: body.width, height: 3.5).fill()
            NSGraphicsContext.restoreGraphicsState()

            // 日期数字
            let text = String(format: "%02d", day) as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedDigitSystemFont(ofSize: 10.5, weight: .semibold),
                .foregroundColor: NSColor.black,
            ]
            let textSize = text.size(withAttributes: attributes)
            let area = NSRect(x: body.minX, y: body.minY, width: body.width, height: body.height - 3.5)
            text.draw(at: NSPoint(x: area.midX - textSize.width / 2, y: area.midY - textSize.height / 2 - 0.25),
                      withAttributes: attributes)
            return true
        }
        image.isTemplate = true
        return image
    }
}
