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
import GeoFire


class HomeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {

    @IBOutlet weak var LocationView: UIView!
    @IBOutlet weak var recentCollectionView: UICollectionView!
    @IBOutlet weak var HomecollectionView: UICollectionView!
    
    var item: ItemModel!
    

    @IBOutlet weak var RecentOrderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var LocationViewBarHeight: NSLayoutConstraint!
    
    var menu = [ItemModel]()
    
    var order_list = [Recent_order_model]()
    let searchBarColor = UIColor(red: 247/255, green: 248/255, blue: 250/255, alpha: 1.0)
    
    let locationManager = CLLocationManager()
    var restaurant_key = [String]()
    var final_restaurant = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        recentCollectionView.delegate = self
        recentCollectionView.dataSource = self
        
        
        HomecollectionView.delegate = self
        HomecollectionView.dataSource = self
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if let layout = HomecollectionView?.collectionViewLayout as? PinterestLayout {
          layout.delegate = self
        }
        HomecollectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
       
        getNearByRestaurant()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        load_recent_order()
        configureLocationService()
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "moveToDetailVC1"{
            if let destination = segue.destination as? itemDetail
            {
                
                destination.item = self.item
               
                
            }
        }
        
        
    }
    
    
    func getNearByRestaurant() {
        
        guard let coordinate = locationManager.location?.coordinate else { return }
        
        
        let url = DataService.instance.mainRealTimeDataBaseRef.child("Restaurant_coordinator")
        let geofireRef = url
        let geoFire = GeoFire(firebaseRef: geofireRef)
        let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let query = geoFire.query(at: loc, withRadius: 20)
            
        restaurant_key.removeAll()
        
        self.getRestaurantRadius(query: query)
        

        
    }
    
    
    func getRestaurantRadius(query: GFCircleQuery) {
    
        query.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            
            if let key = key {
                
                self.restaurant_key.append(key)
                
            }
            
           
        })
        
        query.observeReady {
            

            query.removeAllObservers()
            
            if self.restaurant_key.isEmpty != true {
                for i in self.restaurant_key {
                    self.verifyRestaurant(id: i) {
                        
                        
                        self.loadMenu()
                        
                    }
                }
            }

            
        }
        
        
    
    }
    
    func verifyRestaurant(id: String, completed: @escaping DownloadComplete) {
        
        DataService.instance.mainFireStoreRef.collection("Restaurant_check_list").whereField("Restaurant_id", isEqualTo: id).whereField("Menu", isEqualTo: true).getDocuments { (snapCheck, err) in
            
            if err != nil {
            
                SwiftLoader.hide()
                self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                print(err?.localizedDescription as Any)
                return
            
            }
            
            if snapCheck?.isEmpty == true {
                
                
                
            } else {
                
                
                self.final_restaurant.append(id)
                
            }
            
            completed()
            
            
        }
        
    }
    
    func loadMenu() {
        
        for i in self.final_restaurant {
            
            DataService.instance.mainFireStoreRef.collection("Menu").whereField("restaurant_id", isEqualTo: i).getDocuments { (snap, err) in
            
            if err != nil {
                
                self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                return
                
            }
            
            for item in snap!.documents {
                
                let dict = ItemModel(postKey: item.documentID, Item_model: item.data())
                self.menu.append(dict)
                
                
                }
                
                self.HomecollectionView.reloadData()
                
            }
            
        }
        
        
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
            return menu.count
        }
           
    }
       
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        if collectionView == recentCollectionView {
            
            let item = order_list[indexPath.row]
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "order_cell", for: indexPath) as? order_cell {
                
                cell.configureCell(item)
                
                return cell
                
            } else {
                
                return order_cell()
                
            }
            
        } else {
            
            let item = menu[indexPath.row]
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? ItemCell {
                
                cell.configureCell(item)
                
                return cell
                
            } else {
                
                return ItemCell()
                
            }
            
            
        }
           
          

    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == recentCollectionView {
            
            return CGSize(width: self.recentCollectionView.frame.width - 20, height: 63)
            
        } else {
            
            let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
            return CGSize(width: itemSize, height: itemSize)
            
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == recentCollectionView {
            return 10.0
        }
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == HomecollectionView {
            item = menu[indexPath.row]
            self.performSegue(withIdentifier: "moveToDetailVC1", sender: nil)
            
        }
    }
    

    @IBAction func searchBtnPressed(_ sender: Any) {
        
       // self.performSegue(withIdentifier: "moveToSearchVC", sender: nil)
        
    }
    
}
extension HomeVC: PinterestLayoutDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
    
    if collectionView == HomecollectionView {
        return 500.0
    } else {
        return 0.0
    }
    
  }
}
