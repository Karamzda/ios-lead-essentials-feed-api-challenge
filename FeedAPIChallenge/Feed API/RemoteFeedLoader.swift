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
					let feedImageList = try JSONDecoder().decode(FeedImagesResponse.self, from: data)
					completion(.success(feedImageList.items.map({ FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) })))
				} catch {
					completion(.failure(Error.invalidData))
				}
			default:
				completion(.failure(Error.connectivity))
			}
		}
	}

	private struct NetworkFeedImage: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL

		private enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}

	private struct FeedImagesResponse: Decodable {
		let items: [NetworkFeedImage]
	}
}
