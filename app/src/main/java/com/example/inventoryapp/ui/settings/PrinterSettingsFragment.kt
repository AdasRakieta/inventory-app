package com.example.inventoryapp.ui.settings

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.Toast
import androidx.core.widget.doAfterTextChanged
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.inventoryapp.R
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.local.entities.PrinterEntity
import com.example.inventoryapp.data.repository.PrinterRepository
import com.example.inventoryapp.databinding.FragmentPrinterSettingsBinding
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.google.android.material.textfield.TextInputEditText
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

/**
 * Fragment for managing multiple printers
 */
class PrinterSettingsFragment : Fragment() {

    private var _binding: FragmentPrinterSettingsBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var printerRepository: PrinterRepository
    private lateinit var printersAdapter: PrintersAdapter

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentPrinterSettingsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val database = AppDatabase.getDatabase(requireContext())
        printerRepository = PrinterRepository(database.printerDao())
        
        setupRecyclerView()
        setupListeners()
        observePrinters()
    }

    private fun setupRecyclerView() {
        printersAdapter = PrintersAdapter(
            onPrinterClick = { printer -> showEditPrinterDialog(printer) },
            onSetDefaultClick = { printer -> setDefaultPrinter(printer) },
            onDeleteClick = { printer -> showDeleteConfirmationDialog(printer) }
        )
        
        binding.printersRecyclerView.apply {
            layoutManager = LinearLayoutManager(requireContext())
            adapter = printersAdapter
        }
    }

    private fun setupListeners() {
        binding.addPrinterButton.setOnClickListener {
            showAddPrinterDialog()
        }
    }

    private fun observePrinters() {
        viewLifecycleOwner.lifecycleScope.launch {
            printerRepository.getAllPrinters().collect { printers ->
                printersAdapter.submitList(printers)
                
                if (printers.isEmpty()) {
                    binding.emptyStateLayout.visibility = View.VISIBLE
                    binding.printersRecyclerView.visibility = View.GONE
                } else {
                    binding.emptyStateLayout.visibility = View.GONE
                    binding.printersRecyclerView.visibility = View.VISIBLE
                }
            }
        }
    }

    private fun showAddPrinterDialog() {
        val dialogView = LayoutInflater.from(requireContext())
            .inflate(R.layout.dialog_add_printer, null)
        
        val nameInput = dialogView.findViewById<TextInputEditText>(R.id.printerNameInput)
        val macInput = dialogView.findViewById<TextInputEditText>(R.id.printerMacInput)
        val widthInput = dialogView.findViewById<TextInputEditText>(R.id.labelWidthInput)
        val heightInput = dialogView.findViewById<TextInputEditText>(R.id.labelHeightInput)
        
        // Auto-format MAC address
        macInput.doAfterTextChanged {
            val text = it.toString().replace(":", "").uppercase()
            if (text.length >= 2) {
                val formatted = text.chunked(2).joinToString(":")
                if (formatted != it.toString()) {
                    macInput.removeTextChangedListener(null)
                    macInput.setText(formatted)
                    macInput.setSelection(formatted.length)
                }
            }
        }
        
        MaterialAlertDialogBuilder(requireContext())
            .setTitle("Add Printer")
            .setView(dialogView)
            .setPositiveButton("Add") { _, _ ->
                val name = nameInput.text.toString().trim()
                val mac = macInput.text.toString().trim()
                val width = widthInput.text.toString().toIntOrNull() ?: 50
                val height = heightInput.text.toString().toIntOrNull() ?: 30
                
                if (validatePrinterInput(name, mac, width, height)) {
                    addPrinter(name, mac, width, height)
                }
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun showEditPrinterDialog(printer: PrinterEntity) {
        val dialogView = LayoutInflater.from(requireContext())
            .inflate(R.layout.dialog_add_printer, null)
        
        val nameInput = dialogView.findViewById<TextInputEditText>(R.id.printerNameInput)
        val macInput = dialogView.findViewById<TextInputEditText>(R.id.printerMacInput)
        val widthInput = dialogView.findViewById<TextInputEditText>(R.id.labelWidthInput)
        val heightInput = dialogView.findViewById<TextInputEditText>(R.id.labelHeightInput)
        
        // Pre-fill with existing values
        nameInput.setText(printer.name)
        macInput.setText(printer.macAddress)
        widthInput.setText(printer.labelWidthMm.toString())
        heightInput.setText(printer.labelHeightMm.toString())
        
        // Auto-format MAC address
        macInput.doAfterTextChanged {
            val text = it.toString().replace(":", "").uppercase()
            if (text.length >= 2) {
                val formatted = text.chunked(2).joinToString(":")
                if (formatted != it.toString()) {
                    macInput.removeTextChangedListener(null)
                    macInput.setText(formatted)
                    macInput.setSelection(formatted.length)
                }
            }
        }
        
        MaterialAlertDialogBuilder(requireContext())
            .setTitle("Edit Printer")
            .setView(dialogView)
            .setPositiveButton("Save") { _, _ ->
                val name = nameInput.text.toString().trim()
                val mac = macInput.text.toString().trim()
                val width = widthInput.text.toString().toIntOrNull() ?: 50
                val height = heightInput.text.toString().toIntOrNull() ?: 30
                
                if (validatePrinterInput(name, mac, width, height)) {
                    updatePrinter(printer.copy(
                        name = name,
                        macAddress = mac,
                        labelWidthMm = width,
                        labelHeightMm = height
                    ))
                }
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun validatePrinterInput(
        name: String,
        mac: String,
        width: Int,
        height: Int
    ): Boolean {
        if (name.isEmpty()) {
            Toast.makeText(requireContext(), "Please enter printer name", Toast.LENGTH_SHORT).show()
            return false
        }
        
        if (mac.isEmpty()) {
            Toast.makeText(requireContext(), "Please enter MAC address", Toast.LENGTH_SHORT).show()
            return false
        }
        
        // Validate MAC address format
        val macRegex = Regex("^([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})$")
        if (!macRegex.matches(mac)) {
            Toast.makeText(
                requireContext(),
                "Invalid MAC address. Use: XX:XX:XX:XX:XX:XX",
                Toast.LENGTH_LONG
            ).show()
            return false
        }
        
        if (width < 10 || width > 200) {
            Toast.makeText(
                requireContext(),
                "Label width must be between 10-200mm",
                Toast.LENGTH_SHORT
            ).show()
            return false
        }
        
        if (height < 10 || height > 200) {
            Toast.makeText(
                requireContext(),
                "Label height must be between 10-200mm",
                Toast.LENGTH_SHORT
            ).show()
            return false
        }
        
        return true
    }

    private fun addPrinter(name: String, mac: String, width: Int, height: Int) {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val isFirstPrinter = printerRepository.getPrinterCount() == 0
                
                val printer = PrinterEntity(
                    name = name,
                    macAddress = mac,
                    labelWidthMm = width,
                    labelHeightMm = height,
                    isDefault = isFirstPrinter // First printer is default
                )
                
                printerRepository.insertPrinter(printer)
                Toast.makeText(requireContext(), "✅ Printer added", Toast.LENGTH_SHORT).show()
                
            } catch (e: Exception) {
                Toast.makeText(
                    requireContext(),
                    "Failed to add printer: ${e.message}",
                    Toast.LENGTH_LONG
                ).show()
            }
        }
    }

    private fun updatePrinter(printer: PrinterEntity) {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                printerRepository.updatePrinter(printer)
                Toast.makeText(requireContext(), "✅ Printer updated", Toast.LENGTH_SHORT).show()
            } catch (e: Exception) {
                Toast.makeText(
                    requireContext(),
                    "Failed to update printer: ${e.message}",
                    Toast.LENGTH_LONG
                ).show()
            }
        }
    }

    private fun setDefaultPrinter(printer: PrinterEntity) {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                printerRepository.setDefaultPrinter(printer.id)
                Toast.makeText(
                    requireContext(),
                    "✅ ${printer.name} set as default",
                    Toast.LENGTH_SHORT
                ).show()
            } catch (e: Exception) {
                Toast.makeText(
                    requireContext(),
                    "Failed to set default: ${e.message}",
                    Toast.LENGTH_LONG
                ).show()
            }
        }
    }

    private fun showDeleteConfirmationDialog(printer: PrinterEntity) {
        MaterialAlertDialogBuilder(requireContext())
            .setTitle("Delete Printer")
            .setMessage("Are you sure you want to delete \"${printer.name}\"?")
            .setPositiveButton("Delete") { _, _ ->
                deletePrinter(printer)
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun deletePrinter(printer: PrinterEntity) {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                printerRepository.deletePrinter(printer)
                Toast.makeText(requireContext(), "Printer deleted", Toast.LENGTH_SHORT).show()
            } catch (e: Exception) {
                Toast.makeText(
                    requireContext(),
                    "Failed to delete printer: ${e.message}",
                    Toast.LENGTH_LONG
                ).show()
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
