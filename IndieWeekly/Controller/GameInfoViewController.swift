//
//  GameInfoViewController.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 16/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit
import Nuke
import SafariServices
import UserNotifications

class GameInfoViewController: UIViewController {
    
    var selectedGame:Game!
    
    // Game information
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var gameDev: UILabel!
    @IBOutlet weak var gameGenre: UILabel!
    @IBOutlet weak var gamePlatforms: UILabel!
    @IBOutlet weak var gameReleaseDate: UILabel!
    @IBOutlet weak var gamePoster: UIImageView!
    @IBOutlet weak var gameScreenshot: UIImageView!
    @IBOutlet weak var infoTableView: UITableView!
    @IBOutlet weak var backgroudImageView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    var sourceViewController:UIViewController? = nil
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    weak var activityIndicator:ActivityView?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameName.text = self.selectedGame.name
        self.gameDev.text = self.selectedGame.developer
        self.gameGenre.text = self.selectedGame.genre
        self.gamePlatforms.text = self.selectedGame.platforms
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        self.gameReleaseDate.text = dateFormatter.string(from: selectedGame.releaseDate)
        
        self.gamePoster.layer.borderColor = UIColor.white.cgColor
        self.gamePoster.layer.borderWidth = 2.0
        self.gamePoster.clipsToBounds = true
        self.backgroudImageView.dropShadow()
        
        Manager.shared.loadImage(with: selectedGame.posterURL!, into: self.gamePoster) { (result, cache) in
            if result.error == nil {
                self.gamePoster.image = result.value
                
                self.gamePoster.alpha = 0
                UIView.animate(withDuration: 0.25, animations: {
                    self.gamePoster.alpha = 1
                })
            }
        }
        
        Manager.shared.loadImage(with: selectedGame.screenshotURL!, into: self.gameScreenshot) { (result, cache) in
            if result.error == nil {
                self.gameScreenshot.applyGradient()
                self.gameScreenshot.image = result.value
                
                self.gameScreenshot.alpha = 0
                UIView.animate(withDuration: 0.25, animations: {
                    self.gameScreenshot.alpha = 1
                })
            }
        }

        
        
        self.infoTableView.estimatedRowHeight = 44
        self.infoTableView.dataSource = self
        self.infoTableView.delegate = self
        
        if sourceViewController == nil {
            backBtn.isHidden = true
        } else {
            backBtn.isHidden = false
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            if error == nil {
                print("Successful Authorization")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadUpperBarInfo()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var libraryLabel: UILabel!
    @IBOutlet weak var libraryImage: UIImageView!
    @IBAction func libraryBtnPressed(_ sender: Any) {
        if let mainUser = MainUser.shared {
            if mainUser.library.contains(where:{$0.id == selectedGame.id}) {
                mainUser.remove(game: selectedGame, fromList: .library, completion: {
                    self.loadUpperBarInfo()
                })
            } else {
                mainUser.add(game: selectedGame, toList: .library, completion: {
                    self.loadUpperBarInfo()
                })
            }
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Login Neccessary", comment: ""), message: NSLocalizedString("Please log in to add this game to your library.", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var wishlistLabel: UILabel!
    @IBOutlet weak var wishlistImage: UIImageView!
    @IBAction func wishlistBtnPressed(_ sender: Any) {
        if let mainUser = MainUser.shared {
            if mainUser.wishlist.contains(where:{$0.id == selectedGame.id}) {
                mainUser.remove(game: selectedGame, fromList: .wishlist, completion: {
                    self.loadUpperBarInfo()
                })
            } else {
                mainUser.add(game: selectedGame, toList: .wishlist, completion: {
                    self.loadUpperBarInfo()
                })
            }
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Login Neccessary", comment: ""), message: NSLocalizedString("Please log in to add this game to your wishlist.", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        let text = NSLocalizedString("Hey there! I just read about \(selectedGame.name) and thought you might like it!\n\nAlso, check out IndieWeekly and get recommendations on the best indie games!\n\nDownload it on AppStore: https://itunes.apple.com/br/app/indieweekly/id1341177863", comment: "")
        let activityViewController = UIActivityViewController(activityItems: [text as NSString], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func loadUpperBarInfo(){
        if let mainUser = MainUser.shared {
            if mainUser.library.contains(where: {$0.id == selectedGame.id}){
                self.libraryLabel.text = NSLocalizedString("On Library", comment: "")
                self.libraryLabel.textColor = .green
                self.libraryImage.image = UIImage(named: "gameOptions_library")
            } else {
                self.libraryLabel.text = NSLocalizedString("Add to Library", comment: "")
                self.libraryLabel.textColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
                self.libraryImage.image = UIImage(named: "gameOptions_library_neutral")
            }
            
            if mainUser.wishlist.contains(where: {$0.id == selectedGame.id}){
                self.wishlistLabel.text = NSLocalizedString("On Wishlist", comment: "")
                self.wishlistLabel.textColor = .red
                self.wishlistImage.image = UIImage(named: "gameOptions_wishlist")
            } else {
                self.wishlistLabel.text = NSLocalizedString("Add to Wishlist", comment: "")
                self.wishlistLabel.textColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
                self.wishlistImage.image = UIImage(named: "gameOptions_wishlist_neutral")
            }
        } else {
            self.libraryLabel.text = "Add to Library"
            self.libraryLabel.textColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
            self.libraryImage.image = UIImage(named: "gameOptions_library_neutral")
            
            self.wishlistLabel.text = "Add to Wishlist"
            self.wishlistLabel.textColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
            self.wishlistImage.image = UIImage(named: "gameOptions_wishlist_neutral")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToCommunity" {
            let destination = segue.destination as! CommunityTableViewController
            destination.selectedGame = self.selectedGame
        }
    }
    
    func setUpActivityIndicator() {
        if let views = Bundle.main.loadNibNamed("ActivityView", owner: self, options: nil) as? [ActivityView], views.count > 0 {
            
            self.activityIndicator = views.first!
            self.activityIndicator?.center = self.view.center
            self.view.addSubview(activityIndicator!)
            self.activityIndicator?.startIndicator()
        }
    }
    
    func stopActivityIndicator() {
        self.activityIndicator?.stopIndicator()
    }

}
