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

    var theme = STPTheme.default()
    @IBOutlet weak var tableView: UITableView!
    
    var defaultID = ""
    
    let SupportedPaymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex, PKPaymentNetwork.discover]
    
    var paymentArr = [PaymentModel]()
    let themeViewController = ThemeViewController()
    
    var stripeIDs = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
       tableView.delegate = self
       tableView.dataSource = self
       tableView.allowsSelection = true
        
       loadPayment()
       loadStripe()
        
        
        
    }
    
    func loadStripe() {
        
        storage.async.object(forKey: Auth.auth().currentUser!.uid) { result in
            switch result {
                
            case .value(let user):

                self.stripeIDs = user.stripe_cus
                   
            case .error( _):
                
                
                SwiftLoader.hide()
                self.showErrorAlert("Oopps !!!", msg: "Cache Error, please log out and login again")
                
         }
            
       }
        
        
    }
    
    func loadPayment() {
         
        paymentArr.removeAll()
        
        if let uid = Auth.auth().currentUser?.uid {
            
            storage.async.object(forKey: uid) { result in
             switch result {
                 
                 case .value(let user):
                    
                    self.RetrieveCard(cus_id: user.stripe_cus) {
                        
                        self.loadApplePay()
                        
                    }
                
                 
                 case .error( _):
                    
                    self.showErrorAlert("Opss !", msg: "Can't load your payment, please sign out and try to login again")
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
    
    
    
    
    func loadApplePay () {
        
        
        let paymentInfo: Dictionary<String, AnyObject> = ["Brand": "Apple_pay" as AnyObject]
        
        let PaymentData = PaymentModel(postKey: "Apple_pay", PaymentModel: paymentInfo)
        
        self.paymentArr.append(PaymentData)
        self.tableView.reloadData()
        
        
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
    
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return paymentArr.count + 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
         if indexPath.row < paymentArr.count {
            
            let payment = paymentArr[indexPath.row]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell") as? PaymentCell {
                
                
                cell.delegate = self
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = paymentArr[indexPath.row]
        
        
        chargedCardID = card.Id
        cardBrand = card.Brand
        cardLast4Digits = card.Last4
        
        
        
        chargedlast4Digit = card.Last4
        chargedCardBrand = card.Brand
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "setPayment")), object: nil)
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        return true;
    }
    
    // Fetch object from the cache
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        

        
        let color = UIColor(red: 249/255, green: 252/255, blue: 254/255, alpha: 1.0)
        
        swipeSettings.transition = MGSwipeTransition.border;
        expansionSettings.buttonIndex = 0
        let padding = 25
        if direction == MGSwipeDirection.rightToLeft {
            expansionSettings.fillOnTrigger = false;
            expansionSettings.threshold = 1.1
            

            let RemoveResize = resizeImage(image: UIImage(named: "remove")!, targetSize: CGSize(width: 25.0, height: 25.0))
            let defaultResize = resizeImage(image: UIImage(named: "default")!, targetSize: CGSize(width: 25.0, height: 25.0))
        
            
            
            let remove = MGSwipeButton(title: "", icon: RemoveResize, backgroundColor: color, padding: padding,  callback: { (cell) -> Bool in
                
                
                
                
                self.deleteAtIndexPath(self.tableView.indexPath(for: cell)!, stripe_id: self.stripeIDs)
                
                return false; //don't autohide to improve delete animation
                
                
            });
            
            
            
            let defaults = MGSwipeButton(title: "", icon: defaultResize, backgroundColor: color, padding: padding, callback: { (cell) -> Bool in
                
              
                self.defaultAtIndexPath(self.tableView.indexPath(for: cell)!, stripe_id: self.stripeIDs)
                
                return false; //autohide
                
            });
            
            return [defaults, remove]
        } else {
            
            return nil
        }
           
        
    }
    
    
    func deleteAtIndexPath(_ path: IndexPath, stripe_id: String) {
           
        let card = paymentArr[path.row]
        
        if card.Brand != "Apple_pay" {
            
            swiftLoader()
            
            let url = MainAPIClient.shared.baseURLString
            let urls = URL(string: url!)?.appendingPathComponent("delete_card")
            
            
            AF.request(urls!, method: .post, parameters: [
                
                "Card_Id": card.Id!,
                "cus_id": stripe_id,
                
                ])
                
                .validate(statusCode: 200..<500)
                .responseJSON { responseJSON in
                    
                    switch responseJSON.result {
                        
                    case .success( _):
                        
                        SwiftLoader.hide()
                        let fingerPrint = card.Fingerprint
                        DataService.instance.mainRealTimeDataBaseRef.child("fingerPrint").child(Auth.auth().currentUser!.uid).child(fingerPrint!).removeValue()
                        self.paymentArr.remove(at: (path as NSIndexPath).row)
                        self.tableView.deleteRows(at: [path], with: .left)
                        
                        if defaultCardID == card.Id {
                            
                        
                            if self.paymentArr.isEmpty != true {
                                
                                let next = self.paymentArr[0]
                                
                       
                                
                                if next.Brand != "Apple_pay" {
                                    
                                    defaultCardID = next.Id
                                    defaultcardLast4Digits = next.Last4
                                    defaultBrand = next.Brand
                                    
                                    
                                    
                                } else {
                                    
                                    defaultCardID = ""
                                    chargedCardID = ""
                                    chargedlast4Digit = ""
                                    chargedCardBrand = ""

                                    cardID = ""
                                    cardBrand = ""
                                    cardLast4Digits = ""

                                    defaultBrand = ""
                                    defaultcardLast4Digits = ""
                                    
                                }
                                
                                
                                
                            }
                            
                         
                        }

                      
                    case .failure(let error):
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops !!!", msg: error.localizedDescription)
                        
                    }
                                   
            }
            
        } else {
            
            SwiftLoader.hide()
            self.showErrorAlert("Oops !!!", msg: "Cannot remove Apple pay")
            
            
        }
        
    }
    
     func defaultAtIndexPath(_ path: IndexPath, stripe_id: String) {
   
        let card = paymentArr[path.row]
        
        if card.Brand != "Apple_pay" {
            
            DataService.instance.mainRealTimeDataBaseRef.child("Default_Card").child(Auth.auth().currentUser!.uid).child(card.Id).observeSingleEvent(of: .value, with: { (snap) in
            
                if snap.exists() {
                    
                     self.showErrorAlert("Oops !!!", msg: "This is already your default card ")
                    
                } else {
                    
                    self.swiftLoader()
                    
                    let url = MainAPIClient.shared.baseURLString
                    let urls = URL(string: url!)?.appendingPathComponent("set_default")
                    
                    AF.request(urls!, method: .post, parameters: [
                        
                        "Card_Id": card.Id!,
                        "cus_id": stripe_id,
                        
                        ])
                        
                        .validate(statusCode: 200..<500)
                        .responseJSON { responseJSON in
                            
                            switch responseJSON.result {
                                
                            case .success( _):
                                
                                
                                SwiftLoader.hide()
                                DataService.instance.mainRealTimeDataBaseRef.child("Default_Card").child(Auth.auth().currentUser!.uid).removeValue()
                            DataService.instance.mainRealTimeDataBaseRef.child("Default_Card").child(Auth.auth().currentUser!.uid).child(card.Id).setValue(["Timestamp": ServerValue.timestamp()])
                                
                                //card.Id
                                
                                defaultCardID = card.Id
                                defaultcardLast4Digits = card.Last4
                                defaultBrand = card.Brand
                                
                                self.paymentArr.remove(at: (path as NSIndexPath).row)
                                self.paymentArr.insert(card, at: 0)
                                self.tableView.reloadData()
                                
                                
                                
                            case .failure(let error):
                                
                                SwiftLoader.hide()
                                self.showErrorAlert("Oops !", msg: error.localizedDescription)
                                
                                
                            }
                            
                    }
                    
                }
                
            })
            
        } else {
            
            SwiftLoader.hide()
            self.showErrorAlert("Oops !", msg: "Cannot default Apple pay")
            
            
        }
        
        
        
    }
    
    @objc func addCardBtnPressed() {
        
        //sendSmsNoti(Phone: "+16036179650", text: "You order is ready to pickup")
        
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentVC.refreshPayment), name: (NSNotification.Name(rawValue: "refreshPayment")), object: nil)
        
  
       self.performSegue(withIdentifier: "MoveToAddCardVC", sender: nil)
 
        
    }
    
    
    func sendSmsNoti(Phone: String, text: String) {
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("sms_noti")
        
        AF.request(urls!, method: .post, parameters: [
            
            "phone": Phone,
            "body": text
            
            
            ])
            
            .validate(statusCode: 200..<500)
            .responseJSON { responseJSON in
                
                switch responseJSON.result {
                    
                    
                case .success(let json):
                    
                    print( json)
                    
                case .failure(let err):
                    
                    print(err)
                }
                
        }
        
    }
    
    @objc func refreshPayment() {
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "refreshPayment")), object: nil)
        
        loadPayment()
        
        
    }

    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90.0
    }
    
    func RetrieveCard(cus_id: String, completed: @escaping DownloadComplete) {
        
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("customers_card")

        AF.request(urls!, method: .post, parameters: [
            
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
                                    
                                    self.paymentArr.append(PaymentData)

                                    
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


