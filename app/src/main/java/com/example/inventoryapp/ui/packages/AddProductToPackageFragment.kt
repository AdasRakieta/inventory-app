package com.example.inventoryapp.ui.packages

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.example.inventoryapp.databinding.FragmentAddProductToPackageBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.PackageRepository
import com.example.inventoryapp.data.repository.ProductRepository
import com.example.inventoryapp.utils.CategoryHelper
import kotlinx.coroutines.launch

class AddProductToPackageFragment : Fragment() {

    private var _binding: FragmentAddProductToPackageBinding? = null
    private val binding get() = _binding!!
    
    private val args: AddProductToPackageFragmentArgs by navArgs()
    private lateinit var viewModel: PackageDetailsViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val database = AppDatabase.getDatabase(requireContext())
        val productRepository = ProductRepository(database.productDao())
        val packageRepository = PackageRepository(database.packageDao(), database.productDao())
        val factory = PackageDetailsViewModelFactory(args.packageId, packageRepository, productRepository)
        val vm: PackageDetailsViewModel by viewModels { factory }
        viewModel = vm
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentAddProductToPackageBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupCategoryDropdown()
        setupClickListeners()
    }

    private fun setupCategoryDropdown() {
        val categories = CategoryHelper.getCategoryNames()
        
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
        val serialNumber = binding.serialNumberInput.text.toString().trim()
        val categoryName = binding.categoryInput.text.toString().trim()
        
        when {
            serialNumber.isEmpty() -> {
                binding.serialNumberLayout.error = "Serial number is required"
                return
            }
            else -> {
                binding.serialNumberLayout.error = null
                binding.productNameLayout.error = null
                
                // Map category name to ID
                val categoryId = if (categoryName.isNotEmpty()) {
                    CategoryHelper.getCategoryIdByName(categoryName)
                } else {
                    null
                }
                
                viewLifecycleOwner.lifecycleScope.launch {
                    try {
                        viewModel.addNewProductToPackage(serialNumber, categoryId, name)
                        
                        Toast.makeText(
                            requireContext(),
                            "Product added to package successfully!",
                            Toast.LENGTH_SHORT
                        ).show()
                        
                        findNavController().navigateUp()
                    } catch (e: Exception) {
                        Toast.makeText(
                            requireContext(),
                            "Error: ${e.message}",
                            Toast.LENGTH_SHORT
                        ).show()
                    }
                }
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
