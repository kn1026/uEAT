//
//  ItemCell.swift
//  uEAT
//
//  Created by Khoi Nguyen on 12/10/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ItemCell: UICollectionViewCell {
    
    
    @IBOutlet var img: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    
    var info: RestaurantModel!
    
    func configureCell(_ Information: RestaurantModel) {
        self.info = Information
        
        
        if info.Restaurant_status != "Ready" {
            
            nameLbl.text = "\(info.Restaurant_name!) - Upcoming"
            
        } else {
            
            
            if info.Restaurant_Open_status == true {
                    
            
                    nameLbl.text = info.Restaurant_name!
                    
            } else {
                
                nameLbl.text = "\(info.Restaurant_name!) - Closed"
                
            }
            
            
        }
        
        
        
        if info.Restaurant_url != "" {
            
            
            imageStorage.async.object(forKey: info.Restaurant_url) { result in
                if case .value(let image) = result {
                    
                    DispatchQueue.main.async { // Make sure you're on the main thread here
                        
                        
                        self.img.image = image
                        
                        //try? imageStorage.setObject(image, forKey: url)
                        
                    }
                    
                } else {
                    
                    
                    AF.request(self.info.Restaurant_url).responseImage { response in
                        
                        
                        switch response.result {
                        case let .success(value):
                            self.img.image = value
                            try? imageStorage.setObject(value, forKey: self.info.Restaurant_url)
                        case let .failure(error):
                            print(error)
                        }
                        
                        
                        
                    }
                    
                }
                
            }
            
            
            
        }
        
        
        
        
    }
    
    
}
