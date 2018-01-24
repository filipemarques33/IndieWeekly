//
//  ActivityView.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 18/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit

class ActivityView: UIView {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor(red: 0/255, green: 164/255, blue: 241/255, alpha: 1)
        self.layer.cornerRadius = 8.0
        
        self.activityIndicator.activityIndicatorViewStyle = .whiteLarge
        self.activityIndicator.hidesWhenStopped = true
    }
    
    func startIndicator() {
        self.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    func stopIndicator() {
        self.isHidden = true
        self.activityIndicator.stopAnimating()
    }
}
