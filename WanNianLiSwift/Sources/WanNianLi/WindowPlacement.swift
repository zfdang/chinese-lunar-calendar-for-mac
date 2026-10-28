import CoreGraphics

/// 将窗口放在屏幕可见区域的中央。
enum WindowPlacement {
    static func centeredOrigin(size: CGSize, in visible: CGRect) -> CGPoint {
        CGPoint(x: max(visible.minX, visible.midX - size.width / 2),
                y: max(visible.minY, visible.midY - size.height / 2))
    }
}
