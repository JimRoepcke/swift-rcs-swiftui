//
//  RCSUITabBar.swift
//
//
//  Created by Jim Roepcke on 2020-06-17.
//

import Foundation
import Combine
import UIKit
import SwiftUI
import ComposableArchitecture
import RCSFoundation

public enum RCSUITabBar {

  public struct State: Equatable {
    public var selectedTabIndex: Int

    public init(selectedTabIndex: Int) {
      self.selectedTabIndex = selectedTabIndex
    }
  }

  public enum Action {
    case selectTabByIndex(Int)
  }
}

open class RCSUITabBarDelegate: NSObject {

  public weak var controller: UITabBarController?
  let viewStore: ViewStore<RCSUITabBar.State, RCSUITabBar.Action>
  var sendingSelectTabIntoState = false

  init(controller: UITabBarController, viewStore: ViewStore<RCSUITabBar.State, RCSUITabBar.Action>) {
    self.controller = controller
    self.viewStore = viewStore
  }

  func accept(selectedTabIndex: Int) {
    // print(#function, "LOG:", "INFO:", "selectedTab: \(selectedTab)")
    guard !sendingSelectTabIntoState // otherwise we're synchronizing a user action, ignore
      else { return }

    // print(#function, "LOG:", "INFO:", "updating selectedIndex to \(selectedTabIndex)")
    controller?.selectedIndex = selectedTabIndex
  }
}

public extension RCSUITabBar {

  private enum Keys: String, RCSCancellableKey {
    case selectedTab
  }

  /// The returned `UITabBarController` reacts to changes to:
  /// - `RCSUITabBar.State.selectedTabIndex`.
  static func make(viewStore: ViewStore<RCSUITabBar.State, RCSUITabBar.Action>, viewControllers: [UIViewController]) -> UITabBarController {
    let selectedTab = viewStore.state.selectedTabIndex
    let it = UITabBarController()
    let tabBarDelegate = RCSUITabBarDelegate(controller: it, viewStore: viewStore)
    it.delegate = tabBarDelegate
    it.setViewControllers(viewControllers, animated: false)
    it.selectedIndex = selectedTab

    /// Listen to changes in `RCSUITabBar.State` and update `it` accordingly.
    /// This explicitly retains the `tabBarDelegate`, because `it` won't.
    /// Using `dropFirst` because `publisher` immediately emits the current
    /// `RCSUITabBar.State` and we only want changes.
    it[rcsCancellableKey: Keys.selectedTab] = viewStore.publisher
      .map(\.selectedTabIndex)
      .dropFirst()
      .removeDuplicates()
      .sink(receiveValue: tabBarDelegate.accept(selectedTabIndex:))
    return it
  }
}

extension RCSUITabBarDelegate: UITabBarControllerDelegate {

  /// When the user changes the tab by tapping on it, update the `RCSUITabBar.State`
  /// accordingly. According to my testing, this will not be called when
  /// `selectedIndex` is set programmatically.
  public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

    let tab = viewController.tabBarItem!.tag

    self.sendingSelectTabIntoState = true
    viewStore.send(.selectTabByIndex(tab))
    self.sendingSelectTabIntoState = false

    return viewStore.state.selectedTabIndex == tab
  }
}
