package com.kineticui.demo

import com.fadeanimation.EffectPresets
import com.fadeanimation.EasingCurves

/**
 * 所有动效预设目录 — 对齐 Kinetic UI 网站展示的全部效果
 */
object EffectCatalog {

    val sections: List<EffectSection> = listOf(
        EffectSection("基础过渡 Transitions", listOf(
            EffectDemoItem("Fade In", "淡入", EffectPresets.FADE_IN, true),
            EffectDemoItem("Fade Out", "淡出", EffectPresets.FADE_OUT, false),
            EffectDemoItem("Scale Fade In", "缩放淡入", EffectPresets.SCALE_FADE_IN, true),
            EffectDemoItem("Scale Fade Out", "缩放淡出", EffectPresets.SCALE_FADE_OUT, false),
            EffectDemoItem("Blur Fade In", "模糊淡入", EffectPresets.BLUR_FADE_IN, true),
            EffectDemoItem("Blur Fade Out", "模糊淡出", EffectPresets.BLUR_FADE_OUT, false),
        )),
        EffectSection("滑动 Slide", listOf(
            EffectDemoItem("Slide Up In", "从下方滑入", EffectPresets.SLIDE_UP_IN, true),
            EffectDemoItem("Slide Down Out", "向下滑出", EffectPresets.SLIDE_DOWN_OUT, false),
            EffectDemoItem("Slide Left In", "从左侧滑入", EffectPresets.SLIDE_LEFT_IN, true),
            EffectDemoItem("Slide Right In", "从右侧滑入", EffectPresets.SLIDE_RIGHT_IN, true),
        )),
        EffectSection("旋转 Rotate", listOf(
            EffectDemoItem("Rotate Fade In", "旋转淡入 -10°→0°", EffectPresets.ROTATE_FADE_IN, true),
            EffectDemoItem("Rotate Fade Out", "旋转淡出 0°→10°", EffectPresets.ROTATE_FADE_OUT, false),
        )),
        EffectSection("3D 翻转 Flip", listOf(
            EffectDemoItem("Flip X In", "绕 X 轴翻入 90°→0°", EffectPresets.FLIP_X_IN, true),
            EffectDemoItem("Flip X Out", "绕 X 轴翻出 0°→90°", EffectPresets.FLIP_X_OUT, false),
            EffectDemoItem("Flip Y In", "绕 Y 轴翻入 90°→0°", EffectPresets.FLIP_Y_IN, true),
            EffectDemoItem("Flip Y Out", "绕 Y 轴翻出 0°→90°", EffectPresets.FLIP_Y_OUT, false),
        )),
        EffectSection("折叠 Collapse", listOf(
            EffectDemoItem("Collapse In", "展开 0→auto", EffectPresets.COLLAPSE_IN, true),
            EffectDemoItem("Collapse Out", "折叠 auto→0", EffectPresets.COLLAPSE_OUT, false),
        )),
        EffectSection("弹性/缩放/旋转 Emphasis", listOf(
            EffectDemoItem("Bounce In", "弹性进入 scale 0.3→1（bounce 缓动过冲）", EffectPresets.BOUNCE_IN, true, EasingCurves.BOUNCE),
            EffectDemoItem("Zoom In", "缩放进入 scale 0.5→1", EffectPresets.ZOOM_IN, true),
            EffectDemoItem("Zoom Slide In", "缩放上滑 scale 0.9→1 + 上滑 32", EffectPresets.ZOOM_SLIDE_IN, true),
            EffectDemoItem("Spin In", "旋转进入 -180°→0°", EffectPresets.SPIN_IN, true, EasingCurves.EXPRESSIVE),
        )),
        EffectSection("预置业务组件 Components", listOf(
            EffectDemoItem("Bubble Expand", "气泡展开：阻尼谐振子弹性展开 + 文字后段淡入", emptyList(), true, component = "bubble"),
            EffectDemoItem("Continue Watching", "最近播放浮层：滑入→停留→详情淡出→收缩→变形小浮窗", emptyList(), true, component = "continue"),
            EffectDemoItem("Toast", "pill 消息条（SLIDE_UP_IN 滑入 + 自动退出）", emptyList(), true, component = "toast"),
            EffectDemoItem("Notification Banner", "应用内通知横幅（fade + 下滑）", emptyList(), true, component = "notification"),
            EffectDemoItem("Spotlight Overlay", "聚光灯引导遮罩：挖空高亮 + 提示（淡入）", emptyList(), true, component = "spotlight"),
        )),
    )

    /** 扁平化的全部 demo 列表（用于 RecyclerView adapter） */
    sealed class ListItem {
        data class Header(val title: String) : ListItem()
        data class Demo(val item: EffectDemoItem, val index: Int) : ListItem()
    }

    val flatList: List<ListItem> by lazy {
        val result = mutableListOf<ListItem>()
        var globalIndex = 0
        for (section in sections) {
            result.add(ListItem.Header(section.title))
            for (item in section.items) {
                result.add(ListItem.Demo(item, globalIndex))
                globalIndex++
            }
        }
        result
    }

    /** 根据全局索引获取 demo item */
    fun getItem(index: Int): EffectDemoItem {
        var i = 0
        for (section in sections) {
            for (item in section.items) {
                if (i == index) return item
                i++
            }
        }
        throw IndexOutOfBoundsException("Invalid index: $index")
    }
}
