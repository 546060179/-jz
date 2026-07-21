package com.kineticui.demo

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.fadeanimation.BubbleExpandView
import com.fadeanimation.ContinueWatchingView
import com.fadeanimation.CWTiming
import com.fadeanimation.EffectPresets
import com.fadeanimation.FadeOptions
import com.fadeanimation.MotionAnimator
import com.fadeanimation.MotionEffect
import com.fadeanimation.MotionIntent
import com.fadeanimation.NotificationBanner
import com.fadeanimation.SlideDirection
import com.fadeanimation.SpotlightOverlayView
import com.fadeanimation.ToastView
import android.graphics.RectF
import com.google.android.material.appbar.MaterialToolbar
import com.google.android.material.button.MaterialButton

/**
 * 动效详情页 — 展示单个效果的实际运行效果。
 *
 * 两种模式：
 * - 预设模式：在通用盒子上用 MotionAnimator 播放预设效果，结束后自动反向。
 * - 业务组件模式（item.component != null）：注入对应自定义 View 并触发其内建动画。
 */
class EffectDetailActivity : AppCompatActivity() {

    private lateinit var animatedBox: View
    private lateinit var tvEmoji: TextView
    private lateinit var componentHost: FrameLayout
    private lateinit var btnPlay: MaterialButton
    private lateinit var tvInfo: TextView
    private lateinit var item: EffectDemoItem

    private val handler = Handler(Looper.getMainLooper())
    private var playComponent: (() -> Unit)? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_effect_detail)

        val index = intent.getIntExtra("index", 0)
        item = EffectCatalog.getItem(index)

        val toolbar = findViewById<MaterialToolbar>(R.id.toolbar)
        toolbar.title = item.name
        toolbar.setNavigationOnClickListener { onBackPressedDispatcher.onBackPressed() }

        animatedBox = findViewById(R.id.animatedBox)
        tvEmoji = findViewById(R.id.tvEmoji)
        componentHost = findViewById(R.id.componentHost)
        btnPlay = findViewById(R.id.btnPlay)
        tvInfo = findViewById(R.id.tvInfo)

        if (item.component != null) {
            setupComponent(item.component!!)
            tvInfo.text = item.subtitle
            btnPlay.setOnClickListener { playComponent?.invoke() }
        } else {
            tvInfo.text = "${item.subtitle}\n效果数: ${item.effects.size} · entering: ${item.entering}"
            btnPlay.setOnClickListener { playAnimation() }
        }
    }

    private val Int.dp: Int get() = (this * resources.displayMetrics.density).toInt()

    /** 业务组件模式：隐藏通用盒子，注入对应自定义 View，并设置播放逻辑 */
    private fun setupComponent(key: String) {
        animatedBox.visibility = View.GONE
        tvEmoji.visibility = View.GONE
        componentHost.visibility = View.VISIBLE
        componentHost.removeAllViews()

        when (key) {
            "bubble" -> {
                val bubble = BubbleExpandView(this).apply {
                    text = "限时免费"
                    arrowDirection = BubbleExpandView.ArrowDirection.RIGHT
                }
                componentHost.addView(bubble, FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.WRAP_CONTENT, 22.dp))
                playComponent = { bubble.play() }
                bubble.post { bubble.play() }
            }
            "continue" -> {
                val bar = ContinueWatchingView(this).apply {
                    timing = CWTiming()
                    configure(cover = null, title = "Genius Baby", subtitle = "EP.1 / EP.100")
                }
                componentHost.addView(bar, FrameLayout.LayoutParams(320.dp, 68.dp))
                playComponent = { bar.show() }
                bar.post { bar.show() }
            }
            "toast" -> {
                val toast = ToastView(this, "操作成功")
                componentHost.addView(toast, FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT))
                playComponent = {
                    MotionAnimator(toast).start(
                        entering = true,
                        effects = EffectPresets.SLIDE_UP_IN,
                        options = FadeOptions(intent = MotionIntent.ENTER)
                    )
                    handler.postDelayed({
                        MotionAnimator(toast).start(entering = false, effects = EffectPresets.SLIDE_DOWN_OUT)
                    }, 2500)
                }
                toast.post { playComponent?.invoke() }
            }
            "notification" -> {
                val banner = NotificationBanner(this, "你有一条新消息")
                componentHost.addView(banner, FrameLayout.LayoutParams(300.dp,
                    FrameLayout.LayoutParams.WRAP_CONTENT))
                playComponent = {
                    MotionAnimator(banner).start(
                        entering = true,
                        effects = listOf(
                            MotionEffect.Fade(0f, 1f),
                            MotionEffect.Slide(SlideDirection.DOWN, 20f)
                        )
                    )
                }
                banner.post { playComponent?.invoke() }
            }
            "spotlight" -> {
                val host = FrameLayout(this)
                // 底部放一个"目标"按钮，遮罩挖空高亮它
                val target = MaterialButton(this).apply { text = "发布" }
                val targetLp = FrameLayout.LayoutParams(100.dp, 44.dp)
                targetLp.leftMargin = 90.dp; targetLp.topMargin = 60.dp
                host.addView(target, targetLp)
                val overlay = SpotlightOverlayView(this, tipText = "点击这里发布").apply {
                    targetRect = RectF(90f * resources.displayMetrics.density,
                        60f * resources.displayMetrics.density,
                        (90f + 100f) * resources.displayMetrics.density,
                        (60f + 44f) * resources.displayMetrics.density)
                }
                host.addView(overlay, FrameLayout.LayoutParams(280.dp, 200.dp))
                componentHost.addView(host, FrameLayout.LayoutParams(280.dp, 200.dp))
                playComponent = {
                    MotionAnimator(overlay).start(
                        entering = true,
                        effects = EffectPresets.FADE_IN,
                        options = FadeOptions(intent = MotionIntent.ENTER)
                    )
                }
                overlay.post { playComponent?.invoke() }
            }
        }
    }

    private fun playAnimation() {
        // Reset state
        animatedBox.alpha = 1f
        animatedBox.scaleX = 1f
        animatedBox.scaleY = 1f
        animatedBox.translationX = 0f
        animatedBox.translationY = 0f
        animatedBox.rotation = 0f
        animatedBox.rotationX = 0f
        animatedBox.rotationY = 0f
        animatedBox.visibility = View.VISIBLE

        handler.postDelayed({
            val options = FadeOptions(duration = 600L, interpolator = item.interpolator)
            val animator = MotionAnimator(animatedBox, options)
            animator.start(
                entering = item.entering,
                effects = item.effects,
                onEnd = {
                    handler.postDelayed({ reverseAnimation() }, 500)
                }
            )
        }, 100)
    }

    private fun reverseAnimation() {
        val options = FadeOptions(duration = 600L)
        val animator = MotionAnimator(animatedBox, options)
        animator.start(
            entering = !item.entering,
            effects = item.effects,
            onEnd = null
        )
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacksAndMessages(null)
    }
}
