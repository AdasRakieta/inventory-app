package com.example.inventoryapp.ui.boxes

import android.app.AlertDialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.core.widget.doAfterTextChanged
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.inventoryapp.InventoryApplication
import com.example.inventoryapp.databinding.FragmentEditBoxBinding
import com.example.inventoryapp.utils.CategoryHelper
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

/**
 * Fragment for editing box details.
 */
class EditBoxFragment : Fragment() {

    private var _binding: FragmentEditBoxBinding? = null
    private val binding get() = _binding!!

    private val args: EditBoxFragmentArgs by navArgs()

    private val viewModel: EditBoxViewModel by viewModels {
        EditBoxViewModelFactory(
            (requireActivity().application as InventoryApplication).boxRepository,
            (requireActivity().application as InventoryApplication).productRepository,
            args.boxId
        )
    }

    private lateinit var productsAdapter: SelectableProductsAdapter

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentEditBoxBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupRecyclerView()
        setupInputListeners()
        setupClickListeners()
        observeViewModel()
    }

    private fun setupRecyclerView() {
        productsAdapter = SelectableProductsAdapter(
            onProductToggle = { productId ->
                viewModel.toggleProductSelection(productId)
            },
            selectedProductIds = emptySet()
        )

        binding.productsRecyclerView.apply {
            layoutManager = LinearLayoutManager(requireContext())
            adapter = productsAdapter
        }
    }

    private fun setupInputListeners() {
        binding.boxNameInput.doAfterTextChanged { text ->
            viewModel.setBoxName(text?.toString() ?: "")
        }

        binding.boxDescriptionInput.doAfterTextChanged { text ->
            viewModel.setBoxDescription(text?.toString() ?: "")
        }

        binding.warehouseLocationInput.doAfterTextChanged { text ->
            viewModel.setWarehouseLocation(text?.toString() ?: "")
        }

        // Search input listener
        binding.searchInput.doAfterTextChanged { text ->
            viewModel.setSearchQuery(text?.toString() ?: "")
        }
    }

    private fun setupClickListeners() {
        binding.saveFab.setOnClickListener {
            viewModel.saveBox()
        }

        // Filter button - show category filter dialog
        binding.filterButton.setOnClickListener {
            showCategoryFilterDialog()
        }

        // Select All Products button
        binding.selectAllProductsButton.setOnClickListener {
            viewLifecycleOwner.lifecycleScope.launch {
                val selectedCount = viewModel.selectedProductIds.value.size
                val filteredCount = viewModel.filteredProducts.value.size
                
                if (selectedCount >= filteredCount && filteredCount > 0) {
                    viewModel.deselectAll()
                } else {
                    viewModel.selectAll()
                }
            }
        }
    }

    private fun showCategoryFilterDialog() {
        val categories = CategoryHelper.getAllCategories()
        val categoryNames = mutableListOf("All Categories")
        categoryNames.addAll(categories.map { it.name })

        val currentCategoryId = viewModel.selectedCategoryId.value
        val selectedIndex = if (currentCategoryId == null) {
            0
        } else {
            categories.indexOfFirst { it.id == currentCategoryId } + 1
        }

        AlertDialog.Builder(requireContext())
            .setTitle("Filter by Category")
            .setSingleChoiceItems(categoryNames.toTypedArray(), selectedIndex) { dialog, which ->
                val categoryId = if (which == 0) null else categories[which - 1].id
                viewModel.setCategoryFilter(categoryId)
                dialog.dismiss()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun observeViewModel() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.box.collect { box ->
                box?.let {
                    // Set initial values
                    if (binding.boxNameInput.text.isNullOrEmpty()) {
                        binding.boxNameInput.setText(it.name)
                    }
                    if (binding.boxDescriptionInput.text.isNullOrEmpty()) {
                        binding.boxDescriptionInput.setText(it.description ?: "")
                    }
                    if (binding.warehouseLocationInput.text.isNullOrEmpty()) {
                        binding.warehouseLocationInput.setText(it.warehouseLocation ?: "")
                    }
                }
            }
        }

        // Observe filtered products
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.filteredProducts.collect { products ->
                productsAdapter.submitList(products)
                updateEmptyState(products.isEmpty())
            }
        }

        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.selectedProductIds.collect { selectedIds ->
                productsAdapter.updateSelectedIds(selectedIds)
                updateSelectedCountText(selectedIds.size)
                updateSelectAllButtonText(selectedIds.size, viewModel.filteredProducts.value.size)
            }
        }

        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.errorMessage.collect { error ->
                error?.let {
                    Toast.makeText(requireContext(), it, Toast.LENGTH_SHORT).show()
                    viewModel.clearError()
                }
            }
        }

        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.boxSaved.collect { saved ->
                if (saved) {
                    Toast.makeText(
                        requireContext(),
                        "Box updated successfully",
                        Toast.LENGTH_SHORT
                    ).show()
                    findNavController().navigateUp()
                }
            }
        }
    }

    private fun updateEmptyState(isEmpty: Boolean) {
        if (isEmpty) {
            binding.productsRecyclerView.visibility = View.GONE
            binding.noProductsText.visibility = View.VISIBLE
        } else {
            binding.productsRecyclerView.visibility = View.VISIBLE
            binding.noProductsText.visibility = View.GONE
        }
    }

    private fun updateSelectedCountText(count: Int) {
        binding.selectedCountText.text = "$count products selected"
    }

    private fun updateSelectAllButtonText(selectedCount: Int, totalCount: Int) {
        val allSelected = selectedCount == totalCount && selectedCount > 0
        binding.selectAllProductsButton.text = if (allSelected) {
            "Deselect All"
        } else {
            "Select All"
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
