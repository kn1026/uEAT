//
//  ProfileVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 11/3/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVKit
import AVFoundation
import CoreLocation

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate  {
    
    @IBOutlet weak var profileImg: borderAvatarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var PhoneLbl: UILabel!
    @IBOutlet weak var avatarImg: UIButton!
    
    var feature = ["Notifications", "My Order", "Payment", "Security", "Voucher", "Profile Info", "Help & Support"]
    
    var url = ""
    
    let locationManager = CLLocationManager()
    var authorizationStatus = CLLocationManager.authorizationStatus()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        
        storage.async.object(forKey: Auth.auth().currentUser!.uid) { result in
             switch result {
                                            
             case .value(let user):
                
                
                imageStorage.async.object(forKey: "avatarUrl") { result in
                    if case .value(let image) = result {
                        
                        DispatchQueue.main.async { // Make sure you're on the main thread here
                            
                            
                            self.profileImg.image = image
                            
                            
                        }
                        
                    }
                }
                
 
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    
                    
                    
                    self.NameLbl.text = user.FullName
                    self.PhoneLbl.text = user.Phone
                    
                }

                        
             case .error( _):
                 
                 
                 SwiftLoader.hide()
                 self.showErrorAlert("Oopps !!!", msg: "Cache Error, please log out and login again")
                 
          }
             
        }
        
        if profileImg.image != nil {
            
            avatarImg.isHidden = true
   
            
        } else {
            
            
            avatarImg.isHidden = false
           
            
        }
        
        
    }
    
    
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        tableView.reloadData()
        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feature.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = feature[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as? ProfileCell {
            
            if indexPath.row != 0 {
                
                let lineFrame = CGRect(x:0, y:-10, width: self.view.frame.width, height: 11)
                let line = UIView(frame: lineFrame)
                line.backgroundColor = UIColor.lightGray
                cell.addSubview(line)
                
            }
            
            cell.configureCell(item)
            
            return cell
            
        } else {
            
            return ProfileCell()
            
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let item = feature[indexPath.row]
        
        if item == "Notifications" {
            
            self.performSegue(withIdentifier: "MoveToNotificationVC", sender: nil)
            
        } else if item == "Payment" {
            
            
            self.performSegue(withIdentifier: "moveToPaymentVC", sender: nil)
            
            
        } else if item == "Security" {
            
            self.performSegue(withIdentifier: "moveToSecurityVC", sender: nil)
            
        }
    }
    
    
    @IBAction func UploadImg(_ sender: Any) {
        
        let sheet = UIAlertController(title: "Upload your photo", message: "", preferredStyle: .actionSheet)
        
        
        let camera = UIAlertAction(title: "Take a new photo", style: .default) { (alert) in
            
            self.camera()
            
        }
        
        let album = UIAlertAction(title: "Upload from album", style: .default) { (alert) in
            
            self.album()
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        
        sheet.addAction(camera)
        sheet.addAction(album)
        sheet.addAction(cancel)
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    func album() {
        
        self.getMediaFrom(kUTTypeImage as String)
        
        
    }
    
    func camera() {
        
        
        
        self.getMediaCamera(kUTTypeImage as String)
        
    }
    
    // get media
    
    func getMediaFrom(_ type: String) {
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.allowsEditing = true
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    func getMediaCamera(_ type: String) {
        
        
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.allowsEditing = true
        mediaPicker.mediaTypes = [type as String] //UIImagePickerController.availableMediaTypes(for: .camera)!
        mediaPicker.sourceType = .camera
        self.present(mediaPicker, animated: true, completion: nil)
        
    }
    
    func getImage(image: UIImage) {

        uploadImg(image: image) {
            
            self.CacheItem(image: image)
            
        }
       

    }
    
    
    func uploadImg(image: UIImage, completed: @escaping DownloadComplete) {
        
        
        swiftLoader()
        
        self.swiftLoader()
        let metaData = StorageMetadata()
        let imageUID = UUID().uuidString
        metaData.contentType = "image/jpeg"
        var imgData = Data()
        imgData = image.jpegData(compressionQuality: 1.0)!
        
        
        
        DataService.instance.AvatarStorageRef.child(imageUID).putData(imgData, metadata: metaData) { (meta, err) in
            
            if err != nil {
                
                SwiftLoader.hide()
                self.showErrorAlert("Oopss !!!", msg: "Error while saving your image, please try again")
                print(err?.localizedDescription as Any)
                
            } else {
                
                DataService.instance.AvatarStorageRef.child(imageUID).downloadURL(completion: { (url, err) in
                    
                    
                    guard let Url = url?.absoluteString else { return }
                    
                    let downUrl = Url as String
                    let downloadUrl = downUrl as NSString
                    let downloadedUrl = downloadUrl as String
                    
                   // SwiftLoader.hide()
                    
                    DataService.instance.mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: Auth.auth().currentUser?.uid as Any).getDocuments { (snap, err) in
                    
                    
                        if err != nil {
                        
                            self.showErrorAlert("Opss !", msg: err.debugDescription)
      
                        } else {
                            if snap?.isEmpty != true {
                                
                                for dict in (snap?.documents)! {
                                    
                                    let id = dict.documentID
                                DataService.instance.mainFireStoreRef.collection("Users").document(id).updateData(["avatarUrl": downloadedUrl])
                                    
                                    
                                    self.profileImg.isHidden = false
                                    self.profileImg.image = image
                                    
                                    
                                    completed()
                                    SwiftLoader.hide()
                                    break
                                                      
                                    
                                }
                                
                            } else {
                                
                                self.showErrorAlert("Opss !", msg: "Can't find user")
                                
                            }
                        }
                        
                    }
                    
                    
                    
                })
                
                
                
                
                
            }
            
            
        }
        
        
        
        
    }
    
    func CacheItem(image: UIImage) {
        
        
        
        dataStorage.async.removeAll(completion: { (result) in
            if case .value = result {
                print("Cache cleaned")
            }
        })
        
        
        try? imageStorage.setObject(image, forKey: "avatarUrl")
        
    }
    

    
}


extension ProfileVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let editedImage = info[.editedImage] as? UIImage {
            getImage(image: editedImage)
        } else if let originalImage =
            info[.originalImage] as? UIImage {
            getImage(image: originalImage)
        }
        
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    

    
}
