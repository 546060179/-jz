package com.fadeanimation

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView

/**
 * NotificationBanner — 应用内通知横幅视图
 *
 * 顶部下滑进入的通知卡片,含可选图标与标题。动画由 [MotionAnimator] 驱动
 * (通常 fade + slide down)。与 iOS 端 `NotificationBanner` 对齐。
 *
 * ```kotlin
 * val banner = NotificationBanner(context, "新消息")
 * container.addView(banner)
 * MotionAnimator(banner).start(
 *   entering = true,
 *   effects = listOf(MotionEffect.Fade(0f, 1f), MotionEffect.Slide(SlideDirection.DOWN, 20f))
 * )
 * ```
 */
class NotificationBanner @JvmOverloads constructor(
    context: Context,
    initialTitle: String = ""
) : LinearLayout(context) {

    private val iconView = ImageView(context)
    private val titleLabel = TextView(context)

    /** 标题文字 */
    var title: String
        get() = titleLabel.text?.toString() ?: ""
        set(value) { titleLabel.text = value }

    init {
        val d = resources.displayMetrics.density
        orientation = HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        setPadding((12 * d).toInt(), (10 * d).toInt(), (12 * d).toInt(), (10 * d).toInt())
        background = GradientDrawable().apply {
            cornerRadius = 12 * d
            setColor(0x0FFFFFFF)                    // 白色 6% 透明
            setStroke((1 * d).toInt(), 0x1AFFFFFF)  // 白色 10% 描边
        }

        val iconSize = (24 * d).toInt()
        iconView.layoutParams = LayoutParams(iconSize, iconSize).apply {
            marginEnd = (10 * d).toInt()
        }
        iconView.visibility = GONE
        addView(iconView)

        titleLabel.text = initialTitle
        titleLabel.setTextColor(Color.WHITE)
        titleLabel.textSize = 14f
        titleLabel.maxLines = 2
        titleLabel.layoutParams = LayoutParams(0, LayoutParams.WRAP_CONTENT, 1f)
        addView(titleLabel)
    }

    /** 设置左侧图标(资源 id),传 0 隐藏 */
    fun setIcon(resId: Int) {
        if (resId == 0) {
            iconView.visibility = GONE
        } else {
            iconView.setImageResource(resId)
            iconView.visibility = VISIBLE
        }
    }
}
