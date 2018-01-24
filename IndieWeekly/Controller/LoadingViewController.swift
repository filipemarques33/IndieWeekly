//
//  LoadingViewController.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 16/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    weak var activityIndicator:ActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpActivityIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkSegue()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkSegue() {
        
        
        
        let loginScreenNeed = LoginServices.checkLoginScreenNeed()
        
        if loginScreenNeed != false {
            self.stopActivityIndicator()
            self.performSegue(withIdentifier: "segueToLogin", sender: self)
        } else {
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            LoginServices.checkAndStartSession(completionHandler: {
                (fetchedUser) in
                MainUser.shared = fetchedUser
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            DatabaseManager.fetchGameOfTheWeek(completionHandler: {
                (fetchedGame) in
                if fetchedGame == nil {
                    print("error fetching game")
                } else {
                    GameOfTheWeek.shared = fetchedGame
                }
                dispatchGroup.leave()
            })
            
            dispatchGroup.notify(queue: .main, execute: {
                self.stopActivityIndicator()
                self.performSegue(withIdentifier: "segueToApp", sender: self)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToLogin", let destination = segue.destination as? LoginViewController {
            destination.sourceViewController = self
            
        } else if segue.identifier == "segueToApp" {
            
            let tabVc = segue.destination as! UITabBarController
            let navVc = tabVc.viewControllers!.first as! UINavigationController
            let gameVc = navVc.viewControllers.first as! GameInfoViewController
            gameVc.selectedGame = GameOfTheWeek.shared!
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
