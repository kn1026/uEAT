//
//  HomeVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 11/3/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation


class HomeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {

    @IBOutlet weak var LocationView: UIView!
    @IBOutlet weak var recentCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var RecentOrderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var LocationViewBarHeight: NSLayoutConstraint!
    
    var order_list = [Recent_order_model]()
    let searchBarColor = UIColor(red: 247/255, green: 248/255, blue: 250/255, alpha: 1.0)
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        recentCollectionView.delegate = self
        recentCollectionView.dataSource = self
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        load_recent_order()
        configureLocationService()

    }
    
    func configureLocationService() {
        
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            self.LocationViewBarHeight.constant = 0
            self.LocationView.isHidden = true
            
        } else {
             self.LocationViewBarHeight.constant = 70
            self.LocationView.isHidden = false
        }
        
        
        
    }

    func load_recent_order() {
        
        
        self.order_list.removeAll()
        
        if let uid = Auth.auth().currentUser?.uid
        
        {
            DataService.instance.mainFireStoreRef.collection("Processing_orders").order(by: "Order_time", descending: true).whereField("userUID", isEqualTo: uid).getDocuments { (snap, err) in
                
                if err != nil {
                    
                    self.RecentOrderHeightConstraint.constant = 0.0
                    self.showErrorAlert("Opss !", msg: "Can't load your recent orders")
                    return
                    
                }
                
                if snap?.isEmpty == true {
                       
                    self.RecentOrderHeightConstraint.constant = 0.0
                    
                } else {
                    
                    self.RecentOrderHeightConstraint.constant = 63.0
                    
        
                    for item in snap!.documents {
                        
                        
                        let i = item.data()
                        let order = Recent_order_model(postKey: item.documentID, Order_model: i)
                        self.order_list.append(order)
                        self.recentCollectionView.reloadData()
                        
                        
                    }
      
                }
            
                
            }
            
        }
        
        
    }
    
    
    @IBAction func LocationRequestBtnPressed(_ sender: Any) {
        
        locationManager.requestWhenInUseAuthorization()
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // get my location with zoom 30
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            
            print("Granted")
            self.LocationViewBarHeight.constant = 0
            self.LocationView.isHidden = true
            
        } else {
            
            print("Not determined")
            self.LocationViewBarHeight.constant = 70
            self.LocationView.isHidden = false
            
        }
  
        
    }
    
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
           return 1
       }
       
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           
        if collectionView == recentCollectionView {
            return order_list.count
        } else {
            return 0
        }
           
    }
       
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        if collectionView == recentCollectionView {
            
            let item = order_list[indexPath.row]
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "order_cell", for: indexPath) as? order_cell {
                
                cell.configureCell(item)
                
                return cell
                
            } else {
                
                return UICollectionViewCell()
                
            }
            
        } else {
            
            
            return UICollectionViewCell()
        }
           
          

    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == recentCollectionView {
            
            return CGSize(width: self.recentCollectionView.frame.width - 20, height: 63)
            
        }
        
        return CGSize(width: 300, height: 63)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == recentCollectionView {
            
            let item = order_list[indexPath.item]
            print(item.Order_id, item.Restaurant_name)
            
        }
        
       
        
        
    }

    @IBAction func searchBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToSearchVC", sender: nil)
        
    }
    
}

