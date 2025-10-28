package com.example.inventoryapp.ui.main

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import com.example.inventoryapp.R
import com.example.inventoryapp.databinding.FragmentHomeBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.ProductRepository
import com.example.inventoryapp.data.repository.PackageRepository
import kotlinx.coroutines.launch

class HomeFragment : Fragment() {

    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentHomeBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupClickListeners()
        loadStatistics()
    }

    private fun setupClickListeners() {
        // Scanner card - navigate to scanner
        binding.scannerCard.setOnClickListener {
            findNavController().navigate(R.id.action_home_to_scanner)
        }

        // Products card - navigate to products list
        binding.productsCard.setOnClickListener {
            findNavController().navigate(R.id.action_home_to_products)
        }

        // Packages card - navigate to packages list
        binding.packagesCard.setOnClickListener {
            findNavController().navigate(R.id.action_home_to_packages)
        }
    }

    private fun loadStatistics() {
        val database = AppDatabase.getDatabase(requireContext())
        val productRepository = ProductRepository(database.productDao())
        val packageRepository = PackageRepository(database.packageDao())

        viewLifecycleOwner.lifecycleScope.launch {
            // Load product count
            productRepository.getAllProducts().collect { products ->
                binding.productsCountText.text = products.size.toString()
            }
        }

        viewLifecycleOwner.lifecycleScope.launch {
            // Load package count
            packageRepository.getAllPackages().collect { packages ->
                binding.packagesCountText.text = packages.size.toString()
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
