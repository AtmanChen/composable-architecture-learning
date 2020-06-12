// 

import SwiftUI
import ComposableArchitecture

private let readMe = """
This file demonstrates how to handle two-way bindings in the Composable Architecture.

Two-way bindings in SwiftUI are powerful, but also go against the grain of the "unidirectional \
data flow" of the Composable Architecture. This is because anything can mutate the value \
whenever it wants.

On the other hand, the Composable Architecture demands that mutations can only happen by sending \
actions to the store, and this means there is only ever one place to see how the state of our \
feature evolves, which is the reducer.

Any SwiftUI component that requires a Binding to do its job can be used in the Composable \
Architecture. You can derive a Binding from your ViewStore by using the `binding` method. This \
will allow you to specify what state renders the component, and what action to send when the \
component changes, which means you can keep using a unidirectional style for your feature.
"""

struct BindingsBasicsState: Equatable {
  var sliderValue = 5.0
  var stepperValue = 10
  var text = ""
  var toggleIsOn = false
}

enum BindingsBasicsAction: Equatable {
  case sliderValueChanged(Double)
  case stepCountChanged(Int)
  case textChange(String)
  case toggleChange(isOn: Bool)
}

struct BindingsBasicsEnvironment { }

let bindingsBasicsReducer = Reducer<BindingsBasicsState, BindingsBasicsAction, BindingsBasicsEnvironment> { state, action, _ in
  switch action {
  case let .sliderValueChanged(sliderValue):
    state.sliderValue = sliderValue
  case let .stepCountChanged(stepValue):
    state.stepperValue = stepValue
  case let .textChange(textValue):
    state.text = textValue
  case let .toggleChange(isOn):
    state.toggleIsOn = isOn
  }
  return .none
}


struct BindingsBasicsView: View {
  let store: Store<BindingsBasicsState, BindingsBasicsAction>
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Form {
        Section(header: Text(readMe)) {
          HStack {
            TextField(
              "Type here",
              text: viewStore.binding(get: \.text, send: BindingsBasicsAction.textChange)
            )
              .foregroundColor(viewStore.toggleIsOn ? .gray : .primary)
            Text(alternate(viewStore.text))
          }
          .disabled(viewStore.toggleIsOn)
          
          Toggle(isOn: viewStore.binding(get: \.toggleIsOn, send: BindingsBasicsAction.toggleChange)) {
            Text("Disable other controls")
          }
          
          Stepper(
            value: viewStore.binding(get: \.stepperValue, send: BindingsBasicsAction.stepCountChanged),
            in: 0...100
          ) {
              Text("Max slider value: \(viewStore.state.stepperValue)")
                .font(Font.body.monospacedDigit())
          }
          .disabled(viewStore.toggleIsOn)
          
          HStack {
            Text("Slider value: \(Int(viewStore.sliderValue))")
              .font(Font.body.monospacedDigit())
            Slider(
              value: viewStore.binding(get: \.sliderValue, send: BindingsBasicsAction.sliderValueChanged),
              in: 0...Double(viewStore.stepperValue)
            )
          }
          .disabled(viewStore.toggleIsOn)
        }
      }
      .navigationBarTitle("Bindings basics")
    }
  }
}

private func alternate(_ string: String) -> String {
  string
    .enumerated()
    .map { idx, char in
      idx.isMultiple(of: 2)
        ? char.uppercased()
        : char.lowercased()
    }
    .joined()
}
