//
//  UserLocationManager.swift
//  M-Tribes Maps
//
//  Created by Michael Attia on 8/14/18.
//  Copyright © 2018 Mike Attia. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

class UserLocationManager: NSObject {
    
    // MARK: - Instance Properties
    
    private var locationManager = CLLocationManager()
    
    // MARK: - Initialization
    
    override init() {
        userLocationVariable = BehaviorSubject<CLLocation?>(value: locationManager.location)
        let permissionGranted = CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
        observablePermission = Variable(permissionGranted)
        super.init()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        addNotificationListener()
    }
    
    // MARK: - Location related properties
    
    var isLocationGranted: Bool{
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }
    
    var observablePermission: Variable<Bool>
    
    fileprivate var userLocationVariable: BehaviorSubject<CLLocation?>
    
    var userLocationObservable: Observable<CLLocation?>{
        return userLocationVariable.asObserver()
    }
    
    var userLocation: CLLocation?{
        return locationManager.location
    }
    
    // MARK: - Asking for permission
    
    func promptForPermission(){
        
        guard  !self.isLocationGranted else {return}
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            warnUserPermissionNotGranted()
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
    }
    
    private func warnUserPermissionNotGranted(){
        let alert = UIAlertController(title: nil, message: "Looks like we can't access your location 🙁 \nWe need to know your location to show nearby cars", preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let grantPermissinAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            let url = URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
        alert.addAction(grantPermissinAction)
        alert.addAction(continueAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Enter forground Notification listener
    
    private func addNotificationListener(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkAndAskForPermission),
                                               name: Notification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    fileprivate var lastPermissionStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
    @objc private func checkAndAskForPermission(){
        let shouldReaskForPermission = lastPermissionStatus != CLLocationManager.authorizationStatus()
        if shouldReaskForPermission{
            promptForPermission()
        }
        lastPermissionStatus = CLLocationManager.authorizationStatus()
        
        let permissionGranted = CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
        observablePermission.value = permissionGranted
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Location Manager Delegate

extension UserLocationManager: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let permissionGranted = status == .authorizedWhenInUse || status == .authorizedAlways
        observablePermission.value = permissionGranted
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocationVariable.onNext(locations[safe: 0])
    }
}
