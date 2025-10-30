package com.example.inventoryapp.ui.packages

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import com.example.inventoryapp.databinding.FragmentAddPackageBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.PackageRepository
import com.example.inventoryapp.data.repository.ProductRepository

class AddPackageFragment : Fragment() {

    private var _binding: FragmentAddPackageBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: PackageListViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val database = AppDatabase.getDatabase(requireContext())
        val productRepository = ProductRepository(database.productDao())
        val packageRepository = PackageRepository(database.packageDao(), database.productDao())
        val factory = PackageListViewModelFactory(packageRepository, productRepository)
        val vm: PackageListViewModel by viewModels { factory }
        viewModel = vm
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentAddPackageBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupClickListeners()
    }

    private fun setupClickListeners() {
        binding.saveButton.setOnClickListener {
            savePackage()
        }
        
        binding.cancelButton.setOnClickListener {
            findNavController().navigateUp()
        }
    }

    private fun savePackage() {
        val name = binding.packageNameInput.text.toString().trim()
        val description = binding.descriptionInput.text.toString().trim().takeIf { it.isNotEmpty() }
        
        when {
            name.isEmpty() -> {
                binding.packageNameLayout.error = "Package name is required"
                return
            }
            else -> {
                binding.packageNameLayout.error = null
                
                viewModel.createPackage(name)
                
                Toast.makeText(
                    requireContext(),
                    "Package created successfully!",
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
