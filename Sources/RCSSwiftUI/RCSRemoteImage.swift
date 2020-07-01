//
//  File.swift
//  
//
//  Created by Jim Roepcke on 2020-05-20.
//

import Foundation
import UIKit
import Combine

public final class RCSRemoteImage: ObservableObject {

  public struct Value {
    public fileprivate(set) var image: UIImage?
    public fileprivate(set) var error: Error?
    public fileprivate(set) var received: Bool = false
  }

  public let url: URL
  private let fetcher: (URL) -> AnyPublisher<UIImage, Error>
  private var cancellable: AnyCancellable?

  public var objectWillChange: AnyPublisher<Value, Never> = Publishers.Sequence<[Value], Never>(sequence: [Value()]).eraseToAnyPublisher()

  @Published public private(set) var value: Value = .init()

  public init(
    url: URL,
    fetcher: @escaping (URL) -> AnyPublisher<UIImage, Error> = RCSRemoteImage.imagePublisher
  ) {
    self.url = url
    self.fetcher = fetcher
    self.objectWillChange = self.$value
      .handleEvents(
        receiveSubscription: { [weak self] _ in
          // print("RemoteImage value subscribed to")
          self?.loadImage()
        },
        receiveCancel: { [weak self] in
          // print("RemoteImage value subscription cancelled")
          self?.cancellable?.cancel()
      })
      .eraseToAnyPublisher()
  }

  private func loadImage() {
    guard value.image == nil else {
      return
    }
    // print("RemoteImage fetching image")
    cancellable = fetcher(url)
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          if case .failure(let error) = completion {
            // print("RemoteImage failed")
            self?.value.image = nil
            self?.value.error = error
            self?.value.received = true
          }
          self?.cancellable = nil
        },
        receiveValue: { [weak self] image in
          // print("RemoteImage received image")
          self?.value.image = image
          self?.value.error = nil
          self?.value.received = true
          self?.cancellable = nil
        }
    )
  }

  deinit {
    cancellable?.cancel()
  }


  public enum ImagePublisherError: Error {
    case responseBodyIsNotAValidImage(URLResponse)
  }

  public static func imagePublisher(for url: URL) -> AnyPublisher<UIImage, Error> {
    return URLSession.shared.dataTaskPublisher(for: url)
      //.breakpointOnError()
      .mapError { $0 as Error }
      .flatMap { data, response -> AnyPublisher<UIImage, Error> in
        // print("dataTaskPublisher received response")
        return UIImage(data: data)
          .map { Just($0).setFailureType(to: Error.self).eraseToAnyPublisher() }
          ?? Fail(outputType: UIImage.self, failure: ImagePublisherError.responseBodyIsNotAValidImage(response) as Error).eraseToAnyPublisher()
    }
    .eraseToAnyPublisher()
  }
}

public extension RCSRemoteImage {

  typealias Cache = NSCache<NSURL, RCSRemoteImage>

  static func cached(
    for url: URL,
    in cache: Cache,
    fetcher: @escaping (URL) -> AnyPublisher<UIImage, Error>
  ) -> RCSRemoteImage {
    guard let it = cache.object(forKey: url as NSURL) else {
      let it = RCSRemoteImage(url: url, fetcher: fetcher)
      // TODO: figure out a cost for the `RemoteImage`
      cache.setObject(it, forKey: url as NSURL)
      return it
    }
    return it
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
