//
//  LocationsDataStore.swift
//  M-Tribes Maps
//
//  Created by Michael Attia on 8/14/18.
//  Copyright © 2018 Mike Attia. All rights reserved.
//

import Foundation
import RxSwift

class LocationsDataStore{
    
    // MARK: - Shared Instance
    
    static let shared = LocationsDataStore()
    private init(){}
    
    // MARK: - Cars locations fetching and publishing
    
    var placemarks = BehaviorSubject<[MapPlacemarker]>(value: [])
    
    func fetchPlacemarks(){
        LocationApi { (carsFeed, error) in
            if let carsFeed = carsFeed{
                DispatchQueue.global().async {
                    self.persist(carsFeed.placemarks)
                }
                self.publish(carsFeed.placemarks)
            }else if let error = error{
                print(error)
                do{
                    let placemarks = try self.getPersistedPlacemarks()
                    self.publish(placemarks)
                }catch{
                    self.placemarks.onError(error)
                }
            }
        }.call()
    }
    
    private func publish(_ placeMarks: [Placemark]){
        let mapMarkers = placeMarks.compactMap{MapPlacemarker(placemark: $0, selectedMark: self.selectedMark.asObservable())}
        self.placemarks.onNext(mapMarkers)
        
    }
    
    // MARK: - Mark selection
    
    var selectedMark = Variable<MapPlacemarker?>(nil)
    
    func select(_ mark: MapPlacemarker?){
        selectedMark.value = mark
    }
    
    // MARK: - List filteration
    
    var filteredPlacemarks = BehaviorSubject<[MapPlacemarker]>(value: [])
    
    func filterMarks(with keyword: String){
        guard let marks = try? placemarks.value() else {return}
        let filteredList = marks
            .filter{$0.placemark.name.contains(keyword) || ($0.placemark.address?.contains(keyword) ?? false)}
        filteredPlacemarks.onNext(filteredList)
    }
    
    
    // MARK: - getting and persisting data
    
    private func getPersistedPlacemarks() throws -> [Placemark]{
        return try PlacemarksPersistenceManager().getPersistedPlacemarks()
    }
    
    private func persist(_ placemarks: [Placemark]){
        do{
            try PlacemarksPersistenceManager().persist(placemarks: placemarks)
        }catch{
            print(error)
        }
    }
}
