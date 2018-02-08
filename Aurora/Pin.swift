//
//  Pin.swift
//  Aurora
//
//  Created by Julian van 't Veld on 08-02-18.
//  Copyright © 2018 Julian van 't Veld. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Pin {
    var name: String
    var description: String
    var geopoint: GeoPoint
}
