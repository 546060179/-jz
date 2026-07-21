package com.fadeanimation

/**
 * 时间刻度枚举 — 对齐 Web 端 @fade-animation/core tokens。
 *
 * - T1 (extra-fast): 微交互，按钮状态切换
 * - T2 (fast): 小组件动画，tooltip
 * - T3 (normal): 标准过渡，卡片
 * - T4 (slow): 大面积过渡，页面切换
 * - T5 (extra-slow): 复杂编排，全屏过渡
 */
enum class TimingScale(val durationMs: Long) {
    T1(100L),
    T2(150L),
    T3(300L),
    T4(500L),
    T5(700L)
}
