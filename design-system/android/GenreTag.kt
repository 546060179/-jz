package com.designsystem

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun GenreTag(label: String, dark: Boolean = false) {
    Row(
        modifier = Modifier
            .height(20.dp)
            .clip(RoundedCornerShape(DSRadius.md))
            .background(if (dark) DSColor.BgD2 else DSColor.BgD1)
            .padding(horizontal = 6.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = label,
            color = if (dark) DSColor.TagPurple else DSColor.Primary,
            fontSize = 9.sp,
            fontWeight = if (dark) FontWeight.Medium else FontWeight.Normal,
            lineHeight = 14.sp,
        )
    }
}
