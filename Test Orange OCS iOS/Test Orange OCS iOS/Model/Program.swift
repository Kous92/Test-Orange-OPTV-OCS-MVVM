//
//  Program.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 12/09/2021.
//

import Foundation

struct Programs: Decodable {
    let template: String?
    let parentalrating: Int?
    let title: String?
    let offset: Int?
    let limit: String?
    let total, count: Int?
    let contents: [Content]?
}

// MARK: - Content
struct Content: Decodable {
    let title: [Title]?
    let subtitle: String?
    let subtitlefocus: [String]?
    let imageurl, fullscreenimageurl, id, detaillink: String?
    let duration: String?
    let playinfoid: PlayInfo?
}

// MARK: - Playinfoid
struct PlayInfo: Decodable {
    let hd, sd, uhd: String?
}

struct Title: Decodable {
    let color: String?
    let type, value: String?
}

