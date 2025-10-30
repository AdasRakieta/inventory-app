package com.example.inventoryapp.ui.packages

import android.app.AlertDialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.EditText
import android.widget.Spinner
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.inventoryapp.databinding.FragmentPackageDetailsBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.local.entities.CategoryEntity
import com.example.inventoryapp.data.repository.ContractorRepository
import com.example.inventoryapp.data.repository.PackageRepository
import com.example.inventoryapp.data.repository.ProductRepository
import com.example.inventoryapp.R
import com.example.inventoryapp.utils.CategoryHelper
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.first
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
        val packageRepository = PackageRepository(database.packageDao(), database.productDao())
        val productRepository = ProductRepository(database.productDao())
        val contractorRepository = ContractorRepository(database.contractorDao())
        val factory = PackageDetailsViewModelFactory(packageRepository, productRepository, contractorRepository, args.packageId)
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
        observeContractor()
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
        
        binding.addNewProductButton.setOnClickListener {
            showAddNewProductDialog()
        }
        
        binding.editPackageButton.setOnClickListener {
            showEditPackageDialog()
        }
        
        binding.changeStatusButton.setOnClickListener {
            showChangeStatusDialog()
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

    private fun observeContractor() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.contractor.collect { contractor ->
                binding.packageContractorText.text = contractor?.name ?: "No contractor assigned"
            }
        }
    }

    private fun showEditPackageDialog() {
        val currentPackage = viewModel.packageEntity.value ?: return

        val dialogView = layoutInflater.inflate(R.layout.dialog_edit_package, null)
        val packageNameEdit = dialogView.findViewById<EditText>(R.id.packageNameEdit)
        val contractorSpinner = dialogView.findViewById<Spinner>(R.id.contractorSpinner)

        // Set current package name
        packageNameEdit.setText(currentPackage.name)

        // Load contractors for spinner
        val database = AppDatabase.getDatabase(requireContext())
        val contractorDao = database.contractorDao()

        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val contractors = contractorDao.getAllContractors().first()
                val contractorList = mutableListOf<com.example.inventoryapp.data.local.entities.ContractorEntity?>()
                contractorList.add(null) // "No contractor" option
                contractorList.addAll(contractors.map { it as? com.example.inventoryapp.data.local.entities.ContractorEntity })

                val adapter = ArrayAdapter(
                    requireContext(),
                    android.R.layout.simple_spinner_item,
                    contractorList.map { it?.name ?: "No contractor assigned" }
                )
                adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
                contractorSpinner.adapter = adapter

                // Set current contractor selection
                val currentContractorIndex = contractorList.indexOfFirst { it?.id == currentPackage.contractorId }
                if (currentContractorIndex >= 0) {
                    contractorSpinner.setSelection(currentContractorIndex)
                }

                // Show dialog
                AlertDialog.Builder(requireContext())
                    .setTitle("Edit Package")
                    .setView(dialogView)
                    .setPositiveButton("Save") { _, _ ->
                        val newName = packageNameEdit.text.toString().trim()
                        val selectedContractorIndex = contractorSpinner.selectedItemPosition
                        val selectedContractor = if (selectedContractorIndex > 0) contractorList[selectedContractorIndex] else null

                        if (newName.isNotEmpty()) {
                            viewModel.updatePackageName(newName)
                            viewModel.updatePackageContractor(selectedContractor?.id)
                            Toast.makeText(requireContext(), "Package updated", Toast.LENGTH_SHORT).show()
                        } else {
                            Toast.makeText(requireContext(), "Package name cannot be empty", Toast.LENGTH_SHORT).show()
                        }
                    }
                    .setNegativeButton("Cancel", null)
                    .show()
            } catch (e: Exception) {
                Toast.makeText(requireContext(), "Error loading contractors: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
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

    private fun showAddNewProductDialog() {
        // Navigate to AddProductFragment with packageId to automatically assign product to this package
        val action = PackageDetailsFragmentDirections.actionPackageDetailsFragmentToAddProductFragment(
            packageId = args.packageId
        )
        findNavController().navigate(action)
    }

    private fun showChangeStatusDialog() {
        val currentPackage = viewModel.packageEntity.value ?: return
        
        val statuses = arrayOf("PREPARATION", "READY", "SHIPPED", "DELIVERED")
        val currentStatusIndex = statuses.indexOf(currentPackage.status)
        
        AlertDialog.Builder(requireContext())
            .setTitle("Change Package Status")
            .setSingleChoiceItems(statuses, currentStatusIndex) { dialog, which ->
                val selectedStatus = statuses[which]
                
                viewLifecycleOwner.lifecycleScope.launch {
                    try {
                        viewModel.updatePackageStatus(selectedStatus)
                        Toast.makeText(requireContext(), "Status updated to $selectedStatus", Toast.LENGTH_SHORT).show()
                        dialog.dismiss()
                    } catch (e: Exception) {
                        Toast.makeText(requireContext(), "Error updating status: ${e.message}", Toast.LENGTH_SHORT).show()
                    }
                }
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
