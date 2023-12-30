import { ComboboxDataRow } from "@pointotech/react-native-combobox/ComboboxDataRow"
import { ComboboxProps } from "@pointotech/react-native-combobox/ComboboxProps"
import React from "react"
import {
  requireNativeComponent,
  NativeModules,
  HostComponent,
  Platform,
} from "react-native"

const ComboboxImplementation = requireNativeComponent(
  Platform.OS === "android" ? "ComboboxImplementationAndroid" : "Combobox"
) as HostComponent<ComboboxProps>

const prepareSelectedItem = (
  selectedItem: string | ComboboxDataRow | null | undefined
): { text: string; isAvailable?: boolean } | null => {
  if (selectedItem === null || selectedItem === undefined) {
    return null
  } else {
    if (typeof selectedItem === "string") {
      return {
        text: selectedItem,
      }
    } else if (typeof selectedItem === "object") {
      if (selectedItem.text && typeof selectedItem.text === "string") {
        return {
          text: selectedItem.text,
          isAvailable: selectedItem.hasOwnProperty("isAvailable")
            ? !!selectedItem.isAvailable
            : undefined,
        }
      } else {
        throw new Error(`Selected item must have a "text" property.`)
      }
    } else {
      throw new Error(
        "Selected item must be an object, a string, null, or undefined. Value received: " +
          selectedItem
      )
    }
  }
}

export function Combobox(props: ComboboxProps) {
  const { selectedItem, ...propsWithoutSelectedItem } = props
  return (
    <ComboboxImplementation
      selectedItem={prepareSelectedItem(selectedItem)}
      {...propsWithoutSelectedItem}
    />
  )
}

export const ComboboxManager = NativeModules.Combobox
