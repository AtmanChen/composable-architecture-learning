
import SwiftUI

struct ActivityIndicator: View {
  var body: some View {
    UIViewRepresented(makeUIView: { _ in
      let view = UIActivityIndicatorView()
      view.startAnimating()
      return view
    })
  }
}

struct UIViewRepresented<UIViewType>: UIViewRepresentable where UIViewType: UIView {
  let makeUIView: (Context) -> UIViewType
  let updateUIView: (UIViewType, Context) -> Void = { _, _ in }

  func makeUIView(context: Context) -> UIViewType {
    self.makeUIView(context)
  }

  func updateUIView(_ uiView: UIViewType, context: Context) {
    self.updateUIView(uiView, context)
  }
}
