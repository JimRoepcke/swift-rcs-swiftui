//
//  File.swift
//  
//
//  Created by Jim Roepcke on 2020-05-20.
//

import SwiftUI
import RCSFoundation
import ComposableArchitecture

public struct RCSCarouselView<T: Hashable & Identifiable, Content: View>: View {

  let store: RCSCarouselView.Store
  let action: (State.Item) -> Void
  let elementContent: (State.Item) -> Content

  @SwiftUI.State var xTranslation: CGFloat = 0

  public init(
    store: RCSCarouselView.Store,
    action: @escaping (State.Item) -> Void,
    elementContent: @escaping (State.Item) -> Content
  ) {
    self.store = store
    self.action = action
    self.elementContent = elementContent
  }

  public var body: some View {
    WithViewStore(store) { viewStore in
      GeometryReader { geometry in
        ZStack {
          ForEach(viewStore.state.visibleItems) { item in
            self.elementContent(item)
              .frame(width: geometry.size.width, height: geometry.size.height)
              .offset(x: geometry.size.width * CGFloat(item.offset - viewStore.state.displayed), y: 0)
              .onTapGesture(perform: {
                self.action(item)
                self.xTranslation = 0
              })
          }
          .offset(x: self.xTranslation, y: 0)
          .animation(.spring())
          .gesture(
            DragGesture()
              .onChanged { self.xTranslation = viewStore.state.dragChanged(width: geometry.size.width, value: $0) }
              .onEnded { viewStore.state.dragEndedAction($0).do(viewStore.send); self.xTranslation = 0 }
          )
        }
        .frame(width: geometry.size.width)
      }
    }
  }
}

extension RCSCarouselView.State {

  func draggingOutOfBounds(_ t: CGFloat) -> Bool {
    ((displayed == items.startIndex) && (t > 0.0))
      || ((displayed == items.endIndex - 1) && (t < 0.0))
  }

  func dragTranslation(_ t: CGFloat, width: CGFloat) -> CGFloat {
    draggingOutOfBounds(t)
      ? rubberBandedTranslation(t, width: width)
      : t
  }

  func dragChanged(width: CGFloat, value: DragGesture.Value) -> CGFloat {
    dragTranslation(value.translation.width, width: width)
  }

  func dragEndedAction(_ value: DragGesture.Value) -> RCSCarouselView.Action? {
    value.translation.width < -44.0
      ? .displayNextImage
      : value.translation.width > 44.0
      ? .displayPreviousImage
      : nil
  }
}

private func rubberBandedTranslation(_ t: CGFloat, width: CGFloat) -> CGFloat {
  t < 0
    ? max(-rubberBandedDistance(abs(t), width), t)
    : min(rubberBandedDistance(t, width), t)
}

private func rubberBandedDistance(_ t: CGFloat, _ width: CGFloat) -> CGFloat {
  log10(t) * width / 16.0
}
