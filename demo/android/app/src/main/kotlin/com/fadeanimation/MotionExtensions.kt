package com.fadeanimation

import android.view.View

/**
 * View 扩展函数 — 通用动效 API。
 *
 * 通过 View.tag 持有 MotionAnimator 引用，防止 GC 提前回收。
 */

internal class MotionAnimatorHolder(var animator: MotionAnimator?)

private fun View.getMotionHolder(): MotionAnimatorHolder {
    val existing = this.getTag(MOTION_TAG_KEY)
    if (existing is MotionAnimatorHolder) return existing
    val holder = MotionAnimatorHolder(null)
    this.setTag(MOTION_TAG_KEY, holder)
    return holder
}

// 使用 View.generateViewId() 风格的常量避免和 FadeAnimator 的 tag 冲突
private val MOTION_TAG_KEY = View.generateViewId()

/**
 * 在当前 View 上执行通用动效。
 *
 * @param entering true 为进入动画，false 为退出动画
 * @param effects 效果列表
 * @param options 动画配置
 * @param onEnd 动画结束回调
 */
fun View.motion(
    entering: Boolean = true,
    effects: List<MotionEffect> = EffectPresets.FADE_IN,
    options: FadeOptions = FadeOptions(),
    onEnd: (() -> Unit)? = null
) {
    val animator = MotionAnimator(this, options)
    val holder = getMotionHolder()
    holder.animator?.cancel()
    holder.animator = animator
    animator.start(entering = entering, effects = effects, onEnd = {
        holder.animator = null
        onEnd?.invoke()
    })
}

/** 缩放淡入 */
fun View.scaleFadeIn(options: FadeOptions = FadeOptions(), onEnd: (() -> Unit)? = null) {
    motion(entering = true, effects = EffectPresets.SCALE_FADE_IN, options = options, onEnd = onEnd)
}

/** 缩放淡出 */
fun View.scaleFadeOut(options: FadeOptions = FadeOptions(), onEnd: (() -> Unit)? = null) {
    motion(entering = false, effects = EffectPresets.SCALE_FADE_OUT, options = options, onEnd = onEnd)
}

/** 从下方滑入 + 淡入 */
fun View.slideUpIn(options: FadeOptions = FadeOptions(), onEnd: (() -> Unit)? = null) {
    motion(entering = true, effects = EffectPresets.SLIDE_UP_IN, options = options, onEnd = onEnd)
}

/** 向下滑出 + 淡出 */
fun View.slideDownOut(options: FadeOptions = FadeOptions(), onEnd: (() -> Unit)? = null) {
    motion(entering = false, effects = EffectPresets.SLIDE_DOWN_OUT, options = options, onEnd = onEnd)
}

/** 从左侧滑入 + 淡入 */
fun View.slideLeftIn(options: FadeOptions = FadeOptions(), onEnd: (() -> Unit)? = null) {
    motion(entering = true, effects = EffectPresets.SLIDE_LEFT_IN, options = options, onEnd = onEnd)
}

/** 从右侧滑入 + 淡入 */
fun View.slideRightIn(options: FadeOptions = FadeOptions(), onEnd: (() -> Unit)? = null) {
    motion(entering = true, effects = EffectPresets.SLIDE_RIGHT_IN, options = options, onEnd = onEnd)
}
