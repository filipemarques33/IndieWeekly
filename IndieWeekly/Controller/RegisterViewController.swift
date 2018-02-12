//
//  RegisterViewController.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 11/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit
import SafariServices

class RegisterViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    weak var activityIndicator:ActivityView?
    
    var source:LoginViewController!
    
    @IBAction func backBtn(_ sender: UIButton) {
        source.registered = false
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func PrivacyPolicyTap(_ sender: UITapGestureRecognizer) {
        let ppURL = URL(string: "https://drive.google.com/file/d/1r4lt2rMjsYaX_F4N30RcyEsSL10XBq8r/view")
        
        let webVC = WebViewController(url: ppURL!)
        webVC.delegate = self
        if #available(iOS 11.0, *) {
            webVC.dismissButtonStyle = .close
        }
        
        self.present(webVC, animated: true, completion: nil)
    }
    
    @IBAction func TermsAndConditionsTap(_ sender: UITapGestureRecognizer) {
        let tcURL = URL(string: "https://docs.google.com/document/d/17WVoQ3uVMVIJ4lHcu57XtujoRbDEKYWq8MDIP489gc8/view")
        
        let webVC = WebViewController(url: tcURL!)
        webVC.delegate = self
        if #available(iOS 11.0, *) {
            webVC.dismissButtonStyle = .close
        }
        
        self.present(webVC, animated: true, completion: nil)
    }
    
    
    @IBAction func registerBtnPressed (_ sender: UIButton) {
        let username = self.nameField.text!
        let email = self.emailField.text!
        let password = self.passwordField.text!
        let passwordConfirmation = self.confirmPasswordField.text!
        
        self.setUpActivityIndicator()
        LoginServices.handleUserRegistration(username: username, email: email, password: password, passwordConfirmation: passwordConfirmation) {
            (error) in
            self.stopActivityIndicator()
            if error != nil {
                if let errorDesc = error?.localizedDescription {
                    self.errorLabel.text = errorDesc
                }
            } else {
                self.showConfirmationAlert()
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.errorLabel.text = ""
        
        nameField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Username", comment: "User's username"), attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        nameField.delegate = self
        
        emailField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("E-mail", comment: "User's Email"), attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        emailField.keyboardType = .emailAddress
        emailField.delegate = self
        
        passwordField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Password", comment: "User's Password"), attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        passwordField.delegate = self
        
        confirmPasswordField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Confirm Password", comment: "Password Confirmation"), attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        confirmPasswordField.delegate = self
        
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

extension RegisterViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            confirmPasswordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
