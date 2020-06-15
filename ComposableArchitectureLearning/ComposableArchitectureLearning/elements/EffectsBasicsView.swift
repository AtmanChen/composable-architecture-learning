// 

import SwiftUI
import ComposableArchitecture
import Combine

private let readMe = """
  This screen demonstrates how to introduce side effects into a feature built with the \
  Composable Architecture.

  A side effect is a unit of work that needs to be performed in the outside world. For example, an \
  API request needs to reach an external service over HTTP, which brings with it lots of \
  uncertainty and complexity.

  Many things we do in our applications involve side effects, such as timers, database requests, \
  file access, socket connections, and anytime a scheduler is involved (such as debouncing, \
  throttling and delaying), and they are typically difficult to test.

  This application has two simple side effects:

  • Each time you count down the number will be incremented back up after a delay of 1 second.
  • Tapping "Number fact" will trigger an API request to load a piece of trivia about that number.

  Both effects are handled by the reducer, and a full test suite is written to confirm that the \
  effects behave in the way we expect.
  """

struct EffectBasicsState: Equatable {
  var count = 0
  var isNumberFactRequestInFlight = false
  var numberFact: String?
}

enum EffectsBasicsAction: Equatable {
  case decrementButtonTapped
  case incrementButtonTapped
  case numberFactButtonTapped
  case numberFactResponse(Result<String, NumbersApiError>)
}

struct NumbersApiError: Error, Equatable {}

struct EffectsBasicsEnvironment {
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var numberFact: (Int) -> Effect<String, NumbersApiError>
  
  static let live = EffectsBasicsEnvironment(
    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
    numberFact: liveNumberFact(for:)
  )
}

let effectsBasicsReducer = Reducer<
  EffectBasicsState, EffectsBasicsAction, EffectsBasicsEnvironment
> { state, action, environment in
  switch action {
  case .decrementButtonTapped:
    state.count -= 1
    state.numberFact = nil
    return Effect(value: EffectsBasicsAction.incrementButtonTapped)
      .delay(for: 1, scheduler: environment.mainQueue)
      .eraseToEffect()
  case .incrementButtonTapped:
    state.count += 1
    state.numberFact = nil
    return .none
  case .numberFactButtonTapped:
    state.isNumberFactRequestInFlight = true
    state.numberFact = nil
    return environment.numberFact(state.count)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(EffectsBasicsAction.numberFactResponse)
  case let .numberFactResponse(.success(response)):
    state.isNumberFactRequestInFlight = false
    state.numberFact = response
    return .none
  case .numberFactResponse(.failure):
    state.isNumberFactRequestInFlight = false
    return .none
  }
}

struct EffectsBasicsView: View {
  let store: Store<EffectBasicsState, EffectsBasicsAction>
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Form {
        Section(header: Text(readMe)) {
          EmptyView()
        }
        Section(
          footer: Button("Number facts provided by numbersapi.com") {
            UIApplication.shared.open(URL(string: "http://numbersapi.com")!)
          }
        ) {
          HStack {
            Spacer()
            Button("-") { viewStore.send(.decrementButtonTapped) }
            Text("\(viewStore.count)").font(Font.body.monospacedDigit())
            Button("+") { viewStore.send(.incrementButtonTapped) }
            Spacer()
          }
          .buttonStyle(BorderlessButtonStyle())
          
          Button("number fact") { viewStore.send(.numberFactButtonTapped) }
          if viewStore.isNumberFactRequestInFlight {
            ActivityIndicator()
          }
          viewStore.numberFact.map(Text.init)
        }
      }
      .navigationBarTitle("Effect Basics")
    }
  }
}

private func liveNumberFact(for n: Int) -> Effect<String, NumbersApiError> {
  URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://numbersapi.com/\(n)/trivia")!)
    .map { data, _ in String(decoding: data, as: UTF8.self) }
    .catch { _ in
      Just("\(n) is a good number Brent")
        .delay(for: 1, scheduler: DispatchQueue.main)
    }
    .mapError { _ in NumbersApiError() }
    .eraseToEffect()
}
