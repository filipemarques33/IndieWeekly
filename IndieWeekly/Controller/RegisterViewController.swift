//
//  RegisterViewController.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 11/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    var source:LoginViewController!
    
    @IBAction func backBtn(_ sender: UIButton) {
        source.registered = false
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerBtnPressed (_ sender: UIButton) {
        let username = self.nameField.text!
        let email = self.emailField.text!
        
        if username != "" && email != "" && self.passwordField.text! != "" &&  self.confirmPasswordField.text! != "" {
            if self.passwordField.text! == self.confirmPasswordField.text! {
                LoginServices.handleUserRegistration(username: username, email: email, password: self.passwordField.text!) {
                    (error) in
                    if error != nil {
                        if let errorDesc = error?.localizedDescription {
                            print(errorDesc)
                        }
                    } else {
                        self.showConfirmationAlert()
                    }
                }
                
            } else {
                print ("Password and Confirmation must be the same")
            }

            
        } else {
            print ("Fill all fields to proceed")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Username", comment: "User's username"), attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        emailField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("E-mail", comment: "User's Email"), attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        emailField.keyboardType = .emailAddress
        
        passwordField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Password", comment: "User's Password"), attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        confirmPasswordField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Confirm Password", comment: "Password Confirmation"), attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        // Tap gesture to hide keyboard
        let tap = UITapGestureRecognizer(target:self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    func showConfirmationAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Registration Successful", comment: ""), message: NSLocalizedString("Thank you, \(self.nameField.text!), your registration was succesful! Enjoy IndieWeekly!", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action) in
            self.source.registered = true
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
