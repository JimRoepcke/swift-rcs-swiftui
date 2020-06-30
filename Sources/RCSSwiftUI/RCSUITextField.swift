//
//  RCSUITextField.swift
//
//
//  Created by Jim Roepcke on 2020-06-06.
//

import Foundation
import UIKit
import SwiftUI
import ComposableArchitecture

public struct RCSUITextField: UIViewRepresentable {

  public struct State: Hashable {
    public var text: String

    public enum FirstResponderStatus {
      case inactive
      case becomingActive
      case active
      case becomingInactive
    }
    public var firstResponderStatus: FirstResponderStatus

    public init(text: String) {
      self.text = text
      self.firstResponderStatus = .inactive
    }
  }

  public enum Action {
    case becomeFirstResponder
    case resignFirstResponder
    case firstResponderStatusChanged(State.FirstResponderStatus)
    case textChanged(String)
  }

  public static let reducer: Reducer<State, Action, Void> = .init { state, action, _ -> Effect<Action, Never> in
    switch action {
    case .becomeFirstResponder:
      state.firstResponderStatus = .becomingActive
      return .none
    case .resignFirstResponder:
      state.firstResponderStatus = .becomingInactive
      return .none
    case .firstResponderStatusChanged(let status):
      state.firstResponderStatus = status
    case .textChanged(let it):
      state.text = it
    }
    return .none
  }
  public static let debugReducer = reducer.debug()

  @ObservedObject var viewStore: ViewStore<State, Action>

  let isSecureTextEntry: Bool
  let font: UIFont?
  let placeholder: String?
  let borderStyle: BorderStyle
  let keyboardType: UIKeyboardType?
  let autocapitalization: UITextAutocapitalizationType?
  let autocorrection: UITextAutocorrectionType?

  public init(
    viewStore: ViewStore<State, Action>,
    isSecureTextEntry: Bool = false,
    font: UIFont?,
    placeholder: String?,
    borderStyle: BorderStyle = .none,
    keyboardType: UIKeyboardType? = nil,
    autocapitalization: UITextAutocapitalizationType? = nil,
    autocorrection: UITextAutocorrectionType? = nil
  ) {
    self.viewStore = viewStore
    self.isSecureTextEntry = isSecureTextEntry
    self.font = font
    self.placeholder = placeholder
    self.borderStyle = borderStyle
    self.keyboardType = keyboardType
    self.autocapitalization = autocapitalization
    self.autocorrection = autocorrection
  }

  public enum BorderStyle {
    /// The text field does not display a border.
    case none
    /// Displays a thin rectangle around the text field.
    case line
    /// Displays a bezel-style border for the text field. This style is typically used for standard data-entry fields.
    case bezel
    /// Displays a rounded-style border for the text field.
    case roundedRect

    fileprivate var asUITextFieldBorderStyle: UITextField.BorderStyle {
      switch self {
      case .none: return .none
      case .line: return .line
      case .bezel: return .bezel
      case .roundedRect: return .roundedRect
      }
    }
  }

  class MyTextField: UITextField {

    var viewStore: ViewStore<RCSUITextField.State, RCSUITextField.Action>?

    override func becomeFirstResponder() -> Bool {
      let result = super.becomeFirstResponder()
      viewStore?.send(.firstResponderStatusChanged(result ? .active : .inactive))
      return result
    }

    override func resignFirstResponder() -> Bool {
      let result = super.resignFirstResponder()
      viewStore?.send(.firstResponderStatusChanged(result ? .active : .inactive))
      return result
    }
  }

  public func makeUIView(context: UIViewRepresentableContext<RCSUITextField>) -> UITextField {
    let textField = MyTextField()
    textField.isSecureTextEntry = self.isSecureTextEntry
    textField.viewStore = self.viewStore
    textField.borderStyle = self.borderStyle.asUITextFieldBorderStyle
    if let it = self.font {
      textField.font = it
    }
    if let it = self.keyboardType {
      textField.keyboardType = it
    }
    if let it = self.autocapitalization {
      textField.autocapitalizationType = it
    }
    if let it = self.autocorrection {
      textField.autocorrectionType = it
    }
    textField.delegate = context.coordinator
    textField.setContentHuggingPriority(
      .defaultHigh,
      for: .vertical
    )
    textField.addTarget(
      context.coordinator,
      action: #selector(Coordinator.editingChanged(_:)), for: .editingChanged
    )
    return textField
  }

  public func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<RCSUITextField>) {
    uiView.text = viewStore.state.text
    if viewStore.state.firstResponderStatus == .becomingActive, uiView.window != nil {
      DispatchQueue.main.async {
        uiView.becomeFirstResponder()
      }
    } else if viewStore.firstResponderStatus == .becomingInactive, uiView.window != nil {
      DispatchQueue.main.async {
        uiView.resignFirstResponder()
      }
    }
  }

  public func makeCoordinator() -> RCSUITextField.Coordinator {
    Coordinator(self)
  }

  public final class Coordinator: NSObject, UITextFieldDelegate {

    var control: RCSUITextField

    init(_ control: RCSUITextField) {
      self.control = control
    }

    @objc fileprivate func editingChanged(_ sender: UITextField) {
      control.viewStore.send(.textChanged(sender.text ?? ""))
    }
  }
}
