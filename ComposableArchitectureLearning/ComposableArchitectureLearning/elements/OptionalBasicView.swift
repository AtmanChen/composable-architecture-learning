// 

import SwiftUI
import ComposableArchitecture

private let readMe = """
This screen demonstrates how to show and hide views based on the presence of some optional child \
state.

The parent state holds a `CounterState?` value. When it is `nil` we will default to a plain text \
view. But when it is non-`nil` we will show a view fragment for a counter that operates on the \
non-optional counter state.

Tapping "Toggle counter state" will flip between the `nil` and non-`nil` counter states.
"""

struct OptionalBasicsState: Equatable {
  var optionalCounter: CounterState?
}

enum OptionalBasicsAction: Equatable {
  case optionalCounter(CounterAction)
  case toggleCounterButtonTapped
}

struct OptionalBasicsEnvironment {}

let optionalBasicsReducer = Reducer<
  OptionalBasicsState, OptionalBasicsAction, OptionalBasicsEnvironment
>.combine(
  Reducer { state, action, environment in
    switch action {
    case .toggleCounterButtonTapped:
      state.optionalCounter =
        state.optionalCounter == nil
        ? CounterState()
        : nil
      return .none
    case .optionalCounter:
      return .none
    }
  },
  counterReducer.optional.pullback(
    state: \.optionalCounter,
    action: /OptionalBasicsAction.optionalCounter,
    environment: { _ in CounterEnvironment() }
  )
)

struct OptionalBasicView: View {
  let store: Store<OptionalBasicsState, OptionalBasicsAction>
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Form {
        Section(header: Text(readMe).font(.caption)) {
          Button("Toggle counter state") {
            viewStore.send(.toggleCounterButtonTapped)
          }
          IfLetStore(
            self.store.scope(state: \.optionalCounter, action: OptionalBasicsAction.optionalCounter),
            then: { store in
              VStack(alignment: .leading, spacing: 16) {
                Text("`CounterState` is non-`nil`").font(.body)
                CounterView(store: store)
                  .buttonStyle(BorderlessButtonStyle())
              }
            },
            else: Text("`CounterState` is non-`nil`").font(.body)
          )
        }
      }
    }
    .navigationBarTitle("Optional state")
  }
}
