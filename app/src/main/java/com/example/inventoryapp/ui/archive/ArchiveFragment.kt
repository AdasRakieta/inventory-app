package com.example.inventoryapp.ui.archive

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
import com.example.inventoryapp.databinding.FragmentArchiveBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.ContractorRepository
import com.example.inventoryapp.data.repository.PackageRepository
import com.example.inventoryapp.ui.packages.PackagesAdapter
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

/**
 * Fragment displaying archived packages (RETURNED + archived=true)
 * Allows unarchiving packages back to main package list
 */
class ArchiveFragment : Fragment() {

    private var _binding: FragmentArchiveBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: ArchiveViewModel
    private lateinit var adapter: PackagesAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val database = AppDatabase.getDatabase(requireContext())
        val repository = PackageRepository(database.packageDao(), database.productDao(), database.boxDao())
        val contractorRepository = ContractorRepository(database.contractorDao())
        val factory = ArchiveViewModelFactory(repository, contractorRepository)
        val vm: ArchiveViewModel by viewModels { factory }
        viewModel = vm
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentArchiveBinding.inflate(inflater, container, false)
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
                val action = ArchiveFragmentDirections
                    .actionArchiveToPackageDetails(packageEntity.id)
                findNavController().navigate(action)
            },
            onPackageLongClick = { packageEntity ->
                adapter.enterSelectionMode()
                adapter.toggleSelection(packageEntity.id)
                updateSelectionUI()
                true
            }
        )
        
        binding.archiveRecyclerView.apply {
            layoutManager = LinearLayoutManager(requireContext())
            adapter = this@ArchiveFragment.adapter
        }
    }

    private fun setupClickListeners() {
        binding.btnUnarchive.setOnClickListener {
            unarchiveSelectedPackages()
        }
        
        binding.btnCancelSelection.setOnClickListener {
            exitSelectionMode()
        }
    }

    private fun setupSearchBar() {
        binding.searchBar.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                viewModel.setSearchQuery(s?.toString() ?: "")
            }
            override fun afterTextChanged(s: Editable?) {}
        })
    }

    private fun observePackages() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.filteredPackages.collect { packages ->
                adapter.submitList(packages)
                
                if (packages.isEmpty()) {
                    binding.emptyStateText.visibility = View.VISIBLE
                    binding.archiveRecyclerView.visibility = View.GONE
                } else {
                    binding.emptyStateText.visibility = View.GONE
                    binding.archiveRecyclerView.visibility = View.VISIBLE
                }
            }
        }
    }

    private fun updateSelectionUI() {
        val selectedCount = adapter.getSelectedIds().size
        
        if (adapter.isInSelectionMode()) {
            binding.selectionToolbar.visibility = View.VISIBLE
            binding.normalToolbar.visibility = View.GONE
            binding.selectedCountText.text = "$selectedCount selected"
        } else {
            binding.selectionToolbar.visibility = View.GONE
            binding.normalToolbar.visibility = View.VISIBLE
        }
    }

    private fun unarchiveSelectedPackages() {
        val selectedIds = adapter.getSelectedIds()
        if (selectedIds.isEmpty()) {
            Toast.makeText(requireContext(), "No packages selected", Toast.LENGTH_SHORT).show()
            return
        }
        
        AlertDialog.Builder(requireContext())
            .setTitle("Unarchive Packages")
            .setMessage("Restore ${selectedIds.size} package(s) to active packages?")
            .setPositiveButton("Unarchive") { _, _ ->
                viewLifecycleOwner.lifecycleScope.launch {
                    selectedIds.forEach { packageId ->
                        viewModel.unarchivePackage(packageId)
                    }
                    Toast.makeText(
                        requireContext(),
                        "${selectedIds.size} package(s) restored",
                        Toast.LENGTH_SHORT
                    ).show()
                    exitSelectionMode()
                }
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun exitSelectionMode() {
        adapter.exitSelectionMode()
        updateSelectionUI()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
