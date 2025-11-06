package com.example.inventoryapp.ui.toolspackage com.example.inventoryapp.ui.tools



import android.view.LayoutInflaterimport android.view.LayoutInflater

import android.view.Viewimport android.view.ViewGroup

import android.view.ViewGroupimport androidx.core.content.ContextCompat

import android.widget.CheckBoximport androidx.recyclerview.widget.DiffUtil

import android.widget.TextViewimport androidx.recyclerview.widget.ListAdapter

import androidx.recyclerview.widget.DiffUtilimport androidx.recyclerview.widget.RecyclerView

import androidx.recyclerview.widget.ListAdapterimport com.example.inventoryapp.R

import androidx.recyclerview.widget.RecyclerViewimport com.example.inventoryapp.data.local.entities.ProductEntity

import com.example.inventoryapp.Rimport com.example.inventoryapp.data.local.entities.PackageEntity

import com.example.inventoryapp.data.local.entities.ProductTemplateEntity

/**import com.example.inventoryapp.databinding.ItemImportPreviewBinding

 * Unified item for import preview - can represent any entity type

 *//**

data class ImportPreviewItem( * Sealed class representing different types of preview items

    val id: String, */

    val type: ImportItemType,sealed class ImportPreviewItem {

    val name: String,    abstract val id: String

    val serialNumber: String? = null,    abstract val title: String

    val description: String? = null,    abstract val subtitle: String

    val relations: List<String> = emptyList(),    abstract val category: String

    var isSelected: Boolean = true,    abstract val isNew: Boolean

    val originalData: Any

)    data class ProductItem(

        val product: ProductEntity,

enum class ImportItemType(val displayName: String) {        override val isNew: Boolean

    CONTRACTOR("Contractor"),    ) : ImportPreviewItem() {

    PACKAGE("Package"),        override val id: String = product.serialNumber ?: product.id.toString()

    BOX("Box"),        override val title: String = product.name

    PRODUCT("Product")        override val subtitle: String = "SN: ${product.serialNumber ?: "N/A"}"

}        override val category: String = "Category ID: ${product.categoryId ?: "None"}"

    }

class ImportPreviewAdapter(

    private val onSelectionChanged: () -> Unit    data class PackageItem(

) : ListAdapter<ImportPreviewItem, ImportPreviewAdapter.ViewHolder>(DiffCallback()) {        val packageEntity: PackageEntity,

        override val isNew: Boolean

    class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {    ) : ImportPreviewItem() {

        val checkbox: CheckBox = view.findViewById(R.id.checkbox)        override val id: String = packageEntity.id.toString()

        val typeBadge: TextView = view.findViewById(R.id.typeBadge)        override val title: String = "Package #${packageEntity.id}"

        val title: TextView = view.findViewById(R.id.title)        override val subtitle: String = packageEntity.name

        val serialNumber: TextView = view.findViewById(R.id.serialNumber)        override val category: String = "Status: ${packageEntity.status}"

        val description: TextView = view.findViewById(R.id.description)    }

        val relations: TextView = view.findViewById(R.id.relations)

    }    data class TemplateItem(

        val template: ProductTemplateEntity,

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {        override val isNew: Boolean = true // Templates are always new in import

        val view = LayoutInflater.from(parent.context)    ) : ImportPreviewItem() {

            .inflate(R.layout.item_import_preview, parent, false)        override val id: String = template.id.toString()

        return ViewHolder(view)        override val title: String = template.name

    }        override val subtitle: String = template.description ?: "No description"

        override val category: String = "Category ID: ${template.categoryId ?: "None"}"

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {    }

        val item = getItem(position)}

        

        holder.checkbox.isChecked = item.isSelectedclass ImportPreviewAdapter : ListAdapter<ImportPreviewItem, ImportPreviewAdapter.ViewHolder>(DiffCallback()) {

        holder.checkbox.setOnCheckedChangeListener { _, isChecked ->

            item.isSelected = isChecked    // Track selected items

            onSelectionChanged()    private val selectedItems = mutableSetOf<String>()

        }    

            init {

        holder.typeBadge.text = item.type.displayName        // Select all items by default

        holder.typeBadge.setBackgroundColor(getColorForType(item.type, holder.itemView.context))        selectedItems.clear()

            }

        holder.title.text = item.name    

            override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {

        if (!item.serialNumber.isNullOrBlank()) {        val binding = ItemImportPreviewBinding.inflate(

            holder.serialNumber.visibility = View.VISIBLE            LayoutInflater.from(parent.context),

            holder.serialNumber.text = "SN: ${item.serialNumber}"            parent,

        } else {            false

            holder.serialNumber.visibility = View.GONE        )

        }        return ViewHolder(binding)

            }

        if (!item.description.isNullOrBlank()) {

            holder.description.visibility = View.VISIBLE    override fun onBindViewHolder(holder: ViewHolder, position: Int) {

            holder.description.text = item.description        val item = getItem(position)

        } else {        holder.bind(item, selectedItems.contains(item.id)) { isChecked ->

            holder.description.visibility = View.GONE            if (isChecked) {

        }                selectedItems.add(item.id)

                    } else {

        if (item.relations.isNotEmpty()) {                selectedItems.remove(item.id)

            holder.relations.visibility = View.VISIBLE            }

            holder.relations.text = item.relations.joinToString(" | ")        }

        } else {    }

            holder.relations.visibility = View.GONE    

        }    fun getSelectedItems(): Set<String> = selectedItems.toSet()

            

        holder.itemView.setOnClickListener {    fun selectAll() {

            holder.checkbox.toggle()        selectedItems.clear()

        }        selectedItems.addAll(currentList.map { it.id })

    }        notifyDataSetChanged()

    }

    private fun getColorForType(type: ImportItemType, context: android.content.Context): Int {    

        return when (type) {    fun deselectAll() {

            ImportItemType.CONTRACTOR -> context.getColor(android.R.color.holo_blue_dark)        selectedItems.clear()

            ImportItemType.PACKAGE -> context.getColor(android.R.color.holo_orange_dark)        notifyDataSetChanged()

            ImportItemType.BOX -> context.getColor(android.R.color.holo_purple)    }

            ImportItemType.PRODUCT -> context.getColor(android.R.color.holo_green_dark)

        }    class ViewHolder(

    }        private val binding: ItemImportPreviewBinding

    ) : RecyclerView.ViewHolder(binding.root) {

    fun getSelectedItems(): List<ImportPreviewItem> {

        return currentList.filter { it.isSelected }        fun bind(item: ImportPreviewItem, isSelected: Boolean, onSelectionChanged: (Boolean) -> Unit) {

    }            binding.itemTitle.text = item.title

            binding.itemSubtitle.text = item.subtitle

    fun selectAll() {            binding.itemCategory.text = item.category

        currentList.forEach { it.isSelected = true }            

        notifyDataSetChanged()            // Set checkbox state

        onSelectionChanged()            binding.itemCheckbox.isChecked = isSelected

    }            binding.itemCheckbox.setOnCheckedChangeListener { _, isChecked ->

                onSelectionChanged(isChecked)

    fun deselectAll() {            }

        currentList.forEach { it.isSelected = false }            

        notifyDataSetChanged()            // Allow clicking the whole card to toggle checkbox

        onSelectionChanged()            binding.root.setOnClickListener {

    }                binding.itemCheckbox.isChecked = !binding.itemCheckbox.isChecked

            }

    class DiffCallback : DiffUtil.ItemCallback<ImportPreviewItem>() {

        override fun areItemsTheSame(oldItem: ImportPreviewItem, newItem: ImportPreviewItem): Boolean {            // Set icon based on item type (using Android built-in icons)

            return oldItem.id == newItem.id            val iconRes = when (item) {

        }                is ImportPreviewItem.ProductItem -> android.R.drawable.ic_menu_info_details

                is ImportPreviewItem.PackageItem -> android.R.drawable.ic_menu_send

        override fun areContentsTheSame(oldItem: ImportPreviewItem, newItem: ImportPreviewItem): Boolean {                is ImportPreviewItem.TemplateItem -> android.R.drawable.ic_menu_agenda

            return oldItem == newItem            }

        }            binding.itemIcon.setImageResource(iconRes)

    }

}            // Set status chip

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
