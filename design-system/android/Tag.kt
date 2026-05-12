package com.designsystem

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

enum class TagVariant(val label: String, val gradient: Brush, val textColor: Color) {
    New("New", DSColor.NewGradient, DSColor.BgD2),
    Hot("Hot", DSColor.HotGradient, DSColor.BgD2),
    Free("Free", DSColor.NewGradient, DSColor.BgD2),
    Exclusive("Exclusive", DSColor.NewGradient, DSColor.BgD2),
    MembersOnly("Members Only", DSColor.VipGradient, DSColor.VipGold);
}

@Composable
fun Tag(variant: TagVariant, label: String? = null) {
    val shape = RoundedCornerShape(topStart = DSRadius.sm, bottomStart = DSRadius.sm)
    Row(
        modifier = Modifier
            .height(16.dp)
            .clip(shape)
            .background(variant.gradient)
            .padding(start = 8.dp, end = 2.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = label ?: variant.label,
            color = variant.textColor,
            fontSize = 9.sp,
            fontWeight = FontWeight.Medium,
            lineHeight = 12.sp,
        )
    }
}
