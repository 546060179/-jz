package com.fadeanimation

import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewPropertyAnimator
import androidx.annotation.MainThread


/**
 * 核心淡入淡出动画控制器。
 *
 * 使用 Android ViewPropertyAnimator 驱动 alpha 动画，支持：
 * - fadeIn（不透明度 0→1）和 fadeOut（不透明度 1→0）
 * - 自定义 duration、delay、interpolator
 * - 预设速度方案（fast/normal/slow）
 * - 动画结束回调（保证仅调用一次）
 * - 视图从窗口移除时自动取消动画
 * - 安全网定时器，确保回调在异常情况下也能触发
 *
 * @param targetView 动画目标视图
 * @param options 动画配置选项，默认使用 FadeOptions 默认值
 */
class FadeAnimator(
    private val targetView: View,
    private val options: FadeOptions = FadeOptions()
) {

    /** 当前活跃的 ViewPropertyAnimator，用于 cancel */
    private var currentAnimator: ViewPropertyAnimator? = null

    /** 安全网定时器的 Handler */
    private val handler = Handler(Looper.getMainLooper())

    /** 安全网定时器的 Runnable */
    private var safetyRunnable: Runnable? = null

    /** 确保 onEnd 回调仅调用一次的标志（所有操作均在主线程，无需 AtomicBoolean） */
    private var callbackInvoked = false

    /** 视图 attach 状态监听器，用于自动取消动画 */
    private var attachListener: View.OnAttachStateChangeListener? = null

    /**
     * 启动淡入或淡出动画。
     *
     * 如果有正在进行的动画，会先取消再启动新动画。
     *
     * @param fadeIn true 执行淡入（alpha 0→1），false 执行淡出（alpha 1→0）
     * @param onEnd 动画结束时的回调，保证仅调用一次；null 表示不需要回调
     */
    @MainThread
    fun start(fadeIn: Boolean = true, onEnd: (() -> Unit)? = null) {
        // 取消之前的动画（不触发旧回调）
        cancelInternal(invokeCallback = false)

        // 重置回调标志
        callbackInvoked = false

        // 解析配置
        val config = resolveConfig(options, targetView.context)

        // 确定目标 alpha 和初始 alpha
        val targetAlpha = if (fadeIn) 1f else 0f
        val initialAlpha = if (fadeIn) 0f else 1f

        // 设置初始不透明度
        targetView.alpha = initialAlpha

        // 合并回调：options.onAnimationEnd 和 start 参数的 onEnd
        val combinedOnEnd: (() -> Unit)? = when {
            options.onAnimationEnd != null && onEnd != null -> {
                {
                    options.onAnimationEnd.invoke()
                    onEnd()
                }
            }
            options.onAnimationEnd != null -> options.onAnimationEnd
            onEnd != null -> onEnd
            else -> null
        }

        // 安全触发回调的辅助函数（确保仅调用一次）
        val invokeOnEnd = {
            if (combinedOnEnd != null && !callbackInvoked) {
                callbackInvoked = true
                cleanupSafetyTimer()
                cleanupAttachListener()
                combinedOnEnd()
            }
        }

        // 注册视图 detach 监听器，自动取消动画
        val listener = object : View.OnAttachStateChangeListener {
            override fun onViewAttachedToWindow(v: View) {
                // no-op
            }

            override fun onViewDetachedFromWindow(v: View) {
                cancelInternal(invokeCallback = false)
            }
        }
        attachListener = listener
        targetView.addOnAttachStateChangeListener(listener)

        // 启动 ViewPropertyAnimator
        val animator = targetView.animate()
            .alpha(targetAlpha)
            .setDuration(config.duration)
            .setStartDelay(config.delay)
            .setInterpolator(config.interpolator)
            .withEndAction {
                invokeOnEnd()
            }

        currentAnimator = animator

        // 设置安全网定时器：duration + delay + 50ms
        if (combinedOnEnd != null) {
            val safetyDelay = config.duration + config.delay + 50L
            val runnable = Runnable {
                invokeOnEnd()
            }
            safetyRunnable = runnable
            handler.postDelayed(runnable, safetyDelay)
        }
    }

    /**
     * 取消当前正在进行的动画并清理所有资源。
     *
     * 取消后不会触发 onEnd 回调。
     */
    @MainThread
    fun cancel() {
        cancelInternal(invokeCallback = false)
    }

    /**
     * 内部取消方法。
     *
     * @param invokeCallback 是否在取消时触发回调（通常为 false）
     */
    private fun cancelInternal(invokeCallback: Boolean) {
        // 标记回调已处理（防止后续触发）
        if (!invokeCallback) {
            callbackInvoked = true
        }

        // 取消 ViewPropertyAnimator
        currentAnimator?.cancel()
        currentAnimator = null

        // 清理安全网定时器
        cleanupSafetyTimer()

        // 清理 attach 监听器
        cleanupAttachListener()
    }

    /** 移除安全网定时器 */
    private fun cleanupSafetyTimer() {
        safetyRunnable?.let { handler.removeCallbacks(it) }
        safetyRunnable = null
    }

    /** 移除视图 attach 状态监听器 */
    private fun cleanupAttachListener() {
        attachListener?.let { targetView.removeOnAttachStateChangeListener(it) }
        attachListener = null
    }
}
