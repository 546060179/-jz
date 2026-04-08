package com.fadeanimation

import android.content.Context
import android.provider.Settings

/**
 * Android 平台无障碍动效偏好检测工具。
 *
 * 通过读取系统 Animator duration scale 设置判断用户是否关闭了动画效果。
 * 当 ANIMATOR_DURATION_SCALE 为 0 时，表示用户希望跳过动画。
 */
object ReducedMotionHelper {

    /**
     * 检测当前系统是否启用了减少动效（Animator duration scale 为 0）。
     *
     * @param context Android Context，用于访问系统设置
     * @return true 表示用户关闭了动画效果（duration scale = 0），应跳过动画
     */
    fun isReducedMotionEnabled(context: Context): Boolean {
        val scale = Settings.Global.getFloat(
            context.contentResolver,
            Settings.Global.ANIMATOR_DURATION_SCALE,
            1f
        )
        return scale == 0f
    }
}
