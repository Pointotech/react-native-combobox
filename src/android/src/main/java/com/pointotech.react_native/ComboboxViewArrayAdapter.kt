package com.pointotech.react_native

import android.content.Context
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.ImageView
import android.widget.TextView
import androidx.annotation.DrawableRes
import androidx.annotation.IdRes
import androidx.annotation.LayoutRes

class ComboboxViewArrayAdapter(context: Context,
                               @LayoutRes private val layoutResource: Int,
                               @IdRes private val textViewResourceId: Int = 0,
                               values: List<ComboboxDataRow>,
                               @DrawableRes private val itemAvailableImageName: Int,
                               @DrawableRes private val itemNotAvailableImageName: Int) : ArrayAdapter<ComboboxDataRow>(context, layoutResource, values) {

    override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
        val view = createViewFromResource(convertView, parent, layoutResource)

        return bindData(getItem(position), view)
    }

    override fun getDropDownView(position: Int, convertView: View?, parent: ViewGroup): View {
        val view = createViewFromResource(convertView, parent, android.R.layout.simple_spinner_dropdown_item)

        return bindData(getItem(position), view)
    }

    private fun createViewFromResource(convertView: View?, parent: ViewGroup, layoutResource: Int): ViewGroup {
        val context = parent.context
        val view = convertView
                ?: LayoutInflater.from(context).inflate(layoutResource, parent, false)
        return try {
            if (textViewResourceId == 0) view as ViewGroup
            else {
                view.findViewById(textViewResourceId)
                        ?: throw RuntimeException("Failed to find view with ID " +
                                "${context.resources.getResourceName(textViewResourceId)} in item layout")
            }
        } catch (ex: ClassCastException) {
            Log.e("CustomArrayAdapter", "You must supply a resource ID for a ViewGroup")
            throw IllegalStateException(
                    "ArrayAdapter requires the resource ID to be a ViewGroup", ex)
        }
    }

    private fun bindData(value: ComboboxDataRow?, view: ViewGroup): ViewGroup {
        val availabilityImageView = view.findViewById<ImageView>(R.id.availabilityImageView)
        if (value?.isAvailable == null) {
            availabilityImageView.visibility = View.GONE
            availabilityImageView.setImageDrawable(null)
        } else {
            availabilityImageView.visibility = View.VISIBLE
            availabilityImageView.setImageResource(if (value.isAvailable) itemAvailableImageName else itemNotAvailableImageName)
        }
        val textView1 = view.findViewById<TextView>(android.R.id.text1)
        textView1.text = value?.text ?: "null"
        return view
    }
}