# Pointotech React Native Combobox

## Install

### Yarn installation

```bash
yarn add @pointotech/react-native-combobox@latest
```

### NPM installation

```bash
npm install @pointotech/react-native-combobox@latest
```

## Create JavaScript wrapper for the native component

Put this code in a `Combobox.tsx` file in your project:

```tsx
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
  selectedItem: string | ComboboxDataRow | null
): { text: string; isAvailable?: boolean } | null => {
  if (selectedItem === null) {
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
        "Selected item must be an object or a string. Value received: " +
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
```

## Use

Import the Combobox component from your `Combobox.tsx` file, and use it in your app's UI:

```tsx
import { Combobox } from "./src/Combobox"

export const App = () => {
  return (
    <Combobox
      style={{ height: 100 }}
      items={[
        "foo",
        "bar",
        "qux",
        { text: "hello world", isAvailable: true },
        "narf",
      ]}
      selectedItem="hello world"
      placeholder="Pick a nonsense, please! Or don't."
      onSelectedItemChanged={(event) => {
        if (!event) {
          throw new Error("onSelectedItemChanged event is null.")
        }
        if (!(event instanceof Object)) {
          throw new Error("onSelectedItemChanged event is not an object.")
        }
        if (event.hasOwnProperty("nativeEvent")) {
          const nativeEvent = (event as { nativeEvent: unknown }).nativeEvent

          if (nativeEvent.hasOwnProperty("selectedItem")) {
            const selectedItem = (nativeEvent as { selectedItem: unknown })
              .selectedItem

            if (selectedItem && typeof selectedItem === "object") {
              if (selectedItem.hasOwnProperty("text")) {
                console.log(
                  "onSelectedItemChanged text " +
                    (selectedItem as { text: unknown }).text
                )
              } else {
                throw new Error("onSelectedItemChanged text not defined")
              }

              if (selectedItem.hasOwnProperty("isAvailable")) {
                console.log(
                  "onSelectedItemChanged isAvailable " +
                    (selectedItem as { isAvailable: unknown }).isAvailable
                )
              } else {
                console.log("onSelectedItemChanged isAvailable not defined")
              }
            }
          } else {
            throw new Error(
              'onSelectedItemChanged native event has no "selectedItem" property.'
            )
          }
        } else {
          throw new Error(
            'onSelectedItemChanged event has no "nativeEvent" property.'
          )
        }
      }}
    />
  )
}
```
