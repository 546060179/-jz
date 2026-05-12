package com.fadeanimation

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ValueAnimator
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.view.ViewPropertyAnimator
import androidx.annotation.MainThread

/**
 * 通用动效控制器 — 对齐 Web 端 <Motion> 组件。
 *
 * 支持 fade、scale、slide、flip 及其任意组合，使用 ViewPropertyAnimator 驱动。
 * FadeAnimator 保留作为向后兼容的特化版本。
 *
 * @param targetView 动画目标视图
 * @param options 动画配置选项
 */
class MotionAnimator(
    private val targetView: View,
    private val options: FadeOptions = FadeOptions()
) {
    private var currentAnimator: ViewPropertyAnimator? = null
    private var flipAnimator: ValueAnimator? = null
    private var collapseAnimator: ValueAnimator? = null
    private val handler = Handler(Looper.getMainLooper())
    private var safetyRunnable: Runnable? = null
    private var callbackInvoked = false
    private var attachListener: View.OnAttachStateChangeListener? = null

    /**
     * 启动动画。
     *
     * @param entering true 为进入动画，false 为退出动画
     * @param effects 效果列表，支持 Fade、Scale、Slide 的任意组合
     * @param onEnd 动画结束回调，保证仅调用一次
     */
    @MainThread
    fun start(
        entering: Boolean = true,
        effects: List<MotionEffect> = EffectPresets.FADE_IN,
        onEnd: (() -> Unit)? = null
    ) {
        cancelInternal()
        callbackInvoked = false

        val config = resolveConfig(options, targetView.context)

        // Flip + Rotate 冲突检测：优先 Flip，忽略 Rotate
        val hasFlip = effects.any { it is MotionEffect.Flip }
        val hasRotate = effects.any { it is MotionEffect.Rotate }
        val resolvedEffects = if (hasFlip && hasRotate) {
            Log.w(
                "FadeAnimation",
                "[FadeAnimation] FlipEffect and RotateEffect cannot be used together. RotateEffect will be ignored."
            )
            effects.filter { it !is MotionEffect.Rotate }
        } else {
            effects
        }

        // 合并回调
        val combinedOnEnd: (() -> Unit)? = when {
            options.onAnimationEnd != null && onEnd != null -> {
                { options.onAnimationEnd.invoke(); onEnd() }
            }
            options.onAnimationEnd != null -> options.onAnimationEnd
            onEnd != null -> onEnd
            else -> null
        }

        val invokeOnEnd = {
            if (combinedOnEnd != null && !callbackInvoked) {
                callbackInvoked = true
                cleanupSafetyTimer()
                cleanupAttachListener()
                combinedOnEnd()
            }
        }

        // 设置初始状态和目标状态
        // entering=true:  初始=变换状态(偏移/缩小/旋转), 目标=identity
        // entering=false: 初始=identity, 目标=变换状态(偏移/缩小/旋转)
        for (effect in resolvedEffects) {
            when (effect) {
                is MotionEffect.Fade -> {
                    val from = effect.from ?: if (entering) 0f else 1f
                    targetView.alpha = from
                }
                is MotionEffect.Scale -> {
                    val from = effect.from ?: if (entering) 0.95f else 1f
                    targetView.scaleX = from
                    targetView.scaleY = from
                }
                is MotionEffect.Slide -> {
                    val dist = effect.distance
                    if (entering) {
                        // 进入：初始偏移
                        when (effect.direction) {
                            SlideDirection.UP -> targetView.translationY = dist
                            SlideDirection.DOWN -> targetView.translationY = -dist
                            SlideDirection.LEFT -> targetView.translationX = dist
                            SlideDirection.RIGHT -> targetView.translationX = -dist
                        }
                    } else {
                        // 退出：初始在原位
                        targetView.translationX = 0f
                        targetView.translationY = 0f
                    }
                }
                is MotionEffect.Rotate -> {
                    val from = effect.from ?: if (entering) -10f else 0f
                    targetView.rotation = from
                }
                is MotionEffect.Blur -> {
                    // Blur requires RenderEffect (API 31+), skip on older versions
                }
                is MotionEffect.Flip -> {
                    // Flip initial state is applied via Camera+Matrix in the ValueAnimator below
                    val startAngle = if (entering) effect.from else effect.to
                    applyFlipTransform(targetView, startAngle, effect.axis, effect.perspective)
                    // Handle backfaceVisibility initial state (normalize to 0-360 range)
                    if (effect.backfaceVisibility == "hidden") {
                        val normalizedAngle = ((startAngle % 360) + 360) % 360
                        targetView.visibility = if (normalizedAngle > 90 && normalizedAngle < 270) {
                            View.INVISIBLE
                        } else {
                            View.VISIBLE
                        }
                    }
                }
                is MotionEffect.Collapse -> {
                    // Measure content height and set initial height
                    val collapsedPx = when (effect.collapsedHeight) {
                        is CollapseHeight.Fixed -> effect.collapsedHeight.value.toInt()
                        is CollapseHeight.Auto -> targetView.height
                    }
                    // Measure the full content height
                    targetView.measure(
                        View.MeasureSpec.makeMeasureSpec(targetView.width, View.MeasureSpec.EXACTLY),
                        View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
                    )
                    val contentHeight = targetView.measuredHeight

                    val startHeight = if (entering) collapsedPx else contentHeight
                    val lp = targetView.layoutParams
                    lp.height = startHeight
                    targetView.layoutParams = lp

                    // Set clipping on parent ViewGroup during animation
                    (targetView.parent as? ViewGroup)?.let { parent ->
                        parent.clipChildren = true
                        parent.clipToPadding = true
                    }
                }
            }
        }

        // 注册 detach 监听
        val listener = object : View.OnAttachStateChangeListener {
            override fun onViewAttachedToWindow(v: View) {}
            override fun onViewDetachedFromWindow(v: View) { cancelInternal() }
        }
        attachListener = listener
        targetView.addOnAttachStateChangeListener(listener)

        // 构建动画：设置目标状态
        val animator = targetView.animate()
            .setDuration(config.duration)
            .setStartDelay(config.delay)
            .setInterpolator(config.interpolator)

        for (effect in resolvedEffects) {
            when (effect) {
                is MotionEffect.Fade -> {
                    val to = effect.to ?: if (entering) 1f else 0f
                    animator.alpha(to)
                }
                is MotionEffect.Scale -> {
                    val to = effect.to ?: if (entering) 1f else 0.95f
                    animator.scaleX(to).scaleY(to)
                }
                is MotionEffect.Slide -> {
                    if (entering) {
                        // 进入：目标回到原位
                        animator.translationX(0f).translationY(0f)
                    } else {
                        // 退出：目标移到偏移位置
                        val dist = effect.distance
                        when (effect.direction) {
                            SlideDirection.UP -> animator.translationX(0f).translationY(dist)
                            SlideDirection.DOWN -> animator.translationX(0f).translationY(-dist)
                            SlideDirection.LEFT -> animator.translationX(dist).translationY(0f)
                            SlideDirection.RIGHT -> animator.translationX(-dist).translationY(0f)
                        }
                    }
                }
                is MotionEffect.Rotate -> {
                    val to = effect.to ?: if (entering) 0f else 10f
                    animator.rotation(to)
                }
                is MotionEffect.Blur -> {
                    // Blur animated via ValueAnimator + RenderEffect on API 31+
                    // Graceful degradation: no blur on older APIs
                }
                is MotionEffect.Flip -> {
                    // Flip is driven by a separate ValueAnimator below
                }
                is MotionEffect.Collapse -> {
                    // Collapse is driven by a separate ValueAnimator
                }
            }
        }

        animator.withEndAction { invokeOnEnd() }
        currentAnimator = animator

        // Flip 动画：使用 ValueAnimator + Camera + Matrix 实现 3D 翻转
        val flipEffect = resolvedEffects.filterIsInstance<MotionEffect.Flip>().firstOrNull()
        if (flipEffect != null) {
            val startAngle = if (entering) flipEffect.from else flipEffect.to
            val endAngle = if (entering) flipEffect.to else flipEffect.from
            val va = ValueAnimator.ofFloat(startAngle, endAngle).apply {
                duration = config.duration
                startDelay = config.delay
                interpolator = config.interpolator
                addUpdateListener { animation ->
                    val angle = animation.animatedValue as Float
                    applyFlipTransform(targetView, angle, flipEffect.axis, flipEffect.perspective)
                    // Handle backfaceVisibility
                    if (flipEffect.backfaceVisibility == "hidden") {
                        val normalizedAngle = ((angle % 360) + 360) % 360
                        targetView.visibility = if (normalizedAngle > 90 && normalizedAngle < 270) {
                            View.INVISIBLE
                        } else {
                            View.VISIBLE
                        }
                    }
                }
            }
            flipAnimator = va
            va.start()
        }

        // Collapse 动画：使用 ValueAnimator 驱动 LayoutParams.height
        val collapseEffect = resolvedEffects.filterIsInstance<MotionEffect.Collapse>().firstOrNull()
        if (collapseEffect != null) {
            val collapsedPx = when (collapseEffect.collapsedHeight) {
                is CollapseHeight.Fixed -> collapseEffect.collapsedHeight.value.toInt()
                is CollapseHeight.Auto -> targetView.height
            }
            // Measure content height
            targetView.measure(
                View.MeasureSpec.makeMeasureSpec(targetView.width, View.MeasureSpec.EXACTLY),
                View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
            )
            val contentHeight = targetView.measuredHeight

            val startHeight = if (entering) collapsedPx else contentHeight
            val endHeight = if (entering) contentHeight else collapsedPx

            // Record original clip state to restore later
            val parentGroup = targetView.parent as? ViewGroup
            val origClipChildren = parentGroup?.clipChildren ?: true
            val origClipToPadding = parentGroup?.clipToPadding ?: true

            val va = ValueAnimator.ofInt(startHeight, endHeight).apply {
                duration = config.duration
                startDelay = config.delay
                interpolator = config.interpolator
                addUpdateListener { animation ->
                    val value = animation.animatedValue as Int
                    val lp = targetView.layoutParams
                    lp.height = value
                    targetView.layoutParams = lp
                }
                addListener(object : AnimatorListenerAdapter() {
                    override fun onAnimationEnd(animation: Animator) {
                        val lp = targetView.layoutParams
                        if (entering) {
                            // Restore WRAP_CONTENT to allow content to resize freely
                            lp.height = ViewGroup.LayoutParams.WRAP_CONTENT
                        } else {
                            // Set fixed collapsed height
                            lp.height = collapsedPx
                        }
                        targetView.layoutParams = lp

                        // Restore original clip state
                        parentGroup?.clipChildren = origClipChildren
                        parentGroup?.clipToPadding = origClipToPadding
                    }
                })
            }
            collapseAnimator = va
            va.start()
        }

        // 安全网定时器
        if (combinedOnEnd != null) {
            val runnable = Runnable { invokeOnEnd() }
            safetyRunnable = runnable
            handler.postDelayed(runnable, config.duration + config.delay + 50L)
        }
    }

    @MainThread
    fun cancel() { cancelInternal() }

    private fun cancelInternal() {
        callbackInvoked = true
        currentAnimator?.cancel()
        currentAnimator = null
        flipAnimator?.cancel()
        flipAnimator = null
        collapseAnimator?.cancel()
        collapseAnimator = null
        cleanupSafetyTimer()
        cleanupAttachListener()
    }

    private fun cleanupSafetyTimer() {
        safetyRunnable?.let { handler.removeCallbacks(it) }
        safetyRunnable = null
    }

    private fun cleanupAttachListener() {
        attachListener?.let { targetView.removeOnAttachStateChangeListener(it) }
        attachListener = null
    }

    /**
     * 使用 Camera + Matrix 将 3D 翻转变换应用到 View。
     *
     * Android View 原生支持 rotationX/rotationY 和 cameraDistance，
     * 内部通过 Camera + Matrix 实现 3D 变换。
     *
     * @param view 目标视图
     * @param angle 当前旋转角度（度）
     * @param axis 翻转轴（X 或 Y）
     * @param perspective 透视距离（px）
     */
    private fun applyFlipTransform(view: View, angle: Float, axis: FlipAxis, perspective: Float) {
        val density = view.resources.displayMetrics.density
        // cameraDistance 单位为 px（density * dp），perspective 已经是 px 单位
        view.cameraDistance = perspective * density

        when (axis) {
            FlipAxis.X -> view.rotationX = angle
            FlipAxis.Y -> view.rotationY = angle
        }
    }
}
