package com.example.inventoryapp.ui.boxes

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.inventoryapp.InventoryApplication
import com.example.inventoryapp.R
import com.example.inventoryapp.databinding.FragmentBoxDetailsBinding
import com.example.inventoryapp.ui.products.ProductsAdapter
import com.example.inventoryapp.utils.ZPLPrinterHelper
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
            layoutManager = LinearLayoutManager(requireContext())
            adapter = productsAdapter
        }
    }

    private fun setupClickListeners() {
        binding.printLabelFab.setOnClickListener {
            printBoxLabel()
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
        viewLifecycleOwner.lifecycleScope.launch {
            val box = viewModel.box.value
            val products = viewModel.productsInBox.value

            if (box == null) {
                Toast.makeText(requireContext(), "Box data not available", Toast.LENGTH_SHORT).show()
                return@launch
            }

            try {
                // Generate ZPL for ZD421 (104mm x 156mm)
                val zplContent = generateZD421Label(box, products)

                // TODO: Implement actual printer integration when printer is available
                // For now, show the ZPL content in a Toast (or log it)
                Toast.makeText(
                    requireContext(),
                    "Label ready to print (${zplContent.length} chars). Connect printer to print.",
                    Toast.LENGTH_LONG
                ).show()

                // Future implementation with ZebraPrinterHelper:
                // val printerHelper = ZebraPrinterHelper()
                // printerHelper.printDocument(macAddress, zplContent) { error ->
                //     if (error == null) {
                //         Toast.makeText(requireContext(), "Label sent to printer", Toast.LENGTH_SHORT).show()
                //     } else {
                //         Toast.makeText(requireContext(), "Print error: $error", Toast.LENGTH_SHORT).show()
                //     }
                // }
            } catch (e: Exception) {
                Toast.makeText(requireContext(), "Print error: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun generateZD421Label(
        box: com.example.inventoryapp.data.local.entities.BoxEntity,
        products: List<com.example.inventoryapp.data.local.entities.ProductEntity>
    ): String {
        // ZD421 label: 104mm x 156mm (4.09" x 6.14") at 203 DPI
        // = 832 dots x 1248 dots
        val labelWidth = 832
        val labelHeight = 1248

        val zpl = StringBuilder()
        zpl.append("^XA") // Start of label
        zpl.append("^CI28") // UTF-8 encoding
        zpl.append("^PW$labelWidth") // Print width

        // Box Name (large, bold)
        zpl.append("^FO50,50^A0N,60,60^FD${box.name}^FS")

        // Location
        box.warehouseLocation?.let { location ->
            zpl.append("^FO50,130^A0N,40,40^FDLocation: $location^FS")
        }

        // Product count
        zpl.append("^FO50,190^A0N,35,35^FDProducts: ${products.size}^FS")

        // QR Code with box ID
        zpl.append("^FO600,50^BQN,2,8^FDQA,BOX_${box.id}^FS")

        // List of product serial numbers (max 20 for space)
        var yPosition = 250
        val maxProducts = 20
        products.take(maxProducts).forEach { product ->
            zpl.append("^FO50,$yPosition^A0N,28,28^FD${product.serialNumber}^FS")
            yPosition += 35
        }

        if (products.size > maxProducts) {
            zpl.append("^FO50,$yPosition^A0N,28,28^FD... and ${products.size - maxProducts} more^FS")
        }

        // Footer with creation date
        val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault())
        val createdDate = dateFormat.format(box.createdAt)
        zpl.append("^FO50,${labelHeight - 80}^A0N,25,25^FDCreated: $createdDate^FS")

        zpl.append("^XZ") // End of label

        return zpl.toString()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
