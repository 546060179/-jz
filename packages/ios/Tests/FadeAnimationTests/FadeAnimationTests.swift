import XCTest
import UIKit
@testable import FadeAnimation

final class ResolveConfigTests: XCTestCase {

    // --- 默认值 ---
    func testDefaultValues() {
        let c = resolveConfigInternal(options: FadeOptions(), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.3, accuracy: 0.001)
        XCTAssertEqual(c.delay, 0.0, accuracy: 0.001)
        XCTAssertEqual(c.curve, UIView.AnimationCurve.easeInOut)
        XCTAssertFalse(c.reducedMotion)
    }

    // --- 自定义值 ---
    func testCustomDuration() {
        let c = resolveConfigInternal(options: FadeOptions(duration: 500), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.5, accuracy: 0.001)
    }

    func testCustomDelay() {
        let c = resolveConfigInternal(options: FadeOptions(delay: 100), motionLevel: .full)
        XCTAssertEqual(c.delay, 0.1, accuracy: 0.001)
    }

    func testZeroDuration() {
        let c = resolveConfigInternal(options: FadeOptions(duration: 0), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.0, accuracy: 0.001)
    }

    func testCustomCurve() {
        let c = resolveConfigInternal(options: FadeOptions(curve: .linear), motionLevel: .full)
        XCTAssertEqual(c.curve, UIView.AnimationCurve.linear)
    }

    // --- 负数回退 ---
    func testNegativeDurationFallsBack() {
        let c = resolveConfigInternal(options: FadeOptions(duration: -100), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.3, accuracy: 0.001)
    }

    func testNegativeDelayFallsBack() {
        let c = resolveConfigInternal(options: FadeOptions(delay: -50), motionLevel: .full)
        XCTAssertEqual(c.delay, 0.0, accuracy: 0.001)
    }

    // --- Preset ---
    func testPresetFast() {
        let c = resolveConfigInternal(options: FadeOptions(preset: .fast), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.15, accuracy: 0.001)
    }

    func testPresetNormal() {
        let c = resolveConfigInternal(options: FadeOptions(preset: .normal), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.3, accuracy: 0.001)
    }

    func testPresetSlow() {
        let c = resolveConfigInternal(options: FadeOptions(preset: .slow), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.5, accuracy: 0.001)
    }

    func testCustomDurationOverridesPreset() {
        let c = resolveConfigInternal(options: FadeOptions(duration: 200, preset: .slow), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.2, accuracy: 0.001)
    }

    // --- Timing Scale ---
    func testTimingT1() {
        let c = resolveConfigInternal(options: FadeOptions(timing: .t1), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.1, accuracy: 0.001)
    }

    func testTimingT3() {
        let c = resolveConfigInternal(options: FadeOptions(timing: .t3), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.3, accuracy: 0.001)
    }

    func testTimingT5() {
        let c = resolveConfigInternal(options: FadeOptions(timing: .t5), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.7, accuracy: 0.001)
    }

    func testCustomDurationOverridesTiming() {
        let c = resolveConfigInternal(options: FadeOptions(duration: 200, timing: .t5), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.2, accuracy: 0.001)
    }

    func testTimingOverridesPreset() {
        // preset before timing in struct order
        let c = resolveConfigInternal(options: FadeOptions(preset: .slow, timing: .t1), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.1, accuracy: 0.001)
    }

    // --- Motion Intent ---
    func testIntentEnter() {
        let c = resolveConfigInternal(options: FadeOptions(intent: .enter), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.3, accuracy: 0.001)
        XCTAssertEqual(c.curve, UIView.AnimationCurve.easeOut)
    }

    func testIntentExit() {
        let c = resolveConfigInternal(options: FadeOptions(intent: .exit), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.15, accuracy: 0.001)
        XCTAssertEqual(c.curve, UIView.AnimationCurve.easeIn)
    }

    func testIntentFeedback() {
        let c = resolveConfigInternal(options: FadeOptions(intent: .feedback), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.1, accuracy: 0.001)
    }

    func testIntentDelight() {
        let c = resolveConfigInternal(options: FadeOptions(intent: .delight), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.5, accuracy: 0.001)
    }

    func testCustomDurationOverridesIntent() {
        let c = resolveConfigInternal(options: FadeOptions(duration: 200, intent: .delight), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.2, accuracy: 0.001)
    }

    func testTimingOverridesIntent() {
        let c = resolveConfigInternal(options: FadeOptions(timing: .t1, intent: .delight), motionLevel: .full)
        XCTAssertEqual(c.duration, 0.1, accuracy: 0.001)
    }

    func testIntentSetsCurve() {
        let c = resolveConfigInternal(options: FadeOptions(intent: .enter), motionLevel: .full)
        XCTAssertEqual(c.curve, UIView.AnimationCurve.easeOut)
    }

    func testCustomCurveOverridesIntent() {
        let c = resolveConfigInternal(options: FadeOptions(curve: .linear, intent: .enter), motionLevel: .full)
        XCTAssertEqual(c.curve, UIView.AnimationCurve.linear)
    }

    // --- Motion Level: NONE（完全跳过，duration/delay 归零）---
    func testMotionLevelNoneZerosDurationAndDelay() {
        let c = resolveConfigInternal(options: FadeOptions(duration: 500, delay: 200), motionLevel: .none)
        XCTAssertEqual(c.duration, 0.0, accuracy: 0.001)
        XCTAssertEqual(c.delay, 0.0, accuracy: 0.001)
        XCTAssertTrue(c.reducedMotion)
    }

    func testMotionLevelNoneWithIntent() {
        let c = resolveConfigInternal(options: FadeOptions(intent: .delight), motionLevel: .none)
        XCTAssertEqual(c.duration, 0.0, accuracy: 0.001)
        XCTAssertTrue(c.reducedMotion)
    }

    // --- Motion Level: REDUCED（时长 clamp 到 100ms，delay 归零）---
    func testMotionLevelReducedClampsDuration() {
        let c = resolveConfigInternal(options: FadeOptions(duration: 500, delay: 200), motionLevel: .reduced)
        XCTAssertEqual(c.duration, 0.1, accuracy: 0.001)
        XCTAssertEqual(c.delay, 0.0, accuracy: 0.001)
        XCTAssertTrue(c.reducedMotion)
    }

    func testMotionLevelReducedKeepsShortDuration() {
        let c = resolveConfigInternal(options: FadeOptions(duration: 50), motionLevel: .reduced)
        XCTAssertEqual(c.duration, 0.05, accuracy: 0.001)
        XCTAssertTrue(c.reducedMotion)
    }

    func testMotionLevelReducedWithIntent() {
        let c = resolveConfigInternal(options: FadeOptions(intent: .delight), motionLevel: .reduced)
        XCTAssertEqual(c.duration, 0.1, accuracy: 0.001) // 500ms clamped to 100ms
        XCTAssertTrue(c.reducedMotion)
    }
}
