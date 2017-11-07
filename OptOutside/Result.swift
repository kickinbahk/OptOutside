//
//  Result.swift
//  OptOutside
//
//  Created by Josiah Mory on 11/6/17.
//  Copyright © 2017 kickinbahk Productions. All rights reserved.
//

import Foundation

class Result: Codable {
    var name: String
    var link: String
    var image: Group_Photo?
    
    struct Group_Photo: Codable {
        var thumb_link: String
    }

}

enum CodingKeys: String, Codable {
    case name
    case link
    case image = "Group_Photo"
}
