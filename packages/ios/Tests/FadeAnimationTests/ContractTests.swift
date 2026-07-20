import XCTest
import QuartzCore
@testable import FadeAnimation

/// 跨端一致性契约测试（iOS 侧）。
///
/// 读取仓库根 `contract/motion-contract.json`（与 core / Android 同一份黄金值），
/// 断言 iOS 的设计令牌与之一致，防止某端漂移（例如新增 easing 时必须四端同步）。
final class ContractTests: XCTestCase {

    // MARK: - 契约数据模型

    struct Contract: Codable {
        let timings: [String: Int]
        let easings: [String: [Double]]
        let intentDefaults: [String: IntentDef]
        let springs: [String: SpringDef]
    }
    struct IntentDef: Codable { let timing: String; let easing: String }
    struct SpringDef: Codable { let stiffness: Double; let damping: Double; let mass: Double }

    // MARK: - 加载 JSON（用 #filePath 定位仓库根，三端共用同一文件）

    private func loadContract() throws -> Contract {
        var root = URL(fileURLWithPath: #filePath)
        // ContractTests.swift → FadeAnimationTests → Tests → ios → packages → 仓库根
        for _ in 0..<5 { root.deleteLastPathComponent() }
        let url = root.appendingPathComponent("contract/motion-contract.json")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Contract.self, from: data)
    }

    /// 读取 CAMediaTimingFunction 的两个控制点 → [c1x, c1y, c2x, c2y]
    private func controlPoints(_ f: CAMediaTimingFunction) -> [Float] {
        var p1 = [Float](repeating: 0, count: 2)
        var p2 = [Float](repeating: 0, count: 2)
        f.getControlPoint(at: 1, values: &p1)
        f.getControlPoint(at: 2, values: &p2)
        return [p1[0], p1[1], p2[0], p2[1]]
    }

    private func easing(named name: String) -> CAMediaTimingFunction? {
        switch name {
        case "productive": return EasingCurves.productive
        case "expressive": return EasingCurves.expressive
        case "enter": return EasingCurves.enter
        case "exit": return EasingCurves.exit
        case "bounce": return EasingCurves.bounce
        default: return nil
        }
    }

    private func spring(named name: String) -> SpringConfig? {
        switch name {
        case "gentle": return SpringPresets.gentle
        case "snappy": return SpringPresets.snappy
        case "bouncy": return SpringPresets.bouncy
        case "slow": return SpringPresets.slow
        case "noWobble": return SpringPresets.noWobble
        default: return nil
        }
    }

    // MARK: - 测试

    func testTimingScales() throws {
        let contract = try loadContract()
        for (key, value) in contract.timings {
            guard let scale = TimingScale(rawValue: key) else {
                XCTFail("iOS 缺少 TimingScale \(key)"); continue
            }
            XCTAssertEqual(scale.durationMs, value, "TimingScale.\(key) 时长不一致")
        }
    }

    func testEasingCurves() throws {
        let contract = try loadContract()
        for (name, points) in contract.easings {
            guard let fn = easing(named: name) else {
                XCTFail("iOS 缺少 easing \(name)"); continue
            }
            let actual = controlPoints(fn)
            for i in 0..<4 {
                XCTAssertEqual(Double(actual[i]), points[i], accuracy: 1e-5,
                               "easing \(name) 控制点[\(i)] 不一致")
            }
        }
    }

    func testSpringPresets() throws {
        let contract = try loadContract()
        for (name, def) in contract.springs {
            guard let cfg = spring(named: name) else {
                XCTFail("iOS 缺少 SpringPreset \(name)"); continue
            }
            XCTAssertEqual(Double(cfg.stiffness), def.stiffness, accuracy: 1e-6, "\(name) stiffness")
            XCTAssertEqual(Double(cfg.damping), def.damping, accuracy: 1e-6, "\(name) damping")
            XCTAssertEqual(Double(cfg.mass), def.mass, accuracy: 1e-6, "\(name) mass")
        }
    }

    func testIntentDefaults() throws {
        let contract = try loadContract()
        for (intentName, def) in contract.intentDefaults {
            guard let intent = MotionIntent(rawValue: intentName) else {
                XCTFail("iOS 缺少 MotionIntent \(intentName)"); continue
            }
            // timing 一致
            XCTAssertEqual(intent.timing.rawValue, def.timing, "\(intentName) 默认 timing 不一致")
            // easing 一致（intent 的 timingFunction 控制点 == 对应命名 easing）
            guard let expected = easing(named: def.easing) else {
                XCTFail("契约引用了未知 easing \(def.easing)"); continue
            }
            XCTAssertEqual(controlPoints(intent.timingFunction), controlPoints(expected),
                           "\(intentName) 默认 easing 不一致")
        }
    }
}
