//
//  AlamofireNetworkManager.swift
//  M-Tribes Maps
//
//  Created by Michael Attia on 8/14/18.
//  Copyright © 2018 Mike Attia. All rights reserved.
//

import Foundation
import Alamofire

class AlamofireNetworkManager: NetworkManager{
    
    // MARK: - Shared Instance
    
    static let shared: NetworkManager = AlamofireNetworkManager()
    private init(){}
    
    // Mark: Session management
    
    static var sessionManager = SessionManager.default
    
    // MARK: - Network Calling
    
    func call<Model: Codable>(api: API<Model>){
        guard let alamofireRequest = api.alamofireRequest else{
            api.completion(nil, URLError(.badURL))
            return
        }
        
        alamofireRequest.validate().responseData { (response) in
            switch response.result{
            case .success(let data):
                if let responseModel = try? JSONDecoder().decode(Model.self, from: data){
                    api.completion(responseModel, nil)
                }else{
                    api.completion(nil, URLError(.cannotParseResponse))
                }
            case .failure(let err):
                api.completion(nil, err)
            }
        }
    }
}

fileprivate extension API{
    var alamofireRequest: DataRequest?{
        guard let url = URL(string: "\(self.base)\(self.path)"),
            let method = Alamofire.HTTPMethod(rawValue: self.method.rawValue)
            else{ return nil }
        return AlamofireNetworkManager.sessionManager.request(url, method: method, parameters: parameters)
    }
}
