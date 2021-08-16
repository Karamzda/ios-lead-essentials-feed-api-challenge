//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((_, httpURLResponse)) where httpURLResponse.statusCode != 200:
				completion(.failure(Error.invalidData))
			case let .success((data, _)):
				do {
					_ = try JSONDecoder().decode([String: [String]].self, from: data)
					completion(.success([]))
				} catch {
					completion(.failure(Error.invalidData))
				}
			default:
				completion(.failure(Error.connectivity))
			}
		}
	}
}
