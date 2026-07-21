package com.fadeanimation

import android.app.Application
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.RectF
import android.view.View
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

/**
 * 库内预置动效 View 组件的运行时冒烟测试(Robolectric)。
 *
 * 在纯 JVM 下加载真实 Android framework，验证 5 个库外效果组件能正常实例化、
 * 设置属性、触发动画、执行自绘(onDraw)而不崩溃。对齐 iOS 端
 * `NativeComponentsSmokeTests.swift` 的测试范围。
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class NativeComponentsSmokeTest {

    private val context: Application get() = RuntimeEnvironment.getApplication()

    /** 让自绘 View 走一遍 measure → layout → draw，触发 onDraw。 */
    private fun exerciseDraw(view: View, w: Int = 240, h: Int = 96) {
        view.measure(
            View.MeasureSpec.makeMeasureSpec(w, View.MeasureSpec.AT_MOST),
            View.MeasureSpec.makeMeasureSpec(h, View.MeasureSpec.AT_MOST)
        )
        view.layout(0, 0, maxOf(view.measuredWidth, 1), maxOf(view.measuredHeight, 1))
        val bmp = Bitmap.createBitmap(
            maxOf(view.measuredWidth, 1), maxOf(view.measuredHeight, 1), Bitmap.Config.ARGB_8888
        )
        view.draw(Canvas(bmp))
    }

    @Test
    fun bubbleExpandView_instantiate_play_draw() {
        val bubble = BubbleExpandView(context)
        bubble.text = "限时免费"
        bubble.expandDurationMs = 650L
        bubble.textFadeDurationMs = 300L
        bubble.showArrow = true
        bubble.arrowDirection = BubbleExpandView.ArrowDirection.RIGHT
        bubble.play()   // 启动 ValueAnimator，不应崩溃
        exerciseDraw(bubble)
        bubble.stop()
        assertEquals("限时免费", bubble.text)
    }

    @Test
    fun toastView_message_getset() {
        val toast = ToastView(context, "操作成功")
        assertEquals("操作成功", toast.message)
        toast.message = "已保存"
        assertEquals("已保存", toast.message)
    }

    @Test
    fun spotlightOverlayView_targetRect_draw() {
        val overlay = SpotlightOverlayView(context, target = null, tipText = "点击这里发布")
        overlay.targetRect = RectF(100f, 200f, 180f, 240f)
        exerciseDraw(overlay, 320, 640)
        assertEquals("点击这里发布", overlay.tipText)
    }

    @Test
    fun continueWatchingView_show_phase_transition() {
        val bar = ContinueWatchingView(context)
        bar.timing = CWTiming(collapseDelay = 3000L)
        bar.configure(cover = null, title = "Genius Baby", subtitle = "EP.1 / EP.100")
        assertEquals(ContinueWatchingView.CWPhase.HIDDEN, bar.phase)
        bar.show()  // 同步进入 slidingUp
        assertEquals(ContinueWatchingView.CWPhase.SLIDING_UP, bar.phase)
        bar.dismiss()
        assertNotNull(bar)
    }

    @Test
    fun notificationBanner_title_and_icon() {
        val banner = NotificationBanner(context, "新消息")
        assertEquals("新消息", banner.title)
        banner.title = "系统通知"
        assertEquals("系统通知", banner.title)
        banner.setIcon(0)   // 传 0 隐藏图标，不应崩溃
        assertNotNull(banner)
    }
}
