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
fun DateDivider(date: String) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.fillMaxWidth(),
    ) {
        Box(modifier = Modifier.width(28.5.dp).height(1.dp).background(DSColor.DividerLeft))
        Text(
            text = date,
            color = DSColor.TextMuted,
            fontSize = 12.sp,
            fontWeight = FontWeight.Light,
            modifier = Modifier
                .clip(RoundedCornerShape(DSRadius.full))
                .background(DSColor.BgCard)
                .padding(horizontal = 8.dp, vertical = 2.dp),
        )
        Box(modifier = Modifier.weight(1f).height(1.dp).background(DSColor.DividerRight))
    }
}
