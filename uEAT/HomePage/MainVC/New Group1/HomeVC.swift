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
import Alamofire


class HomeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    
    var check_order_id = ""
    var check_restaurant_name = ""
    var check_status = ""
    var res_id = ""


    @IBOutlet weak var LocationView: UIView!
    @IBOutlet weak var recentCollectionView: UICollectionView!
    @IBOutlet weak var HomecollectionView: UICollectionView!
    
    
    

    @IBOutlet weak var RecentOrderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var LocationViewBarHeight: NSLayoutConstraint!
    
    var restaurant_list = [RestaurantModel]()
    
    var order_list = [Recent_order_model]()
    let searchBarColor = UIColor(red: 247/255, green: 248/255, blue: 250/255, alpha: 1.0)
    
    let locationManager = CLLocationManager()
    var restaurant_key = [String]()
    var final_restaurant = [String]()
    
    
    private var pullControl = UIRefreshControl()
    
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
        
        
        //pullControl.backgroundColor = UIColor.darkGray
        pullControl.tintColor = UIColor.black
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            HomecollectionView.refreshControl = pullControl
        } else {
            HomecollectionView.addSubview(pullControl)
        }
        
        
        setupFCMToken()
        
    }
    
    func setupFCMToken() {
        
        guard let fcmToken = Messaging.messaging().fcmToken else { return }
             
        DataService.instance.fcmTokenUserRef.child(Auth.auth().currentUser!.uid).child(fcmToken).observeSingleEvent(of: .value, with: { (snapInfo) in
             
             
                 if snapInfo.exists() {
                     
                    
                     
                 } else {
                     
                     let profile = [fcmToken: 0 as AnyObject]
                     DataService.instance.fcmTokenUserRef.child(Auth.auth().currentUser!.uid).updateChildValues(profile)
                     
                     
                 }
        
                 
             })
        
        
    }
    
    @objc private func refreshListData(_ sender: Any) {
       // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        getNearByRestaurant()
        
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        load_recent_order()
        configureLocationService()
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "moveToMenuVC"{
            if let destination = segue.destination as? MenuVC
            {
                
                destination.res_id = self.res_id
               
                
            }
        } else if segue.identifier == "moveToStatusVC2"{
            if let destination = segue.destination as? OrderStatusVC
            {
                
                destination.status_order_id = self.check_order_id
                
            }
        }
        
        
    }
    
    
    func getNearByRestaurant() {
        
        guard let coordinate = locationManager.location?.coordinate else { return }
        
        
        let url = DataService.instance.mainRealTimeDataBaseRef.child("Restaurant_coordinator")
        let geofireRef = url
        let geoFire = GeoFire(firebaseRef: geofireRef)
        let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
       
        let query = geoFire.query(at: loc, withRadius: 50)
            
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
            
            print(self.restaurant_key.count)
      
            self.restaurant_list.removeAll()
            if self.restaurant_key.isEmpty != true {
                for i in self.restaurant_key {
                    
                    self.loadRestaurant(id: i)
                    
                }
            } else {
                print("No nearby restaurant")
            }

            
        }
        
        
    
    }
    
    func loadRestaurant(id: String) {
        
        print("Loading \(id)")
        
        DataService.instance.mainFireStoreRef.collection("Restaurant").whereField("Restaurant_id", isEqualTo: id).getDocuments { (snapCheck, err) in
            
            if err != nil {
            
                
                self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                
                return
            
            }
            
            if snapCheck?.isEmpty == true {
                
                print("Can't find restaurant \(id)")
                
            }
    
            for item in snapCheck!.documents {
            
            
                    let dict = RestaurantModel(postKey: item.documentID, Restaurant_model: item.data())
                    
                    if let open = item.data()["Open"] as? Bool {
                        
                        if open ==  true {
                            
                            self.restaurant_list.insert(dict, at: 0)
                            
                        } else {
                            
                            self.restaurant_list.append(dict)
                            
                        }
                        
                        
                    } else {
                        
                        self.restaurant_list.append(dict)
                        
                    }
                    
                    self.HomecollectionView.reloadData()
                    
                    
                    if self.pullControl.isRefreshing == true {
                        self.pullControl.endRefreshing()
                    }

                
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
    
        
        if let uid = Auth.auth().currentUser?.uid
        
        {
            DataService.instance.mainFireStoreRef.collection("Processing_orders").order(by: "Order_time", descending: true).whereField("userUID", isEqualTo: uid).getDocuments { (snap, err) in
                
                if err != nil {
                    
                    self.RecentOrderHeightConstraint.constant = 0.0
                    //print(err?.localizedDescription)
                    self.showErrorAlert("Opss !", msg: "Can't load your recent orders")
                    return
                    
                }
                
                if snap?.isEmpty == true {
                       
                    self.RecentOrderHeightConstraint.constant = 0.0
                    
                } else {
                    
                    self.RecentOrderHeightConstraint.constant = 63.0
                    
                    self.order_list.removeAll()
                    
                    for item in snap!.documents {
                        
                        if let status = item.data()["Status"] as? String {
                            
                            if status != "Completed" {
                                
                                let i = item.data()
                                let order = Recent_order_model(postKey: item.documentID, Order_model: i)
                                self.order_list.append(order)
                                
                            }
                            
                        }
                        
                        
                        
                        
                    }
                    
                    self.recentCollectionView.reloadData()
      
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
            return restaurant_list.count
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
            
            let item = restaurant_list[indexPath.row]
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
            
            let itemSize = (self.HomecollectionView.frame.width - (self.HomecollectionView.contentInset.left + self.HomecollectionView.contentInset.right + 10)) / 2
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
            let item = restaurant_list[indexPath.row]
            
            if item.Restaurant_Open_status == true,  item.Restaurant_status == "Ready" {
                
                
                res_id = item.Restaurant_id
                self.performSegue(withIdentifier: "moveToMenuVC", sender: nil)
                
            } else {
                
                self.showErrorAlert("Oops !", msg: "The restaurant has closed or temporarily not available")
                
            }
            
            
           
            
        } else {
            
            let item = order_list[indexPath.row]
            

            
            check_order_id = item.Order_id
            check_restaurant_name = item.Restaurant_name
            check_status = item.Status
            
           self.performSegue(withIdentifier: "moveToStatusVC2", sender: nil)
            
        }
    }
    

    
}
extension HomeVC: PinterestLayoutDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
    
    if collectionView == HomecollectionView {
        
        let randomInt = Int.random(in: 0..<2)
        if randomInt == 0 {
            return 250.0
        } else {
            return 300.0
        }
        
    } else {
        return 0.0
    }
    
  }
}
