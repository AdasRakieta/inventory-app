package com.example.inventoryapp.ui.packages

import android.app.AlertDialog
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.EditText
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.inventoryapp.databinding.FragmentPackageListBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.ContractorRepository
import com.example.inventoryapp.data.repository.PackageRepository
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class PackageListFragment : Fragment() {

    private var _binding: FragmentPackageListBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: PackagesViewModel
    private lateinit var adapter: PackagesAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val database = AppDatabase.getDatabase(requireContext())
        val repository = PackageRepository(database.packageDao(), database.productDao())
        val contractorRepository = ContractorRepository(database.contractorDao())
        val factory = PackagesViewModelFactory(repository, contractorRepository)
        val vm: PackagesViewModel by viewModels { factory }
        viewModel = vm
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentPackageListBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupRecyclerView()
        setupClickListeners()
        setupSearchBar()
        observePackages()
    }

    private fun setupRecyclerView() {
        adapter = PackagesAdapter(
            onPackageClick = { packageEntity ->
                val action = PackageListFragmentDirections
                    .actionPackagesToPackageDetails(packageEntity.id)
                findNavController().navigate(action)
            },
            onPackageLongClick = { packageEntity ->
                adapter.enterSelectionMode()
                adapter.toggleSelection(packageEntity.id)
                updateSelectionUI()
                true
            }
        )
        
        binding.packagesRecyclerView.apply {
            layoutManager = LinearLayoutManager(requireContext())
            adapter = this@PackageListFragment.adapter
        }
    }

    private fun setupClickListeners() {
        binding.addPackageFab.setOnClickListener {
            if (adapter.selectionMode) {
                exitSelectionMode()
            } else {
                showCreatePackageDialog()
            }
        }
        
        binding.emptyAddButton.setOnClickListener {
            showCreatePackageDialog()
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
            binding.addPackageFab.setImageResource(android.R.drawable.ic_menu_close_clear_cancel)
            
            // Move FAB up to avoid overlapping with selection panel
            binding.addPackageFab.animate()
                .translationY(-binding.selectionPanel.height.toFloat() - 16f)
                .setDuration(200)
                .start()
        } else {
            // Hide selection panel
            binding.selectionPanel.visibility = View.GONE
            
            // Restore FAB to add icon
            binding.addPackageFab.setImageResource(android.R.drawable.ic_input_add)
            
            // Move FAB back to original position
            binding.addPackageFab.animate()
                .translationY(0f)
                .setDuration(200)
                .start()
        }
    }

    private fun showDeleteConfirmationDialog() {
        val count = adapter.getSelectedCount()
        AlertDialog.Builder(requireContext())
            .setTitle("Delete Packages")
            .setMessage("Are you sure you want to delete $count selected package(s)?")
            .setPositiveButton("Delete") { _, _ ->
                deleteSelectedPackages()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun deleteSelectedPackages() {
        val selectedIds = adapter.getSelectedPackages()
        viewLifecycleOwner.lifecycleScope.launch {
            selectedIds.forEach { packageId ->
                viewModel.deletePackage(packageId)
            }
            Toast.makeText(
                requireContext(),
                "Deleted ${selectedIds.size} package(s)",
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

    private fun showCreatePackageDialog() {
        val editText = EditText(requireContext()).apply {
            hint = "Package name"
            setSingleLine(true)
        }
        
        AlertDialog.Builder(requireContext())
            .setTitle("Create Package")
            .setMessage("Enter a name for the new package")
            .setView(editText)
            .setPositiveButton("Create") { _, _ ->
                val name = editText.text.toString().trim()
                if (name.isNotEmpty()) {
                    viewModel.createPackage(name)
                    Toast.makeText(requireContext(), "Package created", Toast.LENGTH_SHORT).show()
                } else {
                    Toast.makeText(requireContext(), "Package name cannot be empty", Toast.LENGTH_SHORT).show()
                }
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun observePackages() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.packagesWithCount.collect { packages ->
                if (packages.isEmpty()) {
                    binding.emptyStateLayout.visibility = View.VISIBLE
                    binding.packagesRecyclerView.visibility = View.GONE
                } else {
                    binding.emptyStateLayout.visibility = View.GONE
                    binding.packagesRecyclerView.visibility = View.VISIBLE
                    adapter.submitList(packages)
                }
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
