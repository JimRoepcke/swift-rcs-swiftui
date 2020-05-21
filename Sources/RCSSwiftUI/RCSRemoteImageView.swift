//
//  File.swift
//  
//
//  Created by Jim Roepcke on 2020-05-20.
//

import Foundation
import SwiftUI

public struct RCSRemoteImageView<EmptyContent: View, ErrorContent: View>: View {

  @ObservedObject var remoteImage: RCSRemoteImage

  let emptyContent: () -> EmptyContent
  let errorContent: (Error) -> ErrorContent

  public init(
    remoteImage: RCSRemoteImage,
    empty: @escaping () -> EmptyContent,
    error: @escaping (Error) -> ErrorContent
    ) {
    self.remoteImage = remoteImage
    self.emptyContent = empty
    self.errorContent = error
  }

  public var body: some View {
    Group {
      if !remoteImage.value.received {
        self.emptyContent()
      } else if remoteImage.value.image == nil {
        if remoteImage.value.error == nil {
          self.emptyContent()
        } else {
          self.errorContent(remoteImage.value.error!)
        }
      } else {
        Image(uiImage: remoteImage.value.image ?? UIImage())
          .resizable()
          .scaledToFit()
          .clipped()
      }
    }
  }
}
