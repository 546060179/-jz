package com.designsystem

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
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
fun BookCard(
    coverUrl: String,
    title: String,
    description: String,
    genres: List<String>,
    badge: TagVariant? = null,
) {
    Box(
        modifier = Modifier
            .width(225.dp)
            .clip(RoundedCornerShape(DSRadius.lg))
            .background(DSColor.BgD2)
    ) {
        Column {
            AsyncImage(
                model = coverUrl,
                contentDescription = title,
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxWidth().height(300.dp),
            )
        }

        // Overlay
        Column(
            modifier = Modifier.align(Alignment.BottomStart).fillMaxWidth()
        ) {
            Box(modifier = Modifier.fillMaxWidth().height(40.dp).background(DSColor.CoverGradient))
            Column(
                modifier = Modifier.fillMaxWidth().background(DSColor.BgD2).padding(horizontal = 4.dp, vertical = 4.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                // Genres
                Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    genres.forEach { GenreTag(label = it) }
                }
                // Title & desc
                Column(
                    modifier = Modifier.padding(horizontal = 4.dp).padding(bottom = 4.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp),
                ) {
                    Text(
                        text = title, color = DSColor.TextWhite,
                        fontSize = 20.sp, fontWeight = FontWeight.Normal,
                        lineHeight = 28.sp, maxLines = 1, overflow = TextOverflow.Ellipsis,
                    )
                    Text(
                        text = description, color = DSColor.TextMuted,
                        fontSize = 12.sp, fontWeight = FontWeight.Light,
                        lineHeight = 16.sp, maxLines = 2, overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.height(32.dp),
                    )
                }
            }
        }

        // Badge
        badge?.let {
            Box(modifier = Modifier.align(Alignment.TopEnd).padding(top = 8.dp)) {
                Tag(variant = it)
            }
        }
    }
}
