package com.fadeanimation.rewardpopup

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.animation.OvershootInterpolator
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.annotation.ColorInt
import androidx.dynamicanimation.animation.DynamicAnimation
import androidx.dynamicanimation.animation.SpringAnimation
import androidx.dynamicanimation.animation.SpringForce
import com.fadeanimation.EffectPresets
import com.fadeanimation.FadeOptions
import com.fadeanimation.MotionAnimator
import com.fadeanimation.motion

/**
 * BingeUp 通知奖励弹窗 — 弹簧弹出动效
 *
 * 使用 FadeAnimation 库的 MotionAnimator 驱动遮罩淡入，
 * 使用 AndroidX SpringAnimation 驱动弹窗整体的弹簧进入动画。
 * 弹窗内的图片（礼盒、金币、星星）保持静态。
 *
 * 对齐库中 SPRING_PRESETS.bouncy: stiffness=200, damping=10
 *
 * 用法:
 * ```kotlin
 * val popup = RewardPopupView(context)
 * popup.show(parentFrameLayout)
 * ```
 */
class RewardPopupView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : FrameLayout(context, attrs, defStyleAttr) {

    // MARK: - Callbacks
    var onLater: (() -> Unit)? = null
    var onReceive: (() -> Unit)? = null

    // MARK: - Subviews
    private val maskOverlay: View
    private val cardContainer: FrameLayout

    // Spring animations
    private var scaleXSpring: SpringAnimation? = null
    private var scaleYSpring: SpringAnimation? = null
    private var translationYSpring: SpringAnimation? = null

    init {
        // 遮罩层
        maskOverlay = View(context).apply {
            setBackgroundColor(Color.parseColor("#99000000")) // 60% black
            alpha = 0f
            setOnClickListener { dismiss() }
        }
        addView(maskOverlay, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))

        // 弹窗卡片
        cardContainer = buildCard(context)
        val cardW = dp(279)
        val cardLp = LayoutParams(cardW, LayoutParams.WRAP_CONTENT).apply {
            gravity = Gravity.CENTER_HORIZONTAL
            topMargin = dp(251)
        }
        addView(cardContainer, cardLp)
    }

    // MARK: - Build Card UI

    private fun buildCard(ctx: Context): FrameLayout {
        val card = FrameLayout(ctx).apply { clipChildren = false }

        // ── Header (279×160) ──
        val header = FrameLayout(ctx).apply { clipChildren = false }
        val headerLp = LayoutParams(dp(279), dp(160))
        card.addView(header, headerLp)

        // bg_rect (y:72, h:88, #232525, radius top 20)
        val headerBg = View(ctx).apply {
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#232525"))
                cornerRadii = floatArrayOf(dpF(20), dpF(20), dpF(20), dpF(20), 0f, 0f, 0f, 0f)
            }
        }
        header.addView(headerBg, LayoutParams(dp(279), dp(88)).apply { topMargin = dp(72) })

        // 渐变叠加层切图
        val overlayIv = ImageView(ctx).apply {
            scaleType = ImageView.ScaleType.FIT_XY
            setImageResource(R.drawable.popup_header_overlay) // 需要放入 res/drawable
            clipToOutline = true
            outlineProvider = RoundedTopOutlineProvider(dpF(20))
        }
        header.addView(overlayIv, LayoutParams(dp(279), dp(88)).apply { topMargin = dp(72) })

        // 礼盒 (x:62.26, y:4, 133×140)
        val trophy = ImageView(ctx).apply {
            scaleType = ImageView.ScaleType.FIT_XY
            setImageResource(R.drawable.popup_trophy)
        }
        header.addView(trophy, LayoutParams(dp(133), dp(140)).apply {
            leftMargin = dp(62); topMargin = dp(4)
        })

        // 金币 (x:149.26, y:72, 80×80)
        val coins = ImageView(ctx).apply {
            scaleType = ImageView.ScaleType.FIT_XY
            setImageResource(R.drawable.popup_coins)
        }
        header.addView(coins, LayoutParams(dp(80), dp(80)).apply {
            leftMargin = dp(149); topMargin = dp(72)
        })

        // 大星星 (x:55.69, y:20.24, 16.53×25.32)
        val starBig = ImageView(ctx).apply {
            scaleType = ImageView.ScaleType.FIT_CENTER
            setImageResource(R.drawable.popup_star_big)
        }
        header.addView(starBig, LayoutParams(dp(17), dp(25)).apply {
            leftMargin = dp(56); topMargin = dp(20)
        })

        // 小星星 (x:39.34, y:58.2, 6×6.19)
        val starSmall = ImageView(ctx).apply {
            scaleType = ImageView.ScaleType.FIT_CENTER
            setImageResource(R.drawable.popup_star_small)
        }
        header.addView(starSmall, LayoutParams(dp(6), dp(6)).apply {
            leftMargin = dp(39); topMargin = dp(58)
        })

        // ── Body ──
        val body = LinearLayout(ctx).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(dp(8), dp(8), dp(8), dp(8))
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#232525"))
                cornerRadii = floatArrayOf(0f, 0f, 0f, 0f, dpF(20), dpF(20), dpF(20), dpF(20))
            }
        }
        val bodyLp = LayoutParams(dp(279), LayoutParams.WRAP_CONTENT).apply {
            topMargin = dp(160)
        }
        card.addView(body, bodyLp)

        // Title
        val title = TextView(ctx).apply {
            text = "Receive xX award"
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            setTextColor(Color.WHITE)
            typeface = android.graphics.Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
        }
        body.addView(title, LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT
        ))

        // Description
        val desc = TextView(ctx).apply {
            text = "Turn on notification permission to get reward notifications."
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            setTextColor(Color.parseColor("#C4C7D6"))
            gravity = Gravity.CENTER
            setPadding(dp(8), dp(10), dp(8), 0)
        }
        body.addView(desc, LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT
        ))

        // Buttons row
        val btnRow = LinearLayout(ctx).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            setPadding(0, dp(20), 0, 0)
        }
        body.addView(btnRow, LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT
        ))

        // Later button
        val laterBtn = TextView(ctx).apply {
            text = "Later"
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            setTextColor(Color.parseColor("#B8FFFFFF"))
            typeface = android.graphics.Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#3B3F3F"))
                cornerRadius = dpF(20)
            }
            minimumHeight = dp(40)
            setOnClickListener { dismiss { onLater?.invoke() } }
        }
        btnRow.addView(laterBtn, LinearLayout.LayoutParams(0, dp(40), 1f).apply {
            rightMargin = dp(4)
        })

        // Receive button
        val receiveBtn = TextView(ctx).apply {
            text = "Receive"
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            setTextColor(Color.parseColor("#141621"))
            typeface = android.graphics.Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#9AEF5E"))
                cornerRadius = dpF(100)
            }
            minimumHeight = dp(40)
            setOnClickListener { dismiss { onReceive?.invoke() } }
        }
        btnRow.addView(receiveBtn, LinearLayout.LayoutParams(0, dp(40), 1f).apply {
            leftMargin = dp(4)
        })

        return card
    }

    // MARK: - Show / Dismiss

    /**
     * 弹窗弹簧弹出
     *
     * 使用 AndroidX SpringAnimation，对齐库中 SPRING_PRESETS.bouncy:
     * stiffness=200, dampingRatio ≈ damping / (2 * sqrt(stiffness * mass)) = 10 / (2*√200) ≈ 0.354
     */
    fun show(parent: ViewGroup) {
        parent.addView(this, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))

        // 初始状态
        cardContainer.alpha = 0f
        cardContainer.scaleX = 0.3f
        cardContainer.scaleY = 0.3f
        cardContainer.translationY = dp(40).toFloat()

        // 遮罩淡入 — 使用 FadeAnimation 库
        maskOverlay.motion(
            entering = true,
            effects = EffectPresets.FADE_IN,
            options = FadeOptions(duration = 350L, easing = "ease-out")
        )

        // 弹窗 alpha 快速淡入（不用弹簧）
        cardContainer.animate()
            .alpha(1f)
            .setDuration(150)
            .setStartDelay(50)
            .start()

        // 弹窗弹簧动画 — scaleX, scaleY, translationY
        val springForce = SpringForce(1f).apply {
            stiffness = 200f  // 对齐 SPRING_PRESETS.bouncy
            dampingRatio = 0.354f // damping=10 / (2*sqrt(200*1))
        }

        scaleXSpring = SpringAnimation(cardContainer, DynamicAnimation.SCALE_X).apply {
            spring = springForce
            setStartValue(0.3f)
            start()
        }

        scaleYSpring = SpringAnimation(cardContainer, DynamicAnimation.SCALE_Y).apply {
            spring = springForce
            setStartValue(0.3f)
            start()
        }

        val tySpringForce = SpringForce(0f).apply {
            stiffness = 200f
            dampingRatio = 0.354f
        }
        translationYSpring = SpringAnimation(cardContainer, DynamicAnimation.TRANSLATION_Y).apply {
            spring = tySpringForce
            setStartValue(dp(40).toFloat())
            start()
        }

        // 礼盒弹簧弹入（延迟 100ms, stiffness * 0.8）
        val trophyView = cardContainer.getChildAt(0) // header
            ?.let { (it as? FrameLayout)?.getChildAt(3) } // trophy ImageView
        trophyView?.let { trophy ->
            trophy.alpha = 0f
            trophy.scaleX = 0f
            trophy.scaleY = 0f
            trophy.rotation = -8f

            trophy.postDelayed({
                trophy.animate().alpha(1f).setDuration(150).start()

                val trophySpringForce = SpringForce(1f).apply {
                    stiffness = 160f
                    dampingRatio = 0.354f
                }
                SpringAnimation(trophy, DynamicAnimation.SCALE_X).apply {
                    spring = trophySpringForce; setStartValue(0f); start()
                }
                SpringAnimation(trophy, DynamicAnimation.SCALE_Y).apply {
                    spring = trophySpringForce; setStartValue(0f); start()
                }
                SpringAnimation(trophy, DynamicAnimation.ROTATION).apply {
                    spring = SpringForce(0f).apply { stiffness = 160f; dampingRatio = 0.354f }
                    setStartValue(-8f); start()
                }
            }, 100)
        }

        // 金币弹簧弹入（延迟 167ms, stiffness * 0.7）
        val coinsView = cardContainer.getChildAt(0)
            ?.let { (it as? FrameLayout)?.getChildAt(4) } // coins ImageView
        coinsView?.let { coins ->
            coins.alpha = 0f
            coins.scaleX = 0f
            coins.scaleY = 0f
            coins.translationY = dp(10).toFloat()

            coins.postDelayed({
                coins.animate().alpha(1f).setDuration(150).start()

                val coinsSpringForce = SpringForce(1f).apply {
                    stiffness = 140f
                    dampingRatio = 0.354f
                }
                SpringAnimation(coins, DynamicAnimation.SCALE_X).apply {
                    spring = coinsSpringForce; setStartValue(0f); start()
                }
                SpringAnimation(coins, DynamicAnimation.SCALE_Y).apply {
                    spring = coinsSpringForce; setStartValue(0f); start()
                }
                SpringAnimation(coins, DynamicAnimation.TRANSLATION_Y).apply {
                    spring = SpringForce(0f).apply { stiffness = 140f; dampingRatio = 0.354f }
                    setStartValue(dp(10).toFloat()); start()
                }
            }, 167)
        }
    }

    /**
     * 弹窗退出
     */
    fun dismiss(onComplete: (() -> Unit)? = null) {
        // 取消弹簧
        scaleXSpring?.cancel()
        scaleYSpring?.cancel()
        translationYSpring?.cancel()

        // 遮罩淡出
        maskOverlay.motion(
            entering = false,
            effects = EffectPresets.FADE_OUT,
            options = FadeOptions(duration = 250L, easing = "ease-out")
        )

        // 弹窗缩小退出
        cardContainer.animate()
            .alpha(0f)
            .scaleX(0.85f)
            .scaleY(0.85f)
            .translationY(dp(20).toFloat())
            .setDuration(250)
            .withEndAction {
                (parent as? ViewGroup)?.removeView(this)
                onComplete?.invoke()
            }
            .start()
    }

    // MARK: - Helpers

    private fun dp(value: Int): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value.toFloat(), resources.displayMetrics).toInt()

    private fun dpF(value: Int): Float =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value.toFloat(), resources.displayMetrics)

    /**
     * 圆角 OutlineProvider（仅顶部圆角）
     */
    private class RoundedTopOutlineProvider(private val radius: Float) : android.view.ViewOutlineProvider() {
        override fun getOutline(view: View, outline: android.graphics.Outline) {
            outline.setRoundRect(0, 0, view.width, view.height + radius.toInt(), radius)
        }
    }
}
