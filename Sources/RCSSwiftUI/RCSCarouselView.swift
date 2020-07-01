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
  let horizontalPadding: CGFloat?
  let action: (State.Item) -> Void
  let elementContent: (State.Item) -> Content

  @SwiftUI.State var xTranslation: CGFloat = 0

  public init(
    store: RCSCarouselView.Store,
    horizontalPadding: CGFloat?,
    action: @escaping (State.Item) -> Void,
    elementContent: @escaping (State.Item) -> Content
  ) {
    self.store = store
    self.horizontalPadding = horizontalPadding
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
      .padding(.horizontal, self.horizontalPadding)
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

//  Created by Jim Roepcke.
//  Copyright © 2020- Jim Roepcke.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//
