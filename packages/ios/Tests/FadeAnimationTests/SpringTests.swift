import XCTest
@testable import FadeAnimation

/// 验证 iOS 弹簧求解器与 Web 端 @fade-animation/core 数值一致。
/// 断言镜像 core 的 spring.test.ts，保证四端弹簧手感统一。
final class SpringTests: XCTestCase {

    func testStartsAtZero() {
        let solver = SpringSolver()
        XCTAssertEqual(solver.current().position, 0, accuracy: 0.0001)
        XCTAssertFalse(solver.current().atRest)
    }

    func testConvergesToOne() {
        let solver = SpringSolver(config: SpringConfig(stiffness: 200, damping: 20))
        var state = solver.current()
        for _ in 0..<300 {
            state = solver.step(1.0 / 60.0)
        }
        XCTAssertEqual(state.position, 1, accuracy: 0.01)
        XCTAssertTrue(state.atRest)
    }

    func testBouncyOvershoots() {
        let solver = SpringSolver(config: SpringPresets.bouncy)
        var maxPos: CGFloat = 0
        for _ in 0..<300 {
            let state = solver.step(1.0 / 60.0)
            if state.position > maxPos { maxPos = state.position }
        }
        XCTAssertGreaterThan(maxPos, 1.01)
    }

    func testNoWobbleDoesNotOvershoot() {
        let solver = SpringSolver(config: SpringPresets.noWobble)
        var maxPos: CGFloat = 0
        for _ in 0..<300 {
            let state = solver.step(1.0 / 60.0)
            if state.position > maxPos { maxPos = state.position }
        }
        XCTAssertLessThan(maxPos, 1.05)
    }

    func testResetReturnsToInitial() {
        let solver = SpringSolver()
        _ = solver.step(1.0 / 60.0)
        _ = solver.step(1.0 / 60.0)
        solver.reset()
        XCTAssertEqual(solver.current().position, 0, accuracy: 0.0001)
    }

    func testEstimateDurationReasonable() {
        let dur = estimateSpringDuration()
        XCTAssertGreaterThan(dur, 0.2)
        XCTAssertLessThan(dur, 5.0)
    }

    func testSnappyFasterThanSlow() {
        let snappy = estimateSpringDuration(config: SpringPresets.snappy)
        let slow = estimateSpringDuration(config: SpringPresets.slow)
        XCTAssertLessThan(snappy, slow)
    }

    func testAllPresetsConverge() {
        let presets: [SpringConfig] = [
            SpringPresets.gentle, SpringPresets.snappy, SpringPresets.bouncy,
            SpringPresets.slow, SpringPresets.noWobble
        ]
        for config in presets {
            XCTAssertLessThan(estimateSpringDuration(config: config), 5.0)
        }
    }
}
