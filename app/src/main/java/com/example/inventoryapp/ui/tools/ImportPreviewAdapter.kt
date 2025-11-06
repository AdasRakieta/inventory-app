package com.example.inventoryapp.ui.tools

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.inventoryapp.R
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.local.entities.PackageEntity
import com.example.inventoryapp.data.local.entities.ProductTemplateEntity
import com.example.inventoryapp.databinding.ItemImportPreviewBinding

/**
 * Sealed class representing different types of preview items
 */
sealed class ImportPreviewItem {
    abstract val id: String
    abstract val title: String
    abstract val subtitle: String
    abstract val category: String
    abstract val isNew: Boolean

    data class ProductItem(
        val product: ProductEntity,
        override val isNew: Boolean
    ) : ImportPreviewItem() {
        override val id: String = product.serialNumber ?: product.id.toString()
        override val title: String = product.name
        override val subtitle: String = "SN: ${product.serialNumber ?: "N/A"}"
        override val category: String = "Category ID: ${product.categoryId ?: "None"}"
    }

    data class PackageItem(
        val packageEntity: PackageEntity,
        override val isNew: Boolean
    ) : ImportPreviewItem() {
        override val id: String = packageEntity.id.toString()
        override val title: String = "Package #${packageEntity.id}"
        override val subtitle: String = packageEntity.name
        override val category: String = "Status: ${packageEntity.status}"
    }

    data class TemplateItem(
        val template: ProductTemplateEntity,
        override val isNew: Boolean = true // Templates are always new in import
    ) : ImportPreviewItem() {
        override val id: String = template.id.toString()
        override val title: String = template.name
        override val subtitle: String = template.description ?: "No description"
        override val category: String = "Category ID: ${template.categoryId ?: "None"}"
    }
}

class ImportPreviewAdapter : ListAdapter<ImportPreviewItem, ImportPreviewAdapter.ViewHolder>(DiffCallback()) {

    // Track selected items
    private val selectedItems = mutableSetOf<String>()
    
    init {
        // Select all items by default
        selectedItems.clear()
    }
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemImportPreviewBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = getItem(position)
        holder.bind(item, selectedItems.contains(item.id)) { isChecked ->
            if (isChecked) {
                selectedItems.add(item.id)
            } else {
                selectedItems.remove(item.id)
            }
        }
    }
    
    fun getSelectedItems(): Set<String> = selectedItems.toSet()
    
    fun selectAll() {
        selectedItems.clear()
        selectedItems.addAll(currentList.map { it.id })
        notifyDataSetChanged()
    }
    
    fun deselectAll() {
        selectedItems.clear()
        notifyDataSetChanged()
    }

    class ViewHolder(
        private val binding: ItemImportPreviewBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(item: ImportPreviewItem, isSelected: Boolean, onSelectionChanged: (Boolean) -> Unit) {
            binding.itemTitle.text = item.title
            binding.itemSubtitle.text = item.subtitle
            binding.itemCategory.text = item.category
            
            // Set checkbox state
            binding.itemCheckbox.isChecked = isSelected
            binding.itemCheckbox.setOnCheckedChangeListener { _, isChecked ->
                onSelectionChanged(isChecked)
            }
            
            // Allow clicking the whole card to toggle checkbox
            binding.root.setOnClickListener {
                binding.itemCheckbox.isChecked = !binding.itemCheckbox.isChecked
            }

            // Set icon based on item type (using Android built-in icons)
            val iconRes = when (item) {
                is ImportPreviewItem.ProductItem -> android.R.drawable.ic_menu_info_details
                is ImportPreviewItem.PackageItem -> android.R.drawable.ic_menu_send
                is ImportPreviewItem.TemplateItem -> android.R.drawable.ic_menu_agenda
            }
            binding.itemIcon.setImageResource(iconRes)

            // Set status chip
            if (item.isNew) {
                binding.statusChip.text = binding.root.context.getString(R.string.status_new)
                binding.statusChip.setChipBackgroundColorResource(R.color.status_new)
            } else {
                binding.statusChip.text = binding.root.context.getString(R.string.status_update)
                binding.statusChip.setChipBackgroundColorResource(R.color.status_update)
            }
        }
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
