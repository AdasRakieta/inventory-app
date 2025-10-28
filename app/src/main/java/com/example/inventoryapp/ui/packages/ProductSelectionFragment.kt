package com.example.inventoryapp.ui.packages

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.inventoryapp.databinding.FragmentProductSelectionBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.PackageRepository
import com.example.inventoryapp.data.repository.ProductRepository
import kotlinx.coroutines.launch

class ProductSelectionFragment : Fragment() {

    private var _binding: FragmentProductSelectionBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: ProductSelectionViewModel
    private lateinit var adapter: SelectableProductsAdapter
    private val args: ProductSelectionFragmentArgs by navArgs()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val database = AppDatabase.getDatabase(requireContext())
        val productRepository = ProductRepository(database.productDao())
        val packageRepository = PackageRepository(database.packageDao())
        val factory = ProductSelectionViewModelFactory(
            productRepository,
            packageRepository,
            args.packageId
        )
        val vm: ProductSelectionViewModel by viewModels { factory }
        viewModel = vm
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentProductSelectionBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupRecyclerView()
        setupClickListeners()
        observeAvailableProducts()
    }

    private fun setupRecyclerView() {
        adapter = SelectableProductsAdapter { selectedIds ->
            updateSelectedCount(selectedIds.size)
        }
        
        binding.productsRecyclerView.apply {
            layoutManager = LinearLayoutManager(requireContext())
            adapter = this@ProductSelectionFragment.adapter
        }
    }

    private fun setupClickListeners() {
        binding.cancelButton.setOnClickListener {
            findNavController().navigateUp()
        }
        
        binding.addButton.setOnClickListener {
            val selectedIds = adapter.getSelectedProductIds()
            if (selectedIds.isEmpty()) {
                Toast.makeText(
                    requireContext(),
                    "Please select at least one product",
                    Toast.LENGTH_SHORT
                ).show()
                return@setOnClickListener
            }
            
            viewLifecycleOwner.lifecycleScope.launch {
                viewModel.addProductsToPackage(selectedIds)
                Toast.makeText(
                    requireContext(),
                    "${selectedIds.size} product(s) added to package",
                    Toast.LENGTH_SHORT
                ).show()
                findNavController().navigateUp()
            }
        }
    }

    private fun observeAvailableProducts() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.availableProducts.collect { products ->
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

    private fun updateSelectedCount(count: Int) {
        binding.selectedCountText.text = if (count == 1) {
            "1 product selected"
        } else {
            "$count products selected"
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
