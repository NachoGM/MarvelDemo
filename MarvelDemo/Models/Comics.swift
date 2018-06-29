//
//  Comics.swift
//  MarvelDemo
//
//  Created by Nacho González Miró on 27/6/18.
//  Copyright © 2018 Nacho González Miró. All rights reserved.
//

import Foundation

struct Comics {
    
    var series: NSDictionary!
    var format: String!
    var variantDescription: String!
    var thumbnail: [String: Any]!
    var id: Int!
    var title: String!
    var creators: NSDictionary!
    var image: String!
    var description: String!
    
    init(with dict: [String: Any]) {
        self.series = dict["series"] as? NSDictionary
        self.format = dict["format"] as? String ?? "Format not found"
        self.variantDescription = dict["variantDescription"] as? String ?? "Variant description not found"
        self.thumbnail = dict["thumbnail"] as? [String: Any] ?? [:]
        self.id = dict["id"] as? Int ?? 9999999999
        self.title = dict["title"] as? String ?? "Title not found"
        self.creators = dict["creators"] as? NSDictionary
        self.description = dict["description"] as? String ?? "Description not found"
    }
    
    init(title: String, description: String, format: String, image: String, creators: NSDictionary) {
        self.title = title
        self.variantDescription = description
        self.format = format
        self.image = image
        self.creators = creators
    }

}
