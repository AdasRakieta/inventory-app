package com.example.inventoryapp.ui.contractors

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
import com.example.inventoryapp.R
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.ContractorRepository
import com.example.inventoryapp.databinding.FragmentContractorsBinding
import com.example.inventoryapp.databinding.DialogAddContractorBinding
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class ContractorsFragment : Fragment() {

    private var _binding: FragmentContractorsBinding? = null
    private val binding get() = _binding!!

    private lateinit var viewModel: ContractorsViewModel
    private lateinit var adapter: ContractorsAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val database = AppDatabase.getDatabase(requireContext())
        val contractorRepository = ContractorRepository(database.contractorDao())
        val factory = ContractorsViewModelFactory(contractorRepository)
        val vm: ContractorsViewModel by viewModels { factory }
        viewModel = vm
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentContractorsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        // Setup ActionBar with back button
        (requireActivity() as? androidx.appcompat.app.AppCompatActivity)?.supportActionBar?.apply {
            setDisplayHomeAsUpEnabled(true)
            title = "Contractors"
        }

        setupRecyclerView()
        setupClickListeners()
        observeContractors()
    }

    private fun setupRecyclerView() {
        adapter = ContractorsAdapter(
            onEditClick = { contractor -> showEditContractorDialog(contractor) },
            onDeleteClick = { contractor -> showDeleteConfirmationDialog(contractor) }
        )

        binding.contractorsRecyclerView.apply {
            layoutManager = LinearLayoutManager(requireContext())
            adapter = this@ContractorsFragment.adapter
        }
    }

    private fun setupClickListeners() {
        binding.addContractorButton.setOnClickListener {
            showAddContractorDialog()
        }
    }

    private fun observeContractors() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.allContractors.collect { contractors ->
                adapter.submitList(contractors)
                binding.emptyStateTextView.visibility = if (contractors.isEmpty()) View.VISIBLE else View.GONE
            }
        }
    }

    private fun showAddContractorDialog() {
        findNavController().navigate(
            ContractorsFragmentDirections.actionContractorsToAddContractor()
        )
    }

    private fun showEditContractorDialog(contractor: com.example.inventoryapp.data.local.entities.ContractorEntity) {
        findNavController().navigate(
            ContractorsFragmentDirections.actionContractorsToEditContractor(contractor.id)
        )
    }

    private fun showDeleteConfirmationDialog(contractor: com.example.inventoryapp.data.local.entities.ContractorEntity) {
        AlertDialog.Builder(requireContext())
            .setTitle("Delete Contractor")
            .setMessage("Are you sure you want to delete '${contractor.name}'?")
            .setPositiveButton("Delete") { _, _ ->
                viewModel.deleteContractor(contractor)
                Toast.makeText(requireContext(), "Contractor deleted", Toast.LENGTH_SHORT).show()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}