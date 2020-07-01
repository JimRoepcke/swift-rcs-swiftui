//
//  RCSUIHostingNavigationController.swift
//
//
//  Created by Jim Roepcke on 2020-06-19.
//

import Foundation
import UIKit
import SwiftUI
import ComposableArchitecture
import RCSFoundation

/// This class was made because `UIHostingController` messes with the
/// visibility of its `navigationController`'s `UINavigationBar`.
/// This view controller prevents that.
///
/// Instances will also support the edge swipe back gesture.
open class RCSUIHostingNavigationController: UINavigationController {
  public var preventChangesToNavigationBarHidden = false
  public private(set) var synchronizingUserNavigation = false

  public init<Content: View>(
    rootViewController: UIHostingController<Content>
  ) {
    super.init(rootViewController: rootViewController)
    self.delegate = self
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override open func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    interactivePopGestureRecognizer?.delegate = self
  }

  override open func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
    guard !preventChangesToNavigationBarHidden
      else { return }
    super.setNavigationBarHidden(hidden, animated: animated)
  }

  open func synchronizeUserNavigation(didShow viewController: UIViewController, animated: Bool) {

  }
}

extension RCSUIHostingNavigationController: UINavigationControllerDelegate {

  open func navigationController(
    _ navigationController: UINavigationController,
    didShow viewController: UIViewController,
    animated: Bool
  ) {
    synchronizingUserNavigation = true
    synchronizeUserNavigation(didShow: viewController, animated: animated)
    synchronizingUserNavigation = false
  }
}

extension RCSUIHostingNavigationController: UIGestureRecognizerDelegate {

  open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    true
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
