package com.designsystem

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage

@Composable
fun SmallBookCard(
    coverUrl: String,
    title: String,
    playCount: String,
    genres: List<String>,
    badge: TagVariant? = null,
) {
    Column(
        modifier = Modifier.width(117.dp),
        verticalArrangement = Arrangement.spacedBy(4.dp),
    ) {
        // Cover
        Box {
            Box(
                modifier = Modifier
                    .width(117.dp).height(156.dp)
                    .clip(RoundedCornerShape(DSRadius.lg))
            ) {
                AsyncImage(
                    model = coverUrl, contentDescription = title,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.fillMaxSize(),
                )
                // Play count
                Row(
                    modifier = Modifier
                        .align(Alignment.BottomEnd)
                        .padding(4.dp)
                        .height(20.dp)
                        .clip(RoundedCornerShape(DSRadius.md))
                        .background(DSColor.BgOverlay)
                        .padding(horizontal = 4.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                ) {
                    Icon(Icons.Filled.PlayArrow, contentDescription = null, tint = DSColor.TextWhite, modifier = Modifier.size(10.dp))
                    Text(playCount, color = DSColor.TextWhite, fontSize = 10.sp, fontWeight = FontWeight.Medium)
                }
            }
            badge?.let {
                Box(modifier = Modifier.align(Alignment.TopEnd).padding(top = 4.dp)) { Tag(variant = it) }
            }
        }

        // Info
        Column(
            modifier = Modifier.padding(horizontal = 4.dp),
            verticalArrangement = Arrangement.spacedBy(4.dp),
        ) {
            Text(
                text = title, color = DSColor.TextLight,
                fontSize = 12.sp, fontWeight = FontWeight.Light,
                lineHeight = 16.sp, maxLines = 2, overflow = TextOverflow.Ellipsis,
                modifier = Modifier.height(32.dp),
            )
            Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                genres.forEach { GenreTag(label = it, dark = true) }
            }
        }
    }
}
