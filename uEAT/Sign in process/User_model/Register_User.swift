//
//  Register_User_Model.swift
//  uEAT
//
//  Created by Khoi Nguyen on 10/26/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import Foundation


struct Register_User {

  var name: String
  var gender: String // Could become an enum
  var campus: String
  var phone: String // Could also be an enum
  var email: String // Email
  var birthday: String
  var userUID: String
  var stripeID: String
  

  var dictionary: [String: Any] {
    return [
      "Name": name,
      "Gender": gender,
      "Campus": campus,
      "Phone": phone,
      "Email": email,
      "Birthday": birthday,
      "userUID": userUID,
      "stripeID": stripeID,
      
    ]
  }
    
    

}

extension Register_User {


    init?(dictionary: [String : Any]) {
        
      guard let name = dictionary["Name"] as? String,
          let stripeID = dictionary["stripeID"] as? String,
          
          let userUID = dictionary["UserUID"] as? String,
          let gender = dictionary["Gender"] as? String,
          let campus = dictionary["Campus"] as? String,
          let phone = dictionary["Phone"] as? String,
          let email = dictionary["Email"] as? String,
          let birthday = dictionary["Birthday"] as? String else { return nil }

      self.init(name: name,
                gender: gender,
                campus: campus,
                phone: phone,
                email: email,
                birthday: birthday,
                userUID: userUID,
                stripeID: stripeID
                )
        
    }

}
