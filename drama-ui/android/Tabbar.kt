package com.dramaui

import android.content.Context
import android.graphics.Typeface
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.annotation.DrawableRes

data class TabbarItem(
    val id: String,
    val label: String,
    @DrawableRes val iconRes: Int,
    @DrawableRes val activeIconRes: Int? = null
)

/**
 * Bottom tab bar with 5 tabs. 343×56dp rounded pill shape.
 * Active tab: unspecified tint (original icon color), white text, semi-bold.
 * Inactive tab: TextBlue tint, TextBlue text, normal weight.
 */
class TabbarView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    private var items: List<TabbarItem> = emptyList()
    private var activeId: String = ""
    private var onSelect: ((String) -> Unit)? = null
    private val tabViews = mutableListOf<TabItemHolder>()

    private data class TabItemHolder(
        val id: String,
        val icon: ImageView,
        val label: TextView,
        val item: TabbarItem
    )

    init {
        orientation = HORIZONTAL
        setBackgroundResource(R.drawable.bg_tabbar)
        val lp = LayoutParams(dp(343), dp(56))
        layoutParams = lp
    }

    fun setTabs(items: List<TabbarItem>, activeId: String, onSelect: (String) -> Unit) {
        this.items = items
        this.activeId = activeId
        this.onSelect = onSelect
        rebuild()
    }

    fun setActiveId(id: String) {
        activeId = id
        updateStates()
    }

    private fun rebuild() {
        removeAllViews()
        tabViews.clear()

        items.forEach { item ->
            val tabLayout = LayoutInflater.from(context)
                .inflate(R.layout.view_tabbar_item, this, false) as LinearLayout

            val icon = tabLayout.findViewById<ImageView>(R.id.tabIcon)
            val label = tabLayout.findViewById<TextView>(R.id.tabLabel)

            label.text = item.label

            tabLayout.setOnClickListener {
                activeId = item.id
                onSelect?.invoke(item.id)
                updateStates()
            }

            tabViews.add(TabItemHolder(item.id, icon, label, item))
            addView(tabLayout)
        }
        updateStates()
    }

    private fun updateStates() {
        tabViews.forEach { holder ->
            val active = holder.id == activeId
            val iconRes = if (active && holder.item.activeIconRes != null)
                holder.item.activeIconRes else holder.item.iconRes

            holder.icon.setImageResource(iconRes)
            if (active) {
                holder.icon.clearColorFilter()
                holder.label.setTextColor(DramaColor.FillWhite)
                holder.label.typeface = Typeface.create("sans-serif", Typeface.BOLD)
            } else {
                holder.icon.setColorFilter(DramaColor.TextBlue)
                holder.label.setTextColor(DramaColor.TextBlue)
                holder.label.typeface = Typeface.DEFAULT
            }
        }
    }

    private fun dp(value: Int): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value.toFloat(), resources.displayMetrics).toInt()
}

/*
 Usage:

 val tabbar = TabbarView(context)
 tabbar.setTabs(
     items = listOf(
         TabbarItem("home", "Home", R.drawable.icon_tab_home),
         TabbarItem("short", "Short", R.drawable.icon_tab_short),
         TabbarItem("reward", "Reward", R.drawable.icon_tab_reward),
         TabbarItem("collect", "My List", R.drawable.icon_tab_collect),
         TabbarItem("profile", "Profile", R.drawable.icon_tab_profile),
     ),
     activeId = "home",
     onSelect = { id -> /* handle tab change */ }
 )
*/
