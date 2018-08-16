//
//  MainViewController.swift
//  M-Tribes Maps
//
//  Created by Michael Attia on 8/14/18.
//  Copyright © 2018 Mike Attia. All rights reserved.
//

import UIKit
import Pulley

class MainViewController: PulleyViewController {
    
    // MARK: - View Outlets
    
    @IBOutlet var loadingView: UIView?

    // MARK: - View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationsDataStore.shared.fetchPlacemarks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(bounceDrawer), userInfo: nil, repeats: false)
    }
    
    @objc private func bounceDrawer(){
        super.bounceDrawer()
    }

    // MARK: - Loading Indicator
    
    private func showLoadingView() {
        if loadingView == nil{
            loadingView = UIView(frame: self.view.bounds)
            loadingView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            activityIndicator.center = loadingView!.center
            activityIndicator.startAnimating()
            loadingView?.addSubview(activityIndicator)
        }
        self.view.addSubview(loadingView!)
    }
    
    private func hideLoadingView() {
       loadingView?.removeFromSuperview()
    }

}

