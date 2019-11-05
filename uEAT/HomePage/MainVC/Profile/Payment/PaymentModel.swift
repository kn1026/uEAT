//
//  PaymentModel.swift
//  uEAT
//
//  Created by Khoi Nguyen on 11/5/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import Foundation

//let paymentInfo: Dictionary<String, AnyObject> = ["Last4": x["last4"] as AnyObject, "Exp_month": x["exp_month"] as AnyObject, "Brand": x["brand"] as AnyObject, "Id": x["id"] as AnyObject, "Exp_year": x["exp_year"] as AnyObject, "Funding": x["funding"] as AnyObject, "Fingerprint": x["fingerprint"] as AnyObject, "Country": x["country"] as AnyObject]


class PaymentModel {
    
    
    fileprivate var _Last4: String!
    fileprivate var _Exp_month: Int!
    fileprivate var _Brand: String!
    fileprivate var _Exp_year: Int!
    fileprivate var _Funding: String!
    fileprivate var _Fingerprint: String!
    fileprivate var _Country: String!
    fileprivate var _Id: String!
    
    
    var Last4: String! {
        get {
            if _Last4 == nil {
                _Last4 = ""
            }
            return _Last4
        }
        
    }
    
    var Exp_month: Int! {
        get {
            if _Exp_month == nil {
                _Exp_month = 0
            }
            return _Exp_month
        }
        
    }
    
    var Brand: String! {
        get {
            if _Brand == nil {
                _Brand = ""
            }
            return _Brand
        }
        
    }
    
    var Exp_year: Int! {
        get {
            if _Exp_year == nil {
                _Exp_year = 0
            }
            return _Exp_year
        }
        
    }
    
    var Funding: String! {
        get {
            if _Funding == nil {
                _Funding = ""
            }
            return _Funding
        }
        
    }
    
    var Fingerprint: String! {
        get {
            if _Fingerprint == nil {
                _Fingerprint = ""
            }
            return _Fingerprint
        }
        
    }
    
    var Country: String! {
        get {
            if _Country == nil {
                _Country = ""
            }
            return _Country
        }
        
    }
    
    var Id: String! {
        get {
            if _Id == nil {
                _Id = ""
            }
            return _Id
        }
        
    }
    
    
    
    
    
    init(postKey: String, PaymentModel: Dictionary<String, Any>) {
        
        
        
        
        if let Last4 = PaymentModel["Last4"] as? String {
            self._Last4 = Last4
            
        }
        
        if let Exp_month = PaymentModel["Exp_month"] as? Int {
            self._Exp_month = Exp_month
            
        }
        
        if let Brand = PaymentModel["Brand"] as? String {
            self._Brand = Brand
            
        }
        
        if let Exp_year = PaymentModel["Exp_year"] as? Int {
            self._Exp_year = Exp_year
            
        }
        
        if let Funding = PaymentModel["Funding"] as? String {
            self._Funding = Funding
            
        }
        
        if let Fingerprint = PaymentModel["Fingerprint"] as? String {
            self._Fingerprint = Fingerprint
            
        }
        
        if let Country = PaymentModel["Country"] as? String {
            self._Country = Country
            
        }
        
        if let Id = PaymentModel["Id"] as? String {
            self._Id = Id
            
        }
        
       
        
        
        
    }
    
    
    
}
