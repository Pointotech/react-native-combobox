package com.pointotech.react_native;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.Map;

public class ComboboxViewManager extends SimpleViewManager<ComboboxView> {

    @NonNull
    @Override
    public String getName() {
        return "ComboboxImplementationAndroid";
    }

    @NonNull
    @Override
    public ComboboxView createViewInstance(@NonNull ThemedReactContext context) {
        return new ComboboxView(context);
    }

    @ReactProp(name = "items")
    public void setItems(ComboboxView view, @Nullable ReadableArray items) {

        view.setItems(items);
    }

    @ReactProp(name = "placeholder")
    public void setPlaceholder(ComboboxView view, @Nullable String placeholder) {

        view.setPlaceholder(placeholder);
    }

    @ReactProp(name = "selectedItem")
    public void setSelectedItem(ComboboxView view, @Nullable ReadableMap selectedItem) {

        view.setSelectedItem(selectedItem);
    }

    @Nullable
    @Override
    public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.<String, Object>builder()
                .put("onSelectedItemChanged",
                        MapBuilder.of("registrationName", "onSelectedItemChanged"))
                .build();
    }
}