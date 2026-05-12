package com.dramaui

import android.content.Context
import android.util.AttributeSet
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Large book card (225×~400dp) with cover image, gradient overlay,
 * genre tags, title, description, and optional badge.
 *
 * Cover image loading is left to the consumer — call [getCoverImageView]
 * and use Glide/Coil/Picasso to load the URL.
 */
class BookCardView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : FrameLayout(context, attrs, defStyleAttr) {

    private val coverImage: ImageView
    private val genreContainer: LinearLayout
    private val titleText: TextView
    private val descriptionText: TextView
    private val badgeContainer: FrameLayout

    init {
        LayoutInflater.from(context).inflate(R.layout.view_book_card, this, true)
        coverImage = findViewById(R.id.coverImage)
        genreContainer = findViewById(R.id.genreContainer)
        titleText = findViewById(R.id.titleText)
        descriptionText = findViewById(R.id.descriptionText)
        badgeContainer = findViewById(R.id.badgeContainer)
    }

    /** Returns the ImageView for external image loading (Glide/Coil). */
    fun getCoverImageView(): ImageView = coverImage

    fun setTitle(title: String) {
        titleText.text = title
    }

    fun setDescription(description: String) {
        descriptionText.text = description
    }

    fun setGenres(genres: List<String>) {
        genreContainer.removeAllViews()
        genres.forEachIndexed { index, genre ->
            val tag = GenreTagView(context).apply {
                setGenre(genre, dark = false)
            }
            if (index > 0) {
                val lp = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply { marginStart = dp(4) }
                tag.layoutParams = lp
            }
            genreContainer.addView(tag)
        }
    }

    fun setBadge(variant: TagVariant?) {
        badgeContainer.removeAllViews()
        if (variant != null) {
            badgeContainer.visibility = View.VISIBLE
            val tagView = TagView(context).apply {
                setVariant(variant)
            }
            badgeContainer.addView(tagView)
        } else {
            badgeContainer.visibility = View.GONE
        }
    }

    private fun dp(value: Int): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value.toFloat(), resources.displayMetrics).toInt()
}
