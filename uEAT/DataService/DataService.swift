//
//  DataService.swift
//  uEAT
//
//  Created by Khoi Nguyen on 10/23/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import Foundation


import Foundation

let FIR_CHILD_USERS = "User_Info"
let main = "uEAT"

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage


class DataService {
    

    fileprivate static let _instance = DataService()
   
    
    static var instance: DataService {
        return _instance
    }
    
    var mainDataBaseRef: DatabaseReference {
        return Database.database().reference().child(main)
    }
    
    var fcmTokenUserRef: DatabaseReference {
        return mainDataBaseRef.child("fcmToken")
    }
  
    var checkPhoneUserRef: DatabaseReference {
        return mainDataBaseRef.child("Phone")
    }
    
    var checkEmailUserRef: DatabaseReference {
        return mainDataBaseRef.child("Email")
    }
    
    var UsersRef: DatabaseReference {
        return mainDataBaseRef.child(FIR_CHILD_USERS)
    }

    let connectedRef = Database.database().reference(withPath: ".info/connected")
    
    
    
}
