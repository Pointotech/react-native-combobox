import React from "react"
import {
  SafeAreaView,
  StyleSheet,
  ScrollView,
  View,
  Text,
  StatusBar,
} from "react-native"
import { Colors } from "react-native/Libraries/NewAppScreen"

import { Combobox } from "./src/Combobox"

/*
import { NativeModules } from 'react-native'
const Toast = NativeModules.Toast
Toast.hi(
  'The lighthouse beckons. Will you answer its dark summons?',
  (finalMessage) => {
    console.log(finalMessage)
  },
)
*/

const App = () => {
  return (
    <>
      <StatusBar barStyle="dark-content" />
      <SafeAreaView>
        <ScrollView
          contentInsetAdjustmentBehavior="automatic"
          style={styles.scrollView}>
          <Text>Demo App for Pointotech React Native Combobox</Text>
          <View style={styles.body}>
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
                  throw new Error(
                    "onSelectedItemChanged event is not an object."
                  )
                }
                if (event.hasOwnProperty("nativeEvent")) {
                  const nativeEvent = (event as { nativeEvent: unknown })
                    .nativeEvent

                  if (nativeEvent.hasOwnProperty("selectedItem")) {
                    const selectedItem = (
                      nativeEvent as { selectedItem: unknown }
                    ).selectedItem

                    if (selectedItem && typeof selectedItem === "object") {
                      if (selectedItem.hasOwnProperty("text")) {
                        console.log(
                          "onSelectedItemChanged text " +
                            (selectedItem as { text: unknown }).text
                        )
                      } else {
                        throw new Error(
                          "onSelectedItemChanged text not defined"
                        )
                      }

                      if (selectedItem.hasOwnProperty("isAvailable")) {
                        console.log(
                          "onSelectedItemChanged isAvailable " +
                            (selectedItem as { isAvailable: unknown })
                              .isAvailable
                        )
                      } else {
                        console.log(
                          "onSelectedItemChanged isAvailable not defined"
                        )
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
          </View>
        </ScrollView>
      </SafeAreaView>
    </>
  )
}

const styles = StyleSheet.create({
  scrollView: {
    backgroundColor: Colors.lighter,
  },
  engine: {
    position: "absolute",
    right: 0,
  },
  body: {
    backgroundColor: Colors.white,
  },
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: "600",
    color: Colors.black,
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: "400",
    color: Colors.dark,
  },
  highlight: {
    fontWeight: "700",
  },
  footer: {
    color: Colors.dark,
    fontSize: 12,
    fontWeight: "600",
    padding: 4,
    paddingRight: 12,
    textAlign: "right",
  },
})

export default App
