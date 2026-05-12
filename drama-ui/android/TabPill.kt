package com.dramaui

import android.content.Context
import android.graphics.*
import android.graphics.drawable.GradientDrawable
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.LinearLayout
import android.widget.TextView

data class TabPillItem(val id: String, val label: String)

/**
 * Tab switch pills with gradient border on active state + purple glow shadow.
 *
 * Active: 2dp gradient border (#CECECE → #4051FF at 90°), purple glow shadow,
 *         text color #BDC3FF, 16sp medium.
 * Inactive: no border, text white@68%, 14sp normal.
 */
class TabPillView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    private var tabs: List<TabPillItem> = emptyList()
    private var activeId: String = ""
    private var onSelect: ((String) -> Unit)? = null
    private val pillViews = mutableListOf<View>()

    init {
        orientation = HORIZONTAL
    }

    fun setTabs(tabs: List<TabPillItem>, activeId: String, onSelect: (String) -> Unit) {
        this.tabs = tabs
        this.activeId = activeId
        this.onSelect = onSelect
        rebuild()
    }

    fun setActiveId(id: String) {
        activeId = id
        updateStates()
    }

    private fun rebuild() {
        removeAllViews()
        pillViews.clear()

        tabs.forEach { tab ->
            val pill = GradientBorderTextView(context).apply {
                text = tab.label
                gravity = Gravity.CENTER
                val hPad = dp(DramaSpacing.md)
                val vPad = dp(DramaSpacing.xs)
                setPadding(hPad, vPad, hPad, vPad)
                minimumHeight = dp(40)
                setOnClickListener {
                    activeId = tab.id
                    onSelect?.invoke(tab.id)
                    updateStates()
                }
                tag = tab.id
            }
            pillViews.add(pill)
            addView(pill)
        }
        updateStates()
    }

    private fun updateStates() {
        pillViews.forEach { view ->
            val active = view.tag == activeId
            val tv = view as GradientBorderTextView
            tv.setActive(active)
        }
    }

    private fun dp(value: Int): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value.toFloat(), resources.displayMetrics).toInt()
}

/**
 * Custom TextView that draws a gradient border when active.
 */
class GradientBorderTextView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : androidx.appcompat.widget.AppCompatTextView(context, attrs, defStyleAttr) {

    private var isActive = false
    private val borderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeWidth = dpF(2)
    }
    private val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
    }
    private val radiusPx = dpF(DramaRadius.base)
    private val borderWidthPx = dpF(2)

    fun setActive(active: Boolean) {
        isActive = active
        if (active) {
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            setTextColor(DramaColor.TabActiveText)
            // Purple glow shadow
            setLayerType(LAYER_TYPE_SOFTWARE, null)
            setShadowLayer(dpF(8), 0f, 0f, DramaColor.TabGlow)
        } else {
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            typeface = Typeface.DEFAULT
            setTextColor(DramaColor.TextWhite)
            setShadowLayer(0f, 0f, 0f, 0)
            setLayerType(LAYER_TYPE_NONE, null)
        }
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        val rect = RectF(
            borderWidthPx / 2, borderWidthPx / 2,
            width.toFloat() - borderWidthPx / 2,
            height.toFloat() - borderWidthPx / 2
        )

        // Background
        bgPaint.color = DramaColor.BgBlue2
        canvas.drawRoundRect(rect, radiusPx, radiusPx, bgPaint)

        // Gradient border for active state
        if (isActive) {
            borderPaint.shader = LinearGradient(
                0f, 0f, width.toFloat(), 0f,
                DramaColor.GradientTabBorderStart, DramaColor.GradientTabBorderEnd,
                Shader.TileMode.CLAMP
            )
            canvas.drawRoundRect(rect, radiusPx, radiusPx, borderPaint)
        }

        super.onDraw(canvas)
    }

    private fun dpF(value: Int): Float =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value.toFloat(), resources.displayMetrics)
}
