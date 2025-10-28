package com.example.inventoryapp.ui.main

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.example.inventoryapp.R
import com.example.inventoryapp.databinding.FragmentHomeBinding

class HomeFragment : Fragment() {

    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentHomeBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupClickListeners()
    }

    private fun setupClickListeners() {
        // Scanner card - navigate to scanner
        binding.scannerCard.setOnClickListener {
            findNavController().navigate(R.id.action_home_to_scanner)
        }

        // Products card - navigate to products list
        binding.productsCard.setOnClickListener {
            findNavController().navigate(R.id.action_home_to_products)
        }

        // Packages card - navigate to packages list
        binding.packagesCard.setOnClickListener {
            findNavController().navigate(R.id.action_home_to_packages)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
