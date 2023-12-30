package com.pointotech.react_native

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.util.AttributeSet
import android.util.Log
import android.widget.*
import com.facebook.react.bridge.*
import com.facebook.react.uimanager.events.RCTEventEmitter

class ComboboxView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    fun setItems(itemsParam: ReadableArray?) {
        Log.d(t, "setItems $itemsParam")

        items.clear()

        for (item in convertReactBridgeListToKotlinList((itemsParam))) {

            when (item) {
                null -> {
                    items.add(ComboboxDataRow("null", null))
                }
                is Map<*, *> -> {
                    items.add(
                        ComboboxDataRow(
                            item["text"].toString(),
                            item["isAvailable"] as Boolean?
                        )
                    )
                }
                else -> {
                    items.add(ComboboxDataRow(item.toString(), null))
                }
            }
        }

        (selectItemListView.adapter as ArrayAdapter<*>).notifyDataSetChanged()
    }

    fun setPlaceholder(placeholder: String?) {
        Log.d(t, "setPlaceholder $placeholder")

        this.placeholder = placeholder ?: defaultPlaceholder
        showSelection()
    }

    fun setSelectedItem(selectedItem: ReadableMap?) {
        Log.d(t, "setSelectedItem $selectedItem")

        if (selectedItem === null) {
            this.selectedItem = null
        } else {
            this.selectedItem = convertReactBridgeMapToComboboxDataRow(selectedItem)
        }

        showSelection()
    }

    private fun setSelectedItem(selectedItem: ComboboxDataRow?) {
        this.selectedItem = selectedItem
        showSelection()
    }

    private val t = this::class.simpleName

    private val defaultPlaceholder = "Select an item"

    private var placeholder = defaultPlaceholder

    private var selectedItem: ComboboxDataRow? = null

    private val selectedItemTextView: TextView

    private val selectItemListView: ListView

    private val items = ArrayList<ComboboxDataRow>()

    init {
        // Inflate xml resource, pass "this" as the parent, we use <merge> tag in xml to avoid
        // redundant parent, otherwise a LinearLayout will be added to this LinearLayout ending up
        // with two view groups.
        val view = inflate(context, R.layout.combobox, this)

        val popupWindow = PopupWindow(context)
        selectItemListView = ListView(context)
        selectItemListView.adapter = buildListAdapter()
        selectItemListView.onItemClickListener =
            AdapterView.OnItemClickListener { _, _, position, _ ->

                setSelectedItem(selectItemListView.adapter.getItem(position) as ComboboxDataRow)

                popupWindow.dismiss()

                if (context is ReactContext) {

                    val event = Arguments.createMap()
                    val selectedItem = selectedItem
                    if (selectedItem != null) {
                        val selectedItemMap = Arguments.createMap()
                        selectedItemMap.putString("text", selectedItem.text)
                        if (selectedItem.isAvailable != null) {
                            selectedItemMap.putBoolean("isAvailable", selectedItem.isAvailable)
                        }
                        event.putMap("selectedItem", selectedItemMap)
                    }

                    context.getJSModule(RCTEventEmitter::class.java)
                        .receiveEvent(id, "onSelectedItemChanged", event)
                }
            }

        selectedItemTextView = view.findViewById(R.id.selectedItemTextView)
        selectedItemTextView.setOnClickListener {

            // If this is set to true, really bad things happen with the system UI (software
            // versions of the back/home buttons), in full-screen mode.
            // Don't set it to true for any app that needs to use this popup in full-screen mode.
            popupWindow.isFocusable = false

            popupWindow.isOutsideTouchable = true

            popupWindow.width = selectedItemTextView.width

            val isPopupBackgroundTransparent = false
            if (isPopupBackgroundTransparent) {
                popupWindow.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
            } else {
                popupWindow.setBackgroundDrawable(ColorDrawable(Color.WHITE))
                //popupWindow.setBackgroundDrawable(context.getDrawable(android.R.drawable.dialog_holo_light_frame))
            }

            popupWindow.elevation = 10f
            popupWindow.contentView = selectItemListView

            popupWindow.showAsDropDown(it, 0, 0)
        }
        showSelection()
    }

    private fun convertReactBridgeListToKotlinList(readableArray: ReadableArray?): List<Any?> {
        val result = ArrayList<Any?>()
        if (readableArray != null) {
            for (i in 0 until readableArray.size()) {
                val type: ReadableType? = readableArray.getType(i)
                if (type == null) {
                    throw NotImplementedError("ReadableArray must specify a type for each value in convertReactBridgeListToNormalList")
                } else {
                    result.add(convertReactBridgeValueToKotlinValue(readableArray, i, type))
                }
            }
        }
        return result
    }

    private fun convertReactBridgeMapToComboboxDataRow(readableMap: ReadableMap?): ComboboxDataRow? {
        return if (readableMap === null) {
            null
        } else {
            val map = convertReactBridgeMapToKotlinMap(readableMap)

            ComboboxDataRow(map["text"] as String, map["isAvailable"] as Boolean?)
        }
    }

    private fun convertReactBridgeValueToKotlinValue(
        readableArray: ReadableArray,
        i: Int,
        type: ReadableType
    ): Any? {
        return when (type) {
            ReadableType.Null -> null
            ReadableType.Boolean -> readableArray.getBoolean(i)
            ReadableType.Number -> readableArray.getDouble(i)
            ReadableType.String -> readableArray.getString(i)
            ReadableType.Map -> convertReactBridgeMapToKotlinMap(readableArray.getMap(i))
            ReadableType.Array -> convertReactBridgeListToKotlinList(readableArray.getArray(i))
        }
    }

    private fun convertReactBridgeValueToKotlinValue(
        readableArray: ReadableMap,
        key: String,
        type: ReadableType
    ): Any? {
        return when (type) {
            ReadableType.Null -> null
            ReadableType.Boolean -> readableArray.getBoolean(key)
            ReadableType.Number -> readableArray.getDouble(key)
            ReadableType.String -> readableArray.getString(key)
            ReadableType.Map -> convertReactBridgeMapToKotlinMap(readableArray.getMap(key))
            ReadableType.Array -> convertReactBridgeListToKotlinList(readableArray.getArray(key))
        }
    }

    private fun convertReactBridgeMapToKotlinMap(readableMap: ReadableMap?): Map<String, Any?> {
        val result = HashMap<String, Any?>()
        if (readableMap != null) {
            val keysIterator = readableMap.keySetIterator()
            while (keysIterator.hasNextKey()) {
                val key = keysIterator.nextKey()
                val type: ReadableType? = readableMap.getType(key)
                if (type == null) {
                    throw NotImplementedError("ReadableMap must specify a type for each value in convertReactBridgeMapToKotlinMap")
                } else {
                    result[key] = convertReactBridgeValueToKotlinValue(readableMap, key, type)
                }
            }
        }
        return result
    }

    private fun showSelection() {
        Log.d(t, "showSelection")

        val selectedItem = selectedItem
        if (selectedItem == null) {
            Log.d(t, "showSelection selected item is null")
            selectedItemTextView.text = placeholder
        } else {
            Log.d(t, "showSelection selected item text: " + selectedItem.text)
            selectedItemTextView.text = selectedItem.text
        }
    }

    private fun buildListAdapter(): ComboboxViewArrayAdapter {

        return ComboboxViewArrayAdapter(
            context!!,
            R.layout.combobox_list_item,
            0,
            items,
            R.drawable.available,
            R.drawable.not_available
        )
    }
}