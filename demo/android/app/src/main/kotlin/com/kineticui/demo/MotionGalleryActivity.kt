package com.kineticui.demo

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.TextView
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.appbar.MaterialToolbar

/**
 * Kinetic UI 动效画廊主页
 *
 * 展示 22 种预设动效 + 5 个预置业务组件的列表，点击进入详情页播放。
 */
class MotionGalleryActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_motion_gallery)

        val toolbar = findViewById<MaterialToolbar>(R.id.toolbar)
        setSupportActionBar(toolbar)

        val recyclerView = findViewById<RecyclerView>(R.id.recyclerView)
        recyclerView.layoutManager = LinearLayoutManager(this)
        recyclerView.adapter = GalleryAdapter()
    }

    inner class GalleryAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

        private val items = EffectCatalog.flatList

        companion object {
            const val TYPE_HEADER = 0
            const val TYPE_DEMO = 1
        }

        override fun getItemViewType(position: Int): Int = when (items[position]) {
            is EffectCatalog.ListItem.Header -> TYPE_HEADER
            is EffectCatalog.ListItem.Demo -> TYPE_DEMO
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
            return when (viewType) {
                TYPE_HEADER -> {
                    val tv = TextView(parent.context).apply {
                        textSize = 14f
                        setTextColor(0xFF5C6BC0.toInt())
                        setPadding(0, 24.dp, 0, 8.dp)
                        typeface = android.graphics.Typeface.DEFAULT_BOLD
                    }
                    HeaderVH(tv)
                }
                else -> {
                    val view = LayoutInflater.from(parent.context)
                        .inflate(R.layout.item_effect_demo, parent, false)
                    DemoVH(view)
                }
            }
        }

        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
            when (val item = items[position]) {
                is EffectCatalog.ListItem.Header -> {
                    (holder as HeaderVH).textView.text = item.title
                }
                is EffectCatalog.ListItem.Demo -> {
                    val vh = holder as DemoVH
                    vh.tvName.text = item.item.name
                    vh.tvSubtitle.text = item.item.subtitle
                    vh.itemView.setOnClickListener {
                        val intent = Intent(this@MotionGalleryActivity, EffectDetailActivity::class.java)
                        intent.putExtra("index", item.index)
                        startActivity(intent)
                    }
                }
            }
        }

        override fun getItemCount() = items.size
    }

    class HeaderVH(val textView: TextView) : RecyclerView.ViewHolder(textView)

    class DemoVH(view: View) : RecyclerView.ViewHolder(view) {
        val tvName: TextView = view.findViewById(R.id.tvName)
        val tvSubtitle: TextView = view.findViewById(R.id.tvSubtitle)
    }

    private val Int.dp: Int get() = (this * resources.displayMetrics.density).toInt()
}
