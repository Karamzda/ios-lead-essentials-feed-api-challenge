//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Taras Zinchenko on 16.08.2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

class FeedImagesMapper {
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

	static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200 else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		do {
			let feedImageList = try JSONDecoder().decode(FeedImagesResponse.self, from: data)
			return .success(feedImageList.items.map({ FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }))
		} catch {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
	}
}
