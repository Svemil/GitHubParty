//
//  Profiles.swift
//  PARTY ORGANIZER
//
//  Created by Svemil Djusic on 09/01/2021.
//

import Foundation

var arrayOfMembers: [Profile] = []

struct Profile: Decodable {
    let id: Int?
    let username: String?
    let cell: String?
    let photo: String?
    let email: String?
    let gender: String?
    let aboutMe: String?
}
