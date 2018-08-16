//
//  NetworkManager.swift
//  M-Tribes Maps
//
//  Created by Michael Attia on 8/14/18.
//  Copyright © 2018 Mike Attia. All rights reserved.
//

import Foundation

protocol NetworkManager {
    static var shared: NetworkManager {get}
    func call<Model: Codable>(api: API<Model>)
}

class Network {
    static var manager: NetworkManager{
        return AlamofireNetworkManager.shared
    }
}
