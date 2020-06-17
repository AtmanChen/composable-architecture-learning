// 

import SwiftUI
import ComposableArchitecture

struct RootView: View {
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Getting started")) {
          NavigationLink(
            "Basics",
            destination: CounterDemoView(
              store: Store(
                initialState: CounterState(),
                reducer: counterReducer,
                environment: CounterEnvironment()
              )
            )
          )
          
          NavigationLink(
            "Two counters",
            destination: TwoCountersView(
              store: Store(
                initialState: TwoCountersState(),
                reducer: twoCountersReducer,
                environment: TwoCountersEnvironment()
              )
            )
          )
          
          NavigationLink(
            "Binding Basics",
            destination: BindingsBasicsView(
              store: Store(
                initialState: BindingsBasicsState(),
                reducer: bindingsBasicsReducer,
                environment: BindingsBasicsEnvironment()
              )
            )
          )
          
          NavigationLink(
            "Optional state",
            destination: OptionalBasicView(
              store: Store(
                initialState: OptionalBasicsState(),
                reducer: optionalBasicsReducer,
                environment: OptionalBasicsEnvironment()
              )
            )
          )
          
          NavigationLink(
            "Shared State",
            destination: SharedStateView(
              store: Store(
                initialState: SharedState(),
                reducer: sharedStateReducer,
                environment: ()
              )
            )
          )
        }
        
        Section(header: Text("Effects")) {
          NavigationLink(
            "Basics Effects",
            destination: EffectsBasicsView(
              store: Store(
                initialState: EffectBasicsState(),
                reducer: effectsBasicsReducer,
                environment: .live
              )
            )
          )
          
          NavigationLink(
            "Effects cancellation",
            destination: EffectsCancellationView(
              store: Store(
                initialState: EffectsCancellationState(),
                reducer: effectsCanllationReducer,
                environment: .live
              )
            )
          )
        }
      }
      .navigationBarTitle("Case studies")
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    RootView()
  }
}
