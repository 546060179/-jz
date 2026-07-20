// 注意：这里故意使用普通 import（非 @testable），
// 因此只能访问 public 符号。此文件能编译通过，即证明外部开发者
// `import FadeAnimation` 后可以正常使用这些公开 API。
import XCTest
import UIKit
import FadeAnimation

final class PublicAPISmokeTests: XCTestCase {

    func testFadeOptionsAndAnimatorsArePublic() {
        let view = UIView()

        // FadeOptions 公开初始化 + 令牌枚举
        let options = FadeOptions(duration: 300, timing: .t3, intent: .enter)
        _ = FadeAnimator(targetView: view, options: options)

        // MotionAnimator + EffectPresets + MotionEffect
        let animator = MotionAnimator(targetView: view, options: options)
        animator.start(entering: true, effects: EffectPresets.scaleFadeIn)
        let effects: [MotionEffect] = [.fade(from: 0, to: 1), .slide(direction: .up, distance: 16)]
        animator.start(entering: true, effects: effects)
        animator.cancel()

        // UIView 扩展
        view.fadeIn()
        view.motion(entering: true, effects: EffectPresets.slideUpIn)
    }

    func testSpringAPIsArePublic() {
        let solver = SpringSolver(config: SpringPresets.bouncy)
        let state: SpringState = solver.step(1.0 / 60.0)
        XCTAssertGreaterThanOrEqual(state.position, 0)
        _ = estimateSpringDuration(config: SpringConfig(stiffness: 200, damping: 20))

        let anim = SpringAnimator(config: SpringPresets.snappy)
        anim.start(onUpdate: { _ in }, onRest: nil)
        anim.stop()
    }

    func testOrchestrationAPIsArePublic() {
        let delays: [Int] = stagger(3, options: StaggerOptions(interval: 50, direction: .center))
        XCTAssertEqual(delays.count, 3)

        let plan: SequencePlan = planSequence([
            SequenceStep(effects: EffectPresets.fadeIn, duration: 200),
            SequenceStep(effects: EffectPresets.scaleFadeIn, delay: 50),
        ])
        XCTAssertEqual(plan.stepDelays.count, 2)
    }

    func testMotionLevelAndViewsArePublic() {
        ReducedMotionHelper.setMotionLevel(.reduced)
        ReducedMotionHelper.setMotionLevel(nil)

        let dots = TypingDotsView(config: TypingDotsConfig(count: 3))
        dots.startAnimating()
        dots.stopAnimating()

        _ = MarqueePulseAnimator(config: MarqueePulseConfig())
    }
}
