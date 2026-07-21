package com.fadeanimation

/**
 * 编排方向 —— 对齐 Web 端 StaggerOptions.direction。
 */
enum class StaggerDirection {
    FORWARD,
    REVERSE,
    CENTER
}

/**
 * 编排配置 —— 对齐 Web 端 @fade-animation/core 的 StaggerOptions。
 *
 * @property interval 每个子元素之间的延迟间隔（ms）
 * @property baseDelay 起始延迟（ms），默认 0
 * @property direction 编排方向，默认 FORWARD
 */
data class StaggerOptions(
    val interval: Long,
    val baseDelay: Long = 0L,
    val direction: StaggerDirection = StaggerDirection.FORWARD
)

/**
 * 编排工具：计算每个子元素的延迟时间（ms）。
 *
 * 与 Web 端 stagger() 数值完全一致，用于多元素协同动画时创造有节奏的视觉流。
 *
 * @param count 子元素总数
 * @param options 编排配置
 * @return 每个子元素的延迟时间数组（ms）
 *
 * ```kotlin
 * // 5 个卡片依次入场，间隔 50ms
 * stagger(5, StaggerOptions(interval = 50L))
 * // → [0, 50, 100, 150, 200]
 *
 * val delays = stagger(items.size, StaggerOptions(interval = 60L))
 * itemViews.forEachIndexed { i, view ->
 *   MotionAnimator(view, FadeOptions(delay = delays[i], intent = MotionIntent.ENTER))
 *     .start(entering = true, effects = EffectPresets.SCALE_FADE_IN)
 * }
 * ```
 */
fun stagger(count: Int, options: StaggerOptions): List<Long> {
    if (count <= 0) return emptyList()

    val safeInterval = maxOf(0L, options.interval)
    val safeBase = maxOf(0L, options.baseDelay)

    return when (options.direction) {
        StaggerDirection.REVERSE ->
            (0 until count).map { i -> safeBase + (count - 1 - i) * safeInterval }

        StaggerDirection.CENTER -> {
            val center = (count - 1) / 2.0
            (0 until count).map { i ->
                val offset = Math.round(kotlin.math.abs(i - center) * safeInterval)
                safeBase + offset
            }
        }

        StaggerDirection.FORWARD ->
            (0 until count).map { i -> safeBase + i * safeInterval }
    }
}
