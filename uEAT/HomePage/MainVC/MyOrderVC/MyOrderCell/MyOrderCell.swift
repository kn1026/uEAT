//
//  MyOrderCell.swift
//  uEAT
//
//  Created by Khoi Nguyen on 6/20/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import Alamofire

class MyOrderCell: UITableViewCell {
    
    @IBOutlet var img: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var order_ID: UILabel!
    @IBOutlet var time: UILabel!

    
    var info: Recent_order_model!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ Information: Recent_order_model) {
        self.info = Information
        
        
        
        self.name.text = "Order from \(self.info.Restaurant_name!)"
        self.order_ID.text = "CC - \(self.info.Order_id!)"
        
        if let times = info.Order_time as? Date {
            
            time.text = timeAgoSinceDate(times, numericDates: true)
            
        } else {
            
            print("Can't convert \(info.Order_time!)")
            
        }
        
        DataService.instance.mainFireStoreRef.collection("Restaurant").whereField("Restaurant_id", isEqualTo: info.Restaurant_id!).getDocuments { (business, err) in
        
        
            if err != nil {
                   
                   print(err!.localizedDescription)
                   return
                   
            }
            
            for item in business!.documents {
                
                if let LogoUrl = item["LogoUrl"] as? String {
                    
                    imageStorage.async.object(forKey: LogoUrl) { result in
                        if case .value(let image) = result {
                            
                            DispatchQueue.main.async { // Make sure you're on the main thread here
                                
                                
                                self.img.image = image
                                
                                
                            }
                            
                        } else {
                            
                            
                            AF.request(LogoUrl).responseImage { response in
                                
                                switch response.result {
                                case let .success(value):
                                    self.img.image = value
                                    try? imageStorage.setObject(value, forKey: LogoUrl)
                                case let .failure(error):
                                    print(error)
                                }
                                
                                
                                
                            }
                            
                        }
                        
                    }
                    
                    
                }
                
                
                
            }
            
            
            
        }
        
        
        
    }
    
    
    
    

}
