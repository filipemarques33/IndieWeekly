//
//  ViewController.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 10/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var backBtn: UIButton!
    var sourceViewController:UIViewController? = nil
    var registered:Bool = false
    
    weak var activityIndicator:ActivityView?
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        let email = emailField.text!
        let password = passwordField.text!
        
        
        self.setUpActivityIndicator()
        LoginServices.handleUserLoggedIn(email: email, password: password) { (success, error) in
            self.stopActivityIndicator()
            if success {
                self.segueToApp()
            } else {
                if error != nil {
                    if let errorDesc = error?.localizedDescription {
                        self.errorLabel.text = errorDesc
                    }
                }
            }
        }
    }
    
    @IBAction func continueBtnPressed(_ sender: UIButton) {
        self.setUpActivityIndicator()
        self.segueToApp()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.errorLabel.text = ""
        
        // Editing email textfield
        emailField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("E-mail", comment: "User's Email"), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        emailField.delegate = self
        emailField.keyboardType = .emailAddress
        
        
        passwordField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Password", comment: "User's Password"), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        passwordField.delegate = self
        
        
        
        let tap = UITapGestureRecognizer(target:self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tap)
        
        if sourceViewController is LoadingViewController {
            backBtn.isHidden = true
        } else {
            backBtn.isHidden = false
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        if self.registered == true {
            self.setUpActivityIndicator()
            self.segueToApp()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    func segueToApp() {
        if sourceViewController is LoadingViewController {
            DatabaseManager.fetchGameOfTheWeek(completionHandler: {
                (fetchedGame) in
                if fetchedGame == nil {
                    print("error fetching game")
                } else {
                    GameOfTheWeek.shared = fetchedGame
                    self.stopActivityIndicator()
                    self.performSegue(withIdentifier: "segueToApp", sender: self)
                }
            })
            LoginServices.setLoginScreenNeed(isNeeded: false)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguetoRegister", let destinationVC = segue.destination as? RegisterViewController {
            destinationVC.source = self
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

extension LoginViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            textField.resignFirstResponder()
        }
        return false
    }

}


