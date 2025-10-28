package com.example.inventoryapp.ui.products

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.inventoryapp.R
import com.example.inventoryapp.databinding.FragmentProductsListBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.ProductRepository
import kotlinx.coroutines.launch

class ProductsListFragment : Fragment() {

    private var _binding: FragmentProductsListBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: ProductsViewModel
    private lateinit var adapter: ProductsAdapter

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
        _binding = FragmentProductsListBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupRecyclerView()
        setupClickListeners()
        observeProducts()
    }

    private fun setupRecyclerView() {
        adapter = ProductsAdapter { product ->
            // TODO: Navigate to product details
        }
        
        binding.productsRecyclerView.apply {
            layoutManager = LinearLayoutManager(requireContext())
            adapter = this@ProductsListFragment.adapter
        }
    }

    private fun setupClickListeners() {
        binding.addProductFab.setOnClickListener {
            findNavController().navigate(R.id.action_products_to_add_product)
        }
        
        binding.emptyAddButton.setOnClickListener {
            findNavController().navigate(R.id.action_products_to_add_product)
        }
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

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
