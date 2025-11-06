package com.example.inventoryapp.ui.tools

import android.graphics.Color
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.CheckBox
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.inventoryapp.R

class ImportPreviewAdapter : ListAdapter<ImportPreviewAdapter.ImportPreviewItem, ImportPreviewAdapter.ViewHolder>(DiffCallback()) {

    enum class ImportItemType {
        CONTRACTOR, PACKAGE, BOX, PRODUCT
    }

    data class ImportPreviewItem(
        val id: String,
        val type: ImportItemType,
        val name: String,
        val serialNumber: String? = null,
        val description: String? = null,
        val relations: List<String> = emptyList(),
        var isSelected: Boolean = true,
        val originalData: Any
    )

    class ViewHolder(itemView: android.view.View) : RecyclerView.ViewHolder(itemView) {
        val itemCheckbox: CheckBox = itemView.findViewById(R.id.itemCheckbox)
        val typeBadge: TextView = itemView.findViewById(R.id.typeBadge)
        val itemTitle: TextView = itemView.findViewById(R.id.itemTitle)
        val itemSerialNumber: TextView = itemView.findViewById(R.id.itemSerialNumber)
        val itemDescription: TextView = itemView.findViewById(R.id.itemDescription)
        val itemRelations: TextView = itemView.findViewById(R.id.itemRelations)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_import_preview, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = getItem(position)
        
        holder.itemCheckbox.isChecked = item.isSelected
        holder.itemCheckbox.setOnCheckedChangeListener { _, isChecked ->
            item.isSelected = isChecked
        }
        
        holder.typeBadge.text = item.type.name
        when (item.type) {
            ImportItemType.CONTRACTOR -> holder.typeBadge.setBackgroundColor(Color.parseColor("#2196F3"))
            ImportItemType.PACKAGE -> holder.typeBadge.setBackgroundColor(Color.parseColor("#FF9800"))
            ImportItemType.BOX -> holder.typeBadge.setBackgroundColor(Color.parseColor("#9C27B0"))
            ImportItemType.PRODUCT -> holder.typeBadge.setBackgroundColor(Color.parseColor("#4CAF50"))
        }
        
        holder.itemTitle.text = item.name
        
        if (item.serialNumber != null) {
            holder.itemSerialNumber.text = "S/N: ${item.serialNumber}"
            holder.itemSerialNumber.visibility = android.view.View.VISIBLE
        } else {
            holder.itemSerialNumber.visibility = android.view.View.GONE
        }
        
        if (item.description != null) {
            holder.itemDescription.text = item.description
            holder.itemDescription.visibility = android.view.View.VISIBLE
        } else {
            holder.itemDescription.visibility = android.view.View.GONE
        }
        
        if (item.relations.isNotEmpty()) {
            holder.itemRelations.text = item.relations.joinToString(" | ")
            holder.itemRelations.visibility = android.view.View.VISIBLE
        } else {
            holder.itemRelations.visibility = android.view.View.GONE
        }
    }

    fun selectAll() {
        currentList.forEach { it.isSelected = true }
        notifyDataSetChanged()
    }

    fun deselectAll() {
        currentList.forEach { it.isSelected = false }
        notifyDataSetChanged()
    }

    fun getSelectedItems(): List<ImportPreviewItem> {
        return currentList.filter { it.isSelected }
    }

    private class DiffCallback : DiffUtil.ItemCallback<ImportPreviewItem>() {
        override fun areItemsTheSame(oldItem: ImportPreviewItem, newItem: ImportPreviewItem): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: ImportPreviewItem, newItem: ImportPreviewItem): Boolean {
            return oldItem == newItem
        }
    }
}