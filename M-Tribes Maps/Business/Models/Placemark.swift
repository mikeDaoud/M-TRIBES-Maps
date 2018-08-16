//
//  Placemark.swift
//  M-Tribes Maps
//
//  Created by Michael Attia on 8/14/18.
//  Copyright © 2018 Mike Attia. All rights reserved.
//

import Foundation
import CoreLocation

struct Placemark : Codable {
    
    let address : String?
    var coordinates : [Double]
    let engineType : String?
    let exterior : CarStatus?
    let fuel : Int?
    let interior : CarStatus?
    let name : String
    let vin : String
    
    // MARK: - Location Properties
    var longitude: Double?{
        get{return coordinates[safe: 0]}
        set{
            if let newValue = newValue{
                coordinates[0] = newValue
            }
        }
    }
    
    var latitude: Double?{
        get {return coordinates[safe: 1]}
        set{
            if let newValue = newValue{
                coordinates[1] = newValue
            }
        }
    }
    
    var location: CLLocationCoordinate2D?{
        get{
            guard let longitude = longitude, let latitude = latitude else { return nil }
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set{
            if let location = newValue{
                self.latitude = location.latitude
                self.longitude = location.longitude
            }
        }
        
    }
    
    // MARK: - Initialization
    
    init (address: String?,
          latitude: Double,
          longitude: Double,
          engineType: String?,
          exteriorState: String?,
          fuel: Int?,
          interiorState: String?,
          name: String,
          vin: String){
        
        self.address = address
        self.coordinates = [longitude, latitude]
        self.engineType = engineType
        self.fuel = fuel
        self.name = name
        self.vin = vin
        
        if let exteriorState = exteriorState{
            self.exterior = CarStatus(rawValue: exteriorState)
        }else{
            self.exterior = nil
            
        }
        if let interiorState = interiorState{
            self.interior = CarStatus(rawValue: interiorState)
        }else{
            self.interior = nil
        }
        
    }
    
    // MARK: - Nested Types
    
    enum CarStatus: String, Codable{
        case good = "GOOD"
        case unacceptable = "UNACCEPTABLE"
    }
    
}

