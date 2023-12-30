import { StyleProp } from "react-native"

import { ComboboxDataRow } from "./ComboboxDataRow"

export type ComboboxProps = {
  itemAvailableImageName?: string
  itemNotAvailableImageName?: string
  items: (string | ComboboxDataRow)[]
  onSelectedItemChanged(event: unknown): void
  placeholder: string
  selectedItem: string | ComboboxDataRow | null
  style?: StyleProp<unknown>
}
