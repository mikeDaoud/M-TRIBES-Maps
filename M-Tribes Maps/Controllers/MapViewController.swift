//
//  MapViewController.swift
//  M-Tribes Maps
//
//  Created by Michael Attia on 8/14/18.
//  Copyright © 2018 Mike Attia. All rights reserved.
//

import UIKit
import GoogleMaps
import Pulley
import RxSwift

class MapViewController: UIViewController {
    
    // MARK: - Constants
    fileprivate let myLocationButtonPadding: CGFloat = 7
    private let disposeBag = DisposeBag()
    
    // MARK: - View Outlets
    @IBOutlet weak var mapView: GMSMapView!{
        didSet{
            mapView.delegate = self
            mapView.isMyLocationEnabled = true
            let location = locationManager.userLocation?.coordinate ?? Places.M_Tribes.location
            let camera = GMSCameraPosition.camera(withTarget: location, zoom: 15)
            mapView.animate(to: camera)
        }
    }
    @IBOutlet weak var myLocationButton: UIButton!{
        didSet{
            myLocationButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var myLocationButtonBottomConstraint: NSLayoutConstraint!
    
    // MARK: - View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObservingLocationsList()
        startObservingSelectedMarker()
        startObservingLocationPermission()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myLocationButton.isHidden = !locationManager.isLocationGranted
        self.pulleyViewController?.displayMode = .automatic
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAndPromptUserForLocationPermission()
    }
    
    // MARK: - User location tracking
    
    let locationManager =  UserLocationManager()
    
    private func checkAndPromptUserForLocationPermission(){
        if !locationManager.isLocationGranted{
            locationManager.promptForPermission()
        }
    }
    
    private func startObservingLocationPermission(){
        locationManager.observablePermission.asObservable().subscribe(onNext: { (permissionGranted) in
            self.myLocationButton.isHidden = !permissionGranted
        }).disposed(by: disposeBag)
    }
    
    @IBAction func goToMyLocation(_ sender: Any) {
        if let location = locationManager.userLocation{
            mapView.animate(toLocation: location.coordinate)
        }
    }
    
    
    // MARK: - Map Markers
    
    fileprivate var locationsStore = LocationsDataStore.shared
    
    private func startObservingLocationsList(){
        locationsStore.placemarks
            .skipWhile{$0.count == 0}
            .subscribe(onNext: { (marks) in
                marks.forEach{$0.addTo(map: self.mapView)}
            }, onError: { _ in
                self.showErrorAlert()
            }).disposed(by: disposeBag)
    }
    
    private func showErrorAlert(){
        let alert = UIAlertController(title: nil, message: "Oops! Looks like we can't load the cars data", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func startObservingSelectedMarker(){
        locationsStore.selectedMark.asObservable()
            .subscribe(onNext: { (selectedMarker) in
                self.select(selectedMarker)
            }).disposed(by: disposeBag)
    }
    
    private func select(_ marker: MapPlacemarker?){
        guard let marker = marker else{
            mapView.selectedMarker = nil
            return
        }
        DispatchQueue.main.async {
            self.mapView.selectedMarker = marker
            self.mapView.animate(toLocation: marker.position )
        }
    }
}

// MARK: - MapView delegate

extension MapViewController: GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker == mapView.selectedMarker{
            locationsStore.select(nil)
        }else{
            locationsStore.select(marker as? MapPlacemarker)
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        locationsStore.select(nil)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        locationsStore.select(nil)
    }
}

// MARK: - Pulley Primary Controller Delegate

extension MapViewController: PulleyPrimaryContentControllerDelegate{
    
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat)
    {
        guard drawer.currentDisplayMode == .bottomDrawer else {
            myLocationButtonBottomConstraint.constant = myLocationButtonPadding
            return
        }
        guard locationManager.isLocationGranted else { return }
        let distanceFromBottom = distance + myLocationButtonPadding - bottomSafeArea
        myLocationButtonBottomConstraint.constant = distanceFromBottom
        if let drawerHeight = pulleyViewController?.partialRevealDrawerHeight(bottomSafeArea: bottomSafeArea){
            myLocationButton.isHidden = distance > drawerHeight + 30
        }
        
    }
}
