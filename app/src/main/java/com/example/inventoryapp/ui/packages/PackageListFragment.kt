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
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.inventoryapp.databinding.FragmentPackageListBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.PackageRepository
import kotlinx.coroutines.launch

class PackageListFragment : Fragment() {

    private var _binding: FragmentPackageListBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: PackagesViewModel
    private lateinit var adapter: PackagesAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val database = AppDatabase.getDatabase(requireContext())
        val repository = PackageRepository(database.packageDao())
        val factory = PackagesViewModelFactory(repository)
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
        observePackages()
    }

    private fun setupRecyclerView() {
        adapter = PackagesAdapter { packageEntity ->
            // TODO: Navigate to package details
            Toast.makeText(requireContext(), "Package details coming soon", Toast.LENGTH_SHORT).show()
        }
        
        binding.packagesRecyclerView.apply {
            layoutManager = LinearLayoutManager(requireContext())
            adapter = this@PackageListFragment.adapter
        }
    }

    private fun setupClickListeners() {
        binding.addPackageFab.setOnClickListener {
            showCreatePackageDialog()
        }
        
        binding.emptyAddButton.setOnClickListener {
            showCreatePackageDialog()
        }
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
