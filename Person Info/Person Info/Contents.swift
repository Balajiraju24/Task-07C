//
//  Contents.swift
//  Person Info
//
//  Created by Balaji on 25/4/20.
//  Copyright © 2020 Balaji. All rights reserved.
//

import Foundation

//decodabale structure for the biodata
struct Biodata: Codable
{
    var name: String
    var age: Int
    var place: String
    
    init(name: String, age: Int, place: String) {
        self.name = name
        self.age = age
        self.place = place
    }
}

struct Listthebio: Codable {
    
    let bioData: [Biodata]
    init(bioData: [Biodata])
    {
        self.bioData = bioData
    }
}
