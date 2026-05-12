package com.designsystem

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

data class TabItem(val id: String, val label: String)

@Composable
fun TabSwitch(tabs: List<TabItem>, activeId: String, onSelect: (String) -> Unit) {
    val shape = RoundedCornerShape(DSRadius.lg)
    Row {
        tabs.forEach { tab ->
            val active = tab.id == activeId
            Box(
                modifier = Modifier
                    .height(40.dp)
                    .then(if (active) Modifier.shadow(8.dp, shape, ambientColor = Color(0x967F73FF)) else Modifier)
                    .clip(shape)
                    .background(DSColor.BgCard)
                    .then(if (active) Modifier.border(2.dp, DSColor.TabBorderGradient, shape) else Modifier)
                    .clickable { onSelect(tab.id) }
                    .padding(horizontal = 12.dp, vertical = 4.dp),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = tab.label,
                    color = if (active) DSColor.PrimaryLight else Color.White.copy(alpha = 0.68f),
                    fontSize = if (active) 16.sp else 14.sp,
                    fontWeight = if (active) FontWeight.Medium else FontWeight.Normal,
                )
            }
        }
    }
}
