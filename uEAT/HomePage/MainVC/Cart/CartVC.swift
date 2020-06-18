//
//  CartVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 6/15/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase
import MGSwipeTableCell
import Alamofire


class CartVC: UIViewController, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var SubtotalPrice: UILabel!
    @IBOutlet weak var ApplicationFee: UILabel!
    @IBOutlet weak var TaxFee: UILabel!
    @IBOutlet weak var TotalFee: UILabel!
    var formatter: DateFormatter!
    var cartArr = [CartModel]()
    var subtotalF: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        // 1- remove all expired cart
        // 2- group all same item to 1
        // calculate price
        
        //loadCart(uid: Auth.auth().currentUser!.uid)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        prepareDelExpCart()
        
        if let uid = Auth.auth().currentUser?.uid, uid != "" {
        
                 // Fetch object from the cache
                 storage.async.object(forKey: uid) { result in
                     switch result {
                         
                     case .value(let user):
                        let stripe_cus = user.stripe_cus
                        self.retrieveDefaultCard(cus_id: stripe_cus)
                     case .error(let err):
                        
                        print(err.localizedDescription)
                        
                    }
                    
            }
            
        }
        
    }
    
    func retrieveDefaultCard(cus_id: String) {
        
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("default_card")
        
        AF.request(urls!, method: .post, parameters: [
            
            "cus_id": cus_id
            
            ])
            
            .validate(statusCode: 200..<500)
            .responseJSON { responseJSON in
                
                switch responseJSON.result {
                    
                case .success(let json):
                    
                    if let dict = json as? [String: AnyObject] {
                        
                        if let defaults = dict["default_source"] as? String {
                            
                            defaultCardID = defaults
                            chargedCardID = defaultCardID
                            
                        }
                        
                        
                        if let sources = dict["sources"] as? Dictionary<String, AnyObject> {
                            
                            if let cardArr = sources["data"] as? [Dictionary<String, AnyObject>] {
                                
                                
                                if cardArr.isEmpty != true {
                                    
                                    
                                    if let last4 = cardArr[0]["last4"] as? String {
                                        
                                        defaultcardLast4Digits = last4
                                        chargedlast4Digit = defaultcardLast4Digits
                                        
                                        
                                    }
                                    
                                    if let brand = cardArr[0]["brand"] as? String {
                                        
                                        defaultBrand = brand
                                        chargedCardBrand = defaultBrand
                                    }
                                    
                                    
                                }
                                
                                
                                
                            }
                            
                        }
                        
                        
                    }
                    
                    
                case .failure(let error):
                    print(error)
                    
                }
                
        }
        
        
    }
    
    func prepareDelExpCart() {
        
        DeleteExpiredCart(uid: Auth.auth().currentUser!.uid) {
            print("Finish removing objects")
            self.loadCart(uid: Auth.auth().currentUser!.uid)
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
            if snaps?.isEmpty == true {
                completed()
            } else {
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
                
            }
        
            
        }

        
        
    }
    
    @objc func loadCart(uid: String) {
        
        cartArr.removeAll()
        
        DataService.instance.mainFireStoreRef.collection("Cart").whereField("userUID", isEqualTo: uid).getDocuments { (snaps, err) in
        
        if err != nil {
            
            self.showErrorAlert("Opss !", msg: err!.localizedDescription)
            return
            
        }
        
            for item in snaps!.documents {
                
                
                let dict = CartModel(postKey: item.documentID, Item_model: item.data())
                self.cartArr.append(dict)
                
            }
            
            self.caculateSummary()
            self.tableView.reloadData()
            
            
            
            
        }
        
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
    
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return cartArr.count
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = cartArr[indexPath.row]
                   
                   
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell") as? CartCell {
            

            
           cell.delegate = self
            
           cell.PlusAction = { [unowned self] in
                
             
                self.handleCount(self.tableView.indexPath(for: cell)!, type: "Plus")
            
            
           }
            
            cell.MinusAction = { [unowned self] in
              
                self.handleCount(self.tableView.indexPath(for: cell)!, type: "Minus")
             
           }
            
                    
           
            //cell.img.frame = cell.frame.offsetBy(dx: 10, dy: 10);
            cell.configureCell(item)

            return cell
                       
        } else {
                       
            return CartCell()
                       
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 85.0
    }
    
    func handleCount(_ path: IndexPath, type: String) {
        
        
        let modify_item = cartArr[(path as NSIndexPath).row]
        
        
        
        
        let uid = Auth.auth().currentUser?.uid
        
        DataService.instance.mainFireStoreRef.collection("Cart").whereField("userUID", isEqualTo: uid!).whereField("url", isEqualTo: modify_item.url!).getDocuments { (snaps, err) in
               
               if err != nil {
                   
                   self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                   return
                   
               }
            
                if snaps?.isEmpty == true {
            
            
                } else {
                    
                    
                    for item in snaps!.documents {
                        
                        if let quanlity = item["quanlity"] as? Int {
                            var newQuanlity = quanlity
                            if type == "Plus" {
                                newQuanlity += 1
                            } else if type == "Minus" {
                                if quanlity == 1 {
                                    
                                } else {
                                    newQuanlity -= 1
                                }
                            }
                            
                            let id = item.documentID
                            DataService.instance.mainFireStoreRef.collection("Cart").document(id).updateData(["quanlity": newQuanlity])
                            modify_item._NewQuanlity = newQuanlity
                            
                            self.caculateSummary()
                            
                            
                            
                        } else {
                            
                            let id = item.documentID
                            DataService.instance.mainFireStoreRef.collection("Cart").document(id).updateData(["quanlity": 1])
                            modify_item._NewQuanlity = 1
                            
                            
                            self.caculateSummary()
                            
                        }
                        
                        
                        
                        self.tableView.reloadData()
                        
                    }
                    
                    
                    
                    
            }
            
        }
        

    }
    
    
    func caculateSummary() {
        
        
        var subtotal: Float!
        var Application: Float!
        var Tax: Float!
        var total: Float!
        
        subtotal = 0.0
        Application = 0.0
        Tax = 0.0
        total = 0.0
        
        for i in cartArr {
            
            let quanlity = i._NewQuanlity
            let price = i.price * Float(quanlity!)
            subtotal += price
            
        }
        
        Application = subtotal * 5 / 100
        Tax = subtotal * 9 / 100
        total = subtotal + Application + Tax
        
        
        SubtotalPrice.text = "$\(String(format:"%.2f", subtotal!))"
        ApplicationFee.text = "$\(String(format:"%.2f", Application!))"
        TaxFee.text = "$\(String(format:"%.2f", Tax!))"
        TotalFee.text = "$\(String(format:"%.2f", total!))"
        
        
        
        subtotalF = subtotal
        
          
    }
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        return true;
    }
    
    // Fetch object from the cache
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        
        
        let color = UIColor(red: 249/255, green: 252/255, blue: 254/255, alpha: 1.0)
        
        swipeSettings.transition = MGSwipeTransition.border;
        expansionSettings.buttonIndex = 0
        let padding = 70
        if direction == MGSwipeDirection.rightToLeft {
            expansionSettings.fillOnTrigger = false;
            expansionSettings.threshold = 1.1
            

            let RemoveResize = resizeImage(image: UIImage(named: "remove")!, targetSize: CGSize(width: 25.0, height: 25.0))
            
              
            let remove = MGSwipeButton(title: "", icon: RemoveResize, backgroundColor: color, padding: padding,  callback: { (cell) -> Bool in
             
             
                
                self.deleteAtIndexPath(self.tableView.indexPath(for: cell)!)
                
                return false; //don't autohide to improve delete animation
                
                
            });
            
            
            return [remove]
         
        } else {
            
            return nil
         
        }
           
        
    }
    
    
    func deleteAtIndexPath(_ path: IndexPath) {
        
        
        
        let del_item = cartArr[(path as NSIndexPath).row]
        let name = del_item.name!
        let uid = Auth.auth().currentUser?.uid
        
        
        DataService.instance.mainFireStoreRef.collection("Cart").whereField("userUID", isEqualTo: uid!).whereField("url", isEqualTo: del_item.url!).getDocuments { (snaps, err) in
           
           if err != nil {
               
               self.showErrorAlert("Opss !", msg: err!.localizedDescription)
               return
               
           }
        
            if snaps?.isEmpty == true {
        
        
            } else {
                
                for item in snaps!.documents {
                    
                    let id = item.documentID
                    DataService.instance.mainFireStoreRef.collection("Cart").document(id).delete()
                    self.cartArr.remove(at: (path as NSIndexPath).row)
                    self.caculateSummary()
                    self.tableView.reloadData()
                    
                    loadAlertAnimation(title: "Done", desc: "You have removed \(name) succesfully")
                    
                }
                
            }
            
        }

        
    }
  
    @IBAction func checkOutBtnPressed(_ sender: Any) {
        
        if cartArr.isEmpty != true {
            
            
            NotificationCenter.default.addObserver(self, selector: #selector(CartVC.refreshCart), name: (NSNotification.Name(rawValue: "refreshCart")), object: nil)
            self.performSegue(withIdentifier: "moveToFinalOrderVC", sender: nil)
            
        }
        
        
        
    }
    
    @objc func refreshCart() {
        
       NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "refreshCart")), object: nil)
        
        
        if let uid = Auth.auth().currentUser?.uid {
            
            self.loadCart(uid: uid)
              
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "moveToFinalOrderVC"{
            if let destination = segue.destination as? CheckOutVC
            {
                
                destination.subtotal = self.subtotalF
                destination.orderArr = self.cartArr
               
                
            }
        }
        
        
    }
    
}
