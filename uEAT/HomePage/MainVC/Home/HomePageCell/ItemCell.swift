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
    
    
    var info: ItemModel!
    
    func configureCell(_ Information: ItemModel) {
        self.info = Information
        
        
        
        if info.url != "" {
            
            
            imageStorage.async.object(forKey: info.url) { result in
                if case .value(let image) = result {
                    
                    DispatchQueue.main.async { // Make sure you're on the main thread here
                        
                        
                        self.img.image = image
                        
                        //try? imageStorage.setObject(image, forKey: url)
                        
                    }
                    
                } else {
                    
                    
                    Alamofire.request(self.info.url).responseImage { response in
                        
                        if let image = response.result.value {
                            
                            
                            self.img.image = image
                            try? imageStorage.setObject(image, forKey: self.info.url)
                            
                            
                        }
                        
                        
                    }
                    
                }
                
            }
            
            
            
        }
        
        
        
        
    }
    
    
}
