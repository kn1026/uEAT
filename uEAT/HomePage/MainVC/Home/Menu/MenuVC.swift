//
//  MenuVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 6/25/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit

class MenuVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var HomecollectionView: UICollectionView!
    
    var res_id = ""
    var item: ItemModel!
    var itemArr = [ItemModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        HomecollectionView.delegate = self
        HomecollectionView.dataSource = self
        
        if let layout = HomecollectionView?.collectionViewLayout as? PinterestLayout {
            
          layout.delegate = self
            
        }
        
        HomecollectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
        
        loadMenu(id: res_id)
        
    }
    
    
    func loadMenu(id: String) {
        
        DataService.instance.mainFireStoreRef.collection("Menu").whereField("restaurant_id", isEqualTo: id).getDocuments { (snap, err) in
        
        if err != nil {
            
            self.showErrorAlert("Opss !", msg: err!.localizedDescription)
            return
            
        }
        
        for item in snap!.documents {
            
            if let type = item.data()["type"] as? String, type != "Add-on" {
                let dict = ItemModel(postKey: item.documentID, Item_model: item.data())
                self.itemArr.append(dict)
                
                }
                

            }
            
            self.HomecollectionView.reloadData()
            
        }
        
        
    }
    

    @IBAction func backBtn1Pressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func backBtn2Pressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
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
           
        return itemArr.count
           
    }
       
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        let item = itemArr[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: indexPath) as? MenuCell {
            
            cell.configureCell(item)
            
            return cell
            
        } else {
            
            return ItemCell()
            
        }
           
          

    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemSize = (self.HomecollectionView.frame.width - (self.HomecollectionView.contentInset.left + self.HomecollectionView.contentInset.right + 10)) / 2
        return CGSize(width: itemSize, height: itemSize)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    
        let items = itemArr[indexPath.row]
        self.item = items
        
        if items.status == "Online" {
            
            self.performSegue(withIdentifier: "moveToDetailItemVC", sender: nil)
            
        } else {
            
            self.showErrorAlert("Oops !", msg: "This item is temporary unavailable")
            
        }
 
        
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "moveToDetailItemVC"{
            if let destination = segue.destination as? itemDetail
            {
                
                destination.item = self.item
               
                
            }
        }
        
    }
    

    
}
extension MenuVC: PinterestLayoutDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
    
    if collectionView == HomecollectionView {
        
        let randomInt = Int.random(in: 0..<3)
        if randomInt == 0 {
            return 250.0
        } else if randomInt == 1 {
            return 270.0
        } else {
            return 300.0
        }
        
    } else {
        return 0.0
    }
    
  }
}
