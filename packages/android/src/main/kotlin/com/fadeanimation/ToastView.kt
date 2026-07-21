package com.fadeanimation

import android.content.Context
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.widget.TextView

/**
 * ToastView — 轻量提示气泡视图
 *
 * pill 样式的消息条,通常配合 [MotionAnimator] 的 SLIDE_UP_IN 做进入/退出。
 * 与 iOS 端 `ToastView` 对齐。
 *
 * ```kotlin
 * val toast = ToastView(context, "操作成功")
 * container.addView(toast)
 * MotionAnimator(toast).start(entering = true, effects = EffectPresets.SLIDE_UP_IN)
 * ```
 */
class ToastView @JvmOverloads constructor(
    context: Context,
    initialMessage: String = ""
) : TextView(context) {

    /** 提示文字 */
    var message: String
        get() = text?.toString() ?: ""
        set(value) { text = value }

    init {
        val d = resources.displayMetrics.density
        text = initialMessage
        setTextColor(0xFFFFFFFF.toInt())
        textSize = 14f
        gravity = Gravity.CENTER
        maxLines = 1
        setPadding((16 * d).toInt(), (8 * d).toInt(), (16 * d).toInt(), (8 * d).toInt())
        background = GradientDrawable().apply {
            cornerRadius = 8 * d
            setColor(0x1FFFFFFF) // 白色 12% 透明
        }
    }
}
