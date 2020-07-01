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
