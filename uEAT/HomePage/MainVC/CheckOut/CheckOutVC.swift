//
//  CheckOutVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 6/17/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import SwiftEntryKit
import PassKit
import Stripe

class CheckOutVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var TotalLbl: UILabel!
    @IBOutlet weak var TaxLbl: UILabel!
    @IBOutlet weak var FeeLbl: UILabel!
    @IBOutlet weak var subtotalLbl: UILabel!
    @IBOutlet weak var PromoLbl: UILabel!
    @IBOutlet weak var SpecialTxtView: UITextView!
    
    @IBOutlet weak var AddPaymentBtn: UIButton!
    @IBOutlet weak var cardImg: UIImageView!
    @IBOutlet weak var cardLastFour: UILabel!
    
    
    var orderArr = [CartModel]()
    
    var promo: Float!
    
    var subtotal: Float!
    var isReturn = false
    var capturedKey = ""
    
    var count = 0
    var start = 0
    var restaurant_name = ""
    var restaurant_id = ""
    
    var totalItem = 0
    var itemProcessed = 0
    var delItem = 0
    var order_id = ""
    var restaurant_key = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SpecialTxtView.delegate = self
        SpecialTxtView.backgroundColor = UIColor.white
        
        
        
        
            
        loadPrice()
        
        if defaultcardLast4Digits == "" {
            
            AddPaymentBtn.setTitle("Add payment", for: .normal)
            AddPaymentBtn.setTitleColor(UIColor.black, for: .normal)
            
            cardLastFour.text = ""
            cardImg.image = nil
            
            
        } else {
            
            AddPaymentBtn.setTitle("", for: .normal)
            
            
            cardLastFour.text =  " •••• \(defaultcardLast4Digits)"
            cardImg.image = UIImage(named: defaultBrand)
            
        }
        
        
       
        
        
        
    }
    
    func loadPrice() {
        if let sub = subtotal {
             
            var new: Float!
            new = 0.0
            
            if promo != nil {
                
               new = sub * promo / 100
               
                
            } else {
                
                new = sub
                promo = 0.0
            }
            
            
            var Application: Float!
            var Tax: Float!
            var total: Float!
            var stripeFee: Float!
            
            
            Application = 0.0
            Tax = 0.0
            total = 0.0
            stripeFee = 0.0
            
            stripeFee = subtotal * 2.9 / 100 + 0.30
            Application = subtotal * 5 / 100 + stripeFee
            Tax = new * 9 / 100
            total = new + Application + Tax
            
            
            subtotalLbl.text = "$\(String(format:"%.2f", new))"
            FeeLbl.text = "$\(String(format:"%.2f", Application!))"
            TaxLbl.text = "$\(String(format:"%.2f", Tax!))"
            PromoLbl.text = "$\(String(format:"%.2f", promo!))"
            TotalLbl.text = "$\(String(format:"%.2f", total!))"
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }
    

    
    func textViewDidBeginEditing(_ textView: UITextView) {
           if textView.text == "Special instruction (Optional)" {
               
               textView.text = ""
               
           }
       }
       
       func textViewDidEndEditing(_ textView: UITextView) {
           if textView.text == "" {
               
               textView.text = "Special instruction (Optional)"
               
           }
    }
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    @IBAction func AddPaymentBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(CheckOutVC.setPayment), name: (NSNotification.Name(rawValue: "setPayment")), object: nil)
        self.performSegue(withIdentifier: "moveToSelectPaymentVC", sender: nil)
        
    }
    @IBAction func addPromoBtnPressed(_ sender: Any) {
        
        print("Promo button pressed")
        
    }
    
    @objc func setPayment() {
        
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "setPayment")), object: nil)
        

        if cardBrand == "Apple_pay" {
            
            cardLastFour.text = ""
            let icon = UIImage(named: "applepay_icn")
            cardImg.image = icon
            
            AddPaymentBtn.setTitle("", for: .normal)
            AddPaymentBtn.setTitleColor(UIColor.black, for: .normal)
            
            
        } else {
            
            let icon = UIImage(named: cardBrand)
            cardImg.image = icon
            cardLastFour.text = " •••• \(cardLast4Digits)"

            
            AddPaymentBtn.setTitle("", for: .normal)
            AddPaymentBtn.setTitleColor(UIColor.black, for: .normal)
         
        }
          
        
    }
    
    func getItem() {
        
        if let uid = Auth.auth().currentUser?.uid {
            
            DataService.instance.mainFireStoreRef.collection("Cart").whereField("userUID", isEqualTo: uid).getDocuments { (snaps, err) in
            
            if err != nil {
                
                self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                return
                
            }
                if snaps?.isEmpty == true {
                    
                    SwiftLoader.hide()
                    self.loadAlert(message: "You cart is empty")
                    
                    
                } else {
                    
                    self.count = snaps!.count
   
                    for item in snaps!.documents {
                        
                        if let url = item.data()["url"] as? String, let num = item.data()["quanlity"] as? Int {
                            
                            let id = item.documentID
                            self.checkAvailableStock(url: url, key: id, quanlity: num)
                            
                        }
                    
                    }
                
                    
                }
            
            }
            
        }
        
    }
    
    func checkAvailableStock(url: String, key: String, quanlity: Int) {
        
        DataService.instance.mainFireStoreRef.collection("Menu").whereField("url", isEqualTo: url).whereField("status", isEqualTo: "Online").getDocuments { (snap, err) in
        
        if err != nil {
            
            self.showErrorAlert("Opss !", msg: err!.localizedDescription)
            return
            
        }
            if snap?.isEmpty == true {
                
                DataService.instance.mainFireStoreRef.collection("Cart").document(key).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                        
                        self.isReturn = true
                        self.start += 1
                        
                        
                        
                        if self.start == self.count {
                            
                            self.startCheckOut()
                            
                        } else {
                            
                            print("Error check out 0")
                            
                        }
                       
                    }
                }
                
            } else {
                
                for item in snap!.documents {
                    
                    if let quan = item.data()["quanlity"] as? String {
                        
                        if quan == "None" {
                         
                            self.start += 1
                            
    
                            
                            if self.start == self.count {
                                
                                self.startCheckOut()
                                
                            } else {
                                
                                print("Error check out 1")
                                
                            }
                            
                        } else if quan == "0" {
                            
                            if let num = item.data()["count"] as? Int {
                                
                                if quanlity > num {
                                    
                                    DataService.instance.mainFireStoreRef.collection("Cart").document(key).delete() { err in
                                        if let err = err {
                                            print("Error removing document: \(err)")
                                        } else {
                                            print("Document successfully removed!")
                                            
                                            self.isReturn = true
                                            self.start += 1
                                            if self.start == self.count {
                                                
                                                self.startCheckOut()
                                                
                                            } else {
                                                
                                                print("Error check out 2")
                                                
                                            }
                                           
                                        }
                                    }
                                    
                                } else {
                                

                                
                                self.start += 1
                                if self.start == self.count {
                                    
                                    self.startCheckOut()
                                    
                                } else {
                                    
                                    print("Error check out 3")
                                    
                                }
                                
                                
                                
                            }
                            
                            
                            
                            } else {
                                
                                
                                DataService.instance.mainFireStoreRef.collection("Cart").document(key).delete() { err in
                                    if let err = err {
                                        print("Error removing document: \(err)")
                                    } else {
                                        print("Document successfully removed!")
                                        
                                        self.isReturn = true
                                        self.start += 1
                                        if self.start == self.count {
                                            
                                            self.startCheckOut()
                                             
                                        } else {
                                            
                                            print("Error check out 4")
                                            
                                        }
                                       
                                    }
                                }
                                
                                
                            }
                        
                        
                        } else {
                            
                            
                            DataService.instance.mainFireStoreRef.collection("Cart").document(key).delete() { err in
                                if let err = err {
                                    print("Error removing document: \(err)")
                                } else {
                                    print("Document successfully removed!")
                                    
                                    self.isReturn = true
                                    self.start += 1
                                    if self.start == self.count {
                                        
                                        self.startCheckOut()
                                        
                                    } else {
                                        
                                        print("Error check out 5")
                                        
                                    }
                                   
                                }
                            }
                            
                            
                        }
                    
                }
                
                }
    
            }
        
            
        }
        
             
    }
    
    func take_hold_clean(completed: @escaping DownloadComplete) {
            
        for i in orderArr {
            
            
            DataService.instance.mainFireStoreRef.collection("Menu").whereField("restaurant_id", isEqualTo: i.Restaurant_ID!).whereField("url", isEqualTo: i.url!).getDocuments { (snap, err) in
            
            if err != nil {
                
                self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                return
                
            }
            
                for item in snap!.documents {
                
                    let id = item.documentID
                    
                    if let quan = item.data()["quanlity"] as? String {
                    
                    if quan == "None" {
                     
                        DataService.instance.mainFireStoreRef.collection("Cart").whereField("url", isEqualTo: i.url!).getDocuments { (del, err) in
                        
                        if err != nil {
                            
                            self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                            return
                            
                        }
                            
                            for delitem in del!.documents {
                                
                                let delId = delitem.documentID
                                
                                DataService.instance.mainFireStoreRef.collection("Cart").document(delId).delete() { err in
                                if let err = err {
                                    print("Error removing document: \(err)")
                                } else {
                                        
                                    self.delItem += 1
                                    if self.delItem == self.totalItem {
                                        
                                        completed()
                                        
                                    }
                                
                                    }
                                    
                                }
                                
                            }
                            
                            
                        }
                        
                    } else if quan == "0" {
                        
                        if let num = item.data()["count"] as? Int {
                            
                            let new = num - i.quanlity
                            
                            
                            
                            
                            if new <= 0 {
                                
                                DataService.instance.mainFireStoreRef.collection("Menu").document(id).updateData(["status": "Offline", "count": 0])
                                
                            } else {
                                
                                DataService.instance.mainFireStoreRef.collection("Menu").document(id).updateData(["count": new])
                                
                            }
                            
                            
                            DataService.instance.mainFireStoreRef.collection("Cart").whereField("url", isEqualTo: i.url!).getDocuments { (del, err) in
                            
                            if err != nil {
                                
                                self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                                return
                                
                            }
                                
                                for delitem in del!.documents {
                                    
                                    let delId = delitem.documentID
                                    
                                    DataService.instance.mainFireStoreRef.collection("Cart").document(delId).delete() { err in
                                    if let err = err {
                                        print("Error removing document: \(err)")
                                    } else {
                                        
                                    self.delItem += 1
                                    if self.delItem == self.totalItem {
                                        
                                        completed()
                                    }
                                        
                                        }
                                        
                                    }
                                    
                                }
                                
                                
                            }
                            
                            
                            
                            
                        }
                        
                    }
                }
                    
                }
                
                
                
            }
            
            
        }
        
    }
    
    func startCheckOut() {
        
        
        print("Start check out ")
        
        if isReturn == true {
            
            SwiftLoader.hide()
            print("Start returning")
            //shadowView.isHidden = false
            loadAlert(message: "One or more items in your cart are not available, please check your cart and check out again !")
            
        } else {
            
            if chargedCardBrand != "Apple_pay" {
                
                if chargedCardID == "" {
                    
                    SwiftLoader.hide()

                    NotificationCenter.default.addObserver(self, selector: #selector(CheckOutVC.setPayment), name: (NSNotification.Name(rawValue: "setPayment")), object: nil)
                    self.performSegue(withIdentifier: "moveToSelectPaymentVC", sender: nil)
                    
                    return
                    
                }
                
            }
            
     
            if let txt = TotalLbl.text {
                
                if orderArr.isEmpty != true {
                    
                    swiftLoader(title: "Payment processing")
                    print("Start processing payment")
                    
                    let currentDateTime = Date()
                    
                    // initialize the date formatter and set the style
                    let formatter = DateFormatter()
                    formatter.timeStyle = .medium
                    formatter.dateStyle = .long
                    
                    // get the date time String from the date object
                    let result = formatter.string(from: currentDateTime)
                    let description = "Authorize payment for food ordering from uEAT at \(result)"
    
                    let price = String(txt.dropFirst())
                    
                    let new = price.toDouble()! * 100
                    
                  
                    if chargedCardBrand == "Apple_pay" {
                        
                        SwiftLoader.hide()
                        self.makeApple_pay(text: description)
                        
                    } else {
                        
                        makePayment(captured: false, price: new, message: description) {
                               
                               print("Payment completed")
                               self.swiftLoader(title: "Placing order")
                               self.totalItem = self.orderArr.count
                               self.placingOrder() {
                                   
                        
                                   
                                   self.take_hold_clean() {
                          
                                       self.createChatRoom()
                                       
                                       
                                   }
                                   
                                   
                               }
                               
                           }
                        
                    }

                    
                    
                } else {
                    
                    self.showErrorAlert("Opss !", msg: "Can't load cart")
                    
                }
                

                
            } else {
                
                
                
            }
            
        }
        
        self.isReturn = false
        self.start = 0
        self.count = 0

    }
    
    
    func placingOrder(completed: @escaping DownloadComplete) {
        
        // generate key - create information for order and create chat
        
        
        
        DataService.instance.mainFireStoreRef.collection("Order_id").getDocuments { (snap, err) in
        
        if err != nil {
            
            self.showErrorAlert("Opss !", msg: err!.localizedDescription)
            return
            
        }
            if snap?.isEmpty == true {
                
                SwiftLoader.hide()
                self.showErrorAlert("Opss !", msg: "Error loading for placing order")
                return
                
            }
                   
            for item in snap!.documents {
                
                if let recent_id = item.data()["Order_ID"] as? Int {
                    
                    let document_order_id = item.documentID
                    let Order_id = recent_id + 1
                      
                    var cnt = 0
                    
                    for i in self.orderArr {
                        
                        cnt += 1
   
                        if cnt == 1 {
                            
                            
                            DataService.instance.mainFireStoreRef.collection("Restaurant").whereField("Restaurant_id", isEqualTo: i.Restaurant_ID!).getDocuments { (business, err) in
                                
                                
                                if err != nil {
                                           
                                           self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                                           return
                                           
                                       }
                                           if business?.isEmpty == true {
                                               
                                               SwiftLoader.hide()
                                               self.showErrorAlert("Opss !", msg: "Error loading for placing order")
                                               return
                                               
                                    }
                                
                                
                                for z in business!.documents {
                                    
                                    if let businessName = z.data()["businessName"] as? String {
                                        
                                        let processing_orders = ["Order_id": Order_id as Any, "Restaurant_id": i.Restaurant_ID! as Any, "Restaurant_name": businessName as Any, "Status": "Processed" as Any, "userUID": Auth.auth().currentUser!.uid as Any, "Order_time": FieldValue.serverTimestamp()]
                                        
                                        
                                        DataService.instance.mainFireStoreRef.collection("Order_id").document(document_order_id).updateData(["Order_ID": Order_id, "Order_time": FieldValue.serverTimestamp()])
                                        
                                        
                                        let db = DataService.instance.mainFireStoreRef.collection("Processing_orders")
                                        DataService.instance.mainRealTimeDataBaseRef.child("Upcomming_order").child(i.Restaurant_ID!).setValue(["timeStamp": ServerValue.timestamp()])
                                         
                                        db.addDocument(data: processing_orders) { err in
                                          
                                              if let err = err {
                                                  
                                                  SwiftLoader.hide()
                                                  self.showErrorAlert("Opss !", msg: err.localizedDescription)
                                                  
                                              } else {
                                                
 
                                                self.itemProcessed += 1
                                                
                                                if self.itemProcessed > self.totalItem {
                                                    
                                                    completed()
                                                    
                                                }
                                                
                                            }
                                            
                                            
                                        }

                                        
                                    }
                                    
                                }
                                
                                
                            }

                            
                        }
                        
                        var specialRequest = ""
                        
                        if let instruction = self.SpecialTxtView.text, instruction != "", instruction != "Special instruction (Optional)" {
                            
                            specialRequest = instruction
                            
                        } else {
                            
                            
                            specialRequest = "None"
                            
                        }
     
                        
                        
                        self.restaurant_key = i.Restaurant_ID
                        self.order_id = String(Order_id)

                        
                        
                        let  orders_detail = ["Order_id": Order_id as Any, "Order_time": FieldValue.serverTimestamp(), "name": i.name as Any, "price": i.price as Any, "url": i.url as Any, "restaurant_id": i.Restaurant_ID as Any, "userUID": Auth.auth().currentUser!.uid, "quanlity": i.quanlity as Any, "special_Request": specialRequest as Any, "Captured_key": self.capturedKey]
                        
                        
                        let db = DataService.instance.mainFireStoreRef.collection("Orders_detail")
                         
                        db.addDocument(data: orders_detail) { err in
                          
                              if let err = err {
                                  
                                  SwiftLoader.hide()
                                  self.showErrorAlert("Opss !", msg: err.localizedDescription)
                                  
                              } else {

                                self.itemProcessed += 1
                                
                                if self.itemProcessed > self.totalItem {
                                    
                                    completed()
                                    
                                }
                            
                            }
                            
                            
                        }
                    
                        
                    }
                    
                
                    
                }
                
            }
            
            
        }
        
        
        
    }
    
    
    func createChatRoom() {
        
        let open = "Open"
        var ref: DocumentReference? = nil
        
        let chatInformation: Dictionary<String, AnyObject> = ["order_id": self.order_id as AnyObject, "timeStamp": FieldValue.serverTimestamp() , "Restaurant_ID": restaurant_key as AnyObject, "userUID": Auth.auth().currentUser!.uid as AnyObject, "Status": open as AnyObject]
        
        
        
        ref = DataService.instance.mainFireStoreRef.collection("Chat_orders").addDocument(data: chatInformation) { err in
            if let err = err {

                print("Error adding document: \(err)")
            } else {
                let chat_key = ref!.documentID
                DataService.instance.mainFireStoreRef.collection("Chat_orders").document(chat_key).updateData(["chat_key": chat_key])
                SwiftLoader.hide()
                self.loadAlert(message: "You order has been placed successfully, your order number is CC - \(self.order_id). You can now chat with the restaurant and keep track of your order. Thank you for choosing us !")
                
                
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
    
    @IBAction func PayNowBtnPressed(_ sender: Any) {
        
        
        swiftLoader(title: "Checking cart")
        getItem()
        
    }
    
    
    
    
    // payment processing
    
    func makePayment(captured: Bool, price: Double, message: String, completed: @escaping DownloadComplete) {
        
        //chargedCardID
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("pre_authorization")
        
        
        self.capturedKey = ""
        
        
        if let uid = Auth.auth().currentUser?.uid, uid != "" {
        
                 // Fetch object from the cache
                 storage.async.object(forKey: uid) { result in
                     switch result {
                         
                     case .value(let user):
                        let stripe_id = user.stripe_cus
                        let email = user.email
                        
                        
                        AF.request(urls!, method: .post, parameters: [
                            
                            "cus_id": stripe_id,
                            "amount": price,
                            "source": chargedCardID,
                            "captured": captured,
                            "description": message,
                            "receipt_email": email,
                            
                            
                            ])
                            
                            .validate(statusCode: 200..<500)
                            .responseJSON { responseJSON in
                                
                                switch responseJSON.result {
                                    
                                case .success(let json):
                                    
                                    
                                    if let dict = json as? [String: AnyObject] {
                                        
                                        
                                        if let outcome = dict["outcome"] as? Dictionary<String, AnyObject> {
                                            
                                            
                                            
                                            
                                            if let risk_level = outcome["risk_level"] as? String, let type = outcome["type"] as? String {
                                                
                                                if risk_level == "high" || risk_level == "elevated" || risk_level == "highest" || type == "issuer_declined" || type == "blocked"
                                                    || type == "invalid"
                                                    
                                                {
                                                    
                                                    
                                                    if let reason = outcome["reason"] as? String {
                                                        
                                                        SwiftLoader.hide()
                                                        self.capturedKey = ""
                                                        self.showErrorAlert("Oops !!!", msg: "This card is flagged by our system as fraudulent, please contact us and the payment will be released immediately - \(reason)")
                                                        
                                                        return
                                                        
                                                    }
                                                    
                                                    return
                                                }
                                                
                                                if let captureID = dict["id"] as? String {
                                                    
                                                    self.capturedKey = captureID
                                                    
                                                    completed()
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    
                                    
                                    
                                    
                                    
                                case .failure( _):
                                    SwiftLoader.hide()
                                    self.showErrorAlert("Oops !!!", msg: "This card can't be used for this order, please revise or choose another card")
                                    
                                }
                                
                                
                        }
                        
                     case .error(let err):
                        
                        print(err.localizedDescription)
                        
                    }
                    
            }
            
        }
         
        
        
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
        
        SwiftLoader.show(title: title, animated: true)
        
                                                                                            
    }
    
    // 1 recheck for in stock item
    // check the payment
    // generate order id
    // create chat for order to the restaurant
    // place the order
    // send notification
    // put to notification list (sms, in app)
    
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
        let okButtonLabel = EKProperty.LabelContent(text: "Got it", style: okButtonLabelStyle)
        let okButton = EKProperty.ButtonContent(label: okButtonLabel, backgroundColor: .clear, highlightedBackgroundColor:  EKColor.black) {
            
            
            //self.shadowView.isHidden = true
            self.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "refreshCart")), object: nil)
            SwiftEntryKit.dismiss()
            
        }
        
        // Generate the content
        let buttonsBarContent = EKProperty.ButtonBarContent(with: okButton, separatorColor: EKColor.chatMessage, expandAnimatedly: true)
        
        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)

        // Setup the view itself
        let contentView = EKAlertMessageView(with: alertMessage)
        
        SwiftEntryKit.display(entry: contentView, using: attributes)
        
        
        
        
    }
    
    func makeApple_pay(text: String) {
        
        
        SwiftLoader.hide()
        
        let request = PKPaymentRequest()
        request.merchantIdentifier = STPPaymentConfiguration.shared().appleMerchantIdentifier!
        request.supportedNetworks = [.visa, .amex, .masterCard, .discover]
        request.merchantCapabilities = .capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.paymentSummaryItems = calculateSummaryItemsFromSwag(text: text)
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController?.delegate = self
        if applePayController != nil {
            
            self.present(applePayController!, animated: true, completion: nil)
            
        } else {
            
            //print("Nil")
            
        }
        
        
        
        
    }
    
    
    func calculateSummaryItemsFromSwag(text: String) -> [PKPaymentSummaryItem] {
        var summaryItems = [PKPaymentSummaryItem]()
        var p = TotalLbl.text
        p = String(p!.dropFirst())
        let price = NSDecimalNumber(string: p)
        
        summaryItems.append(PKPaymentSummaryItem(label: text, amount: price))
        return summaryItems
    }
    
    
    func makeDictForApplePay(json: Any, completed: @escaping DownloadComplete) {
        
        
        if let dict = json as? [String: AnyObject] {
            
            
            if let outcome = dict["outcome"] as? Dictionary<String, AnyObject> {
                
                
                if let risk_level = outcome["risk_level"] as? String, let type = outcome["type"] as? String {
                    
                    if risk_level == "high" || risk_level == "elevated" || risk_level == "highest" || type == "issuer_declined" || type == "blocked"
                        || type == "invalid"
                        
                    {
                        
                        
                        if let reason = outcome["reason"] as? String {
                            
                            SwiftLoader.hide()
                            self.capturedKey = ""
                            self.showErrorAlert("Oops !!!", msg: "This card is flagged by our system as fraudulent, please contact us and the payment will be released immediately - \(reason)")
                            
                            return
                            
                        }
                        
                        return
                    }
                    
                    if let captureID = dict["id"] as? String {
                        
                        self.capturedKey = captureID
                        
                        completed()
                        
                    }
                    
                }
                
            }
            
        }
        
        
    }

    
    
}

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}

extension CheckOutVC: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        
        STPAPIClient.shared().createToken(with: payment) { (token, err) in
            
            if (err != nil) {
                self.showErrorAlert("Oops !!!", msg: "This card cannot be used !!!")
                completion(PKPaymentAuthorizationStatus.failure)
                return
            }
            
            var description = ""
            
            let url = MainAPIClient.shared.baseURLString
            let urls = URL(string: url!)?.appendingPathComponent("pre_authorization_apple_pay")
            
            let currentDateTime = Date()
            
            // initialize the date formatter and set the style
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            formatter.dateStyle = .long
            
            // get the date time String from the date object
            let result = formatter.string(from: currentDateTime)
            
            
            let txt = self.TotalLbl.text
            let price = String(txt!.dropFirst())
           
            let new = price.toDouble()! * 100
            
            description = "Authorize payment for request ride from Campus Connect at \(result)"
            
            self.capturedKey = ""
            
            storage.async.object(forKey: Auth.auth().currentUser!.uid) { result in
                switch result {
                
                    case .value(let user):
                    
                        AF.request(urls!, method: .post, parameters: [
                            
                            
                            
                            "cus_id": stripeID,
                            "amount": new,
                            "token": token!,
                            "captured": false,
                            "description": description,
                            "receipt_email": user.email,
                            
                            
                            ])
                            
                            .validate(statusCode: 200..<500)
                            .responseJSON { responseJSON in
                                
                                switch responseJSON.result {
                                    
                                case .success(let json):
                                    
                                    completion(PKPaymentAuthorizationStatus.success)
                                    
                                       
                                    self.swiftLoader(title: "Payment Processing")
                                    
                                    self.makeDictForApplePay(json: json) {
                                        
                                         
                                        self.swiftLoader(title: "Placing order")
                                        self.totalItem = self.orderArr.count
                                        self.placingOrder() {
                        
                                            self.take_hold_clean() {
                                          
                                                self.createChatRoom()
                                                       
                                                       
                                            }
                                                   
                                                   
                                        }
                                      
                                        
                                    }
                                    
                                    
                                    
                                    
                                case .failure( _):
                                    
                                    
                                    completion(PKPaymentAuthorizationStatus.failure)
                                    return
                                    
                                }
                                
                                
                        }

                    
                    case .error(let err):
                    
                        print(err.localizedDescription)
                    
                }
                
                
            

            
        }

        
    }
        
        
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        
        controller.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    
}
