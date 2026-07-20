package com.kineticui.demo

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.fadeanimation.FadeOptions
import com.fadeanimation.MotionAnimator
import com.google.android.material.appbar.MaterialToolbar
import com.google.android.material.button.MaterialButton

/**
 * 动效详情页 — 展示单个效果的实际运行效果
 *
 * 点击播放按钮触发进入动画，结束后自动反向播放退出动画。
 */
class EffectDetailActivity : AppCompatActivity() {

    private lateinit var animatedBox: View
    private lateinit var btnPlay: MaterialButton
    private lateinit var tvInfo: TextView
    private lateinit var item: EffectDemoItem

    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_effect_detail)

        val index = intent.getIntExtra("index", 0)
        item = EffectCatalog.getItem(index)

        val toolbar = findViewById<MaterialToolbar>(R.id.toolbar)
        toolbar.title = item.name
        toolbar.setNavigationOnClickListener { onBackPressedDispatcher.onBackPressed() }

        animatedBox = findViewById(R.id.animatedBox)
        btnPlay = findViewById(R.id.btnPlay)
        tvInfo = findViewById(R.id.tvInfo)

        tvInfo.text = "${item.subtitle}\n效果数: ${item.effects.size} · entering: ${item.entering}"

        btnPlay.setOnClickListener { playAnimation() }
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

        // Play the animation
        handler.postDelayed({
            val options = FadeOptions(duration = 600L)
            val animator = MotionAnimator(animatedBox, options)
            animator.start(
                entering = item.entering,
                effects = item.effects,
                onEnd = {
                    // Auto-reverse after 500ms
                    handler.postDelayed({
                        reverseAnimation()
                    }, 500)
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
