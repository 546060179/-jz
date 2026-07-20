import XCTest
@testable import FadeAnimation

/// 验证 iOS stagger / planSequence 与 Web 端 @fade-animation/core 数值一致。
/// 断言镜像 core 的 stagger.test.ts 与 sequence.test.ts。
final class StaggerSequenceTests: XCTestCase {

    // MARK: - stagger

    func testEmptyForZeroCount() {
        XCTAssertEqual(stagger(0, options: StaggerOptions(interval: 50)), [])
    }

    func testEmptyForNegativeCount() {
        XCTAssertEqual(stagger(-1, options: StaggerOptions(interval: 50)), [])
    }

    func testSingleElement() {
        XCTAssertEqual(stagger(1, options: StaggerOptions(interval: 50)), [0])
    }

    func testForward() {
        XCTAssertEqual(stagger(5, options: StaggerOptions(interval: 50)), [0, 50, 100, 150, 200])
    }

    func testForwardBaseDelay() {
        XCTAssertEqual(stagger(3, options: StaggerOptions(interval: 50, baseDelay: 100)), [100, 150, 200])
    }

    func testReverse() {
        XCTAssertEqual(
            stagger(5, options: StaggerOptions(interval: 50, direction: .reverse)),
            [200, 150, 100, 50, 0]
        )
    }

    func testCenterOdd() {
        XCTAssertEqual(
            stagger(5, options: StaggerOptions(interval: 50, direction: .center)),
            [100, 50, 0, 50, 100]
        )
    }

    func testCenterEven() {
        XCTAssertEqual(
            stagger(4, options: StaggerOptions(interval: 50, direction: .center)),
            [75, 25, 25, 75]
        )
    }

    func testCenterBaseDelay() {
        XCTAssertEqual(
            stagger(3, options: StaggerOptions(interval: 50, baseDelay: 200, direction: .center)),
            [250, 200, 250]
        )
    }

    func testNegativeIntervalTreatedAsZero() {
        XCTAssertEqual(stagger(3, options: StaggerOptions(interval: -10)), [0, 0, 0])
    }

    func testNegativeBaseDelayTreatedAsZero() {
        XCTAssertEqual(stagger(3, options: StaggerOptions(interval: 50, baseDelay: -100)), [0, 50, 100])
    }

    // MARK: - planSequence

    func testSingleStep() {
        let plan = planSequence([SequenceStep(effects: EffectPresets.fadeIn)])
        XCTAssertEqual(plan.stepDelays, [0])
        XCTAssertEqual(plan.stepDurations, [300])
        XCTAssertEqual(plan.totalDuration, 300)
    }

    func testSequentialStepsDefaultDuration() {
        let plan = planSequence([
            SequenceStep(effects: EffectPresets.fadeIn),
            SequenceStep(effects: EffectPresets.scaleFadeIn),
            SequenceStep(effects: EffectPresets.slideUpIn),
        ])
        XCTAssertEqual(plan.stepDelays, [0, 300, 600])
        XCTAssertEqual(plan.totalDuration, 900)
    }

    func testCustomDurations() {
        let plan = planSequence([
            SequenceStep(effects: EffectPresets.fadeIn, duration: 200),
            SequenceStep(effects: EffectPresets.scaleFadeIn, duration: 100),
        ])
        XCTAssertEqual(plan.stepDelays, [0, 200])
        XCTAssertEqual(plan.stepDurations, [200, 100])
        XCTAssertEqual(plan.totalDuration, 300)
    }

    func testStepDelays() {
        let plan = planSequence([
            SequenceStep(effects: EffectPresets.fadeIn, duration: 200),
            SequenceStep(effects: EffectPresets.scaleFadeIn, duration: 100, delay: 50),
        ])
        XCTAssertEqual(plan.stepDelays, [0, 250])
        XCTAssertEqual(plan.totalDuration, 350)
    }

    func testCustomDefaultDuration() {
        let plan = planSequence([SequenceStep(effects: EffectPresets.fadeIn)], defaultDuration: 500)
        XCTAssertEqual(plan.stepDurations, [500])
        XCTAssertEqual(plan.totalDuration, 500)
    }

    func testEmptySteps() {
        let plan = planSequence([])
        XCTAssertEqual(plan.stepDelays, [])
        XCTAssertEqual(plan.totalDuration, 0)
    }
}
