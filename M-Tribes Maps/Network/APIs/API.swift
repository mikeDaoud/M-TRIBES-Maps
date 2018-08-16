//
//  API.swift
//  M-Tribes Maps
//
//  Created by Michael Attia on 8/14/18.
//  Copyright © 2018 Mike Attia. All rights reserved.
//

import Foundation

class API<Model: Codable>{
    
    var base = "http://data.m-tribes.com/"
    var method: HTTPMethod
    var path: String
    var parameters: [String : Any]?
    var completion: (Model?, Error?) -> Void
    
    init(method: HTTPMethod,
         path: String,
         parameters: [String : Any]? = nil,
         completion: @escaping (Model?, Error?) -> Void) {
        
        self.method = method
        self.path = path
        self.parameters = parameters
        self.completion = completion
    }
    
    final func call(){
        Network.manager.call(api: self)
    }
}

enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}
