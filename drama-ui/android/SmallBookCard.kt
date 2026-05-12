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
 * Small book card (117×156dp cover) with play count overlay,
 * title, genre tags, and optional badge.
 *
 * Cover image loading is left to the consumer — call [getCoverImageView]
 * and use Glide/Coil/Picasso to load the URL.
 */
class SmallBookCardView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    private val coverImage: ImageView
    private val playCountText: TextView
    private val titleText: TextView
    private val genreContainer: LinearLayout
    private val badgeContainer: FrameLayout

    init {
        orientation = VERTICAL
        LayoutInflater.from(context).inflate(R.layout.view_small_book_card, this, true)
        coverImage = findViewById(R.id.coverImage)
        playCountText = findViewById(R.id.playCountText)
        titleText = findViewById(R.id.titleText)
        genreContainer = findViewById(R.id.genreContainer)
        badgeContainer = findViewById(R.id.badgeContainer)
    }

    fun getCoverImageView(): ImageView = coverImage

    fun setTitle(title: String) {
        titleText.text = title
    }

    fun setPlayCount(count: String) {
        playCountText.text = count
    }

    fun setGenres(genres: List<String>) {
        genreContainer.removeAllViews()
        genres.forEachIndexed { index, genre ->
            val tag = GenreTagView(context).apply {
                setGenre(genre, dark = true)
            }
            if (index > 0) {
                val lp = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT).apply {
                    marginStart = dp(4)
                }
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
