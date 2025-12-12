package com.example.inventoryapp.ui.inventorycount

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.inventoryapp.databinding.ItemInventoryCountProductBinding
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.utils.CategoryHelper

class InventoryCountProductsAdapter : ListAdapter<ProductEntity, InventoryCountProductsAdapter.ViewHolder>(DiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemInventoryCountProductBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    class ViewHolder(private val binding: ItemInventoryCountProductBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(product: ProductEntity) {
            val category = CategoryHelper.getCategoryById(product.categoryId)

            binding.productIconText.text = category?.icon ?: "📦"
            binding.productNameText.text = product.name
            binding.productSerialText.text = product.serialNumber ?: "No SN"
            binding.productCategoryText.text = category?.name ?: "Unknown"
        }
    }

    private class DiffCallback : DiffUtil.ItemCallback<ProductEntity>() {
        override fun areItemsTheSame(oldItem: ProductEntity, newItem: ProductEntity): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: ProductEntity, newItem: ProductEntity): Boolean {
            return oldItem == newItem
        }
    }
}