//
//  OrderStatusVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 6/20/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase

class OrderStatusVC: UIViewController {
    
    let didPrepareItem = UIImage(named: "prep_icn")
    let PreparedItem = UIImage(named: "prep_active_icn")
    let didReadyItem = UIImage(named: "pickup_icn")
    let ReadyItem = UIImage(named: "pickup_active_icn")

    @IBOutlet weak var prepareImg: UIImageView!
    @IBOutlet weak var pickupImg: UIImageView!
    @IBOutlet weak var timeApprovedLbl: UILabel!
    @IBOutlet weak var timePreparingLbl: UILabel!
    @IBOutlet weak var timePickupLbl: UILabel!
    
    var status_order_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let uid = Auth.auth().currentUser?.uid {
            
            if uid != "", status_order_id != "" {
                
                loadOrderStatus(uid: uid, order_id: status_order_id)
                
            } else {
                  
                print(status_order_id)
            
            }
    
            
        }
        
        
    }
    
    func loadOrderStatus(uid: String, order_id: String) {
        
        DataService.instance.mainFireStoreRef.collection("Processing_orders").whereField("userUID", isEqualTo: uid).whereField("Order_id", isEqualTo: Int(order_id)!).getDocuments { (snap, err) in
                  
                  if err != nil {
                      

                      self.showErrorAlert("Opss !", msg: "Can't load your recent orders")
                      return
                      
                  }

                      
                      for item in snap!.documents {
                          
                          
                        if let status = item.data()["Status"] as? String {
                            
                            
                            if status == "Processed" {
               
                                self.prepareImg.image = self.didPrepareItem
                                self.pickupImg.image = self.didReadyItem
                                
                                if let date = item.data()["Order_time"] {
                                    
                                    if let times = date as? Date {
                                        
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateStyle = .medium
                                        dateFormatter.timeStyle = .short
                                        let final = dateFormatter.string(from: times)
                                        
                                        
                                        self.timeApprovedLbl.text = final
                                        self.timePreparingLbl.text = ""
                                        self.timePickupLbl.text = ""
                                        
                                        
                                    }
                                    
                                }
                                
                            } else if status == "Started" {
                                
              
                                self.prepareImg.image = self.PreparedItem
                                self.pickupImg.image = self.didReadyItem
                                
                                if let date = item.data()["Order_time"] {
                                    
                                    if let times = date as? Date {
                                        
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateStyle = .medium
                                        dateFormatter.timeStyle = .short
                                        let final = dateFormatter.string(from: times)
                                        
                                        
                                        self.timeApprovedLbl.text = ""
                                        self.timePreparingLbl.text = final
                                        self.timePickupLbl.text = ""
                                        
                                        
                                        
                                        
                                        
                                    }
                                    
                                }
                                
                            } else if status == "Cooked" {
                                
                                self.prepareImg.image = self.PreparedItem
                                self.pickupImg.image = self.ReadyItem
                                
                                if let date = item.data()["Order_time"] {
                                    
                                    if let times = date as? Date {
                                        
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateStyle = .medium
                                        dateFormatter.timeStyle = .short
                                        let final = dateFormatter.string(from: times)
                                        
                                        
                                        self.timeApprovedLbl.text = ""
                                        self.timePreparingLbl.text = ""
                                        self.timePickupLbl.text = final
        
                                        
                                    }
                                    
                                }
                                
                            } else if status == "Completed" {
                                
                                self.prepareImg.image = self.PreparedItem
                                self.pickupImg.image = self.ReadyItem
                                                        
                                if let date = item.data()["Order_time"] {
                                                            
                                    if let times = date as? Date {
                                                                
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateStyle = .short
                                            dateFormatter.timeStyle = .short
                                            let final = dateFormatter.string(from: times)
                                                                
                                                                
                                            self.timeApprovedLbl.text = ""
                                            self.timePreparingLbl.text = ""
                                            self.timePickupLbl.text = "Picked up at \(final)"
                                
                                                                
                                        }
                                                            
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
    
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
}
