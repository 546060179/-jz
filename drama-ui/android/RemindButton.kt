package com.dramaui

import android.content.Context
import android.graphics.Typeface
import android.util.AttributeSet
import android.util.TypedValue
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Remind / Reserved toggle button.
 *
 * Off state: gradient background (-90° #CECECE → #6A74FF), dark text, remind icon.
 * On state: solid dark background, blue text, checkin icon.
 */
class RemindButtonView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    private val root: LinearLayout
    private val icon: ImageView
    private val label: TextView

    var reserved: Boolean = false
        private set

    var onToggle: (() -> Unit)? = null

    init {
        LayoutInflater.from(context).inflate(R.layout.view_remind_button, this, true)
        root = findViewById(R.id.remindRoot)
        icon = findViewById(R.id.remindIcon)
        label = findViewById(R.id.remindText)

        root.setOnClickListener {
            setReserved(!reserved)
            onToggle?.invoke()
        }

        updateState()
    }

    fun setReserved(value: Boolean) {
        reserved = value
        updateState()
    }

    private fun updateState() {
        if (reserved) {
            root.setBackgroundResource(R.drawable.bg_remind_reserved)
            icon.setImageResource(R.drawable.icon_checkin)
            icon.setColorFilter(DramaColor.FillBlue)
            label.text = "Reserved"
            label.setTextColor(DramaColor.FillBlue)
        } else {
            root.setBackgroundResource(R.drawable.bg_gradient_remind_off)
            icon.setImageResource(R.drawable.icon_remind)
            icon.setColorFilter(DramaColor.BgBlue)
            label.text = "Remind Me"
            label.setTextColor(DramaColor.BgBlue3)
        }
    }
}
