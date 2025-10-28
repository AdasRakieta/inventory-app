package com.example.inventoryapp.ui.products

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import com.example.inventoryapp.R
import com.example.inventoryapp.databinding.FragmentAddProductBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.ProductRepository

class AddProductFragment : Fragment() {

    private var _binding: FragmentAddProductBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: ProductsViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val database = AppDatabase.getDatabase(requireContext())
        val repository = ProductRepository(database.productDao())
        val factory = ProductsViewModelFactory(repository)
        val vm: ProductsViewModel by viewModels { factory }
        viewModel = vm
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentAddProductBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupCategoryDropdown()
        setupClickListeners()
    }

    private fun setupCategoryDropdown() {
        val categories = arrayOf(
            "Scanners",
            "Printers",
            "Docking Stations",
            "Laptops",
            "Tablets",
            "Accessories",
            "Other"
        )
        
        val adapter = ArrayAdapter(
            requireContext(),
            android.R.layout.simple_dropdown_item_1line,
            categories
        )
        
        binding.categoryInput.setAdapter(adapter)
    }

    private fun setupClickListeners() {
        binding.scanSerialButton.setOnClickListener {
            // TODO: Navigate to scanner with result callback
            Toast.makeText(requireContext(), "Scanner integration coming soon!", Toast.LENGTH_SHORT).show()
        }
        
        binding.saveButton.setOnClickListener {
            saveProduct()
        }
        
        binding.cancelButton.setOnClickListener {
            findNavController().navigateUp()
        }
    }

    private fun saveProduct() {
        val name = binding.productNameInput.text.toString().trim()
        val serialNumber = binding.serialNumberInput.text.toString().trim().takeIf { it.isNotEmpty() }
        val description = binding.descriptionInput.text.toString().trim().takeIf { it.isNotEmpty() }
        
        when {
            name.isEmpty() -> {
                binding.productNameLayout.error = "Product name is required"
                return
            }
            else -> {
                binding.productNameLayout.error = null
                
                viewModel.addProduct(
                    name = name,
                    categoryId = null, // TODO: Map category to ID
                    serialNumber = serialNumber,
                    description = null // TODO: Add description field to ProductEntity
                )
                
                Toast.makeText(
                    requireContext(),
                    "Product added successfully!",
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
