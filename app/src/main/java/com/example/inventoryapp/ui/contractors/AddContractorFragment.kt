package com.example.inventoryapp.ui.contractors

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import com.example.inventoryapp.databinding.FragmentAddContractorBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.ContractorRepository

class AddContractorFragment : Fragment() {

    private var _binding: FragmentAddContractorBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: ContractorsViewModel

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
        _binding = FragmentAddContractorBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupClickListeners()
    }

    private fun setupClickListeners() {
        binding.saveButton.setOnClickListener {
            saveContractor()
        }
        
        binding.cancelButton.setOnClickListener {
            findNavController().navigateUp()
        }
    }

    private fun saveContractor() {
        val name = binding.nameInput.text.toString().trim()
        val contactPerson = binding.contactPersonInput.text.toString().trim()
        val email = binding.emailInput.text.toString().trim()
        val phone = binding.phoneInput.text.toString().trim()
        val address = binding.addressInput.text.toString().trim()
        val notes = binding.notesInput.text.toString().trim()
        
        when {
            name.isEmpty() -> {
                binding.nameLayout.error = "Contractor name is required"
                return
            }
            else -> {
                binding.nameLayout.error = null
                
                viewModel.addContractor(
                    name = name,
                    contactPerson = if (contactPerson.isNotEmpty()) contactPerson else null,
                    email = if (email.isNotEmpty()) email else null,
                    phone = if (phone.isNotEmpty()) phone else null,
                    address = if (address.isNotEmpty()) address else null,
                    notes = if (notes.isNotEmpty()) notes else null
                )
                
                Toast.makeText(
                    requireContext(),
                    "Contractor added successfully!",
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
