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
