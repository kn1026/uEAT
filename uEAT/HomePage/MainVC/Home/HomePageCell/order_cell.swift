//
//  order_cell.swift
//  uEAT
//
//  Created by Khoi Nguyen on 11/3/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit

class order_cell: UICollectionViewCell {
    
    
    
    @IBOutlet var restaurant_name: UILabel!
    @IBOutlet var Message: UILabel!
    @IBOutlet var Image: UIImageView!
    
    var info: Recent_order_model!
    
    func configureCell(_ Information: Recent_order_model) {
        self.info = Information
        
        
        
        self.restaurant_name.text = "Order from \(self.info.Restaurant_name!)"
        if self.info.Status == "Processed" {
            self.Image.image = UIImage(named: "20")
            self.Message.text = "Your order has been processed"
        } else if self.info.Status == "Started" {
            self.Image.image = UIImage(named: "50")
            self.Message.text = "Your order has been started cooking"
        } else if self.info.Status == "Cooked" {
            self.Image.image = UIImage(named: "80")
            self.Message.text = "Your order is ready to pick up"
        } else {
            self.Message.text = "Your order is being processed"
        }
        
        
        
    }
    
    
    
}
