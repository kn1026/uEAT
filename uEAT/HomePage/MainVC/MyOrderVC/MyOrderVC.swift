//
//  MyOrderVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 6/20/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase

class MyOrderVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var orderArr = [Recent_order_model]()
    
    var check_order_id = ""
    var check_restaurant_name = ""
    var check_status = ""
    var promo_id = ""
    
    private var pullControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        

        if let uid = Auth.auth().currentUser?.uid {
            
            loadOrders(uid: uid)
            
        }
        
        pullControl.tintColor = UIColor.black
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = pullControl
        } else {
            tableView.addSubview(pullControl)
        }
        
    }
    
    
    @objc private func refreshListData(_ sender: Any) {
          // self.pullControl.endRefreshing() // You can stop after API Call
           // Call API
           
           if let uid = Auth.auth().currentUser?.uid {
               
               loadOrders(uid: uid)
               
           }
           
       }
    
    @objc func loadOrders(uid: String) {
        
        
        
        DataService.instance.mainFireStoreRef.collection("Processing_orders").order(by: "Order_time", descending: true).whereField("userUID", isEqualTo: uid).limit(to: 20).getDocuments { (snaps, err) in
        
        if err != nil {
            
            self.showErrorAlert("Opss !", msg: err!.localizedDescription)
            return
            
        }
            
            self.orderArr.removeAll()
        
            for item in snaps!.documents {
                
                
                let i = item.data()
                let order = Recent_order_model(postKey: item.documentID, Order_model: i)
                self.orderArr.append(order)
                
                
                
            }
            
       
            self.tableView.reloadData()
            if self.pullControl.isRefreshing == true {
                self.pullControl.endRefreshing()
            }
            
            
            
        }
        
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
           
       
            if orderArr.isEmpty != true {
                
                tableView.restore()
                return 1
                
            } else {
                
                tableView.setEmptyMessage("Loading order !!!")
                return 1
                
            }
           
       }
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           
           
           return orderArr.count
           
           
           
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
           let item = orderArr[indexPath.row]
                      
           if let cell = tableView.dequeueReusableCell(withIdentifier: "MyOrderCell") as? MyOrderCell {
            
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
                          
               return MyOrderCell()
                          
           }
           
       }
       
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           
           return 100.0
       }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = orderArr[indexPath.row]
        
        check_order_id = item.Order_id
        check_restaurant_name = item.Restaurant_name
        check_status = item.Status
        promo_id = item.Promo_id
        
        
        self.performSegue(withIdentifier: "moveToOrderDetail", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "moveToOrderDetail"{
            if let destination = segue.destination as? OrderDetailVC
            {
                
                

                destination.check_order_id = self.check_order_id
                destination.check_restaurant_name = self.check_restaurant_name
                destination.check_status = self.check_status
                destination.promo_id = self.promo_id
               
                
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



}
