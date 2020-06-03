//
//  itemDetail.swift
//  uEAT
//
//  Created by Khoi Nguyen on 12/10/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase
import AlamofireImage
import Alamofire

class itemDetail: UIViewController {

    @IBOutlet weak var descriptionTxt: UILabel!
    @IBOutlet weak var titleTxt: UILabel!
    @IBOutlet weak var priceTxt: UILabel!
    @IBOutlet weak var ImgView: UIImageView!
    var item: ItemModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        titleTxt.text = item.name
        priceTxt.text = "\(item.price!)"
        descriptionTxt.text = item.description
        
        
        if item.url != "" {
            
            
            imageStorage.async.object(forKey: item.url) { result in
                if case .value(let image) = result {
                    
                    DispatchQueue.main.async { // Make sure you're on the main thread here
                        
                        
                        self.ImgView.image = image
                        
                        //try? imageStorage.setObject(image, forKey: url)
                        
                    }
                    
                } else {
                    
                    
                    AF.request(self.item.url).responseImage { response in
                        
                        
                        switch response.result {
                        case let .success(value):
                            self.ImgView.image = value
                            try? imageStorage.setObject(value, forKey: self.item.url)
                        case let .failure(error):
                            print(error)
                        }
                        

                        
                        
                    }
                    
                }
                
            }
            
            
            
        }
        
    }
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    

    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func addToCartBtnPressed(_ sender: Any) {
        
        swiftLoader()
        
        let dict = ["name": item.name as Any, "description": item.description as Any, "price": item.price as Any, "url": item.url as Any, "category": item.category as Any, "type": item.type as Any, "restaurant_id": item.Restaurant_ID as Any, "timeStamp": FieldValue.serverTimestamp(), "userUID": Auth.auth().currentUser!.uid]
        
        let db = DataService.instance.mainFireStoreRef.collection("Cart")
        
        
        
        db.addDocument(data: dict) { err in
          
              if let err = err {
                  
                  SwiftLoader.hide()
                  self.showErrorAlert("Opss !", msg: err.localizedDescription)
                  
              } else {
                
                SwiftLoader.hide()
                self.dismiss(animated: true, completion: nil)
                
            
            }
            
            
        }
        

        
    }
    
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    func swiftLoader() {
        
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        SwiftLoader.setConfig(config: config)
        
        SwiftLoader.show(title: "", animated: true)
        
                                                                                            
    }
}
