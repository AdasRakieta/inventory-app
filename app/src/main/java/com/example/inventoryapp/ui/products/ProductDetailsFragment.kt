package com.example.inventoryapp.ui.products

import android.app.AlertDialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.EditText
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.example.inventoryapp.R
import com.example.inventoryapp.databinding.FragmentProductDetailsBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.ProductRepository
import com.example.inventoryapp.utils.CategoryHelper
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class ProductDetailsFragment : Fragment() {

    private var _binding: FragmentProductDetailsBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: ProductDetailsViewModel
    private val args: ProductDetailsFragmentArgs by navArgs()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val database = AppDatabase.getDatabase(requireContext())
        val repository = ProductRepository(database.productDao())
        val factory = ProductDetailsViewModelFactory(repository, args.productId)
        val vm: ProductDetailsViewModel by viewModels { factory }
        viewModel = vm
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentProductDetailsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        observeProduct()
        setupClickListeners()
    }

    private fun observeProduct() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.product.collect { product ->
                product?.let {
                    // Update product name, icon and category
                    binding.productIconText.text = CategoryHelper.getCategoryIcon(it.categoryId)
                    binding.productNameText.text = it.name
                    binding.productCategoryText.text = getCategoryName(it.categoryId)
                    
                    // Update serial number section
                    if (it.serialNumber != null) {
                        binding.serialNumberAssignedLayout.visibility = View.VISIBLE
                        binding.serialNumberNotAssignedLayout.visibility = View.GONE
                        binding.serialNumberText.text = it.serialNumber
                        binding.editSerialButton.text = "Edit"
                    } else {
                        binding.serialNumberAssignedLayout.visibility = View.GONE
                        binding.serialNumberNotAssignedLayout.visibility = View.VISIBLE
                        binding.editSerialButton.text = "Add Manual"
                    }
                    
                    // Update timestamps
                    val dateFormat = SimpleDateFormat("MMM d, yyyy HH:mm", Locale.getDefault())
                    binding.createdAtText.text = dateFormat.format(Date(it.createdAt))
                    binding.updatedAtText.text = dateFormat.format(Date(it.updatedAt))
                }
            }
        }
    }

    private fun setupClickListeners() {
        binding.scanSerialButton.setOnClickListener {
            // TODO: Navigate to scanner with product ID
            Toast.makeText(requireContext(), "Scanner integration coming soon", Toast.LENGTH_SHORT).show()
        }
        
        binding.editSerialButton.setOnClickListener {
            showEditSerialNumberDialog()
        }
        
        binding.editProductButton.setOnClickListener {
            // TODO: Navigate to edit product screen
            Toast.makeText(requireContext(), "Edit product coming soon", Toast.LENGTH_SHORT).show()
        }
        
        binding.deleteProductButton.setOnClickListener {
            showDeleteConfirmationDialog()
        }
    }

    private fun showEditSerialNumberDialog() {
        val currentProduct = viewModel.product.value ?: return
        
        val editText = EditText(requireContext()).apply {
            setText(currentProduct.serialNumber ?: "")
            hint = "Enter serial number"
            setSingleLine(true)
        }
        
        AlertDialog.Builder(requireContext())
            .setTitle("Serial Number")
            .setMessage("Enter or edit the serial number for this product")
            .setView(editText)
            .setPositiveButton("Save") { _, _ ->
                val newSerialNumber = editText.text.toString().trim()
                if (newSerialNumber.isNotEmpty()) {
                    viewModel.updateSerialNumber(newSerialNumber)
                    Toast.makeText(requireContext(), "Serial number updated", Toast.LENGTH_SHORT).show()
                } else {
                    viewModel.updateSerialNumber(null)
                    Toast.makeText(requireContext(), "Serial number removed", Toast.LENGTH_SHORT).show()
                }
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun showDeleteConfirmationDialog() {
        val currentProduct = viewModel.product.value ?: return
        
        AlertDialog.Builder(requireContext())
            .setTitle("Delete Product")
            .setMessage("Are you sure you want to delete \"${currentProduct.name}\"? This action cannot be undone.")
            .setPositiveButton("Delete") { _, _ ->
                viewModel.deleteProduct()
                Toast.makeText(requireContext(), "Product deleted", Toast.LENGTH_SHORT).show()
                findNavController().navigateUp()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun getCategoryName(categoryId: Long?): String {
        return CategoryHelper.getCategoryName(categoryId)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
