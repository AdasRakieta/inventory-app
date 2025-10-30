package com.example.inventoryapp.ui.products

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.inventoryapp.databinding.ItemProductBinding
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.local.entities.PackageEntity
import com.example.inventoryapp.utils.CategoryHelper

data class ProductWithPackage(
    val productEntity: ProductEntity,
    val packageEntity: PackageEntity? = null
)

class ProductsAdapter(
    private val onProductClick: (ProductEntity) -> Unit
) : ListAdapter<ProductWithPackage, ProductsAdapter.ProductViewHolder>(ProductDiffCallback()) {

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

        fun bind(productWithPackage: ProductWithPackage) {
            val product = productWithPackage.productEntity
            val pkg = productWithPackage.packageEntity
            
            binding.productName.text = product.name
            binding.productCategory.text = CategoryHelper.getCategoryName(product.categoryId)
            binding.categoryIcon.text = CategoryHelper.getCategoryIcon(product.categoryId)
            
            // Display package information
            if (pkg != null) {
                binding.packageInfo.text = pkg.name
                binding.packageInfo.visibility = View.VISIBLE
            } else {
                binding.packageInfo.text = "Not in package"
                binding.packageInfo.visibility = View.VISIBLE
            }
            
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

    private class ProductDiffCallback : DiffUtil.ItemCallback<ProductWithPackage>() {
        override fun areItemsTheSame(oldItem: ProductWithPackage, newItem: ProductWithPackage): Boolean {
            return oldItem.productEntity.id == newItem.productEntity.id
        }

        override fun areContentsTheSame(oldItem: ProductWithPackage, newItem: ProductWithPackage): Boolean {
            return oldItem == newItem
        }
    }
}
