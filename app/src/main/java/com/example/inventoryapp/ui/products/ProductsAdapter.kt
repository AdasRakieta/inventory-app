package com.example.inventoryapp.ui.products

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.inventoryapp.databinding.ItemProductBinding
import com.example.inventoryapp.data.local.entities.ProductEntity

class ProductsAdapter(
    private val onProductClick: (ProductEntity) -> Unit
) : ListAdapter<ProductEntity, ProductsAdapter.ProductViewHolder>(ProductDiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ProductViewHolder {
        val binding = ItemProductBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return ProductViewHolder(binding, onProductClick)
    }

    override fun onBindViewHolder(holder: ProductViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    class ProductViewHolder(
        private val binding: ItemProductBinding,
        private val onProductClick: (ProductEntity) -> Unit
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(product: ProductEntity) {
            binding.productName.text = product.name
            binding.productCategory.text = "Category ID: ${product.categoryId ?: "None"}"
            
            if (product.serialNumber != null) {
                binding.serialNumberContainer.visibility = View.VISIBLE
                binding.noSerialNumber.visibility = View.GONE
                binding.productSerialNumber.text = product.serialNumber
            } else {
                binding.serialNumberContainer.visibility = View.GONE
                binding.noSerialNumber.visibility = View.VISIBLE
            }

            binding.root.setOnClickListener {
                onProductClick(product)
            }
        }
    }

    private class ProductDiffCallback : DiffUtil.ItemCallback<ProductEntity>() {
        override fun areItemsTheSame(oldItem: ProductEntity, newItem: ProductEntity): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: ProductEntity, newItem: ProductEntity): Boolean {
            return oldItem == newItem
        }
    }
}
