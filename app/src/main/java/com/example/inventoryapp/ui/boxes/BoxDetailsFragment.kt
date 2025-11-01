package com.example.inventoryapp.ui.boxes

import android.content.Context
import android.graphics.Bitmap
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.inventoryapp.InventoryApplication
import com.example.inventoryapp.R
import com.example.inventoryapp.data.local.entities.PrinterEntity
import com.example.inventoryapp.databinding.FragmentBoxDetailsBinding
import com.example.inventoryapp.ui.products.ProductsAdapter
import com.example.inventoryapp.utils.BluetoothPrinterHelper
import com.example.inventoryapp.utils.PrinterSelectionHelper
import com.example.inventoryapp.utils.QRCodeGenerator
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.google.gson.Gson
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Locale

/**
 * Fragment for displaying box details and printing labels.
 */
class BoxDetailsFragment : Fragment() {

    private var _binding: FragmentBoxDetailsBinding? = null
    private val binding get() = _binding!!

    private val args: BoxDetailsFragmentArgs by navArgs()

    private val viewModel: BoxDetailsViewModel by viewModels {
        BoxDetailsViewModelFactory(
            (requireActivity().application as InventoryApplication).boxRepository,
            args.boxId
        )
    }

    private lateinit var productsAdapter: ProductsAdapter

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentBoxDetailsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupRecyclerView()
        setupClickListeners()
        observeViewModel()
    }

    private fun setupRecyclerView() {
        productsAdapter = ProductsAdapter(
            onProductClick = { /* No action needed in box details */ },
            onProductLongClick = { false }
        )

        binding.productsRecyclerView.apply {
            layoutManager = LinearLayoutManager(requireContext()).apply {
                orientation = LinearLayoutManager.VERTICAL
            }
            adapter = productsAdapter
            setHasFixedSize(false)
            isNestedScrollingEnabled = false
        }
    }

    private fun setupClickListeners() {
        android.util.Log.d("BoxDetails", "Setting up click listeners")
        binding.printLabelFab.setOnClickListener {
            android.util.Log.d("BoxDetails", "Print button clicked")
            printBoxLabel()
        }

        binding.testPrintFab.setOnClickListener {
            android.util.Log.d("BoxDetails", "Test print button clicked")
            testPrinterConnection()
        }
        
        binding.editBoxButton.setOnClickListener {
            editBox()
        }
    }

    private fun observeViewModel() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.box.collect { box ->
                box?.let {
                    binding.boxName.text = it.name
                    binding.boxDescription.text = it.description ?: "No description"
                    binding.boxLocation.text = it.warehouseLocation ?: "No location"

                    val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault())
                    binding.boxCreatedDate.text = "Created: ${dateFormat.format(it.createdAt)}"
                }
            }
        }

        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.productsInBox.collect { products ->
                android.util.Log.d("BoxDetails", "Loading ${products.size} products into adapter")
                // Convert ProductEntity to ProductWithPackage for adapter
                val productsWithPackage = products.map { product ->
                    com.example.inventoryapp.ui.products.ProductWithPackage(
                        productEntity = product,
                        packageEntity = null
                    )
                }
                productsAdapter.submitList(productsWithPackage)
                updateProductsHeader(products.size)
                updateEmptyState(products.isEmpty())
                
                // Force refresh RecyclerView
                binding.productsRecyclerView.adapter?.notifyDataSetChanged()
            }
        }

        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.errorMessage.collect { error ->
                error?.let {
                    Toast.makeText(requireContext(), it, Toast.LENGTH_SHORT).show()
                    viewModel.clearError()
                }
            }
        }
    }

    private fun updateProductsHeader(count: Int) {
        binding.productsHeader.text = "Products ($count)"
    }

    private fun updateEmptyState(isEmpty: Boolean) {
        if (isEmpty) {
            binding.productsRecyclerView.visibility = View.GONE
            binding.noProductsText.visibility = View.VISIBLE
        } else {
            binding.productsRecyclerView.visibility = View.VISIBLE
            binding.noProductsText.visibility = View.GONE
        }
    }

    private fun printBoxLabel() {
        android.util.Log.d("BoxDetails", "printBoxLabel() called")
        // Show printer selection dialog
        PrinterSelectionHelper.getDefaultOrSelectPrinter(this) { selectedPrinter ->
            android.util.Log.d("BoxDetails", "Printer selected: ${selectedPrinter.name}")
            printBoxLabelWithPrinter(selectedPrinter)
        }
    }

    private fun printBoxLabelWithPrinter(printer: PrinterEntity) {
        viewLifecycleOwner.lifecycleScope.launch {
            val box = viewModel.box.value
            val products = viewModel.productsInBox.value

            if (box == null) {
                Toast.makeText(requireContext(), "Box data not available", Toast.LENGTH_SHORT).show()
                return@launch
            }

            try {
                // Generate formatted text content for printing
                val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault())
                val textContent = buildString {
                    // Header
                    append("Box: ${box.name}\n")
                    if (!box.description.isNullOrBlank()) {
                        append("Description: ${box.description}\n")
                    }
                    append("Created: ${dateFormat.format(box.createdAt)}\n")
                    append("Printer: ${printer.name}\n\n")

                    // Products section
                    append("Products:\n")
                    products.forEachIndexed { index, product ->
                        val productNumber = index + 1
                        val name = product.name
                        val sn = product.serialNumber ?: "N/A"

                        // Check if name + SN fits in one line (approximate character limit)
                        val combinedLength = name.length + sn.length + 3 // +3 for ": " and ","
                        if (combinedLength <= 25) { // Fits in one line
                            append("$productNumber. $name: $sn,\n")
                        } else { // Split into two lines
                            append("$productNumber. $name:\n")
                            append("$sn,\n")
                        }
                    }
                }
                
                // Connect to printer and print single label with all products
                val socket = BluetoothPrinterHelper.connectToPrinter(requireContext(), printer.macAddress)
                if (socket == null) {
                    Toast.makeText(
                        requireContext(),
                        "❌ Failed to connect to ${printer.name}\nMAC: ${printer.macAddress}\n\nCheck:\n1. Printer is ON\n2. Bluetooth enabled\n3. In range",
                        Toast.LENGTH_LONG
                    ).show()
                    return@launch
                }

                // Print text label
                val success = BluetoothPrinterHelper.printText(socket, textContent)
                socket.close()
                
                if (success) {
                    Toast.makeText(
                        requireContext(), 
                        "✅ Label printed on ${printer.name}", 
                        Toast.LENGTH_SHORT
                    ).show()
                } else {
                    Toast.makeText(requireContext(), "❌ Failed to print label", Toast.LENGTH_SHORT).show()
                }
            } catch (e: Exception) {
                Toast.makeText(requireContext(), "Print error: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun testPrinterConnection() {
        // Use the same printer selection mechanism as the main print function
        PrinterSelectionHelper.getDefaultOrSelectPrinter(this) { selectedPrinter ->
            android.util.Log.d("BoxDetails", "Test printer selected: ${selectedPrinter.name}")
            testPrinterWithSelected(selectedPrinter)
        }
    }

    private fun testPrinterWithSelected(printer: PrinterEntity) {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                Toast.makeText(requireContext(), "Testing printer: ${printer.name}", Toast.LENGTH_SHORT).show()

                val socket = BluetoothPrinterHelper.connectToPrinter(requireContext(), printer.macAddress)
                if (socket != null) {
                    val success = BluetoothPrinterHelper.sendTestLabel(socket)
                    BluetoothPrinterHelper.disconnect(socket)

                    if (success) {
                        Toast.makeText(requireContext(), "✅ Test label sent! Check printer.", Toast.LENGTH_LONG).show()
                    } else {
                        Toast.makeText(requireContext(), "❌ Test failed - check logs", Toast.LENGTH_SHORT).show()
                    }
                } else {
                    Toast.makeText(
                        requireContext(),
                        "❌ Failed to connect to ${printer.name}\nMAC: ${printer.macAddress}\n\nCheck:\n1. Printer is ON\n2. Bluetooth enabled\n3. In range",
                        Toast.LENGTH_LONG
                    ).show()
                }
            } catch (e: Exception) {
                Toast.makeText(requireContext(), "Test error: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun editBox() {
        val box = viewModel.box.value ?: return
        
        val action = BoxDetailsFragmentDirections.actionBoxDetailsToEditBox(box.id)
        findNavController().navigate(action)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
