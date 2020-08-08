//
//  PromoVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 8/5/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase

class PromoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var restaurant_id = ""
    var voucher_list = [PromotionModel]()
    var orderArr = [CartModel]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = true
        
        if restaurant_id != "" {
            
            self.loadRestaurantVoucher(id: restaurant_id) {
                
                self.loadOwnerVoucher() {
                    
                    self.tableView.reloadData()
                    
                }
                
            }
            
        }
    }
    
    func loadRestaurantVoucher(id: String, completed: @escaping DownloadComplete) {
        
        
        let date = Date()
       
        DataService.instance.mainFireStoreRef.collection("Voucher").whereField("restaurant_id", isEqualTo: id).whereField("untilDate", isGreaterThan: date).getDocuments { (snap, err) in
        
        if err != nil {
            
            self.showErrorAlert("Opss !", msg: err!.localizedDescription)
            return
            
        }
            
            if snap?.isEmpty == true {
                
                completed()
                
            } else {
                
                var count = 0
                let limit  = snap?.count
                
                for item in snap!.documents {
                    
                    /*
                     
                    if let FromTimes = item.data()["fromDate"] as? Date {
                    
                    if date > FromTimes {
                        
                        let dict = PromotionModel(postKey: item.documentID, Voucher_model: item.data())
                        
                        self.voucher_list.append(dict)
                        
                    }
                    
                    }*/
                    
                     DataService.instance.mainRealTimeDataBaseRef.child("Promo_applied").child(Auth.auth().currentUser!.uid).child(item.documentID).observeSingleEvent(of: .value, with: { (snapInfo) in
                     
                     
                         if snapInfo.exists() {
                            
                            count += 1
                            
                         } else {
                            
                            
                            let dict = PromotionModel(postKey: item.documentID, Voucher_model: item.data())
                            self.voucher_list.append(dict)
                            
                            count += 1
                            
                        }
                        
                        if count == limit {
                            
                            completed()
                            
                        }
                        
                    })
                    
                    
                          
                }
                 
            }
        
        
        }
        
    }
    
    func loadOwnerVoucher(completed: @escaping DownloadComplete) {
        
        
        let date = Date()
        
        DataService.instance.mainFireStoreRef.collection("Voucher").whereField("Created by", isEqualTo: "Owner").whereField("untilDate", isGreaterThan: date).getDocuments { (snap, err) in
        
        if err != nil {
            
            self.showErrorAlert("Opss !", msg: err!.localizedDescription)
            return
            
        }
            
            if snap?.isEmpty == true {
                
                completed()
                
            } else {
                
                var count = 0
                let limit  = snap?.count
                
                for item in snap!.documents {
                           
                    DataService.instance.mainRealTimeDataBaseRef.child("Promo_applied").child(Auth.auth().currentUser!.uid).child(item.documentID).observeSingleEvent(of: .value, with: { (snapInfo) in
                     
                         if snapInfo.exists() {
                            
                            count += 1
                            
                         } else {
                            
                            let dict = PromotionModel(postKey: item.documentID, Voucher_model: item.data())
                            self.voucher_list.insert(dict, at: 0)
                            
                            count += 1
                            
                        }
                        
                        if count == limit {
                            
                            completed()
                            
                        }
                        
                    })
                    
                    
                    
                    /*
                    if let FromTimes = item.data()["fromDate"] as? Date {
                        
                        if date > FromTimes {
                            
                            let dict = PromotionModel(postKey: item.documentID, Voucher_model: item.data())
                            
                            self.voucher_list.insert(dict, at: 0)
                            
                        }
                        
                    }
                    */
                    
                }
                    
                    
                    
                }
            
            }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
    
        if voucher_list.isEmpty != true {
            
            tableView.restore()
            return 1
        } else {
            
            tableView.setEmptyMessage("Loading voucher !!!")
            return 1
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
         return voucher_list.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let item = voucher_list[indexPath.row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionCell") as? PromotionCell {
            
          
            cell.configureCell(item)
            return cell
                       
                       
        } else {
                       
            return PromotionCell()
                       
        }

   
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return ""
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90.0
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = voucher_list[indexPath.row]
        
        
        if item.status == "Online" {
            
            if item.Created_by == "Restaurant" {
                
                if item.category == "All menu" {
                    
           
                    if item.type == "%" {
                        
                        if let percentage = item.value as? String {
                        
                            let new = Float(percentage)
                            promo = AdjustSubtotal*new!/100
                            
                            
                            AdjustSubtotal = AdjustSubtotal - promo
                                                                            
                        }
                            else {
                                            
                            print("Can't convert \(item.value!)")
                            
                        }
                        Promo_id = item.Promo_id
                        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "adjustPrice")), object: nil)
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    } else if item.type == "$" {
                    
                        
                        if let minus = item.value as? String {
        
                            let new = Float(minus)
                            promo = new
                            AdjustSubtotal = AdjustSubtotal - new!
                            
                            if AdjustSubtotal <= 0 {
                                AdjustSubtotal = 0.0
                            }
                            Promo_id = item.Promo_id
                            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "adjustPrice")), object: nil)
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                        else {
                            
                            print("Can't convert \(item.value!)")
                        }
               
                        
                        
                    } else {
                        print("Unknown \(item.type!)")
                    }
                    
                    
                } else {
                    
                    var found = false
                    
                    var selectedItem: CartModel!
                    
                    for i in orderArr {
                        
                        if i.name == item.category {
                            found = true
                            selectedItem = i
                        }
                        
                    }
                    
                    if found ==  false {
                        
                        self.showErrorAlert("Oops !!!", msg: "This promotion doesn't work for your current order")
                        
                    } else {
                        
                        print("Works for thí order \(selectedItem.name!)")
                        
                        if item.type == "%" {
                            
                            if let percentage = item.value as? String {
                            
                                
                                if let single = selectedItem.price {
                                    
                                    let new = Float(percentage)
                                    promo = single*new!/100
                                    
                                    
                                   AdjustSubtotal = AdjustSubtotal - promo
                                    
                                    Promo_id = item.Promo_id
                                    NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "adjustPrice")), object: nil)
                                    
                                    self.dismiss(animated: true, completion: nil)
                                    
                                }
                                
                                                                                
                            }
                                else {
                                                
                                print("Can't convert \(item.value!)")
                                
                            }
                            
                            
                            
                        } else if item.type == "$" {
                            
                            if let minus = item.value as? String {
                            
                                let new = Float(minus)
                                promo = new
                                AdjustSubtotal = AdjustSubtotal - new!
                                                
                                if AdjustSubtotal <= 0 {
                                    AdjustSubtotal = 0.0
                                }
                            
                              Promo_id = item.Promo_id
                              NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "adjustPrice")), object: nil)
                              self.dismiss(animated: true, completion: nil)
                                                
                            }
                            else {
                                                
                                print("Can't convert \(item.value!)")
                          }
                            
                            
                        }
                        
                    }
                    
                }
                
            } else if item.Created_by == "Owner" {
                
                
                if item.category == "All" {
                    
                    if item.type == "%" {
                                    
                                    if let percentage = item.value as? String {
                                    
                                        let new = Float(percentage)
                                        promo = AdjustSubtotal*new!/100
                                        
                                        
                                        AdjustSubtotal = AdjustSubtotal - promo
                                                                                        
                                    }
                                        else {
                                                        
                                        print("Can't convert \(item.value!)")
                                        
                                    }
                                    
                                    Promo_id = item.Promo_id
                                    NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "adjustPrice")), object: nil)
                                    
                                    self.dismiss(animated: true, completion: nil)
                                    
                                } else if item.type == "$" {
                                
                                    
                                    if let minus = item.value as? String {
                    
                                        let new = Float(minus)
                                        promo = new
                                        AdjustSubtotal = AdjustSubtotal - new!
                                        
                                        if AdjustSubtotal <= 0 {
                                            AdjustSubtotal = 0.0
                                        }
                                        
                                        
                                        Promo_id = item.Promo_id
                                        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "adjustPrice")), object: nil)
                                        self.dismiss(animated: true, completion: nil)
                                        
                                    }
                                    else {
                                        
                                        print("Can't convert \(item.value!)")
                                    }
                           
                                    
                                    
                                } else {
                                    print("Unknown \(item.type!)")
                                }
                    
                    
                    
                    
                } else if item.category == "First user" {
                    
                    
                    DataService.instance.mainFireStoreRef.collection("Processing_orders").whereField("userUID", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snaps, err) in
                     
                     if err != nil {
                         
                         //self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                         return
                         
                     }
        
                     
                        if snaps?.isEmpty == true {
                            
                            if item.type == "%" {
                                            
                                if let percentage = item.value as? String {
                                            
                                    let new = Float(percentage)
                                    promo = AdjustSubtotal*new!/100
                                                
                                                
                                    AdjustSubtotal = AdjustSubtotal - promo
                                                                                                
                                }
                                    else {
                                                                
                                     print("Can't convert \(item.value!)")
                                                
                                }
                                
                                
                                Promo_id = item.Promo_id
                                NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "adjustPrice")), object: nil)
                                            
                                self.dismiss(animated: true, completion: nil)
                                            
                                } else if item.type == "$" {
                                        
                                            
                                    if let minus = item.value as? String {
                            
                                        let new = Float(minus)
                                        promo = new
                                        AdjustSubtotal = AdjustSubtotal - new!
                                                
                                        if AdjustSubtotal <= 0 {
                                            AdjustSubtotal = 0.0
                                        }
                                        
                                        
                                        Promo_id = item.Promo_id
                                        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "adjustPrice")), object: nil)
                                        self.dismiss(animated: true, completion: nil)
                                                
                                        }
                                        else {
                                                
                                            print("Can't convert \(item.value!)")
                                        }
                                   
                                            
                                            
                                        } else {
                                            print("Unknown \(item.type!)")
                                }
                            
                        } else {
                            
                            
                            self.showErrorAlert("Oops !!!", msg: "This promotion doesn't work for your current order")
                            
                        }
                         
                                    
                     }
                    
                    
                    
                } else if item.category == "Every 10th order" {
                    
                    
                    DataService.instance.mainFireStoreRef.collection("Processing_orders").whereField("userUID", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snaps, err) in
                                        
                        if err != nil {
                                            
                                
                            return
                                            
                        }
                        
                        if snaps?.isEmpty != true {
                            
                            if snaps!.count % 10 == 0 {
                                
                                if item.type == "%" {
                                                
                                    if let percentage = item.value as? String {
                                                
                                        let new = Float(percentage)
                                        promo = AdjustSubtotal*new!/100
                                                    
                                                    
                                        AdjustSubtotal = AdjustSubtotal - promo
                                                                                                    
                                    }
                                        else {
                                                                    
                                         print("Can't convert \(item.value!)")
                                                    
                                    }
                                    
                                    Promo_id = item.Promo_id
                                    NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "adjustPrice")), object: nil)
                                                
                                    self.dismiss(animated: true, completion: nil)
                                                
                                    } else if item.type == "$" {
                                            
                                                
                                        if let minus = item.value as? String {
                                
                                            let new = Float(minus)
                                            promo = new
                                            AdjustSubtotal = AdjustSubtotal - new!
                                                    
                                            if AdjustSubtotal <= 0 {
                                                AdjustSubtotal = 0.0
                                            }
                                            
                                            
                                            Promo_id = item.Promo_id
                                            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "adjustPrice")), object: nil)
                                            self.dismiss(animated: true, completion: nil)
                                                    
                                            }
                                            else {
                                                    
                                                print("Can't convert \(item.value!)")
                                            }
                                       
                                                
                                                
                                            } else {
                                                print("Unknown \(item.type!)")
                                    }
                                
                            } else {
                                
                                self.showErrorAlert("Oops !!!", msg: "You need more \(self.calculatemissing(num: snaps!.count)) orders to use this promotion")
                            }
                            
                        } else {
                            
                            
                            self.showErrorAlert("Oops !!!", msg: "This promotion doesn't work for your current order")
                            
                        }
                        
                        
                        
                    }
                    
                    
                    
                
                }

            }
            
        } else {
            
            self.showErrorAlert("Oops !!!", msg: "This voucher is currently not available")
            
        }

    }
    
    func calculatemissing(num: Int) -> String {
          
        var count = 0
        
        while count <= 9 {
            
            count += 1
            let total = count + num
         
            
            if total % 10 == 0 {
                
                return String(count)
                
            }
            
        }
        
        return "0"
        
    }
    

    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
                
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
