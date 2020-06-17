// 

import SwiftUI
import ComposableArchitecture
import Combine

private let readMe = """
  This screen demonstrates how one can cancel in-flight effects in the Composable Architecture.

  Use the stepper to count to a number, and then tap the "Number fact" button to fetch \
  a random fact about that number using an API.

  While the API request is in-flight, you can tap "Cancel" to cancel the effect and prevent \
  it from feeding data back into the application. Interacting with the stepper while a \
  request is in-flight will also cancel it.
  """

struct EffectsCancellationState: Equatable {
  var count: Int = 0
  var trivial: String?
  var isRequesting: Bool = false
}

enum EffectsCancellationAction: Equatable {
  case cancelButtonTapped
  case stepperValueChanged(Int)
  case trivialButtonTapped
  case trivialResponse(Result<String, TrivialApiError>)
}

struct TrivialApiError: Error, Equatable {}

struct EffectsCancellationEnvironment {
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var trivia: (Int) -> Effect<String, TrivialApiError>
  
  static let live = EffectsCancellationEnvironment(
    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
    trivia: live(for:)
  )
}

let effectsCanllationReducer = Reducer<
  EffectsCancellationState, EffectsCancellationAction, EffectsCancellationEnvironment
> { state, action, environment in
  struct TrivialRequestId: Hashable {}
  switch action {
  case .cancelButtonTapped:
    state.isRequesting = false
    state.trivial = nil
    return .cancel(id: TrivialRequestId())
    
  case let .stepperValueChanged(step):
    state.count = step
    state.isRequesting = false
    state.trivial = nil
    return .cancel(id: TrivialRequestId())
    
  case .trivialButtonTapped:
    state.isRequesting = true
    state.trivial = nil
    return environment.trivia(state.count)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(EffectsCancellationAction.trivialResponse)
      .cancellable(id: TrivialRequestId())
    
  case let .trivialResponse(.success(trivial)):
    state.isRequesting = false
    state.trivial = trivial
    return .none
    
  case .trivialResponse(.failure):
    state.isRequesting = false
    return .none
  }
}

struct EffectsCancellationView: View {
  let store: Store<EffectsCancellationState, EffectsCancellationAction>
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Form {
        Section(
          header: Text(readMe),
          footer: Button("Number facts provided by numbersapi.com") {
            UIApplication.shared.open(URL(string: "http://numbersapi.com")!)
          }
        ) {
          Stepper(
            value: viewStore.binding(
              get: { $0.count },
              send: EffectsCancellationAction.stepperValueChanged
            )
          ) {
            Text("\(viewStore.count)")
          }
          
          if viewStore.isRequesting {
            HStack {
              Button("Cancel") { viewStore.send(.cancelButtonTapped) }
              Spacer()
              ActivityIndicator()
            }
          } else {
            Button("Number fact") { viewStore.send(.trivialButtonTapped) }
          }
          
          viewStore.trivial.map {
            Text($0)
              .padding([.top, .bottom], 8)
          }
        }
      }
      .navigationBarTitle("Effects cancellation")
    }
  }
}

private func live(for n: Int) -> Effect<String, TrivialApiError> {
  URLSession.shared
    .dataTaskPublisher(for: URL(string: "http://numbersapi.com/\(n)/trivia")!)
    .map { data, _ in String(decoding: data, as: UTF8.self) }
    .catch { _ in
      Just("\(n) is a good number brent")
        .delay(for: 1, scheduler: DispatchQueue.main)
    }
    .mapError { _ in TrivialApiError() }
    .eraseToEffect()
}
