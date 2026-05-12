package com.dramaui

import android.content.Context
import android.graphics.*
import android.graphics.drawable.GradientDrawable
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView

enum class TagVariant(
    val label: String,
    val gradientColors: IntArray,
    val textColor: Int,
    val hasTail: Boolean = true
) {
    New("New", intArrayOf(DramaColor.GradientNewStart, DramaColor.GradientNewEnd), DramaColor.BgBlue),
    Hot("Hot", intArrayOf(DramaColor.GradientHotStart, DramaColor.GradientHotEnd), DramaColor.BgBlue),
    Free("Free", intArrayOf(DramaColor.GradientNewStart, DramaColor.GradientNewEnd), DramaColor.BgBlue),
    Exclusive("Exclusive", intArrayOf(DramaColor.GradientNewStart, DramaColor.GradientNewEnd), DramaColor.BgBlue),
    MembersOnly(
        "Members Only",
        intArrayOf(DramaColor.MembersOnlyStart, DramaColor.MembersOnlyEnd),
        DramaColor.TextOrange,
        hasTail = false
    );
}

/**
 * Tag badge with left-rounded shape + optional right SVG tail.
 *
 * Left side: 6dp top-start / bottom-start rounded corners, gradient background.
 * Right tail: 4×18dp light bar + 4×4dp dark dot with 2dp corner radius.
 */
class TagView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    private val tagLabel: TextView
    private val tailContainer: LinearLayout

    private var variant: TagVariant = TagVariant.New

    init {
        orientation = HORIZONTAL
        gravity = Gravity.BOTTOM

        // Tag body
        tagLabel = TextView(context).apply {
            layoutParams = LayoutParams(LayoutParams.WRAP_CONTENT, dp(16)).apply {
                gravity = Gravity.BOTTOM
            }
            this.gravity = Gravity.CENTER_VERTICAL
            setPadding(dp(8), 0, dp(2), 0)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 9f)
            typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL)
        }
        addView(tagLabel)

        // Tail decoration
        tailContainer = LinearLayout(context).apply {
            orientation = VERTICAL
            layoutParams = LayoutParams(dp(4), LayoutParams.WRAP_CONTENT)
        }
        // Light bar 4×18dp
        val lightBar = View(context).apply {
            layoutParams = LayoutParams(dp(4), dp(18))
            setBackgroundColor(Color.parseColor("#CECECE"))
        }
        tailContainer.addView(lightBar)
        // Dark dot 4×4dp with 2dp corner
        val darkDot = View(context).apply {
            layoutParams = LayoutParams(dp(4), dp(4))
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#545472"))
                cornerRadius = dpF(2)
            }
        }
        tailContainer.addView(darkDot)
        addView(tailContainer)
    }

    fun setVariant(variant: TagVariant, customLabel: String? = null) {
        this.variant = variant
        tagLabel.text = customLabel ?: variant.label
        tagLabel.setTextColor(variant.textColor)

        // Left-rounded shape with gradient
        val radiusPx = dpF(DramaRadius.sm)
        val bg = GradientDrawable(
            GradientDrawable.Orientation.LEFT_RIGHT,
            variant.gradientColors
        ).apply {
            cornerRadii = floatArrayOf(radiusPx, radiusPx, 0f, 0f, 0f, 0f, radiusPx, radiusPx)
        }
        tagLabel.background = bg

        tailContainer.visibility = if (variant.hasTail) View.VISIBLE else View.GONE
    }

    private fun dp(value: Int): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value.toFloat(), resources.displayMetrics).toInt()

    private fun dpF(value: Int): Float =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value.toFloat(), resources.displayMetrics)
}
