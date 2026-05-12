package com.dramaui

import android.content.Context
import android.graphics.Typeface
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Rank tag with fire icon — e.g. "🔥 5th in Most Popular".
 * Pill shape with red border at 40% opacity.
 */
class RankTagView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    private val rankText: TextView
    private val fireIcon: ImageView

    init {
        LayoutInflater.from(context).inflate(R.layout.view_rank_tag, this, true)
        // The inflated root is a LinearLayout child; we re-parent its children
        val inflated = getChildAt(0) as LinearLayout
        removeAllViews()

        orientation = HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        val hPad = dp(6)
        setPadding(hPad, 0, hPad, 0)
        minimumHeight = dp(16)
        setBackgroundResource(R.drawable.bg_rank_tag)

        fireIcon = inflated.findViewById<ImageView>(R.id.fireIcon).also {
            inflated.removeView(it)
            addView(it)
        }
        rankText = inflated.findViewById<TextView>(R.id.rankText).also {
            inflated.removeView(it)
            addView(it)
        }
    }

    fun setRank(rank: Int, category: String = "Most Popular") {
        val suffix = when {
            rank % 100 in 11..13 -> "th"
            rank % 10 == 1 -> "st"
            rank % 10 == 2 -> "nd"
            rank % 10 == 3 -> "rd"
            else -> "th"
        }
        rankText.text = "${rank}${suffix} in $category"
    }

    private fun dp(value: Int): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value.toFloat(), resources.displayMetrics).toInt()
}
