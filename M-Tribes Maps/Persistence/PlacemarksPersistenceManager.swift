//
//  PlacemarksPersistenceManager.swift
//  M-Tribes Maps
//
//  Created by Michael Attia on 8/14/18.
//  Copyright © 2018 Mike Attia. All rights reserved.
//

import Foundation
import SQLite

class PlacemarksPersistenceManager{
    
    // MARK: - Instance properties
    private let db: Connection
    
    // Table
    private let placemarksTable = Table("placemarks")
    
    // Table Columns
    private let vin = Expression<String>("vin")
    private let address = Expression<String?>("address")
    private let longitude = Expression<Double>("longitude")
    private let lattitude = Expression<Double>("lattitude")
    private let engineType = Expression<String?>("engineType")
    private let exterior = Expression<String?>("exterior")
    private let interior = Expression<String?>("interior")
    private let fuel = Expression<Int?>("fuel")
    private let name = Expression<String>("name")
    
    // MARK: - Initialization
    
    init() throws{
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        db = try Connection("\(path)/Placemarks.sqlite3")
    }
    
    // MARK: - Persistence APIs
    
    func persist(placemarks: [Placemark]){
        do{
            try create(placemarksTable)
            for placemark in placemarks{
                try db.run(placemarksTable.insert(vin         <- placemark.vin,
                                                  address     <- placemark.address,
                                                  longitude   <- placemark.longitude ?? 0.0,
                                                  lattitude   <- placemark.latitude ?? 0.0,
                                                  engineType  <- placemark.engineType,
                                                  exterior    <- placemark.exterior?.rawValue,
                                                  interior    <- placemark.interior?.rawValue,
                                                  fuel        <- placemark.fuel,
                                                  name        <- placemark.name)
                )
            }
        }catch{
           print(error)
        }
    }
    
    func getPersistedPlacemarks() throws -> [Placemark] {
        return try db.prepare(placemarksTable).map{
            Placemark(address: $0[address],
                      latitude: $0[lattitude],
                      longitude: $0[longitude],
                      engineType: $0[engineType],
                      exteriorState: $0[exterior],
                      fuel: $0[fuel],
                      interiorState: $0[interior],
                      name: $0[name],
                      vin: $0[vin])
        }
        
    }
    
    private func create(_ table: Table, dropIfExists: Bool = true) throws {
        
        try db.run(table.drop(ifExists: true))
            try db.run(table.create(ifNotExists: true) { t in
                t.column(vin, primaryKey: true)
                t.column(address)
                t.column(longitude)
                t.column(lattitude)
                t.column(engineType)
                t.column(exterior)
                t.column(interior)
                t.column(fuel)
                t.column(name)
            })
    }
    
}
