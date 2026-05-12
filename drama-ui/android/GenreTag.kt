package com.dramaui

import android.content.Context
import android.graphics.Typeface
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.widget.TextView

/**
 * Genre label tag — a small rounded pill showing a genre name.
 * Supports light (default) and dark variants.
 */
class GenreTagView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : TextView(context, attrs, defStyleAttr) {

    init {
        gravity = Gravity.CENTER
        val hPad = dp(6)
        setPadding(hPad, 0, hPad, 0)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 9f)
        minimumHeight = dp(20)
        // Default to light variant
        applyStyle(dark = false)
    }

    fun setGenre(label: String, dark: Boolean = false) {
        text = label
        applyStyle(dark)
    }

    private fun applyStyle(dark: Boolean) {
        if (dark) {
            setBackgroundResource(R.drawable.bg_genre_tag_dark)
            setTextColor(DramaColor.GenreDarkText)
            typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL)
        } else {
            setBackgroundResource(R.drawable.bg_genre_tag_light)
            setTextColor(DramaColor.FillBlue)
            typeface = Typeface.DEFAULT
        }
    }

    private fun dp(value: Int): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value.toFloat(), resources.displayMetrics).toInt()
}
