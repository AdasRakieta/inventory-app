package com.example.inventoryapp.ui.boxes

import android.app.AlertDialog
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
import com.example.inventoryapp.data.local.entities.PrinterEntity
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.databinding.FragmentBoxDetailsBinding
import com.example.inventoryapp.utils.BluetoothPrinterHelper
import com.example.inventoryapp.utils.PrinterSelectionHelper
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Locale

/**
 * Fragment for displaying box details and printing labels.
 * Uses the same simple list layout as PackageDetailsFragment.
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

    private lateinit var productsAdapter: BoxProductsAdapter

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
        productsAdapter = BoxProductsAdapter { product ->
            showRemoveProductDialog(product)
        }

        binding.productsRecyclerView.apply {
            layoutManager = LinearLayoutManager(requireContext())
            adapter = productsAdapter
        }
    }

    private fun setupClickListeners() {
        binding.modifyProductsButton.setOnClickListener {
            // Navigate to modify products (mass delete)
            val action = BoxDetailsFragmentDirections.actionBoxDetailsToModifyBoxProducts(args.boxId)
            findNavController().navigate(action)
        }
        
        binding.addProductsButton.setOnClickListener {
            // Navigate to product selection for boxes
            val action = BoxDetailsFragmentDirections.actionBoxDetailsToBoxProductSelection(args.boxId)
            findNavController().navigate(action)
        }
        
        binding.addBulkButton.setOnClickListener {
            // Navigate to bulk scan for boxes
            val action = BoxDetailsFragmentDirections.actionBoxDetailsToBulkBoxScan(args.boxId)
            findNavController().navigate(action)
        }
        
        binding.printLabelButton.setOnClickListener {
            printBoxLabel()
        }

        binding.testPrintButton.setOnClickListener {
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

                    val dateFormat = SimpleDateFormat("MMM d, yyyy HH:mm", Locale.getDefault())
                    binding.boxCreatedDate.text = dateFormat.format(it.createdAt)
                }
            }
        }

        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.productsInBox.collect { products ->
                val count = products.size
                binding.productsHeader.text = if (count == 1) {
                    "1 product assigned"
                } else {
                    "$count products assigned"
                }

                if (products.isEmpty()) {
                    binding.productsRecyclerView.visibility = View.GONE
                    binding.noProductsText.visibility = View.VISIBLE
                } else {
                    binding.productsRecyclerView.visibility = View.VISIBLE
                    binding.noProductsText.visibility = View.GONE
                    productsAdapter.submitList(products)
                }
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

    private fun showRemoveProductDialog(product: ProductEntity) {
        AlertDialog.Builder(requireContext())
            .setTitle("Remove Product")
            .setMessage("Remove ${product.name} from this box?")
            .setPositiveButton("Remove") { _, _ ->
                viewModel.removeProductFromBox(product.id)
                Toast.makeText(requireContext(), "Product removed from box", Toast.LENGTH_SHORT).show()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun printBoxLabel() {
        // Show printer selection dialog
        PrinterSelectionHelper.getDefaultOrSelectPrinter(this) { selectedPrinter ->
            printBoxLabelWithPrinter(selectedPrinter)
        }
    }

    private fun printBoxLabelWithPrinter(printer: PrinterEntity) {
        viewLifecycleOwner.lifecycleScope.launch {
            val box = viewModel.box.value
            val productsWithCategories = viewModel.productsWithCategories.value

            if (box == null) {
                Toast.makeText(requireContext(), "Box data not available", Toast.LENGTH_SHORT).show()
                return@launch
            }

            try {
                // Generate ZPL label using printer dimensions and smart wrapping
                val zplContent = com.example.inventoryapp.printer.ZplContentGenerator.generateBoxLabel(
                    box = box,
                    products = productsWithCategories,
                    printer = printer
                )
                
                // Connect to printer and send ZPL
                val socket = BluetoothPrinterHelper.connectToPrinter(requireContext(), printer.macAddress)
                if (socket == null) {
                    Toast.makeText(
                        requireContext(),
                        "❌ Failed to connect to ${printer.name}\nMAC: ${printer.macAddress}\n\nCheck:\n1. Printer is ON\n2. Bluetooth enabled\n3. In range",
                        Toast.LENGTH_LONG
                    ).show()
                    return@launch
                }

                // Send ZPL to printer
                val success = BluetoothPrinterHelper.printZpl(socket, zplContent)
                socket.close()
                
                if (success) {
                    Toast.makeText(
                        requireContext(), 
                        "✅ Label printed on ${printer.name}\n${productsWithCategories.size} products", 
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
        PrinterSelectionHelper.getDefaultOrSelectPrinter(this) { selectedPrinter ->
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
                        "❌ Failed to connect to ${printer.name}\nMAC: ${printer.macAddress}",
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
    
    private fun showAddNewProductDialog() {
        // Navigate to AddProductFragment with boxId to automatically assign product to this box
        val action = BoxDetailsFragmentDirections.actionBoxDetailsFragmentToAddProductFragment(
            boxId = args.boxId
        )
        findNavController().navigate(action)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
