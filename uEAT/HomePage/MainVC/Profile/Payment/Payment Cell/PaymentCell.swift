//
//  PaymentCell.swift
//  uEAT
//
//  Created by Khoi Nguyen on 11/5/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import Firebase

class PaymentCell: MGSwipeTableCell {
    
    
    @IBOutlet var card_view: UIView!
    @IBOutlet var apple_view: UIView!
    @IBOutlet var Primary_Card: UILabel!
    @IBOutlet var last4Digits: UILabel!
    @IBOutlet var brand: UIImageView!
    
    
    var info: PaymentModel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ Information: PaymentModel) {
           
           
        self.info = Information
        
        if self.info.Id != "" {
            
            DataService.instance.mainRealTimeDataBaseRef.child("Default_Card").child(Auth.auth().currentUser!.uid).child(self.info.Id).observeSingleEvent(of: .value, with: { (snap) in
            
                if snap.exists() {
                    
                    self.Primary_Card.text = "Primary card"
                    
                } else {
                    
                    self.Primary_Card.text = ""
                    
                }
                
                
            })
            
        }
        
        
        
    
           
           if info.Brand == "Apple_pay" {
               
            card_view.isHidden = true
            apple_view.isHidden = false
               
           } else {
            
            last4Digits.text = self.info.Last4
            brand.image = UIImage(named: "\(self.info.Brand!)")
            
            card_view.isHidden = false
            apple_view.isHidden = true
        
        }
        
    }

}
