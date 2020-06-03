//
//  MainAPIClient.swift
//  uEAT
//
//  Created by Khoi Nguyen on 10/29/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import Foundation
import Alamofire
import Stripe

class MainAPIClient: NSObject, STPCustomerEphemeralKeyProvider {
    
    static let shared = MainAPIClient()
    
    var baseURLString:String? = nil
    var baseURL: URL {
        
        if let urlString = self.baseURLString, let url = URL(string: urlString) {
            
            return url
        } else {
            
            fatalError()
            
        }
        
    }
    
    
    
    
    
    

    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = self.baseURL.appendingPathComponent("Empheral_keys")
        AF.request(url, method: .post, parameters: [
        
            "api_verson": apiVersion
        
        ])
            
        .validate(statusCode: 200..<500)
            .responseJSON { responseJSON in
                
                switch responseJSON.result {
                    
                case .success(let json):
                    
                    completion(json as? [String: AnyObject], nil)
                    
                    
                case .failure(let error):
                    completion(nil, error)
                }
                
                
                
        }
        
        
        
    }
 
    
}

