//
//  MapPlacemarker.swift
//  M-Tribes Maps
//
//  Created by Michael Attia on 8/15/18.
//  Copyright © 2018 Mike Attia. All rights reserved.
//

import Foundation
import GoogleMaps
import RxSwift

class MapPlacemarker: GMSMarker{
    
    var placemark: Placemark
    weak var mapView: GMSMapView?
    let disposeBag = DisposeBag()
    
    init?(placemark: Placemark, selectedMark: Observable<MapPlacemarker?>){
        guard let position = placemark.location else{
            return nil
        }
        self.placemark = placemark
        super.init()
        self.position = position
        self.title = placemark.name
        self.icon = #imageLiteral(resourceName: "carMarker")
        startObserving(selectedMark)
    }
    
    private func startObserving(_ selectedMark: Observable<MapPlacemarker?>){
        selectedMark.subscribe(onNext: {[weak self] (selectedMark) in
                if selectedMark == nil || selectedMark == self{
                    self?.show()
                }else{
                    self?.hide()
                }
            }).disposed(by: disposeBag)
    }
    
    func addTo(map: GMSMapView){
        self.mapView = map
        self.map = map
    }
    
    func show(){
        self.map = self.mapView
    }
    
    func hide(){
        self.map = nil
    }
    
}



