//
//  OrderDetailVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 6/20/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase

class OrderDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var restaurantNameLbl: UILabel!
    @IBOutlet weak var OrderNumberLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var PromoLbl: UILabel!
    
    @IBOutlet weak var SubtotalPrice: UILabel!
    @IBOutlet weak var ApplicationFee: UILabel!
    @IBOutlet weak var TaxFee: UILabel!
    @IBOutlet weak var TotalFee: UILabel!
    
    
    var detail = [OrderDetailModel]()
    
    var check_order_id = ""
    var check_restaurant_name = ""
    var check_status = ""
    var promo_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        restaurantNameLbl.text = check_restaurant_name
        OrderNumberLbl.text = "Order #CC - \(check_order_id)"
    
        
        if check_status == "Started" {
            
            statusLbl.text = "Being prepared"
            
        } else if check_status == "Processed" {
            
            statusLbl.text = "Processed"
            
        } else if check_status == "Cooked" {
            
            statusLbl.text = "Picking up"
            
        } else if check_status == "Completed" {
            
            statusLbl.text = "Completed"
            
        }
        
        if let uid = Auth.auth().currentUser?.uid {
            
            
            LoadOrderDetail(uid: uid)
            
        }
        
        
        
    }
    
    func LoadOrderDetail(uid: String) {
        
        //detail.removeAll()
        
        DataService.instance.mainFireStoreRef.collection("Orders_detail").whereField("userUID", isEqualTo: uid).whereField("Order_id", isEqualTo: Int(self.check_order_id)!).getDocuments { (snaps, err) in
        
        if err != nil {
            
            self.showErrorAlert("Opss !", msg: err!.localizedDescription)
            return
            
        }
            if snaps?.isEmpty == true {
                
                print("Can't load order \(self.check_order_id)")
                return
                
            }
        
            for item in snaps!.documents {
                
                let dict = OrderDetailModel(postKey: item.documentID, Item_model: item.data())
                self.detail.append(dict)
                
                
            }
            
            self.caculateSummary()
            self.tableView.reloadData()
            
            
            
            
        }
        
        
        
    }
    
    
    func caculateSummary() {
        
        
        var subtotal: Float!
        var stripeFee: Float!
        var Application: Float!
        var Tax: Float!
        var total: Float!
        
        subtotal = 0.0
        Application = 0.0
        Tax = 0.0
        total = 0.0
        stripeFee = 0.0
        
        for i in detail {
            
            let quanlity = i._NewQuanlity
            let price = i.price * Float(quanlity!)
            subtotal += price
            
        }
        
        if promo_id != "Nil" {
            
            checkpromo(subtotal: subtotal, Promo_id: promo_id)
            
        } else {
            
            stripeFee = subtotal * 2.9 / 100 + 0.3
            Application = subtotal * 5 / 100 + stripeFee
            Tax = subtotal * 9 / 100
            let promo = 0.0
            total = subtotal + Application + Tax
            

            
            SubtotalPrice.text = "$\(String(format:"%.2f", subtotal!))"
            ApplicationFee.text = "$\(String(format:"%.2f", Application!))"
            TaxFee.text = "$\(String(format:"%.2f", Tax!))"
            PromoLbl.text = "$\(String(format:"%.2f", promo))"
            TotalFee.text = "$\(String(format:"%.2f", total!))"
        }
        
    
      
    }
    
    
    func checkpromo(subtotal: Float, Promo_id: String) {
        
       DataService.instance.mainFireStoreRef.collection("Voucher").getDocuments { (snap, err) in
              
                  
              if err != nil {
                  
                  let stripeFee = subtotal * 2.9 / 100 + 0.3
                  let Application = subtotal * 5 / 100 + stripeFee
                  let Tax = subtotal * 9 / 100
                  let promo = 0.0
                  let total = subtotal + Application + Tax
                  

                  
                self.SubtotalPrice.text = "$\(String(format:"%.2f", subtotal))"
                self.ApplicationFee.text = "$\(String(format:"%.2f", Application))"
                self.TaxFee.text = "$\(String(format:"%.2f", Tax))"
                self.PromoLbl.text = "$\(String(format:"%.2f", promo))"
                self.TotalFee.text = "$\(String(format:"%.2f", total))"
                  
                  return
                  
              }
                  
                  if snap?.isEmpty == true {
                      
                      let stripeFee = subtotal * 2.9 / 100 + 0.3
                        let Application = subtotal * 5 / 100 + stripeFee
                        let Tax = subtotal * 9 / 100
                        let promo = 0.0
                        let total = subtotal + Application + Tax
                        

                        
                      self.SubtotalPrice.text = "$\(String(format:"%.2f", subtotal))"
                      self.ApplicationFee.text = "$\(String(format:"%.2f", Application))"
                      self.TaxFee.text = "$\(String(format:"%.2f", Tax))"
                      self.PromoLbl.text = "$\(String(format:"%.2f", promo))"
                      self.TotalFee.text = "$\(String(format:"%.2f", total))"
                      
                      return
                      
                      
                  } else {
                     
                      
                      var count = 0
                      var found = false
                      let limit = snap?.count
                    
                      for item in snap!.documents {
                          
                          count += 1
                          if item.documentID == Promo_id {
                              
                              
                              found = true
                              
                              let data = PromotionModel(postKey: item.documentID, Voucher_model: item.data())
                              
                             
                              
                              if data.type == "%" {
                                              
                                              if let percentage = data.value as? String {
                                              
                                                  let new = Float(percentage)
                                                  let promo = subtotal*new!/100
                                                  
                                                  
                                                  let AdjustSubtotal = subtotal - promo
                                                  let stripeFee = AdjustSubtotal * 2.9 / 100 + 0.3
                                                  let Application = AdjustSubtotal * 5 / 100 + stripeFee
                                                  let Tax = AdjustSubtotal * 9 / 100
                                        
                                                  let total = AdjustSubtotal + Application + Tax
                                                  

                                                  
                                                self.SubtotalPrice.text = "$\(String(format:"%.2f", subtotal))"
                                                self.ApplicationFee.text = "$\(String(format:"%.2f", Application))"
                                                self.TaxFee.text = "$\(String(format:"%.2f", Tax))"
                                                self.PromoLbl.text = "-$\(String(format:"%.2f", promo))"
                                                self.TotalFee.text = "$\(String(format:"%.2f", total))"
                                                                                                  
                                              }
                                                  else {
                                                                  
                                                  print("Can't convert \(data.value!)")
                                                  
                                              }
                                              
                                            
                                          } else if data.type == "$" {
                                          
                                              
                                              if let minus = data.value as? String {
                              
                                                let new = Float(minus)
                                                var promo: Float!
                                                promo =  new
                                                var AdjustSubtotal = subtotal - new!
                                                  
                                                if AdjustSubtotal <= 0 {
                                                      AdjustSubtotal = 0.0
                                                }
                                                  
                                                let stripeFee = AdjustSubtotal * 2.9 / 100 + 0.3
                                                let Application = AdjustSubtotal * 5 / 100 + stripeFee
                                                let Tax = AdjustSubtotal * 9 / 100
                                                
                                                let total = AdjustSubtotal + Application + Tax
                                                          

                                                          
                                                self.SubtotalPrice.text = "$\(String(format:"%.2f", subtotal))"
                                                self.ApplicationFee.text = "$\(String(format:"%.2f", Application))"
                                                self.TaxFee.text = "$\(String(format:"%.2f", Tax))"
                                                self.PromoLbl.text = "-$\(String(format:"%.2f", promo))"
                                                self.TotalFee.text = "$\(String(format:"%.2f", total))"
                                                  
                                              }
                                              else {
                                                  
                                                  print("Can't convert \(data.value!)")
                                              }
                                     
                                              
                                              
                                          } else {
                                              print("Unknown \(data.type!)")
                                          }
                              
                              
                          }
                          
                      }
                      
                      
                      if count == limit!, found == false {
                          
                          let stripeFee = subtotal * 2.9 / 100 + 0.3
                            let Application = subtotal * 5 / 100 + stripeFee
                            let Tax = subtotal * 9 / 100
                            let promo = 0.0
                            let total = subtotal + Application + Tax
                            

                            
                          self.SubtotalPrice.text = "$\(String(format:"%.2f", subtotal))"
                          self.ApplicationFee.text = "$\(String(format:"%.2f", Application))"
                          self.TaxFee.text = "$\(String(format:"%.2f", Tax))"
                          self.PromoLbl.text = "$\(String(format:"%.2f", promo))"
                          self.TotalFee.text = "$\(String(format:"%.2f", total))"
                          
                          return
                          
                        
                          
                      }
                      
                      
                      
                      
                  }
       
              
                  
                  
                  
              }
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
    
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return detail.count
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = detail[indexPath.row]
                   
        if let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailCell") as? OrderDetailCell {
         
         if indexPath.row != 0 {
             let color = self.view.backgroundColor
             let lineFrame = CGRect(x:0, y:-20, width: self.view.frame.width, height: 40)
             let line = UIView(frame: lineFrame)
             line.backgroundColor = color
             cell.addSubview(line)
             
         }
            
            cell.configureCell(item)

            return cell
                       
        } else {
                       
            return OrderDetailCell()
                       
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100.0
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
    
    @IBAction func viewStatusBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToStatusVC", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "moveToStatusVC"{
            if let destination = segue.destination as? OrderStatusVC
            {
                
                

                destination.status_order_id = self.check_order_id
               
                
            }
        }
        
        
    }
}
