//
//  Recent_order_model.swift
//  uEAT
//
//  Created by Khoi Nguyen on 11/3/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import Foundation


class Recent_order_model {
    
    fileprivate var _Order_id: String!
    fileprivate var _Restaurant_id: String!
    fileprivate var _Restaurant_name: String!
    fileprivate var _UID: String!
    fileprivate var _url: String!
    fileprivate var _Status: String!
    fileprivate var _Order_time: Any!
    
    
    var Status: String! {
        get {
            if _Status == nil {
                _Status = ""
            }
            return _Status
        }
        
    }
    
    var Order_id: String! {
        get {
            if _Order_id == nil {
                _Order_id = ""
            }
            return _Order_id
        }
        
    }
    
    var Restaurant_id: String! {
        get {
            if _Restaurant_id == nil {
                _Restaurant_id = ""
            }
            return _Restaurant_id
        }
        
    }
    
    var UID: String! {
        get {
            if _UID == nil {
                _UID = ""
            }
            return _UID
        }
        
    }
    
    var Restaurant_name: String! {
        get {
            if _Restaurant_name == nil {
                _Restaurant_name = ""
            }
            return _Restaurant_name
        }
        
    }
    
    var Order_time: Any! {
        get {
            if _Order_time == nil {
                _Order_time = 0
            }
            return _Order_time
        }
    }
    

    
    init(postKey: String, Order_model: Dictionary<String, Any>) {
        
        
        
        if let Order_id = Order_model["Order_id"] as? Int {
            
            let order = String(Order_id)
            self._Order_id = order
            
        } else {
            print("Can't convert \(Order_model["Order_id"])")
        }
        
        if let Restaurant_id = Order_model["Restaurant_id"] as? String {
            self._Restaurant_id = Restaurant_id
            
        }
        
        if let Restaurant_name = Order_model["Restaurant_name"] as? String {
            self._Restaurant_name = Restaurant_name
            
        }
        
        if let UID = Order_model["UserUID"] as? String {
            self._UID = UID
            
        }
        
        if let Status = Order_model["Status"] as? String {
            self._Status = Status
            
        }
        
        if let Order_time = Order_model["Order_time"] {
            self._Order_time = Order_time
            
        }
        
  
    }
      
    
}
