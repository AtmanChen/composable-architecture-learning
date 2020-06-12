// 

import SwiftUI
import ComposableArchitecture

private let readMe = """
This screen demonstrates how to take small features and compose them into bigger ones using the \
`pullback` and `combine` operators on reducers, and the `scope` operator on stores.

It reuses the the domain of the counter screen and embeds it, twice, in a larger domain.
"""

struct TwoCountersState: Equatable {
  var counter1 = CounterState()
  var counter2 = CounterState()
}

enum TwoCountersAction: Equatable {
  case counter1(CounterAction)
  case counter2(CounterAction)
}

struct TwoCountersEnvironment {}

let twoCountersReducer = Reducer<
  TwoCountersState, TwoCountersAction, TwoCountersEnvironment
>.combine(
  counterReducer.pullback(
    state: \.counter1,
    action: /TwoCountersAction.counter1,
    environment: { _ in CounterEnvironment() }
  ),
  counterReducer.pullback(
    state: \.counter2,
    action: /TwoCountersAction.counter2,
    environment: { _ in CounterEnvironment() }
  )
)

struct TwoCountersView: View {
  let store: Store<TwoCountersState, TwoCountersAction>
  var body: some View {
    Form {
      Section(header: Text(readMe).font(.caption)) {
        HStack {
          Text("Counter 1")
          CounterView(
            store: self.store.scope(state: \.counter1, action: TwoCountersAction.counter1)
          )
          .buttonStyle(BorderlessButtonStyle())
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        }
        HStack {
          Text("Counter 2")
          CounterView(
            store: self.store.scope(state: \.counter2, action: TwoCountersAction.counter2)
          )
          .buttonStyle(BorderlessButtonStyle())
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        }
      }
    }
    .navigationBarTitle("Two counter demo")
  }
}

