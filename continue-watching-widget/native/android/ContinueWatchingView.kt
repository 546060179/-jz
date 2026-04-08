package com.example.continuewatching

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.*
import android.graphics.drawable.GradientDrawable
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Choreographer
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow

// ─── Timing Config ───
data class CWTiming(
    val slideUpDuration: Long = 450L,
    val collapseDelay: Long = 3000L,
    val fadeOutDuration: Long = 300L,
    val shrinkDuration: Long = 400L,
    val morphDuration: Long = 550L,
    val dismissDuration: Long = 300L,
)

// ─── Phase ───
enum class CWPhase {
    HIDDEN, SLIDING_UP, BANNER, FADING_CONTENT,
    SHRINKING, MORPHING, WIDGET, DISMISSING
}

// ─── Listener ───
interface ContinueWatchingListener {
    fun onShow() {}
    fun onCollapsed() {}
    fun onDismissed() {}
    fun onPlayClicked() {}
}

// ─── Easing Functions ───
private fun lerp(a: Float, b: Float, t: Float): Float = a + (b - a) * t
private fun easeOutCubic(t: Float): Float = 1f - (1f - t).pow(3)
private fun easeInOutCubic(t: Float): Float =
    if (t < 0.5f) 4f * t * t * t else 1f - (-2f * t + 2f).pow(3) / 2f
private fun easeOutBack(t: Float): Float {
    val c1 = 1.70158f; val c3 = c1 + 1f
    return 1f + c3 * (t - 1f).pow(3) + c1 * (t - 1f).pow(2)
}

/**
 * Continue Watching banner → widget animation view.
 *
 * Usage:
 *   Add to your FrameLayout (must be full-screen overlay or match_parent).
 *   Call configure(), then show(). The view handles the full animation lifecycle.
 */
class ContinueWatchingView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : FrameLayout(context, attrs, defStyleAttr) {

    // ─── Config ───
    var timing = CWTiming()
    var coverSizeW = 44.35f.dp
    var coverSizeH = 60f.dp
    var widgetSizeW = 90f.dp
    var widgetSizeH = 120f.dp
    var widgetOffsetX = 0f.dp
    var widgetOffsetY = 91f.dp
    var bottomInset = 83f.dp

    var listener: ContinueWatchingListener? = null

    // ─── State ───
    var phase: CWPhase = CWPhase.HIDDEN
        private set

    // ─── Views ───
    private val bannerContainer = FrameLayout(context)
    private val coverImageView = ImageView(context)
    private val infoContainer = LinearLayout(context)
    private val titleView = TextView(context)
    private val subtitleView = TextView(context)
    private val playButton = ImageView(context)
    private val closeButton = ImageView(context)
    private val widgetPlayButton = ImageView(context)
    private val widgetCloseButton = ImageView(context)

    // ─── Animation ───
    private var animPhase = ""
    private var phaseStartNanos = 0L
    private var isAnimating = false
    private val choreographer = Choreographer.getInstance()
    private var collapseRunnable: Runnable? = null

    // ─── Computed ───
    private val bannerHeight get() = coverSizeH + 8f.dp
    private val collapsedW get() = coverSizeW + 8f.dp
    private val collapsedH get() = coverSizeH + 8f.dp
    private val parentW get() = (parent as? View)?.width?.toFloat() ?: 375f.dp

    // ─── dp helper ───
    private val Float.dp: Float
        get() = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, this, resources.displayMetrics)

    init {
        clipChildren = false
        clipToPadding = false
        isClickable = false
        visibility = GONE
        setupViews()
    }

    private fun setupViews() {
        // Banner container
        bannerContainer.clipChildren = true
        bannerContainer.clipToPadding = true
        val bannerBg = GradientDrawable().apply {
            setColor(Color.parseColor("#26282E"))
            cornerRadii = floatArrayOf(8f.dp, 8f.dp, 8f.dp, 8f.dp, 0f, 0f, 0f, 0f)
        }
        bannerContainer.background = bannerBg
        bannerContainer.visibility = GONE
        addView(bannerContainer, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))

        // Cover
        coverImageView.scaleType = ImageView.ScaleType.CENTER_CROP
        coverImageView.clipToOutline = true
        bannerContainer.addView(coverImageView)

        // Info
        infoContainer.orientation = LinearLayout.VERTICAL
        bannerContainer.addView(infoContainer)

        titleView.setTextColor(Color.WHITE)
        titleView.textSize = 12f
        titleView.typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        titleView.maxLines = 1
        titleView.ellipsize = android.text.TextUtils.TruncateAt.END
        infoContainer.addView(titleView)

        subtitleView.setTextColor(Color.parseColor("#9F9FA2"))
        subtitleView.textSize = 10f
        infoContainer.addView(subtitleView)

        // Play button
        playButton.setOnClickListener { listener?.onPlayClicked() }
        bannerContainer.addView(playButton)

        // Close button
        closeButton.setOnClickListener { collapse() }
        bannerContainer.addView(closeButton)

        // Widget buttons
        widgetPlayButton.alpha = 0f
        widgetPlayButton.visibility = GONE
        widgetPlayButton.setOnClickListener { listener?.onPlayClicked() }
        bannerContainer.addView(widgetPlayButton)

        widgetCloseButton.alpha = 0f
        widgetCloseButton.visibility = GONE
        widgetCloseButton.setOnClickListener { dismiss() }
        bannerContainer.addView(widgetCloseButton)
    }

    // ─── Configure ───
    fun configure(coverBitmap: Bitmap?, title: String, subtitle: String? = null) {
        coverImageView.setImageBitmap(coverBitmap)
        titleView.text = title
        if (subtitle != null) {
            subtitleView.text = subtitle
            subtitleView.visibility = VISIBLE
        } else {
            subtitleView.visibility = GONE
        }
    }

    // ─── Layout banner state ───
    private fun layoutBanner() {
        val w = parentW
        val h = bannerHeight
        val pad = 4f.dp
        val padR = 16f.dp
        val btnSize = 32f.dp
        val closeSize = 20f.dp

        bannerContainer.layout(
            0, (height - bottomInset - h).toInt(),
            w.toInt(), (height - bottomInset).toInt()
        )
        bannerContainer.layoutParams = (bannerContainer.layoutParams as LayoutParams).apply {
            width = w.toInt()
            height = h.toInt()
            gravity = Gravity.BOTTOM or Gravity.START
            bottomMargin = bottomInset.toInt()
        }

        coverImageView.layout(pad.toInt(), pad.toInt(),
            (pad + coverSizeW).toInt(), (pad + coverSizeH).toInt())

        val infoX = (pad + coverSizeW + 12f.dp).toInt()
        val playX = (w - padR - closeSize - 12f.dp - btnSize).toInt()
        infoContainer.layout(infoX, pad.toInt(), playX - 8f.dp.toInt(), (pad + coverSizeH).toInt())

        playButton.layout(playX, ((h - btnSize) / 2).toInt(),
            (playX + btnSize).toInt(), ((h + btnSize) / 2).toInt())

        val closeX = (w - padR - closeSize).toInt()
        closeButton.layout(closeX, ((h - closeSize) / 2).toInt(),
            (closeX + closeSize).toInt(), ((h + closeSize) / 2).toInt())
    }

    // ─── Public API ───

    fun show() {
        if (phase != CWPhase.HIDDEN) return
        phase = CWPhase.SLIDING_UP
        visibility = VISIBLE
        bannerContainer.visibility = VISIBLE
        post { // wait for layout
            layoutBanner()
            bannerContainer.translationY = bannerHeight
            bannerContainer.alpha = 0f
            startAnimation("slide-up")
        }
    }

    fun collapse() {
        if (phase != CWPhase.BANNER) return
        collapseRunnable?.let { removeCallbacks(it) }
        stopAnimation()
        phase = CWPhase.FADING_CONTENT
        startAnimation("fade-content")
    }

    fun dismiss() {
        if (phase != CWPhase.WIDGET) return
        phase = CWPhase.DISMISSING
        bannerContainer.isClickable = false
        startAnimation("dismiss")
    }

    // ─── Animation Engine (Choreographer) ───

    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (phase == CWPhase.HIDDEN || !isAnimating) return
            if (phaseStartNanos == 0L) phaseStartNanos = frameTimeNanos
            val elapsedMs = (frameTimeNanos - phaseStartNanos) / 1_000_000f

            when (animPhase) {
                "slide-up" -> tickSlideUp(elapsedMs)
                "fade-content" -> tickFadeContent(elapsedMs)
                "shrink" -> tickShrink(elapsedMs)
                "morph" -> tickMorph(elapsedMs)
                "dismiss" -> tickDismiss(elapsedMs)
            }

            if (isAnimating) choreographer.postFrameCallback(this)
        }
    }

    private fun startAnimation(startPhase: String) {
        animPhase = startPhase
        phaseStartNanos = 0L
        isAnimating = true
        choreographer.postFrameCallback(frameCallback)
    }

    private fun stopAnimation() {
        isAnimating = false
        choreographer.removeFrameCallback(frameCallback)
    }

    // ─── Phase: Slide Up ───
    private fun tickSlideUp(elapsed: Float) {
        val t = min(elapsed / timing.slideUpDuration, 1f)
        val e = easeOutCubic(t)
        bannerContainer.translationY = (1f - e) * bannerHeight
        bannerContainer.alpha = min(t * 3f, 1f)

        if (t >= 1f) {
            bannerContainer.translationY = 0f
            bannerContainer.alpha = 1f
            phase = CWPhase.BANNER
            stopAnimation()
            listener?.onShow()
            // Auto-collapse
            collapseRunnable = Runnable {
                if (phase == CWPhase.BANNER) {
                    phase = CWPhase.FADING_CONTENT
                    startAnimation("fade-content")
                }
            }
            postDelayed(collapseRunnable!!, timing.collapseDelay)
        }
    }

    // ─── Phase: Fade Content ───
    private fun tickFadeContent(elapsed: Float) {
        val t = min(elapsed / timing.fadeOutDuration, 1f)
        val e = easeOutCubic(t)
        infoContainer.alpha = 1f - e
        playButton.alpha = 1f - e
        closeButton.alpha = 1f - e

        if (t >= 1f) {
            infoContainer.visibility = GONE
            playButton.visibility = GONE
            closeButton.visibility = GONE
            animPhase = "shrink"
            phaseStartNanos = 0L
            phase = CWPhase.SHRINKING
        }
    }

    // ─── Phase: Shrink ───
    private fun tickShrink(elapsed: Float) {
        val t = min(elapsed / timing.shrinkDuration, 1f)
        val e = easeInOutCubic(t)

        val w = lerp(parentW, collapsedW, e)
        val h = lerp(bannerHeight, collapsedH, e)

        val lp = bannerContainer.layoutParams as LayoutParams
        lp.width = w.toInt()
        lp.height = h.toInt()
        lp.bottomMargin = bottomInset.toInt()
        bannerContainer.layoutParams = lp
        bannerContainer.translationY = 0f

        // Corner radius
        val radius = if (t < 0.5f) 8f.dp else lerp(8f.dp, 4f.dp, (t - 0.5f) * 2f)
        val bg = bannerContainer.background as? GradientDrawable ?: GradientDrawable()
        val corners = if (t < 0.5f)
            floatArrayOf(radius, radius, radius, radius, 0f, 0f, 0f, 0f)
        else
            floatArrayOf(radius, radius, radius, radius, radius, radius, radius, radius)
        bg.cornerRadii = corners

        // Background fade
        val bgAlpha = lerp(255f, 0f, max(0f, (t - 0.5f) * 2f)).toInt()
        bg.setColor(Color.argb(bgAlpha, 38, 40, 46))
        bannerContainer.background = bg

        // Cover fills container
        val padV = lerp(4f.dp, 0f, e)
        val padR = lerp(16f.dp, 0f, e)
        val padL = lerp(4f.dp, 0f, e)
        coverImageView.layout(padL.toInt(), padV.toInt(),
            (w - padR).toInt(), (h - padV).toInt())
        // Update cover corner radius to match container
        coverImageView.outlineProvider = object : android.view.ViewOutlineProvider() {
            override fun getOutline(view: View, outline: android.graphics.Outline) {
                outline.setRoundRect(0, 0, view.width, view.height, radius)
            }
        }
        coverImageView.clipToOutline = true

        if (t >= 1f) {
            animPhase = "morph"
            phaseStartNanos = 0L
            phase = CWPhase.MORPHING
            bannerContainer.clipChildren = false
            bannerContainer.clipToPadding = false
            bg.setColor(Color.TRANSPARENT)
        }
    }

    // ─── Phase: Morph to Widget ───
    private fun tickMorph(elapsed: Float) {
        val t = min(elapsed / timing.morphDuration, 1f)
        val e = easeOutBack(t)
        val eSmooth = easeOutCubic(t)

        // HTML: C_BOTTOM = TABBAR_H (83), W_BOTTOM = TABBAR_H + 8 (91)
        // Both are absolute distances from parent bottom
        val startBottom = bottomInset  // 83dp — banner sits on tabbar
        val endBottom = bottomInset + 8f.dp  // 91dp — widget floats 8dp above tabbar

        val x = lerp(0f, widgetOffsetX, e)
        val bottom = lerp(startBottom, endBottom, e)
        val w = lerp(collapsedW, widgetSizeW, e)
        val h = lerp(collapsedH, widgetSizeH, e)

        val lp = bannerContainer.layoutParams as LayoutParams
        lp.width = w.toInt()
        lp.height = h.toInt()
        lp.leftMargin = x.toInt()
        lp.bottomMargin = bottom.toInt()
        lp.gravity = Gravity.BOTTOM or Gravity.START
        bannerContainer.layoutParams = lp

        coverImageView.layout(0, 0, w.toInt(), h.toInt())

        val radius = lerp(4f.dp, 8f.dp, eSmooth)
        val bg = bannerContainer.background as? GradientDrawable ?: GradientDrawable()
        bg.cornerRadii = FloatArray(8) { radius }
        bannerContainer.background = bg

        // Shadow (elevation) + border
        bannerContainer.elevation = eSmooth * 16f.dp
        // White border matching HTML: 1px solid rgba(255,255,255, eSmooth * 0.15)
        bg.setStroke(1f.dp.toInt(), Color.argb((eSmooth * 0.15f * 255).toInt(), 255, 255, 255))

        // Cover corner radius
        coverImageView.outlineProvider = object : android.view.ViewOutlineProvider() {
            override fun getOutline(view: View, outline: android.graphics.Outline) {
                outline.setRoundRect(0, 0, view.width, view.height, radius)
            }
        }
        coverImageView.clipToOutline = true

        if (t >= 1f) {
            phase = CWPhase.WIDGET
            stopAnimation()
            bannerContainer.isClickable = true
            listener?.onCollapsed()
            // Show widget buttons
            widgetPlayButton.visibility = VISIBLE
            widgetCloseButton.visibility = VISIBLE
            layoutWidgetButtons(w, h)
            widgetPlayButton.animate().alpha(1f).setDuration(350).start()
            widgetCloseButton.animate().alpha(1f).setDuration(350).start()
        }
    }

    // ─── Phase: Dismiss ───
    private fun tickDismiss(elapsed: Float) {
        val t = min(elapsed / timing.dismissDuration, 1f)
        val e = easeOutCubic(t)

        bannerContainer.alpha = 1f - e
        val scale = lerp(1f, 0.7f, e)
        val ty = lerp(0f, 30f.dp, e)
        bannerContainer.scaleX = scale
        bannerContainer.scaleY = scale
        bannerContainer.translationY = ty

        if (t >= 1f) {
            phase = CWPhase.HIDDEN
            stopAnimation()
            visibility = GONE
            bannerContainer.visibility = GONE
            resetSubviews()
            listener?.onDismissed()
        }
    }

    // ─── Helpers ───

    private fun layoutWidgetButtons(w: Float, h: Float) {
        val playSize = 38f.dp
        widgetPlayButton.layout(
            ((w - playSize) / 2).toInt(), ((h - playSize) / 2).toInt(),
            ((w + playSize) / 2).toInt(), ((h + playSize) / 2).toInt()
        )
        val closeSize = 18f.dp
        widgetCloseButton.layout(
            (w - 11f.dp).toInt(), (-7f.dp).toInt(),
            (w - 11f.dp + closeSize).toInt(), (-7f.dp + closeSize).toInt()
        )
    }

    private fun resetSubviews() {
        bannerContainer.alpha = 1f
        bannerContainer.scaleX = 1f
        bannerContainer.scaleY = 1f
        bannerContainer.translationY = 0f
        bannerContainer.translationX = 0f
        bannerContainer.elevation = 0f
        bannerContainer.clipChildren = true
        bannerContainer.clipToPadding = true
        infoContainer.visibility = VISIBLE
        infoContainer.alpha = 1f
        playButton.visibility = VISIBLE
        playButton.alpha = 1f
        closeButton.visibility = VISIBLE
        closeButton.alpha = 1f
        widgetPlayButton.visibility = GONE
        widgetPlayButton.alpha = 0f
        widgetCloseButton.visibility = GONE
        widgetCloseButton.alpha = 0f
        val bg = GradientDrawable().apply {
            setColor(Color.parseColor("#26282E"))
            cornerRadii = floatArrayOf(8f.dp, 8f.dp, 8f.dp, 8f.dp, 0f, 0f, 0f, 0f)
        }
        bannerContainer.background = bg
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        stopAnimation()
        collapseRunnable?.let { removeCallbacks(it) }
    }
}
