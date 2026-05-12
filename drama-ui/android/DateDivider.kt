package com.dramaui

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Date divider with gradient lines on each side of a date pill.
 * Left line: 28dp gradient (transparent → 12% #C2CAF0).
 * Right line: fills remaining width, gradient (12% #C2CAF0 → transparent).
 */
class DateDividerView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    private val dateText: TextView

    init {
        LayoutInflater.from(context).inflate(R.layout.view_date_divider, this, true)
        dateText = findViewById(R.id.dateText)
    }

    fun setDate(date: String) {
        dateText.text = date
    }
}
