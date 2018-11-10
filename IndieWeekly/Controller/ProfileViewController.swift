//
//  ProfileViewController.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 15/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit
import Nuke
import FirebaseAuth


class ProfileViewController: UIViewController {
    
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var gamesToShow: UISegmentedControl!
    
    @IBOutlet weak var emptyImage: UIImageView!
    
    @IBAction func userOptionPressed(_ sender: UITapGestureRecognizer) {
        if MainUser.shared != nil {
            self.showUserOptionsSheet()
        } else {
            performSegue(withIdentifier: "segueToLogin", sender: self)
        }
    }
    
    @IBAction func notificationBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func infoBtnPressed(_ sender: UIButton) {
    }
    
    @IBOutlet weak var gamesCollectionView: UICollectionView!
    
    @IBAction func segControlChangedValue(_ sender: UISegmentedControl) {
        self.reloadData()
    }
    var library = [Game]()
    var wishlist = [Game]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gamesCollectionView.dataSource = self
        self.gamesCollectionView.delegate = self
        self.gamesCollectionView.reloadData()
        
        self.userProfilePicture.layer.cornerRadius = self.userProfilePicture.bounds.height/2
        self.userProfilePicture.layer.borderWidth = 3.0
        self.userProfilePicture.layer.borderColor = UIColor.white.cgColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.updateProfileInfo()
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func reloadData() {
        self.loadGames()
        self.gamesCollectionView?.reloadData()
        
        if gamesToShow.selectedSegmentIndex == 0, library.isEmpty {
            self.emptyImage.isHidden = false
            self.emptyImage.image = UIImage(named:"empty_library")
        } else if gamesToShow.selectedSegmentIndex == 1, wishlist.isEmpty {
            self.emptyImage.isHidden = false
            self.emptyImage.image = UIImage(named:"empty_wishlist")
        } else {
            self.emptyImage.isHidden = true
        }
    }
    
    func loadGames() {
        if let library = MainUser.shared?.library {
            self.library = library
        } else {
            self.library = [Game]()
        }
        if let wishlist = MainUser.shared?.wishlist {
            self.wishlist = wishlist
        } else {
            self.wishlist = [Game]()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToLogin" {
            let destination = segue.destination as! LoginViewController
            destination.sourceViewController = self
        } else if segue.identifier == "segueToGameInfo" {
            let destination = segue.destination as! GameInfoViewController
            destination.sourceViewController = self
            let indexPath = self.gamesCollectionView.indexPathsForSelectedItems?.first
            if self.gamesToShow.selectedSegmentIndex == 0 {
                destination.selectedGame = self.library[(indexPath?.row)!]
            } else {
                destination.selectedGame = self.wishlist[(indexPath?.row)!]
            }
        }
    }
    
    func showUserOptionsSheet() {
        let optionsSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // TODO: Profile Edit Option handler
        let profPictureOption = UIAlertAction(title: NSLocalizedString("Change Profile Picture", comment: ""), style: .default, handler: {
            (action) in
            self.presentImagePicker()
        })
        optionsSheet.addAction(profPictureOption)
        
        // Log Out Option
        let logOutOption = UIAlertAction(title:NSLocalizedString("Log Out", comment: ""), style: .destructive, handler: {
            (action) in
            LoginServices.handleUserLoggedOut()
            self.updateProfileInfo()
        })
        optionsSheet.addAction(logOutOption)
        
        // Cancel Option
        let cancelOption = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        optionsSheet.addAction(cancelOption)
        
        self.present(optionsSheet, animated: true, completion: nil)
        
    }
    
    func updateProfileInfo(){
        if let user = MainUser.shared {
            self.userName.text = user.username
            self.userEmail.text = user.email
            updateProfilePictureView()
        } else {
            self.userName.text = "Click here to Login"
            self.userEmail.text = "Please login to access your games"
            self.userProfilePicture.image = UIImage(named:"PlaceholderProfilePicture")
        }
        
        self.reloadData()
        
    }
    
    func updateProfilePictureView() {
        self.userProfilePicture.image = UIImage(named:"PlaceholderProfilePicture")
        if let user = MainUser.shared, let picURL = user.profilePictureURL {
            Manager.shared.loadImage(with: picURL, into: self.userProfilePicture)
        }
    }
    
    func presentImagePicker(){
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
    }
}

extension ProfileViewController:UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "segueToGameInfo", sender: self)
    }
}

extension ProfileViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let index = self.gamesToShow.selectedSegmentIndex
        if index == 0 {
            return library.count
        } else {
            return wishlist.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = gamesCollectionView.dequeueReusableCell(withReuseIdentifier: "gameCell", for: indexPath) as! GamePosterCollectionViewCell
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.white.cgColor
        cell.dropShadow()
        
        cell.gamePosterImage.image = UIImage(named: "posterPlaceholder")
        let index = self.gamesToShow.selectedSegmentIndex
        if index == 0 {
            Manager.shared.loadImage(with: library[indexPath.row].posterURL!, into: cell.gamePosterImage)
        } else {
            Manager.shared.loadImage(with: wishlist[indexPath.row].posterURL!, into: cell.gamePosterImage)
        }
        return cell
        
    }
    
}

extension UIView {
    func dropShadow(scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 2
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
}

extension ProfileViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        var selectedImageFromPicker:UIImage?
        
        let indicator = UIActivityIndicatorView()
        indicator.style = .whiteLarge
        indicator.hidesWhenStopped = true
        picker.view.addSubview(indicator)
        indicator.center = self.view.center
        indicator.startAnimating()
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let picture = selectedImageFromPicker, let user = MainUser.shared {
            
            let resizedPicture = picture.resizedImage(newSize: CGSize(width: 250, height: 250))
            
            print(resizedPicture.size)
            
            StorageManager.upload(profilePic: resizedPicture, forUser: user) {
                (error) in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                }
                indicator.stopAnimating()
                self.dismiss(animated: true, completion: {
                    self.updateProfilePictureView()
                })
            }
        }
    }
}


extension UIImage {
    
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
