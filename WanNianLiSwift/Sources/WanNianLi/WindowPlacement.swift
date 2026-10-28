import CoreGraphics

/// 将窗口放在参考区域附近，并限制在屏幕可见区域内。
enum WindowPlacement {
    static func origin(size: CGSize, near anchor: CGRect, in visible: CGRect) -> CGPoint {
        let gap: CGFloat = 8
        let x: CGFloat
        let y: CGFloat
        if anchor.maxX + gap + size.width <= visible.maxX {
            x = anchor.maxX + gap
            y = anchor.maxY - size.height
        } else if anchor.minX - gap - size.width >= visible.minX {
            x = anchor.minX - gap - size.width
            y = anchor.maxY - size.height
        } else if anchor.minY - gap - size.height >= visible.minY {
            x = anchor.midX - size.width / 2
            y = anchor.minY - gap - size.height
        } else {
            x = anchor.midX - size.width / 2
            y = anchor.maxY - size.height
        }
        return CGPoint(x: min(max(x, visible.minX), max(visible.minX, visible.maxX - size.width)),
                       y: min(max(y, visible.minY), max(visible.minY, visible.maxY - size.height)))
    }
}
