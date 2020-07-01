//
//  RCSSwiftUIViews.swift
//
//
//  Created by Jim Roepcke on 2020-04-24.
//

import Foundation
import SwiftUI

public struct RCSActivityIndicator: UIViewRepresentable {

  private var isAnimating: Bool
  private let style: UIActivityIndicatorView.Style

  public init(isAnimating: Bool, style: UIActivityIndicatorView.Style) {
    self.isAnimating = isAnimating
    self.style = style
  }

  public func makeUIView(context: UIViewRepresentableContext<RCSActivityIndicator>) -> UIActivityIndicatorView {
    UIActivityIndicatorView(style: style)
  }

  public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<RCSActivityIndicator>) {
    isAnimating
      ? uiView.startAnimating()
      : uiView.stopAnimating()
  }
}

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
