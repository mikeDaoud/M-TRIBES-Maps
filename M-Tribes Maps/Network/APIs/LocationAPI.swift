//
//  LocationAPI.swift
//  M-Tribes Maps
//
//  Created by Michael Attia on 8/14/18.
//  Copyright © 2018 Mike Attia. All rights reserved.
//

import Foundation

class LocationApi: API<CarsFeed>{
    
    init(completion: @escaping (CarsFeed?, Error?) -> Void){
        super.init(method: .get,
                   path: "locations.json",
                   completion: completion)
    }
}
