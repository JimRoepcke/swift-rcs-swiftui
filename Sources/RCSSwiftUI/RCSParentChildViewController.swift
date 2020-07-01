
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
