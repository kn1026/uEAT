//
//  RestaurantModel.swift
//  uEAT
//
//  Created by Khoi Nguyen on 6/25/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import Foundation


class RestaurantModel {
    
    
   
      fileprivate var _Restaurant_id: String!
      fileprivate var _Restaurant_name: String!
      fileprivate var _Restaurant_url: String!
      fileprivate var _Restaurant_status: String!
      fileprivate var _Restaurant_Open_status: Bool!

      
      
 
      
      var Restaurant_id: String! {
          get {
              if _Restaurant_id == nil {
                  _Restaurant_id = ""
              }
              return _Restaurant_id
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
    
    var Restaurant_url: String! {
        get {
            if _Restaurant_url == nil {
                _Restaurant_url = ""
            }
            return _Restaurant_url
        }
        
    }
    
    var Restaurant_status: String! {
        get {
            if _Restaurant_status == nil {
                _Restaurant_status = ""
            }
            return _Restaurant_status
        }
        
    }
      
    var Restaurant_Open_status: Bool! {
        get {
            if _Restaurant_Open_status == nil {
                _Restaurant_Open_status = false
            }
            return _Restaurant_Open_status
        }
        
    }
     

      
      init(postKey: String, Restaurant_model: Dictionary<String, Any>) {
          
          
          
          if let Restaurant_id = Restaurant_model["Restaurant_id"] as? String {
              self._Restaurant_id = Restaurant_id
              
          }
          
          if let Restaurant_name = Restaurant_model["businessName"] as? String {
              self._Restaurant_name = Restaurant_name
              
          }
        
          if let Restaurant_url = Restaurant_model["LogoUrl"] as? String {
              self._Restaurant_url = Restaurant_url
              
          }
          
          if let Restaurant_status = Restaurant_model["Status"] as? String {
              self._Restaurant_status = Restaurant_status
              
          }
          
          if let Restaurant_Open_status = Restaurant_model["Open"] as? Bool {
              self._Restaurant_Open_status = Restaurant_Open_status
              
          }
          
    
      }
    
    
    
    
    
    
    
    
    
    
    
}
