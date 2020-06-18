//
//  addOnCell.swift
//  uEAT
//
//  Created by Khoi Nguyen on 6/15/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class addOnCell: UICollectionViewCell {
    
    
    @IBOutlet var img: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var price: UILabel!
    
    var info: ItemModel!
    
    func configureCell(_ Information: ItemModel) {
        self.info = Information
        
        
        
        title.text = self.info.name
        price.text = "$\(self.info.price!)"
        
        
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
