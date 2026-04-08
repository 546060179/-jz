import XCTest
import UIKit
@testable import FadeAnimation

final class ResolveConfigTests: XCTestCase {

    // --- 默认值 ---
    func testDefaultValues() {
        let c = resolveConfigInternal(options: FadeOptions(), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.3, accuracy: 0.001)
        XCTAssertEqual(c.delay, 0.0, accuracy: 0.001)
        XCTAssertEqual(c.curve, UIView.AnimationCurve.easeInOut)
        XCTAssertFalse(c.reducedMotion)
    }

    // --- 自定义值 ---
    func testCustomDuration() {
        let c = resolveConfigInternal(options: FadeOptions(duration: 500), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.5, accuracy: 0.001)
    }

    func testCustomDelay() {
        let c = resolveConfigInternal(options: FadeOptions(delay: 100), isReducedMotion: false)
        XCTAssertEqual(c.delay, 0.1, accuracy: 0.001)
    }

    func testZeroDuration() {
        let c = resolveConfigInternal(options: FadeOptions(duration: 0), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.0, accuracy: 0.001)
    }

    func testCustomCurve() {
        let c = resolveConfigInternal(options: FadeOptions(curve: .linear), isReducedMotion: false)
        XCTAssertEqual(c.curve, UIView.AnimationCurve.linear)
    }

    // --- 负数回退 ---
    func testNegativeDurationFallsBack() {
        let c = resolveConfigInternal(options: FadeOptions(duration: -100), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.3, accuracy: 0.001)
    }

    func testNegativeDelayFallsBack() {
        let c = resolveConfigInternal(options: FadeOptions(delay: -50), isReducedMotion: false)
        XCTAssertEqual(c.delay, 0.0, accuracy: 0.001)
    }

    // --- Preset ---
    func testPresetFast() {
        let c = resolveConfigInternal(options: FadeOptions(preset: .fast), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.15, accuracy: 0.001)
    }

    func testPresetNormal() {
        let c = resolveConfigInternal(options: FadeOptions(preset: .normal), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.3, accuracy: 0.001)
    }

    func testPresetSlow() {
        let c = resolveConfigInternal(options: FadeOptions(preset: .slow), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.5, accuracy: 0.001)
    }

    func testCustomDurationOverridesPreset() {
        let c = resolveConfigInternal(options: FadeOptions(duration: 200, preset: .slow), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.2, accuracy: 0.001)
    }

    // --- Timing Scale ---
    func testTimingT1() {
        let c = resolveConfigInternal(options: FadeOptions(timing: .t1), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.1, accuracy: 0.001)
    }

    func testTimingT3() {
        let c = resolveConfigInternal(options: FadeOptions(timing: .t3), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.3, accuracy: 0.001)
    }

    func testTimingT5() {
        let c = resolveConfigInternal(options: FadeOptions(timing: .t5), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.7, accuracy: 0.001)
    }

    func testCustomDurationOverridesTiming() {
        let c = resolveConfigInternal(options: FadeOptions(duration: 200, timing: .t5), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.2, accuracy: 0.001)
    }

    func testTimingOverridesPreset() {
        // preset before timing in struct order
        let c = resolveConfigInternal(options: FadeOptions(preset: .slow, timing: .t1), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.1, accuracy: 0.001)
    }

    // --- Motion Intent ---
    func testIntentEnter() {
        let c = resolveConfigInternal(options: FadeOptions(intent: .enter), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.3, accuracy: 0.001)
        XCTAssertEqual(c.curve, UIView.AnimationCurve.easeOut)
    }

    func testIntentExit() {
        let c = resolveConfigInternal(options: FadeOptions(intent: .exit), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.15, accuracy: 0.001)
        XCTAssertEqual(c.curve, UIView.AnimationCurve.easeIn)
    }

    func testIntentFeedback() {
        let c = resolveConfigInternal(options: FadeOptions(intent: .feedback), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.1, accuracy: 0.001)
    }

    func testIntentDelight() {
        let c = resolveConfigInternal(options: FadeOptions(intent: .delight), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.5, accuracy: 0.001)
    }

    func testCustomDurationOverridesIntent() {
        let c = resolveConfigInternal(options: FadeOptions(duration: 200, intent: .delight), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.2, accuracy: 0.001)
    }

    func testTimingOverridesIntent() {
        let c = resolveConfigInternal(options: FadeOptions(timing: .t1, intent: .delight), isReducedMotion: false)
        XCTAssertEqual(c.duration, 0.1, accuracy: 0.001)
    }

    func testIntentSetsCurve() {
        let c = resolveConfigInternal(options: FadeOptions(intent: .enter), isReducedMotion: false)
        XCTAssertEqual(c.curve, UIView.AnimationCurve.easeOut)
    }

    func testCustomCurveOverridesIntent() {
        let c = resolveConfigInternal(options: FadeOptions(curve: .linear, intent: .enter), isReducedMotion: false)
        XCTAssertEqual(c.curve, UIView.AnimationCurve.linear)
    }

    // --- Reduced Motion ---
    func testReducedMotionZerosDurationAndDelay() {
        let c = resolveConfigInternal(options: FadeOptions(duration: 500, delay: 200), isReducedMotion: true)
        XCTAssertEqual(c.duration, 0.0, accuracy: 0.001)
        XCTAssertEqual(c.delay, 0.0, accuracy: 0.001)
        XCTAssertTrue(c.reducedMotion)
    }

    func testReducedMotionWithIntent() {
        let c = resolveConfigInternal(options: FadeOptions(intent: .delight), isReducedMotion: true)
        XCTAssertEqual(c.duration, 0.0, accuracy: 0.001)
        XCTAssertTrue(c.reducedMotion)
    }
}
