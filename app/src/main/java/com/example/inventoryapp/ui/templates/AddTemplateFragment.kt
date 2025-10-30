package com.example.inventoryapp.ui.templates

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import com.example.inventoryapp.databinding.FragmentAddTemplateBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.TemplateRepository
import com.example.inventoryapp.utils.CategoryHelper

class AddTemplateFragment : Fragment() {

    private var _binding: FragmentAddTemplateBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: TemplatesViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val database = AppDatabase.getDatabase(requireContext())
        val templateRepository = TemplateRepository(database.templateDao())
        val factory = TemplatesViewModelFactory(templateRepository)
        val vm: TemplatesViewModel by viewModels { factory }
        viewModel = vm
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentAddTemplateBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupCategoryDropdown()
        setupClickListeners()
    }

    private fun setupCategoryDropdown() {
        val categories = listOf("None") + CategoryHelper.getCategoryNames()
        
        val adapter = ArrayAdapter(
            requireContext(),
            android.R.layout.simple_dropdown_item_1line,
            categories
        )
        
        binding.categoryInput.setAdapter(adapter)
        // Set default to "None"
        binding.categoryInput.setText("None", false)
    }

    private fun setupClickListeners() {
        binding.saveButton.setOnClickListener {
            saveTemplate()
        }
        
        binding.cancelButton.setOnClickListener {
            findNavController().navigateUp()
        }
    }

    private fun saveTemplate() {
        val name = binding.templateNameInput.text.toString().trim()
        val description = binding.descriptionInput.text.toString().trim().takeIf { it.isNotEmpty() }
        val categoryName = binding.categoryInput.text.toString().trim()
        
        when {
            name.isEmpty() -> {
                binding.templateNameLayout.error = "Template name is required"
                return
            }
            else -> {
                binding.templateNameLayout.error = null
                
                // Map category name to ID (null if "None")
                val categoryId = if (categoryName.isNotEmpty() && categoryName != "None") {
                    CategoryHelper.getCategoryIdByName(categoryName)
                } else {
                    null
                }
                
                viewModel.addTemplate(name, categoryId, description)
                
                Toast.makeText(
                    requireContext(),
                    "Template added successfully!",
                    Toast.LENGTH_SHORT
                ).show()
                
                findNavController().navigateUp()
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
