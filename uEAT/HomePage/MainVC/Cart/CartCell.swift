//
//  CartCell.swift
//  uEAT
//
//  Created by Khoi Nguyen on 6/15/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import Alamofire

class CartCell: MGSwipeTableCell {
    
    
    @IBOutlet weak var Quanlity: UIStackView!

    @IBOutlet var img: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var count: UILabel!
    
    
    @IBOutlet weak var plusBtnPressed: UIButton!
    @IBOutlet weak var minusBtnPressed: UIButton!
    
    
    var info: CartModel!
    
    var PlusAction : (() -> ())?
    var MinusAction : (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.plusBtnPressed.addTarget(self, action: #selector(PlusTapped(_:)), for: .touchUpInside)
        self.minusBtnPressed.addTarget(self, action: #selector(MinusTapped(_:)), for: .touchUpInside)
        
    }
    
    @IBAction func PlusTapped(_ sender: UIButton){
      // if the closure is defined (not nil)
      // then execute the code inside the subscribeButtonAction closure
      PlusAction?()
    }
    
    @IBAction func MinusTapped(_ sender: UIButton){
      // if the closure is defined (not nil)
      // then execute the code inside the subscribeButtonAction closure
      MinusAction?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ Information: CartModel) {
        self.info = Information
        
        
        
        self.name.text = info.name
        
        
        DataService.instance.mainFireStoreRef.collection("Cart").whereField("url", isEqualTo: info.url!).getDocuments { (snap, err) in
        
                if err != nil {
                    
                    return
                    
                }

                for item in snap!.documents {
                    
                    if let quanlity = item["quanlity"] as? Int {
                        
                        let price = self.info.price * Float(quanlity)
                        self.price.text = "$ \(price)"
                        self.count.text = "\(quanlity)"
                        
                    }
                    
            }
            
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

