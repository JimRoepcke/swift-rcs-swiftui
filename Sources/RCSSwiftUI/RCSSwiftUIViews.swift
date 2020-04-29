//
//  RCSSwiftUIViews.swift
//
//
//  Created by Jim Roepcke on 2020-04-24.
//

import Foundation
import SwiftUI

public struct RCSPageControl: UIViewRepresentable {

  private let numberOfPages: Int
  private let currentPage: Int
  private let tintColor: UIColor
  private let currentPageTintColor: UIColor

  public init(numberOfPages: Int, currentPage: Int, tintColor: UIColor, currentPageTintColor: UIColor) {
    self.numberOfPages = numberOfPages
    self.currentPage = currentPage
    self.tintColor = tintColor
    self.currentPageTintColor = currentPageTintColor
  }

  public func makeUIView(context: Context) -> UIPageControl {
    let control = UIPageControl()
    control.numberOfPages = numberOfPages
    control.currentPage = currentPage
    control.pageIndicatorTintColor = tintColor
    control.currentPageIndicatorTintColor = currentPageTintColor
    return control
  }

  public func updateUIView(_ uiView: UIPageControl, context: Context) {
    uiView.currentPage = currentPage
  }
}

public struct RCSUnwrapView<Some: View, None: View>: View {

  private let some: () -> Some?
  private let none: () -> None?

  public init<Value>(
    value: Value?,
    none: @escaping () -> None,
    some: @escaping (Value) -> Some
  ) {
    self.none = { value == nil ? none() : nil }
    self.some = { value.map(some) }
  }

  public var body: some View {
    Group {
      none()
      some()
    }
  }
}

public extension View {
  func rcsMaybeLineSpacing(_ spacing: CGFloat?) -> some View {
    RCSUnwrapView(
      value: spacing,
      none: { self },
      some: { spacing in self.lineSpacing(spacing) }
    )
  }
}

public struct RCSMaybeValueReader<A, ValueContent: View, EmptyContent: View>: View {
  let value: A?
  let valueContent: (A) -> ValueContent
  let emptyContent: () -> EmptyContent

  public init(_ value: A?, value valueContent: @escaping (A) -> ValueContent, empty emptyContent: @escaping () -> EmptyContent) {
    self.value = value
    self.valueContent = valueContent
    self.emptyContent = emptyContent
  }

  @ViewBuilder
  public var body: some View {
    if value != nil {
      valueContent(value!)
    } else {
      emptyContent()
    }
  }
}

public struct RCSValueReader<A, V: View>: View {
  let value: () -> A
  let content: (A) -> V

  public init(_ value: @escaping @autoclosure () -> A, content: @escaping (A) -> V) {
    self.value = value
    self.content = content
  }

  public var body: some View {
    content(value())
  }
}

public struct RCSTwoValueReader<A, B, V: View>: View {
  let first: () -> A
  let second: () -> B
  let content: (A, B) -> V

  public init(
    _ first: @escaping @autoclosure () -> A,
    _ second: @escaping @autoclosure () -> B,
    content: @escaping (A, B) -> V
  ) {
    self.first = first
    self.second = second
    self.content = content
  }

  public var body: some View {
    content(first(), second())
  }
}
