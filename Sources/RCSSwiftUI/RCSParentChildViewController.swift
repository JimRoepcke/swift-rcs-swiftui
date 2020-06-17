
//
//  RCSParentChildViewController.swift
//
//
//  Created by Jim Roepcke on 2020-06-17.
//

import Foundation
import UIKit

open class RCSParentChildViewController: UIViewController {

  var child: Relationship?

  public init() {
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Use this method instead of `addChild`.
  public func setChildRelationship(childViewController: UIViewController) {
    // first, remove the previous child, if any
    if let child = child {
      child.child.willMove(toParent: nil)
      NSLayoutConstraint.deactivate(child.constraints)
      child.child.view.removeFromSuperview()
      child.child.removeFromParent()
      self.child = nil
    }
    let newRelationship = Relationship(parent: self, child: childViewController)

    addChild(newRelationship.child)
    view.addSubview(newRelationship.child.view)
    newRelationship.child.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(newRelationship.constraints)
    newRelationship.child.didMove(toParent: self)

    child = newRelationship
  }
}

public extension RCSParentChildViewController {

  struct Relationship {

    public let child: UIViewController
    public let constraints: [NSLayoutConstraint]

    public init(parent: UIViewController, child: UIViewController) {
      self.child = child
      self.constraints = [
        child.view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
        child.view.topAnchor.constraint(equalTo: parent.view.topAnchor),
        child.view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
        child.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor)
      ]
    }
  }

}

