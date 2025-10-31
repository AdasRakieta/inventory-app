package com.example.inventoryapp.ui.settings

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.inventoryapp.R
import com.example.inventoryapp.data.local.entities.PrinterEntity
import com.example.inventoryapp.databinding.ItemPrinterBinding

/**
 * Adapter for displaying list of printers
 */
class PrintersAdapter(
    private val onPrinterClick: (PrinterEntity) -> Unit,
    private val onSetDefaultClick: (PrinterEntity) -> Unit,
    private val onDeleteClick: (PrinterEntity) -> Unit
) : ListAdapter<PrinterEntity, PrintersAdapter.PrinterViewHolder>(PrinterDiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PrinterViewHolder {
        val binding = ItemPrinterBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return PrinterViewHolder(binding)
    }

    override fun onBindViewHolder(holder: PrinterViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class PrinterViewHolder(
        private val binding: ItemPrinterBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(printer: PrinterEntity) {
            binding.printerNameText.text = printer.name
            binding.printerMacText.text = printer.macAddress
            binding.printerDimensionsText.text = "${printer.labelWidthMm}mm × ${printer.labelHeightMm}mm"
            
            // Show default badge
            if (printer.isDefault) {
                binding.defaultBadge.visibility = View.VISIBLE
                binding.setDefaultButton.visibility = View.GONE
            } else {
                binding.defaultBadge.visibility = View.GONE
                binding.setDefaultButton.visibility = View.VISIBLE
            }
            
            // Click handlers
            binding.root.setOnClickListener {
                onPrinterClick(printer)
            }
            
            binding.setDefaultButton.setOnClickListener {
                onSetDefaultClick(printer)
            }
            
            binding.deleteButton.setOnClickListener {
                onDeleteClick(printer)
            }
        }
    }

    private class PrinterDiffCallback : DiffUtil.ItemCallback<PrinterEntity>() {
        override fun areItemsTheSame(oldItem: PrinterEntity, newItem: PrinterEntity): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: PrinterEntity, newItem: PrinterEntity): Boolean {
            return oldItem == newItem
        }
    }
}
