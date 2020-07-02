//
//  MenuCell.swift
//  uEAT
//
//  Created by Khoi Nguyen on 6/25/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import Alamofire

class MenuCell: UICollectionViewCell {
    
    
    @IBOutlet var img: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    
    var info: ItemModel!
       
       func configureCell(_ Information: ItemModel) {
           self.info = Information
        

        if info.status == "Offline" {
            
            nameLbl.text = "\(self.info.name!) - unavailable"
            
        } else if info.status == "Online" {
            
            nameLbl.text = "\(self.info.name!)"
            
        } else {
            
            nameLbl.text = "\(self.info.name!) - Error"
            
        }
        
           
           if info.url != "" {
               
               
               imageStorage.async.object(forKey: info.url) { result in
                   if case .value(let image) = result {
                       
                       DispatchQueue.main.async { // Make sure you're on the main thread here
                           
                           
                           self.img.image = image
                           
                           //try? imageStorage.setObject(image, forKey: url)
                           
                       }
                       
                   } else {
                       
                       
                    AF.request(self.info.url).responseImage { response in
                           
                           
                           switch response.result {
                           case let .success(value):
                               self.img.image = value
                               try? imageStorage.setObject(value, forKey: self.info.url)
                           case let .failure(error):
                               print(error)
                           }
                           
                           
                           
                       }
                       
                   }
                   
               }
               
               
               
           }
           
           
           
       }
    
    
    
    
    
}
