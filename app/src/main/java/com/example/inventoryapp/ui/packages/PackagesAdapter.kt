package com.example.inventoryapp.ui.packages

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.inventoryapp.databinding.ItemPackageBinding
import com.example.inventoryapp.data.local.entities.ContractorEntity
import com.example.inventoryapp.data.local.entities.PackageEntity
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

data class PackageWithCount(
    val packageEntity: PackageEntity,
    val productCount: Int,
    val contractor: ContractorEntity? = null
)

class PackagesAdapter(
    private val onPackageClick: (PackageEntity) -> Unit
) : ListAdapter<PackageWithCount, PackagesAdapter.PackageViewHolder>(PackageDiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PackageViewHolder {
        val binding = ItemPackageBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return PackageViewHolder(binding, onPackageClick)
    }

    override fun onBindViewHolder(holder: PackageViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    class PackageViewHolder(
        private val binding: ItemPackageBinding,
        private val onPackageClick: (PackageEntity) -> Unit
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(packageWithCount: PackageWithCount) {
            val pkg = packageWithCount.packageEntity
            
            binding.packageName.text = pkg.name
            binding.packageStatus.text = pkg.status
            
            // Format date
            val dateFormat = SimpleDateFormat("MMM d, yyyy", Locale.getDefault())
            binding.packageDate.text = "Created on ${dateFormat.format(Date(pkg.createdAt))}"
            
            // Product count
            val count = packageWithCount.productCount
            binding.productCount.text = if (count == 1) "1 product" else "$count products"
            
            // Contractor
            binding.packageContractor.text = packageWithCount.contractor?.name ?: "No contractor"

            binding.root.setOnClickListener {
                onPackageClick(pkg)
            }
        }
    }

    private class PackageDiffCallback : DiffUtil.ItemCallback<PackageWithCount>() {
        override fun areItemsTheSame(oldItem: PackageWithCount, newItem: PackageWithCount): Boolean {
            return oldItem.packageEntity.id == newItem.packageEntity.id
        }

        override fun areContentsTheSame(oldItem: PackageWithCount, newItem: PackageWithCount): Boolean {
            return oldItem == newItem
        }
    }
}
