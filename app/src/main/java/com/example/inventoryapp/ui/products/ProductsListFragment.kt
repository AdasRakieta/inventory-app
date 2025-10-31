package com.example.inventoryapp.ui.products

import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.inventoryapp.R
import com.example.inventoryapp.databinding.FragmentProductsListBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.ProductRepository
import com.example.inventoryapp.data.repository.PackageRepository
import com.example.inventoryapp.utils.CategoryHelper
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class ProductsListFragment : Fragment() {

    private var _binding: FragmentProductsListBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: ProductsViewModel
    private lateinit var adapter: ProductsAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val database = AppDatabase.getDatabase(requireContext())
        val productRepository = ProductRepository(database.productDao())
        val packageRepository = PackageRepository(database.packageDao(), database.productDao())
        val factory = ProductsViewModelFactory(productRepository, packageRepository)
        val vm: ProductsViewModel by viewModels { factory }
        viewModel = vm
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentProductsListBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupRecyclerView()
        setupClickListeners()
        setupSearchBar()
        setupFilterAndSort()
        observeProducts()
    }

    private fun setupRecyclerView() {
        adapter = ProductsAdapter(
            onProductClick = { product ->
                val action = ProductsListFragmentDirections
                    .actionProductsToProductDetails(product.id)
                findNavController().navigate(action)
            },
            onProductLongClick = { product ->
                adapter.enterSelectionMode()
                adapter.toggleSelection(product.id)
                updateSelectionUI()
                true
            }
        )
        
        binding.productsRecyclerView.apply {
            layoutManager = LinearLayoutManager(requireContext())
            adapter = this@ProductsListFragment.adapter
        }
    }

    private fun setupClickListeners() {
        binding.addProductFab.setOnClickListener {
            if (adapter.selectionMode) {
                exitSelectionMode()
            } else {
                findNavController().navigate(R.id.action_products_to_add_product)
            }
        }
        
        binding.emptyAddButton.setOnClickListener {
            findNavController().navigate(R.id.action_products_to_add_product)
        }

        binding.statsButton.setOnClickListener {
            showCategoryStatisticsDialog()
        }

        binding.selectAllButton.setOnClickListener {
            val totalCount = adapter.itemCount
            val selectedCount = adapter.getSelectedCount()
            
            if (selectedCount == totalCount) {
                adapter.deselectAll()
            } else {
                adapter.selectAll(adapter.currentList)
            }
            updateSelectionUI()
        }

        binding.deleteSelectedButton.setOnClickListener {
            if (adapter.getSelectedCount() > 0) {
                showDeleteConfirmationDialog()
            }
        }
    }

    private fun updateSelectionUI() {
        if (adapter.selectionMode) {
            val count = adapter.getSelectedCount()
            val totalCount = adapter.itemCount
            
            // Show selection panel
            binding.selectionPanel.visibility = View.VISIBLE
            binding.selectionCountText.text = "$count selected"
            
            // Update Select All button text
            binding.selectAllButton.text = if (count == totalCount) "Deselect All" else "Select All"
            
            // Change FAB to cancel icon
            binding.addProductFab.setImageResource(android.R.drawable.ic_menu_close_clear_cancel)
        } else {
            // Hide selection panel
            binding.selectionPanel.visibility = View.GONE
            
            // Restore FAB to add icon
            binding.addProductFab.setImageResource(android.R.drawable.ic_input_add)
        }
    }

    private fun showDeleteConfirmationDialog() {
        val count = adapter.getSelectedCount()
        
        AlertDialog.Builder(requireContext())
            .setTitle("Delete Products")
            .setMessage("Are you sure you want to delete $count selected product(s)?")
            .setPositiveButton("Delete") { _, _ ->
                deleteSelectedProducts()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun deleteSelectedProducts() {
        val selectedIds = adapter.getSelectedProducts()
        viewLifecycleOwner.lifecycleScope.launch {
            selectedIds.forEach { productId ->
                viewModel.deleteProduct(productId)
            }
            Toast.makeText(
                requireContext(),
                "Deleted ${selectedIds.size} product(s)",
                Toast.LENGTH_SHORT
            ).show()
            exitSelectionMode()
        }
    }

    private fun exitSelectionMode() {
        adapter.clearSelection()
        updateSelectionUI()
    }

    private fun setupSearchBar() {
        binding.searchEditText.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                viewModel.setSearchQuery(s?.toString() ?: "")
            }
            
            override fun afterTextChanged(s: Editable?) {}
        })
    }
    
    private fun setupFilterAndSort() {
        binding.filterButton.setOnClickListener {
            showCategoryFilterDialog()
        }
        
        binding.sortButton.setOnClickListener {
            showSortDialog()
        }
    }
    
    private fun showCategoryFilterDialog() {
        val categories = CategoryHelper.getAllCategories()
        val categoryNames = arrayOf("All Categories") + categories.map { "${it.icon} ${it.name}" }.toTypedArray()
        
        val currentCategoryId = viewModel.selectedCategoryId.value
        val currentSelection = if (currentCategoryId == null) {
            0
        } else {
            categories.indexOfFirst { it.id == currentCategoryId } + 1
        }
        
        AlertDialog.Builder(requireContext())
            .setTitle("Filter by Category")
            .setSingleChoiceItems(categoryNames, currentSelection) { dialog, which ->
                val selectedCategoryId = if (which == 0) null else categories[which - 1].id
                viewModel.setCategoryFilter(selectedCategoryId)
                dialog.dismiss()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }
    
    private fun showSortDialog() {
        val sortOptions = arrayOf(
            "Name (A-Z)",
            "Name (Z-A)",
            "Newest First",
            "Oldest First",
            "By Category"
        )
        
        val currentSortOrder = viewModel.sortOrder.value
        val currentSelection = when (currentSortOrder) {
            ProductSortOrder.NAME_ASC -> 0
            ProductSortOrder.NAME_DESC -> 1
            ProductSortOrder.DATE_NEWEST -> 2
            ProductSortOrder.DATE_OLDEST -> 3
            ProductSortOrder.CATEGORY -> 4
        }
        
        AlertDialog.Builder(requireContext())
            .setTitle("Sort Products")
            .setSingleChoiceItems(sortOptions, currentSelection) { dialog, which ->
                val selectedSortOrder = when (which) {
                    0 -> ProductSortOrder.NAME_ASC
                    1 -> ProductSortOrder.NAME_DESC
                    2 -> ProductSortOrder.DATE_NEWEST
                    3 -> ProductSortOrder.DATE_OLDEST
                    4 -> ProductSortOrder.CATEGORY
                    else -> ProductSortOrder.NAME_ASC
                }
                viewModel.setSortOrder(selectedSortOrder)
                dialog.dismiss()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun observeProducts() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.products.collect { products ->
                if (products.isEmpty()) {
                    binding.emptyStateLayout.visibility = View.VISIBLE
                    binding.productsRecyclerView.visibility = View.GONE
                } else {
                    binding.emptyStateLayout.visibility = View.GONE
                    binding.productsRecyclerView.visibility = View.VISIBLE
                    adapter.submitList(products)
                }
            }
        }
    }

    private fun showCategoryStatisticsDialog() {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val statistics = viewModel.getCategoryStatistics()
                
                val dialogView = layoutInflater.inflate(R.layout.dialog_category_statistics, null)
                val dialog = AlertDialog.Builder(requireContext())
                    .setView(dialogView)
                    .create()
                
                val recyclerView = dialogView.findViewById<androidx.recyclerview.widget.RecyclerView>(R.id.categoryStatsRecyclerView)
                val totalCountText = dialogView.findViewById<android.widget.TextView>(R.id.totalCountText)
                val closeButton = dialogView.findViewById<com.google.android.material.button.MaterialButton>(R.id.closeButton)
                
                val statsAdapter = CategoryStatisticsAdapter()
                recyclerView.layoutManager = androidx.recyclerview.widget.LinearLayoutManager(requireContext())
                recyclerView.adapter = statsAdapter
                statsAdapter.submitList(statistics)
                
                val totalCount = statistics.sumOf { it.count }
                totalCountText.text = totalCount.toString()
                
                closeButton.setOnClickListener {
                    dialog.dismiss()
                }
                
                dialog.show()
            } catch (e: Exception) {
                Toast.makeText(requireContext(), "Error loading statistics: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
