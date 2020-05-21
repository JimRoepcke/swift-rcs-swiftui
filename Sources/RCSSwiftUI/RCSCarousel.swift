//
//  RCSCarousel.swift
//  
//
//  Created by Jim Roepcke on 2020-05-20.
//

import Foundation
import UIKit
import RCSFoundation
import ComposableArchitecture

public extension RCSCarouselView {

  enum Action {
    case displayPreviousImage
    case displayImage(Int)
    case displayNextImage
  }

  struct State: Hashable {

    public var items: [Item]
    public var displayed: Int

    var elements: [T] {
      get { items.map { $0.element } }
      set {
        items = newValue.enumerated().map(Item.init)
        displayed = displayed |> clamp(range: elements.indices) |> or(0)
      }
    }

    public init(
      elements: [T] = [],
      displayed: Int = 0
    ) {
      let items = elements.enumerated().map(Item.init)
      self.items = items
      self.displayed = displayed |> clamp(range: items.indices) |> or(0)
    }

    public mutating func reset() {
      self = .init()
    }

    public struct Item: Hashable, Identifiable {
      public let offset: Int
      public let element: T

      public var id: T.ID { element.id }
    }

    private var visibleRange: Range<Int> {
      Range<Int>(
        uncheckedBounds: (
          lower: displayed - 2,
          upper: displayed + 3
        )
      ).clamped(to: elements.indices)
    }

    public var visibleItems: [Item] {
      Array(items[visibleRange])
    }
  }

  static func reducer() -> Reducer<State, Action, Void> {
    Reducer { state, action, _ in
      switch action {
      case .displayPreviousImage:
        state.displayed = (state.displayed - 1) |> clamp(min: 0)
        return .none
      case .displayImage(let displayed):
        state.displayed = displayed
        return .none
      case .displayNextImage:
        state.displayed = (state.displayed + 1) |> clamp(max: state.items.count - 1)
        return .none
      }
    }
  }

  typealias Store = ComposableArchitecture.Store<State, Action>
  typealias ViewStore = ComposableArchitecture.ViewStore<State, Action>
}
