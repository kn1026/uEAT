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
import SwiftEntryKit

class itemDetail: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet weak var descriptionTxt: UILabel!
    @IBOutlet weak var titleTxt: UILabel!
    @IBOutlet weak var priceTxt: UILabel!
    @IBOutlet weak var ImgView: UIImageView!
    var item: ItemModel!
    var selectetItem: ItemModel!
    var selectedRow: Int!
    @IBOutlet weak var collectionView: UICollectionView!
    var Add_on = [ItemModel]()
    var removeArr = [String]()
    var type = ""
    @IBOutlet weak var quanlityLbl: UILabel!
    var quanlity = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        titleTxt.text = item.name
        priceTxt.text = "$\(item.price!)"
        descriptionTxt.text = item.description
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
        
        if item.Restaurant_ID != "" {
            loadAddOne(id: item.Restaurant_ID)
        } else {
            print("Can't get restaurant id")
        }
        
        
        
        
    }
    
    
    
    
    func DeleteExpiredCart(uid: String, completed: @escaping DownloadComplete) {
         
         let calendar = Calendar.current
         let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
         let start = calendar.date(from: components)!
         let newDate = calendar.date(byAdding: .minute, value: -30, to: start)
         

    
         DataService.instance.mainFireStoreRef.collection("Cart").whereField("userUID", isEqualTo: uid).whereField("timeStamp", isLessThanOrEqualTo: newDate!).getDocuments { (snaps, err) in
         
         if err != nil {
             
             self.showErrorAlert("Opss !", msg: err!.localizedDescription)
             return
             
         }
         
             for item in snaps!.documents {
                 
                 
                 DataService.instance.mainFireStoreRef.collection("Cart").document(item.documentID).delete() { err in
                     if let err = err {
                         print("Error removing document: \(err)")
                     } else {
                         print("Document successfully removed!")
                     }
                 }
                 
                 completed()
                 
             }
             
             completed()
             
             
             
             
         }

         
         
     }
    
    // load add-on
    
    
    func loadAddOne(id: String) {
        
        
        DataService.instance.mainFireStoreRef.collection("Menu").whereField("restaurant_id", isEqualTo: id).whereField("type", isEqualTo: "Add-on").getDocuments { (snap, err) in
        
        if err != nil {
            
            self.showErrorAlert("Opss !", msg: err!.localizedDescription)
            return
            
        }
        
        for item in snap!.documents {
            
            let dict = ItemModel(postKey: item.documentID, Item_model: item.data())
            self.Add_on.append(dict)
                
                
            }
            
            self.collectionView.reloadData()
            
            
        }
        
        
    }
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    

    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func checkDifferentRestaurant(completed: @escaping DownloadComplete) {
        
        
        self.removeArr.removeAll()
        
        swiftLoader(title: "Checking cart")
        
        let uid = Auth.auth().currentUser?.uid
        
        DataService.instance.mainFireStoreRef.collection("Cart").whereField("userUID", isEqualTo: uid!).getDocuments { (snaps, err) in
            
            
            if err != nil {
                       
                self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                return
                       
            }
            
            if snaps?.isEmpty == true {
                
                completed()
                
            } else {
                
                
                
                for items in snaps!.documents {
                    
                    if let res_id = items.data()["restaurant_id"] as? String {
                        
                        if res_id != self.item.Restaurant_ID {
                                                     
                            let remove_id = items.documentID
                            self.removeArr.append(remove_id)
         
                            
                        }
                        
                    }
                    
                }
                
                if self.removeArr.isEmpty != true {
                    
                    SwiftLoader.hide()
                    self.loadAlert(message: "Are you sure to proceed a new cart ?")
                    
                } else {
                    
                    completed()
                    
                }
            }
            
        }
        
        
    }
    
    func removeElement() {
        
        swiftLoader(title: "Removing old cart")
        
        for id in removeArr {
            
            DataService.instance.mainFireStoreRef.collection("Cart").document(id).delete()
            
        }
        
        if type == "Item" {
            
            self.addToCart()
            
        } else {
            if selectetItem != nil {
                
                self.addAddOn(item_addon: selectetItem, row: selectedRow)
                
            }
            
            
        }
        
     
        
    }
    
    
    @IBAction func addToCartBtnPressed(_ sender: Any) {
        
        checkDifferentRestaurant() {
            
            self.addToCart()
            
        }
    }
    
    
    func addToCart() {
        
        type = "Item"
        
        let uid = Auth.auth().currentUser?.uid
              
              swiftLoader(title: "Adding to cart")
              
              DeleteExpiredCart(uid: uid!) {
                  
                  DataService.instance.mainFireStoreRef.collection("Cart").whereField("userUID", isEqualTo: uid!).whereField("url", isEqualTo: self.item.url!).getDocuments { (snaps, err) in
                             
                             if err != nil {
                                 
                                 self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                                 return
                                 
                             }
                      if snaps?.isEmpty == true {
                          
                          let dict = ["name": self.item.name as Any, "description": self.item.description as Any, "price": self.item.price as Any, "url": self.item.url as Any, "category": self.item.category as Any, "type": self.item.type as Any, "restaurant_id": self.item.Restaurant_ID as Any, "timeStamp": FieldValue.serverTimestamp(), "userUID": Auth.auth().currentUser!.uid, "quanlity": self.quanlity]
                          
                          let db = DataService.instance.mainFireStoreRef.collection("Cart")
                          
                          
                          
                          db.addDocument(data: dict) { err in
                            
                                if let err = err {
                                    
                                    SwiftLoader.hide()
                                    self.showErrorAlert("Opss !", msg: err.localizedDescription)
                                    
                                } else {
                                  
                                  SwiftLoader.hide()
                                  loadAlertAnimation(title: "Conratulation", desc: "You have added to cart succesfully")
                                  
                                  
                              
                              }
                              
                              
                          }
                          
                      } else {
                          
                          for item in snaps!.documents {
                          
                          if let count = item.data()["quanlity"] as? Int {
                              
                              
                              
                              let id = item.documentID
                              
        
                              DataService.instance.mainFireStoreRef.collection("Cart").document(id).updateData(["quanlity": count+self.quanlity, "timeStamp": FieldValue.serverTimestamp()])
                              
                              
                              SwiftLoader.hide()
                              loadAlertAnimation(title: "Conratulation", desc: "You have added to cart succesfully")
                                  
                          } else {
                              print("Can't convert")
                          }
                          
                          
                      }
                             
                                 
                                  
                          }
                      
                      
                      
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
    
    func swiftLoader(title: String) {
        
        
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
    
    // collectionview
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
              return 1
          }
          
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
              
        return Add_on.count
              
    }
          
          
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           
           
           
           let item = Add_on[indexPath.row]
           
           if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addOnCell", for: indexPath) as? addOnCell {
               
               cell.configureCell(item)
               
               return cell
               
           } else {
               
               return order_cell()
               
           }
              
             

       }
       

       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           
            return CGSize(width: 141.0, height: 76.0)
           
       }
       
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           
           return 10.0
       }

       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           return 0

       }
       
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        type = "AddOn"
        selectedRow = indexPath.row
        let item_addon = Add_on[indexPath.row]
        
        selectetItem = item_addon
            
        checkDifferentRestaurant() {
            
            self.addAddOn(item_addon: item_addon, row: indexPath.row)
            
        }
          
        
    }
    
    func addAddOn(item_addon: ItemModel, row: Int) {
        
        swiftLoader(title: "Adding to cart")
        
        let uid = Auth.auth().currentUser?.uid
        
        DeleteExpiredCart(uid: uid!) {
            
            
            DataService.instance.mainFireStoreRef.collection("Cart").whereField("userUID", isEqualTo: uid!).whereField("url", isEqualTo: item_addon.url!).getDocuments { (snaps, err) in
                   
                   if err != nil {
                       
                       self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                       return
                       
                   }
                
                if snaps?.isEmpty == true {
                    
                    let dict = ["name": item_addon.name as Any, "description": item_addon.description as Any, "price": item_addon.price as Any, "url": item_addon.url as Any, "category": item_addon.category as Any, "type": item_addon.type as Any, "restaurant_id": item_addon.Restaurant_ID as Any, "timeStamp": FieldValue.serverTimestamp(), "userUID": Auth.auth().currentUser!.uid, "quanlity": 1]
                    
                    let db = DataService.instance.mainFireStoreRef.collection("Cart")
                    
                    
                    
                    db.addDocument(data: dict) { err in
                      
                          if let err = err {
                              
                              SwiftLoader.hide()
                              self.showErrorAlert("Opss !", msg: err.localizedDescription)
                              
                          } else {
                         
                            self.Add_on.remove(at: row)
                            self.collectionView.reloadData()
                            
                            SwiftLoader.hide()
                            loadAlertAnimation(title: "Conratulation", desc: "You have added to cart succesfully")
                            
                        
                        }
                        
                        
                    }
                    
                } else {
                    
                    
                    for item in snaps!.documents {
                            
                            if let count = item.data()["quanlity"] as? Int {
                                
                                let id = item.documentID
                                 DataService.instance.mainFireStoreRef.collection("Cart").document(id).updateData(["quanlity": count+1, "timeStamp": FieldValue.serverTimestamp()])
                                
                                self.Add_on.remove(at: row)
                                self.collectionView.reloadData()
           
                                SwiftLoader.hide()
                                loadAlertAnimation(title: "Conratulation", desc: "You have added to cart succesfully")
                                    
                                    
                                }
                            
                    }
                    
                }
                   
                       
                           
                        
            
            
            
            
                       
            }
            
            
            
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    @IBAction func plusBtn(_ sender: Any) {
        
        quanlity += 1
        quanlityLbl.text = "\(quanlity)"
        let price = item.price * Float(quanlity)
        priceTxt.text = "$\(price)"
        
    }
    
    
    @IBAction func MinusBtn(_ sender: Any) {
        
        if quanlity == 1 {
            
            quanlity = 1
            quanlityLbl.text = "\(quanlity)"
            
            let price = item.price * Float(quanlity)
            priceTxt.text = "$\(price)"
            
        } else {
            
            quanlity -= 1
            quanlityLbl.text = "\(quanlity)"
            
            let price = item.price * Float(quanlity)
            priceTxt.text = "$\(price)"
            
        }
        
    }
    
    
    
    func loadAlert(message: String) {
        
        var attributes = EKAttributes.centerFloat
        
        
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.entryBackground = .color(color: .dimmedDarkBackground)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.screenBackground = .color(color: EKColor.dimmedDarkBackground)
        attributes.screenInteraction = .absorbTouches
    
        
        // Generate textual content
        let title = EKProperty.LabelContent(text: "Hi there!", style: .init(font: MainFont.medium.with(size: 15), color: .white, alignment: .center))
        let description = EKProperty.LabelContent(text: message, style: .init(font: MainFont.light.with(size: 13), color: .white, alignment: .center))
        let image = EKProperty.ImageContent(imageName: "uEAT_logo", size: CGSize(width: 25, height: 25), contentMode: .scaleAspectFit)
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)

        
        // Generate buttons content
        let buttonFont = MainFont.medium.with(size: 16)

        
        // Ok Button
        let okButtonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: EKColor.white)
        let okButtonLabel = EKProperty.LabelContent(text: "Proceed", style: okButtonLabelStyle)
        let okButton = EKProperty.ButtonContent(label: okButtonLabel, backgroundColor: .clear, highlightedBackgroundColor:  EKColor.black) {
            
            SwiftEntryKit.dismiss()
            self.removeElement()
            
        
        }
        
        
        // Ok Button
        let CancelButtonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: EKColor.white)
        let CancelButtonLabel = EKProperty.LabelContent(text: "Cancel", style: CancelButtonLabelStyle)
        let CancelButton = EKProperty.ButtonContent(label: CancelButtonLabel, backgroundColor: .clear, highlightedBackgroundColor:  EKColor.black) {
            
            
            SwiftEntryKit.dismiss()
            
            
        }
        
        // Generate the content
        let buttonsBarContent = EKProperty.ButtonBarContent(with: okButton, CancelButton, separatorColor: EKColor.chatMessage, expandAnimatedly: true)
        
        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)

        // Setup the view itself
        let contentView = EKAlertMessageView(with: alertMessage)
        
        SwiftEntryKit.display(entry: contentView, using: attributes)
        
        
        
        
    }
    
    
}
