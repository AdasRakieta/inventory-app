package com.example.inventoryapp.ui.templates

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
<<<<<<< HEAD
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
=======
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.inventoryapp.R
import com.example.inventoryapp.databinding.FragmentTemplatesBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.ProductTemplateRepository
import kotlinx.coroutines.launch
>>>>>>> 38e7ca868b963369e9e301f0dc67297dce0cab91

class TemplatesFragment : Fragment() {

    private var _binding: FragmentTemplatesBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: TemplatesViewModel
    private lateinit var adapter: TemplatesAdapter

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
<<<<<<< HEAD

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
=======
        
        setupViewModel()
        setupRecyclerView()
        setupFab()
        observeTemplates()
    }

    private fun setupViewModel() {
        val database = AppDatabase.getDatabase(requireContext())
        val repository = ProductTemplateRepository(database.productTemplateDao())
        viewModel = TemplatesViewModel(repository)
    }

    private fun setupRecyclerView() {
        adapter = TemplatesAdapter(
            onTemplateClick = { template ->
                showEditTemplateDialog(template)
            },
            onTemplateLongClick = { template ->
                showDeleteConfirmation(template)
            }
        )
        
        binding.templatesRecycler.layoutManager = LinearLayoutManager(requireContext())
        binding.templatesRecycler.adapter = adapter
    }

    private fun setupFab() {
        binding.fabAddTemplate.setOnClickListener {
            showAddTemplateDialog()
        }
    }

    private fun observeTemplates() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.templates.collect { templates ->
                adapter.submitList(templates)
            }
        }
    }

    private fun showAddTemplateDialog() {
        val dialog = TemplateDialogFragment.newInstance()
        dialog.setOnSaveListener { name, categoryId, description ->
            viewModel.addTemplate(name, categoryId, description)
        }
        dialog.show(childFragmentManager, "AddTemplateDialog")
    }

    private fun showEditTemplateDialog(template: com.example.inventoryapp.data.local.entities.ProductTemplateEntity) {
        val dialog = TemplateDialogFragment.newInstance(template)
        dialog.setOnSaveListener { name, categoryId, description ->
            viewModel.updateTemplate(template.id, name, categoryId, description)
        }
        dialog.show(childFragmentManager, "EditTemplateDialog")
    }

    private fun showDeleteConfirmation(template: com.example.inventoryapp.data.local.entities.ProductTemplateEntity) {
        AlertDialog.Builder(requireContext())
            .setTitle(R.string.delete)
            .setMessage(R.string.template_delete_confirm)
            .setPositiveButton(R.string.delete) { _, _ ->
                viewModel.deleteTemplate(template)
            }
            .setNegativeButton(R.string.cancel, null)
            .show()
>>>>>>> 38e7ca868b963369e9e301f0dc67297dce0cab91
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

