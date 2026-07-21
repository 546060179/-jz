package com.fadeanimation

/**
 * 预设速度枚举（向后兼容）。
 * 新代码建议使用 TimingScale 替代。
 */
enum class PresetSpeed(val durationMs: Long) {
    FAST(TimingScale.T2.durationMs),     // 150ms
    NORMAL(TimingScale.T3.durationMs),   // 300ms
    SLOW(TimingScale.T4.durationMs)      // 500ms
}
