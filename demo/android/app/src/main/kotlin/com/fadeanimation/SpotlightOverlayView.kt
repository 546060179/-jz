package com.fadeanimation

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.RectF
import android.view.View

/**
 * SpotlightOverlayView — 聚光灯引导遮罩
 *
 * 铺满父视图的半透明遮罩,在目标区域"挖空"出高亮孔,并在其下方显示提示文字。
 * 通常配合 [MotionAnimator] 做淡入。与 iOS 端 `SpotlightOverlayView` 对齐。
 *
 * ```kotlin
 * val overlay = SpotlightOverlayView(context, publishBtn)
 * rootView.addView(overlay)
 * MotionAnimator(overlay).start(entering = true, effects = EffectPresets.FADE_IN)
 * ```
 */
class SpotlightOverlayView @JvmOverloads constructor(
    context: Context,
    private val target: View? = null,
    var tipText: String = "点击这里"
) : View(context) {

    /** 高亮目标区域(相对本视图坐标系),未设时从 target 视图推导 */
    var targetRect: RectF = RectF()
        set(value) { field = value; invalidate() }
    /** 目标外扩内边距(dp),默认 8 */
    var holePaddingDp: Float = 8f
    /** 挖空孔圆角(dp),默认 8 */
    var holeCornerRadiusDp: Float = 8f
    /** 遮罩颜色,默认黑色 50% */
    var maskColor: Int = 0x80000000.toInt()

    private val clearPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        xfermode = PorterDuffXfermode(PorterDuff.Mode.CLEAR)
    }
    private val tipPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        textAlign = Paint.Align.CENTER
        isFakeBoldText = true
    }

    private val density: Float get() = resources.displayMetrics.density

    init {
        // PorterDuff.CLEAR 需要软件层
        setLayerType(LAYER_TYPE_SOFTWARE, null)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        // 铺满父视图
        (parent as? View)?.let { p ->
            layoutParams = layoutParams?.apply {
                width = p.width
                height = p.height
            }
        }
        resolveTargetRect()
    }

    private fun resolveTargetRect() {
        val t = target ?: return
        if (targetRect.isEmpty) {
            targetRect = RectF(
                t.x, t.y,
                t.x + t.width, t.y + t.height
            )
        }
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        // 铺满遮罩
        canvas.drawColor(maskColor)

        if (!targetRect.isEmpty) {
            val pad = holePaddingDp * density
            val hole = RectF(
                targetRect.left - pad, targetRect.top - pad,
                targetRect.right + pad, targetRect.bottom + pad
            )
            val r = holeCornerRadiusDp * density
            canvas.drawRoundRect(hole, r, r, clearPaint)

            // 提示文字
            if (tipText.isNotEmpty()) {
                tipPaint.textSize = 14f * density
                val ty = hole.bottom + 12 * density - tipPaint.ascent()
                canvas.drawText(tipText, width / 2f, ty, tipPaint)
            }
        }
    }
}
