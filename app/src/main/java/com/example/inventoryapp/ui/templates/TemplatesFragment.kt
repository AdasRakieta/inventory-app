package com.example.inventoryapp.ui.templates

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.EditText
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import com.example.inventoryapp.databinding.FragmentTemplatesBinding
import com.example.inventoryapp.databinding.DialogAddTemplateBinding
import com.example.inventoryapp.databinding.ItemTemplateBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.ProductTemplateRepository
import com.example.inventoryapp.utils.CategoryHelper

class TemplatesFragment : Fragment() {

    private var _binding: FragmentTemplatesBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentTemplatesBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        // ViewModel
        val db = AppDatabase.getDatabase(requireContext())
        val repo = ProductTemplateRepository(db.productTemplateDao())
        val factory = TemplatesViewModelFactory(repo)
        val vm: TemplatesViewModel by viewModels { factory }

        binding.templatesRecycler.layoutManager = LinearLayoutManager(requireContext())
        val adapter = TemplatesAdapter(onLongClick = { entity ->
            vm.deleteTemplate(entity)
            Toast.makeText(requireContext(), "Template deleted", Toast.LENGTH_SHORT).show()
        })
        binding.templatesRecycler.adapter = adapter

        // Observe data (StateFlow to LiveData via asLiveData not available; use lifecycleScope)
        viewLifecycleOwner.lifecycleScope.launch {
            vm.templates.collect { list ->
                adapter.submitList(list)
            }
        }

        binding.fabAddTemplate.setOnClickListener {
            showAddDialog(onAdd = { name, categoryId ->
                if (name.isNotBlank()) {
                    vm.addTemplate(name.trim(), categoryId)
                    Toast.makeText(requireContext(), "Template added", Toast.LENGTH_SHORT).show()
                }
            })
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}

private fun TemplatesFragment.showAddDialog(onAdd: (String, Long?) -> Unit) {
    val dialogBinding = DialogAddTemplateBinding.inflate(LayoutInflater.from(requireContext()))
    // Category dropdown
    val categories = CategoryHelper.getCategoryNames()
    val adapter = android.widget.ArrayAdapter(requireContext(), android.R.layout.simple_dropdown_item_1line, categories)
    dialogBinding.categoryInput.setAdapter(adapter)

    androidx.appcompat.app.AlertDialog.Builder(requireContext())
        .setTitle("Add Template")
        .setView(dialogBinding.root)
        .setPositiveButton("Add") { d, _ ->
            val name = dialogBinding.nameInput.text?.toString() ?: ""
            val catName = dialogBinding.categoryInput.text?.toString()?.trim().orEmpty()
            val categoryId = if (catName.isNotEmpty()) CategoryHelper.getCategoryIdByName(catName) else null
            onAdd(name, categoryId)
            d.dismiss()
        }
        .setNegativeButton("Cancel") { d, _ -> d.dismiss() }
        .show()
}

// Adapter using ListAdapter + DiffUtil
private class TemplatesAdapter(
    private val onLongClick: (com.example.inventoryapp.data.local.entities.ProductTemplateEntity) -> Unit
) : androidx.recyclerview.widget.ListAdapter<
        com.example.inventoryapp.data.local.entities.ProductTemplateEntity,
        TemplatesViewHolder>(
    object : androidx.recyclerview.widget.DiffUtil.ItemCallback<com.example.inventoryapp.data.local.entities.ProductTemplateEntity>() {
        override fun areItemsTheSame(
            oldItem: com.example.inventoryapp.data.local.entities.ProductTemplateEntity,
            newItem: com.example.inventoryapp.data.local.entities.ProductTemplateEntity
        ): Boolean = oldItem.id == newItem.id

        override fun areContentsTheSame(
            oldItem: com.example.inventoryapp.data.local.entities.ProductTemplateEntity,
            newItem: com.example.inventoryapp.data.local.entities.ProductTemplateEntity
        ): Boolean = oldItem == newItem
    }
) {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): TemplatesViewHolder {
        val binding = ItemTemplateBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return TemplatesViewHolder(binding)
    }

    override fun onBindViewHolder(holder: TemplatesViewHolder, position: Int) {
        val item = getItem(position)
        holder.binding.templateName.text = item.name
        val categoryName = item.categoryId?.let { CategoryHelper.getCategoryName(it) } ?: "No category"
        holder.binding.templateCategory.text = categoryName
        holder.binding.root.setOnLongClickListener {
            onLongClick(item)
            true
        }
    }
}

private class TemplatesViewHolder(val binding: ItemTemplateBinding) :
    androidx.recyclerview.widget.RecyclerView.ViewHolder(binding.root)

