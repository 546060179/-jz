package com.designsystem

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage

@Composable
fun UpdateReminderCard(
    date: String,
    coverUrl: String,
    title: String,
    reserved: Boolean,
    onToggleRemind: () -> Unit,
) {
    Column(
        modifier = Modifier.width(117.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        DateDivider(date = date)

        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            AsyncImage(
                model = coverUrl, contentDescription = title,
                contentScale = ContentScale.Crop,
                modifier = Modifier.width(117.dp).height(156.dp).clip(RoundedCornerShape(DSRadius.lg)),
            )
            Column(
                modifier = Modifier.padding(horizontal = 4.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Text(
                    text = title, color = DSColor.TextLight,
                    fontSize = 12.sp, fontWeight = FontWeight.Light,
                    lineHeight = 16.sp, maxLines = 2, overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.height(32.dp),
                )
                RemindButton(reserved = reserved, onToggle = onToggleRemind)
            }
        }
    }
}
