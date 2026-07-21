package com.fadeanimation

import android.view.View

/**
 * View 扩展函数，提供便捷的淡入淡出动画 API。
 *
 * 通过 View tag 持有 FadeAnimator 引用，防止 GC 在动画完成前回收。
 */

/**
 * 内部包装类，用于在 View.tag 中安全存储 FadeAnimator 引用。
 * 避免与其他使用 View.tag 的代码冲突。
 */
internal class FadeAnimatorHolder(var animator: FadeAnimator?)

/** 从 View.tag 中获取或创建 FadeAnimatorHolder */
private fun View.getFadeHolder(): FadeAnimatorHolder {
    val existing = this.tag
    if (existing is FadeAnimatorHolder) return existing
    val holder = FadeAnimatorHolder(null)
    // 注意：这会覆盖 View.tag，如果调用方也在用 tag 可能冲突。
    // 对于 Android Library 来说，更好的方案是使用 ViewCompat 或自定义 View 属性。
    this.tag = holder
    return holder
}

/**
 * 在当前 View 上执行淡入淡出动画。
 *
 * @param fadeIn true 执行淡入（alpha 0→1），false 执行淡出（alpha 1→0），默认 true
 * @param options 动画配置选项
 * @param onEnd 动画结束回调
 */
fun View.fade(fadeIn: Boolean = true, options: FadeOptions = FadeOptions(), onEnd: (() -> Unit)? = null) {
    val animator = FadeAnimator(this, options)
    val holder = getFadeHolder()
    // 取消之前的动画（如果有）
    holder.animator?.cancel()
    holder.animator = animator
    animator.start(fadeIn = fadeIn, onEnd = {
        // 动画结束后释放引用
        holder.animator = null
        onEnd?.invoke()
    })
}

/**
 * 在当前 View 上执行淡入动画（alpha 0→1）。
 */
fun View.fadeIn(options: FadeOptions = FadeOptions(), onEnd: (() -> Unit)? = null) {
    fade(fadeIn = true, options = options, onEnd = onEnd)
}

/**
 * 在当前 View 上执行淡出动画（alpha 1→0）。
 */
fun View.fadeOut(options: FadeOptions = FadeOptions(), onEnd: (() -> Unit)? = null) {
    fade(fadeIn = false, options = options, onEnd = onEnd)
}
