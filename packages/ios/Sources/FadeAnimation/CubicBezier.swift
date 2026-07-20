import UIKit
import QuartzCore

/// 与 CSS / WebKit `cubic-bezier()` 完全相同算法的三次贝塞尔缓动求值器。
///
/// 控制点固定为 P0=(0,0)、P3=(1,1)，仅 P1(c1)、P2(c2) 可配置，
/// 与 Web 端 `EASING_CURVES` 中的 `cubic-bezier(x1,y1,x2,y2)` 一一对应。
///
/// 用途：
/// - 通过 `timingFunction` 提供 `UIViewPropertyAnimator` 所需的控制点，
///   让 UIKit 动画曲线与 Web 端逐帧一致。
/// - 通过 `value(at:)` 为 CADisplayLink 驱动的帧动画（如 flip）提供
///   与 CSS 一致的缓动进度，替代粗糙的多项式近似。
struct CubicBezierCurve {
    let c1: CGPoint
    let c2: CGPoint

    init(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) {
        self.c1 = CGPoint(x: x1, y: y1)
        self.c2 = CGPoint(x: x2, y: y2)
    }

    /// 从 `CAMediaTimingFunction` 提取控制点构造。
    init(timingFunction: CAMediaTimingFunction) {
        var p1 = [Float](repeating: 0, count: 2)
        var p2 = [Float](repeating: 0, count: 2)
        timingFunction.getControlPoint(at: 1, values: &p1)
        timingFunction.getControlPoint(at: 2, values: &p2)
        self.c1 = CGPoint(x: CGFloat(p1[0]), y: CGFloat(p1[1]))
        self.c2 = CGPoint(x: CGFloat(p2[0]), y: CGFloat(p2[1]))
    }

    /// 转回 `CAMediaTimingFunction`。
    var timingFunction: CAMediaTimingFunction {
        CAMediaTimingFunction(
            controlPoints: Float(c1.x), Float(c1.y), Float(c2.x), Float(c2.y)
        )
    }

    /// 给定线性进度 t∈[0,1]，返回缓动后的进度 y∈[0,1]（与 CSS 逐帧一致）。
    func value(at t: CGFloat) -> CGFloat {
        let x = min(max(t, 0), 1)
        let u = solveForU(x)
        return sampleY(u)
    }

    // MARK: - WebKit UnitBezier polynomial form

    // x(u) = ((ax*u + bx)*u + cx)*u ；y(u) 同理
    private var cx: CGFloat { 3 * c1.x }
    private var bx: CGFloat { 3 * (c2.x - c1.x) - cx }
    private var ax: CGFloat { 1 - cx - bx }
    private var cy: CGFloat { 3 * c1.y }
    private var by: CGFloat { 3 * (c2.y - c1.y) - cy }
    private var ay: CGFloat { 1 - cy - by }

    private func sampleX(_ u: CGFloat) -> CGFloat { ((ax * u + bx) * u + cx) * u }
    private func sampleY(_ u: CGFloat) -> CGFloat { ((ay * u + by) * u + cy) * u }
    private func sampleDerivativeX(_ u: CGFloat) -> CGFloat { (3 * ax * u + 2 * bx) * u + cx }

    /// 用 Newton-Raphson 求解 x(u)=x 的参数 u，失败时回退二分。
    private func solveForU(_ x: CGFloat) -> CGFloat {
        var u = x
        for _ in 0..<8 {
            let dx = sampleX(u) - x
            if abs(dx) < 1e-6 { return u }
            let d = sampleDerivativeX(u)
            if abs(d) < 1e-6 { break }
            u -= dx / d
        }
        // 二分兜底
        var lo: CGFloat = 0
        var hi: CGFloat = 1
        u = x
        while lo < hi {
            let xU = sampleX(u)
            if abs(xU - x) < 1e-6 { return u }
            if x > xU { lo = u } else { hi = u }
            u = (lo + hi) / 2
            if hi - lo < 1e-6 { break }
        }
        return u
    }
}

/// 将 UIKit 的粗粒度 `UIView.AnimationCurve` 映射为对应的精确贝塞尔曲线，
/// 以便在没有显式 `timingFunction` 时仍走统一的 property-animator 路径。
extension CubicBezierCurve {
    init(animationCurve: UIView.AnimationCurve) {
        switch animationCurve {
        case .easeInOut: self.init(0.42, 0, 0.58, 1)
        case .easeIn:    self.init(0.42, 0, 1, 1)
        case .easeOut:   self.init(0, 0, 0.58, 1)
        case .linear:    self.init(0, 0, 1, 1)
        @unknown default: self.init(0.42, 0, 0.58, 1)
        }
    }
}
