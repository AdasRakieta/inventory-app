package com.example.inventoryapp.ui.inventorycount

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.inventoryapp.R
import com.example.inventoryapp.databinding.ItemInventoryCountSessionBinding
import com.example.inventoryapp.data.local.dao.SessionWithCount
import java.text.SimpleDateFormat
import java.util.*

/**
 * Adapter for displaying inventory count sessions with item count.
 */
class InventoryCountSessionsAdapter(
    private val onSessionClick: (SessionWithCount) -> Unit,
    private val onSessionLongClick: (SessionWithCount) -> Boolean
) : ListAdapter<SessionWithCount, InventoryCountSessionsAdapter.SessionViewHolder>(SessionDiffCallback()) {

    private val selectedSessions = mutableSetOf<Long>()
    var selectionMode = false
        private set

    fun toggleSelection(sessionId: Long) {
        if (selectedSessions.contains(sessionId)) {
            selectedSessions.remove(sessionId)
        } else {
            selectedSessions.add(sessionId)
        }
        notifyDataSetChanged()
    }

    fun clearSelection() {
        selectedSessions.clear()
        selectionMode = false
        notifyDataSetChanged()
    }

    fun enterSelectionMode() {
        selectionMode = true
        notifyDataSetChanged()
    }

    fun getSelectedSessions(): Set<Long> = selectedSessions.toSet()

    fun getSelectedCount(): Int = selectedSessions.size

    fun selectAll(sessions: List<SessionWithCount>) {
        sessions.forEach { selectedSessions.add(it.session.id) }
        notifyDataSetChanged()
    }

    fun deselectAll() {
        selectedSessions.clear()
        notifyDataSetChanged()
    }

    private fun isSelected(sessionId: Long): Boolean = selectedSessions.contains(sessionId)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): SessionViewHolder {
        val binding = ItemInventoryCountSessionBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return SessionViewHolder(binding, onSessionClick, onSessionLongClick, ::isSelected)
    }

    override fun onBindViewHolder(holder: SessionViewHolder, position: Int) {
        holder.bind(getItem(position), selectionMode)
    }

    class SessionViewHolder(
        private val binding: ItemInventoryCountSessionBinding,
        private val onSessionClick: (SessionWithCount) -> Unit,
        private val onSessionLongClick: (SessionWithCount) -> Boolean,
        private val isSelected: (Long) -> Boolean
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(sessionWithCount: SessionWithCount, selectionMode: Boolean) {
            val session = sessionWithCount.session
            val itemCount = sessionWithCount.itemCount
            
            binding.sessionName.text = session.name
            binding.sessionStatus.text = session.status
            binding.sessionItemCount.text = "$itemCount items"
            
            // Format dates
            val dateFormat = SimpleDateFormat("MMM d, yyyy", Locale.getDefault())
            binding.sessionDate.text = "Created on ${dateFormat.format(Date(session.createdAt))}"
            
            if (session.completedAt != null) {
                binding.sessionCompletedDate.text = "Completed"
                binding.sessionCompletedDate.visibility = android.view.View.VISIBLE
            } else {
                binding.sessionCompletedDate.visibility = android.view.View.GONE
            }

            // Handle selection state
            val isItemSelected = isSelected(session.id)
            if (isItemSelected) {
                binding.root.setBackgroundColor(
                    ContextCompat.getColor(binding.root.context, R.color.selection_highlight)
                )
            } else {
                binding.root.setBackgroundColor(
                    ContextCompat.getColor(binding.root.context, R.color.card_background)
                )
            }

            binding.root.setOnClickListener {
                if (selectionMode) {
                    onSessionLongClick(sessionWithCount)
                } else {
                    onSessionClick(sessionWithCount)
                }
            }

            binding.root.setOnLongClickListener {
                onSessionLongClick(sessionWithCount)
            }
        }
    }

    private class SessionDiffCallback : DiffUtil.ItemCallback<SessionWithCount>() {
        override fun areItemsTheSame(
            oldItem: SessionWithCount,
            newItem: SessionWithCount
        ): Boolean {
            return oldItem.session.id == newItem.session.id
        }

        override fun areContentsTheSame(
            oldItem: SessionWithCount,
            newItem: SessionWithCount
        ): Boolean {
            return oldItem == newItem
        }
    }
}
