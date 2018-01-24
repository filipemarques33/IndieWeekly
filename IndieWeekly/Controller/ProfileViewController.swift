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
    
    @IBAction func userOptionsBtnPressed(_ sender: UIButton) {
        if let user = MainUser.shared {
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
        
        self.userProfilePicture.layer.cornerRadius = self.userProfilePicture.frame.height/2
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
        let profOption = UIAlertAction(title: NSLocalizedString("Edit Profile Info", comment: ""), style: .default, handler: nil)
        optionsSheet.addAction(profOption)
        
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
            //Manager.shared.loadImage(with: user.profilePictureURL, into: self.userProfilePicture)
            self.userProfilePicture.image = UIImage(named:"PlaceholderProfilePicture")
        } else {
            self.userName.text = "Click here to Login"
            self.userEmail.text = "Please login to access your games"
            self.userProfilePicture.image = UIImage(named:"PlaceholderProfilePicture")
        }
        self.loadGames()
        self.gamesCollectionView.reloadData()
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
