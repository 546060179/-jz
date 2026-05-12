package com.designsystem

import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

// Colors
object DSColor {
    val Primary = Color(0xFF5A68FF)
    val PrimaryLight = Color(0xFFBDC3FF)
    val BgD1 = Color(0xFF050713)
    val BgD2 = Color(0xFF141621)
    val BgCard = Color(0x1FC2CAF0) // 12% opacity
    val BgOverlay = Color(0x1F141621)
    val TextWhite = Color.White
    val TextLight = Color(0xFFC4C7D6)
    val TextMuted = Color(0xFF6C7398)
    val TagPurple = Color(0xFF5D67F4)
    val VipGold = Color(0xFFFFE0B5)
    val HotPink = Color(0xFFFA5E7B)

    val NewGradient = Brush.horizontalGradient(listOf(Color(0xFF6A74FF), Color(0xFFCECECE)))
    val HotGradient = Brush.horizontalGradient(listOf(Color(0xFFFA5E7B), Color(0xFFCECECE)))
    val VipGradient = Brush.horizontalGradient(listOf(Color(0xFF121732), Color(0xFF2634C7)))
    val TabBorderGradient = Brush.horizontalGradient(listOf(Color(0xFFCECECE), Color(0xFF4051FF)))
    val DividerLeft = Brush.horizontalGradient(listOf(Color(0x00C2CAF0), Color(0x1FC2CAF0)))
    val DividerRight = Brush.horizontalGradient(listOf(Color(0x1FC2CAF0), Color(0x00C2CAF0)))
    val CoverGradient = Brush.verticalGradient(listOf(Color(0x00141621), Color(0xFF141621)))
}

// Radii
object DSRadius {
    val sm = 6.dp
    val md = 8.dp
    val lg = 12.dp
    val full = 100.dp
}
