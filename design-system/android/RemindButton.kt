package com.designsystem

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun RemindButton(reserved: Boolean, onToggle: () -> Unit) {
    val shape = RoundedCornerShape(DSRadius.md)
    Row(
        modifier = Modifier
            .height(24.dp)
            .clip(shape)
            .background(if (reserved) DSColor.BgD2 else DSColor.NewGradient)
            .clickable(onClick = onToggle)
            .padding(horizontal = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(2.dp),
    ) {
        Icon(
            imageVector = if (reserved) Icons.Filled.Check else Icons.Filled.Notifications,
            contentDescription = null,
            tint = if (reserved) DSColor.Primary else DSColor.BgD1,
            modifier = Modifier.size(16.dp),
        )
        Text(
            text = if (reserved) "Reserved" else "Remind Me",
            color = if (reserved) DSColor.Primary else DSColor.BgD1,
            fontSize = 12.sp,
            fontWeight = FontWeight.Medium,
        )
    }
}
