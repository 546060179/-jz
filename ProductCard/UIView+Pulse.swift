import UIKit

// MARK: - 脉冲动效扩展
// FadeAnimation 库目前不包含脉冲效果，此处补充实现。
// 建议后续集成回 FadeAnimation 库的 UIViewExtensions.swift 中，
// 作为 UIView.pulse(scale:duration:) 方法。

extension UIView {

    /// 脉冲效果：先缩小到指定比例，再弹回原始大小。
    /// - Parameters:
    ///   - scale: 缩小比例，默认 0.95
    ///   - duration: 单次动画时长，默认 0.1s（总时长 = duration × 2）
    ///   - completion: 动画完成回调
    func pulse(scale: CGFloat = 0.95, duration: TimeInterval = 0.1, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        ) { _ in
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: [.curveEaseOut],
                animations: {
                    self.transform = .identity
                },
                completion: { _ in
                    completion?()
                }
            )
        }
    }
}
