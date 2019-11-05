//
//  PaymentVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 11/5/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import PassKit
import Stripe
import Alamofire
import MGSwipeTableCell
import Firebase

class PaymentVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    var defaultID = ""
    
    let SupportedPaymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex, PKPaymentNetwork.discover]
    
    var paymentArr = [PaymentModel]()
    //var listCard = [[PaymentModel]]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
       
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if let uid = Auth.auth().currentUser?.uid {
            
            storage.async.object(forKey: uid) { result in
             switch result {
                 
                 case .value(let user):
                    
                    self.checkDefault {
                        
                        self.RetrieveCard(cus_id: user.stripe_cus) {
                            
                            self.loadApplePay()
                            
                        }
                        
                    }
                    
                 
                 case .error( _):
                    
                    self.showErrorAlert("Opss !", msg: "Can't load your payment, please sign out and try to login again")
                 }
                 
             }
            
        }
        
        
        
        
    }
    
    func checkDefault(completed: @escaping DownloadComplete) {
        
        if let uid = Auth.auth().currentUser?.uid {
            
            DataService.instance.checkDefaultUserRef.child(uid).observeSingleEvent(of: .value, with: { (snapData) in
                
                if snapData.exists() {
                    
                    if let dict = snapData.value as? Dictionary<String, Any> {
                        
                        if let defaultIDs = dict["defaultID"] as? String {
                            
                            self.defaultID = defaultIDs
                            
                        } else {
                            
                            self.defaultID = ""
                            
                        }
                        
                        completed()
                        
                    }
                    
                } else {
                    
                    self.defaultID = ""
                    completed()
                    
                    
                    
                }
                
                
                
            })
            
        }
        
        
        
    }
    
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    func loadApplePay () {
        
        
        // load apple pay
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: self.SupportedPaymentNetworks) == true {
                   
            let paymentInfo: Dictionary<String, AnyObject> = ["Brand": "Apple_pay" as AnyObject]
            let PaymentData = PaymentModel(postKey: "Apple_pay", PaymentModel: paymentInfo)
            self.paymentArr.append(PaymentData)
            self.tableView.reloadData()
                   
        } else {
                   
            print("Not supported")
                   
        }

        
        
        
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
    
        return paymentArr.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return paymentArr.count + 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
         if indexPath.row < paymentArr.count {
            
            let payment = paymentArr[indexPath.row]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell") as? PaymentCell {
                
                if indexPath.row > 0 {
                    
                    let lineFrame = CGRect(x:20, y:0, width: Double(self.view.frame.width) - 42, height: 1)
                    let line = UIView(frame: lineFrame)
                    line.backgroundColor = UIColor.lightGray
                    cell.addSubview(line)
                    
                }
                //cell.delegate = self
                cell.configureCell(payment)
                
                return cell
                
            } else {
                
                return PaymentCell()
                
            }
            
         } else {
             
             if let cell = tableView.dequeueReusableCell(withIdentifier: "addNewPaymentCell") as? addNewPaymentCell {

                 cell.addCardBtn.addTarget(self, action: #selector(PaymentVC.addCardBtnPressed), for: .touchUpInside)
                 return cell
                 
                 
             } else {
                 
                 return addNewPaymentCell()
                 
             }
         }

    
        
        
    }
    
    @objc func addCardBtnPressed() {
        
        print("Pressed")
        //NotificationCenter.default.addObserver(self, selector: #selector(PaymentVC.refreshPayment), name: (NSNotification.Name(rawValue: "refreshPayment")), object: nil)
        //self.performSegue(withIdentifier: "moveTochoosePaymentVC", sender: nil)
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90.0
    }
    
    func RetrieveCard(cus_id: String, completed: @escaping DownloadComplete) {
        
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("customers_card")

        Alamofire.request(urls!, method: .post, parameters: [
            
            "cus_id": cus_id
            
            ])
            
            .validate(statusCode: 200..<500)
            .responseJSON { responseJSON in
                
            switch responseJSON.result {
                    
                case .success(let json):
                    
                    if let dict = json as? [String: AnyObject] {
                        
                        for i in dict {
                            
                            if let result = i.value as? [Dictionary<String, AnyObject>] {
                                
                                for x in result {
                                    
                                    let paymentInfo: Dictionary<String, AnyObject> = ["Last4": x["last4"] as AnyObject, "Exp_month": x["exp_month"] as AnyObject, "Brand": x["brand"] as AnyObject, "Id": x["id"] as AnyObject, "Exp_year": x["exp_year"] as AnyObject, "Funding": x["funding"] as AnyObject, "Fingerprint": x["fingerprint"] as AnyObject, "Country": x["country"] as AnyObject]
                                    
                                    let PaymentData = PaymentModel(postKey: x["id"] as! String, PaymentModel: paymentInfo)
                                    
                                    let id = x["id"] as? String
                                    
                                    if id == self.defaultID {
                                        
                                        
                                        self.paymentArr.insert(PaymentData, at: 0)
                                        
                                        
                                    } else {
                                        
                                        self.paymentArr.append(PaymentData)
                                        
                                    }

                                    
                                    self.tableView.reloadData()
                                    
                                    
                                }
                                
                                completed()
                                
                            }
                            
                        }
                        
                    }
                    
                    
                case .failure(let error):
                    
                    print(error)
                    completed()
                    
                }
                
                
                
        }
        
        
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
