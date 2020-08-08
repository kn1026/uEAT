//
//  PromotionCell.swift
//  uEAT
//
//  Created by Khoi Nguyen on 8/5/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit

class PromotionCell: UITableViewCell {

    @IBOutlet var name: UILabel!
       @IBOutlet var descriptionLbl: UILabel!
       @IBOutlet var created: UILabel!
      @IBOutlet var voucherImg: UIImageView!
       
       var info: PromotionModel!
       override func awakeFromNib() {
           super.awakeFromNib()
           // Initialization code
       }

       override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)

           // Configure the view for the selected state
       }
       
       func configureCell(_ Information: PromotionModel) {
           self.info = Information
           
        
           name.text = "\(self.info.title!) - \(self.info.description!)"
           descriptionLbl.text = self.info.description!
           created.text = "\(self.info.value!)\(self.info.type!)"
        
        if self.info.Created_by == "Restaurant" {
            voucherImg.image = UIImage(named: "voucher_icn (1)")
        } else {
            voucherImg.image = UIImage(named: "prep_active_icn")
        }
              
       }
       
       
      
}
