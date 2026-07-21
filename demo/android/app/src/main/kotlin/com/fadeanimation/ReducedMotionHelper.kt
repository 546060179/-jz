package com.fadeanimation

import android.content.Context
import android.provider.Settings

/**
 * Android 平台无障碍动效偏好检测工具。
 *
 * 支持三级动效级别 — 对齐 Web 端 MotionLevel：
 * - FULL: 完整动效
 * - REDUCED: 减弱动效，保留过渡感但缩短时长到 t1 级别（100ms）
 * - NONE: 完全跳过动画
 */
object ReducedMotionHelper {

    /** 动效级别 — 对齐 Web 端 MotionLevel */
    enum class MotionLevel {
        FULL, REDUCED, NONE
    }

    /** reduced 模式下的最大时长（ms）— 对齐 Web 端 REDUCED_MAX_DURATION */
    const val REDUCED_MAX_DURATION: Long = 100L // TimingScale.T1

    /** 全局动效级别覆盖，null 表示跟随系统偏好 */
    private var globalMotionLevel: MotionLevel? = null

    /** 设置全局动效级别，传入 null 恢复为跟随系统偏好 */
    fun setMotionLevel(level: MotionLevel?) {
        globalMotionLevel = level
    }

    /** 获取当前全局动效级别设置 */
    fun getMotionLevel(): MotionLevel? = globalMotionLevel

    /**
     * 解析当前生效的动效级别。
     * 优先级：全局设置 > 系统偏好 > FULL
     */
    fun resolveMotionLevel(context: Context): MotionLevel {
        globalMotionLevel?.let { return it }
        return if (isSystemReducedMotion(context)) MotionLevel.NONE else MotionLevel.FULL
    }

    /**
     * 向后兼容：检测当前系统是否启用了减少动效。
     */
    fun isReducedMotionEnabled(context: Context): Boolean {
        return resolveMotionLevel(context) != MotionLevel.FULL
    }

    /**
     * 检测系统 Animator duration scale 是否为 0。
     */
    private fun isSystemReducedMotion(context: Context): Boolean {
        val scale = Settings.Global.getFloat(
            context.contentResolver,
            Settings.Global.ANIMATOR_DURATION_SCALE,
            1f
        )
        return scale == 0f
    }
}
