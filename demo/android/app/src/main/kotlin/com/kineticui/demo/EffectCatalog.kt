package com.kineticui.demo

import com.fadeanimation.EffectPresets

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
