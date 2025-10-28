package com.example.inventoryapp.ui.packages

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
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.inventoryapp.databinding.FragmentPackageDetailsBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.PackageRepository
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class PackageDetailsFragment : Fragment() {

    private var _binding: FragmentPackageDetailsBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: PackageDetailsViewModel
    private lateinit var adapter: PackageProductsAdapter
    private val args: PackageDetailsFragmentArgs by navArgs()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val database = AppDatabase.getDatabase(requireContext())
        val repository = PackageRepository(database.packageDao(), database.productDao())
        val factory = PackageDetailsViewModelFactory(repository, args.packageId)
        val vm: PackageDetailsViewModel by viewModels { factory }
        viewModel = vm
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentPackageDetailsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupRecyclerView()
        setupClickListeners()
        observePackage()
        observeProducts()
    }

    private fun setupRecyclerView() {
        adapter = PackageProductsAdapter { product ->
            showRemoveProductDialog(product)
        }
        
        binding.productsRecyclerView.apply {
            layoutManager = LinearLayoutManager(requireContext())
            adapter = this@PackageDetailsFragment.adapter
        }
    }

    private fun setupClickListeners() {
        binding.addProductsButton.setOnClickListener {
            val action = PackageDetailsFragmentDirections
                .actionPackageDetailsToProductSelection(args.packageId)
            findNavController().navigate(action)
        }
        
        binding.editPackageButton.setOnClickListener {
            showEditPackageDialog()
        }
        
        binding.deletePackageButton.setOnClickListener {
            showDeleteConfirmationDialog()
        }
    }

    private fun observePackage() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.packageEntity.collect { pkg ->
                pkg?.let {
                    binding.packageNameText.text = it.name
                    binding.packageStatusText.text = it.status
                    
                    // Format dates
                    val dateFormat = SimpleDateFormat("MMM d, yyyy HH:mm", Locale.getDefault())
                    binding.createdAtText.text = dateFormat.format(Date(it.createdAt))
                    
                    if (it.shippedAt != null) {
                        binding.shippedAtLayout.visibility = View.VISIBLE
                        binding.shippedAtText.text = dateFormat.format(Date(it.shippedAt))
                    } else {
                        binding.shippedAtLayout.visibility = View.GONE
                    }
                }
            }
        }
    }

    private fun observeProducts() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.productsInPackage.collect { products ->
                val count = products.size
                binding.productCountText.text = if (count == 1) {
                    "1 product assigned"
                } else {
                    "$count products assigned"
                }
                
                if (products.isEmpty()) {
                    binding.productsRecyclerView.visibility = View.GONE
                    binding.emptyProductsText.visibility = View.VISIBLE
                } else {
                    binding.productsRecyclerView.visibility = View.VISIBLE
                    binding.emptyProductsText.visibility = View.GONE
                    adapter.submitList(products)
                }
            }
        }
    }

    private fun showEditPackageDialog() {
        val currentPackage = viewModel.packageEntity.value ?: return
        
        val editText = EditText(requireContext()).apply {
            setText(currentPackage.name)
            hint = "Package name"
            setSingleLine(true)
        }
        
        AlertDialog.Builder(requireContext())
            .setTitle("Edit Package")
            .setMessage("Enter a new name for this package")
            .setView(editText)
            .setPositiveButton("Save") { _, _ ->
                val newName = editText.text.toString().trim()
                if (newName.isNotEmpty()) {
                    viewModel.updatePackageName(newName)
                    Toast.makeText(requireContext(), "Package updated", Toast.LENGTH_SHORT).show()
                }
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun showRemoveProductDialog(product: com.example.inventoryapp.data.local.entities.ProductEntity) {
        AlertDialog.Builder(requireContext())
            .setTitle("Remove Product")
            .setMessage("Remove \"${product.name}\" from this package?")
            .setPositiveButton("Remove") { _, _ ->
                viewModel.removeProductFromPackage(product.id)
                Toast.makeText(requireContext(), "Product removed", Toast.LENGTH_SHORT).show()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun showDeleteConfirmationDialog() {
        val currentPackage = viewModel.packageEntity.value ?: return
        
        AlertDialog.Builder(requireContext())
            .setTitle("Delete Package")
            .setMessage("Are you sure you want to delete \"${currentPackage.name}\"? This action cannot be undone.")
            .setPositiveButton("Delete") { _, _ ->
                viewModel.deletePackage()
                Toast.makeText(requireContext(), "Package deleted", Toast.LENGTH_SHORT).show()
                findNavController().navigateUp()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
