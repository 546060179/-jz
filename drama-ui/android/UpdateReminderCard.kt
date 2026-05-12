package com.dramaui

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Update reminder card: date divider + cover image + title + remind button.
 *
 * Cover image loading is left to the consumer — call [getCoverImageView]
 * and use Glide/Coil/Picasso to load the URL.
 */
class UpdateReminderCardView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    private val dateDividerContainer: FrameLayout
    private val coverImage: ImageView
    private val titleText: TextView
    private val remindButtonContainer: FrameLayout

    private var dateDivider: DateDividerView? = null
    private var remindButton: RemindButtonView? = null

    init {
        orientation = VERTICAL
        LayoutInflater.from(context).inflate(R.layout.view_update_reminder_card, this, true)
        dateDividerContainer = findViewById(R.id.dateDividerContainer)
        coverImage = findViewById(R.id.coverImage)
        titleText = findViewById(R.id.titleText)
        remindButtonContainer = findViewById(R.id.remindButtonContainer)

        // Create child components
        dateDivider = DateDividerView(context).also {
            dateDividerContainer.addView(it)
        }
        remindButton = RemindButtonView(context).also {
            remindButtonContainer.addView(it)
        }
    }

    fun getCoverImageView(): ImageView = coverImage

    fun setDate(date: String) {
        dateDivider?.setDate(date)
    }

    fun setTitle(title: String) {
        titleText.text = title
    }

    fun setReserved(reserved: Boolean) {
        remindButton?.setReserved(reserved)
    }

    fun setOnToggleRemind(listener: () -> Unit) {
        remindButton?.onToggle = listener
    }
}
