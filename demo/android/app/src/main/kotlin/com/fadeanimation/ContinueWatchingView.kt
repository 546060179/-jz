package com.fadeanimation

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView

/** ContinueWatchingView 的动画时长配置(ms) */
data class CWTiming(
    val slideUpDuration: Long = 450L,
    val collapseDelay: Long = 3000L,
    val fadeOutDuration: Long = 300L,
    val shrinkDuration: Long = 400L,
    val morphDuration: Long = 550L
)

/** ContinueWatchingView 生命周期回调 */
interface ContinueWatchingListener {
    fun onPlay() {}
    fun onDismiss() {}
    fun onCollapsed() {}
}

/**
 * ContinueWatchingView — "最近播放"浮层
 *
 * 底部滑入的继续播放提示条,展示封面 + 标题 + 集数,停留数秒后自动收缩为只剩封面的
 * 小浮窗。与 iOS 端 `ContinueWatchingView` 对齐,执行 5 阶段序列:
 * slide-up → banner(停留) → 详情淡出 → 横条收缩 → 变形小浮窗。
 *
 * ```kotlin
 * val bar = ContinueWatchingView(context)
 * bar.timing = CWTiming(collapseDelay = 3000L)
 * bar.configure(cover = drawable, title = "剧名", subtitle = "EP.1 / EP.100")
 * container.addView(bar)
 * bar.show()
 * ```
 */
class ContinueWatchingView constructor(
    context: Context
) : FrameLayout(context) {

    enum class CWPhase { HIDDEN, SLIDING_UP, BANNER, FADING_CONTENT, SHRINKING, MORPHING, WIDGET }

    var timing: CWTiming = CWTiming()
    var listener: ContinueWatchingListener? = null
    var phase: CWPhase = CWPhase.HIDDEN
        private set

    private val coverView = ImageView(context)
    private val textColumn = LinearLayout(context)
    private val titleLabel = TextView(context)
    private val subtitleLabel = TextView(context)

    private val density: Float get() = resources.displayMetrics.density
    private var fullWidth: Int = 0
    private var collapsedWidth: Int = 0
    private val bgDrawable = GradientDrawable()

    init {
        val d = density
        bgDrawable.cornerRadius = 12 * d
        bgDrawable.setColor(0xFF26282E.toInt())
        background = bgDrawable

        val coverSize = (44 * d).toInt()
        coverView.layoutParams = LayoutParams(coverSize, coverSize).apply {
            gravity = Gravity.CENTER_VERTICAL
            marginStart = (6 * d).toInt()
        }
        coverView.setBackgroundColor(0xFF186CE5.toInt())
        addView(coverView)

        textColumn.orientation = LinearLayout.VERTICAL
        textColumn.gravity = Gravity.CENTER_VERTICAL
        textColumn.layoutParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT).apply {
            gravity = Gravity.CENTER_VERTICAL
            marginStart = (60 * d).toInt()
        }
        titleLabel.setTextColor(Color.WHITE)
        titleLabel.textSize = 14f
        subtitleLabel.setTextColor(0x99FFFFFF.toInt())
        subtitleLabel.textSize = 12f
        textColumn.addView(titleLabel)
        textColumn.addView(subtitleLabel)
        addView(textColumn)

        setOnClickListener { listener?.onPlay() }
    }

    /** 配置内容 */
    fun configure(cover: android.graphics.drawable.Drawable?, title: String, subtitle: String) {
        if (cover != null) coverView.setImageDrawable(cover)
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    /** 触发进入 + 自动收缩序列 */
    fun show() {
        fullWidth = if (width > 0) width else (300 * density).toInt()
        collapsedWidth = (56 * density).toInt()

        phase = CWPhase.SLIDING_UP
        translationY = 30 * density
        alpha = 0f

        // 阶段1: slide-up
        animate().translationY(0f).alpha(1f)
            .setDuration(timing.slideUpDuration)
            .withEndAction { phase = CWPhase.BANNER }
            .start()

        // 阶段2→3: 停留后详情淡出
        postDelayed({
            phase = CWPhase.FADING_CONTENT
            textColumn.animate().alpha(0f).setDuration(timing.fadeOutDuration)
                .withEndAction { shrinkAndMorph() }
                .start()
        }, timing.slideUpDuration + timing.collapseDelay)
    }

    private fun shrinkAndMorph() {
        // 阶段4: 横条收缩为封面宽
        phase = CWPhase.SHRINKING
        val shrink = ValueAnimator.ofInt(fullWidth, collapsedWidth).apply {
            duration = timing.shrinkDuration
            addUpdateListener {
                val w = it.animatedValue as Int
                layoutParams = layoutParams.apply { this.width = w }
                requestLayout()
            }
        }
        shrink.start()

        // 阶段5: 变形为小浮窗(圆角)
        postDelayed({
            phase = CWPhase.MORPHING
            val morph = ValueAnimator.ofFloat(12 * density, 10 * density).apply {
                duration = timing.morphDuration
                addUpdateListener {
                    bgDrawable.cornerRadius = it.animatedValue as Float
                    invalidate()
                }
            }
            morph.start()
            postDelayed({
                phase = CWPhase.WIDGET
                listener?.onCollapsed()
            }, timing.morphDuration)
        }, timing.shrinkDuration)
    }

    /** 立即关闭 */
    fun dismiss() {
        animate().alpha(0f).translationY(30 * density)
            .setDuration(timing.fadeOutDuration)
            .withEndAction {
                phase = CWPhase.HIDDEN
                listener?.onDismiss()
            }
            .start()
    }
}
