import XCTest
import UIKit
@testable import FadeAnimation

/// 库内预置动效组件的黑盒冒烟测试。
///
/// 验证 4+1 个库外效果组件的 public API 可正常实例化、设置属性、触发动画不崩溃。
/// 对齐 `docs/components.html` 中各效果的 iOS swift 示例代码。
final class NativeComponentsSmokeTests: XCTestCase {

    func testBubbleExpandView() {
        let bubble = BubbleExpandView()
        bubble.text = "限时免费"
        bubble.expandDuration = 0.65
        bubble.textFadeDuration = 0.3
        bubble.showArrow = true
        bubble.arrowDirection = .right
        bubble.frame = CGRect(x: 0, y: 0, width: 20, height: 22)
        bubble.play()   // 启动 CADisplayLink，不应崩溃
        bubble.stop()
        XCTAssertEqual(bubble.text, "限时免费")
    }

    func testToastView() {
        let toast = ToastView(message: "操作成功")
        XCTAssertEqual(toast.message, "操作成功")
        toast.message = "已保存"
        XCTAssertEqual(toast.message, "已保存")
    }

    func testSpotlightOverlayView() {
        let host = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        let overlay = SpotlightOverlayView(
            targetRect: CGRect(x: 100, y: 200, width: 80, height: 40),
            tipText: "点击这里发布"
        )
        host.addSubview(overlay)
        // didMoveToSuperview 后应自动铺满父视图
        XCTAssertEqual(overlay.superview, host)
        XCTAssertEqual(overlay.frame, host.bounds)
    }

    func testContinueWatchingView() {
        let bar = ContinueWatchingView(frame: CGRect(x: 0, y: 0, width: 300, height: 56))
        bar.configure(cover: nil, title: "Genius Baby", subtitle: "EP.1 / EP.100")
        XCTAssertEqual(bar.phase, .hidden)
        bar.show()   // 触发 5 阶段序列，同步部分进入 slidingUp
        XCTAssertEqual(bar.phase, .slidingUp)
        bar.dismiss()
    }

    func testNotificationBanner() {
        let banner = NotificationBanner(title: "新消息")
        XCTAssertEqual(banner.title, "新消息")
        banner.title = "系统通知"
        XCTAssertEqual(banner.title, "系统通知")
    }
}
