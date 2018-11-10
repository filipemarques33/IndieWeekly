//
//  WebViewController.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 17/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit
import SafariServices

class WebViewController: SFSafariViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        UIApplication.shared.statusBarStyle = .default
//        super.viewWillAppear(animated)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        UIApplication.shared.statusBarStyle = .lightContent
//        super.viewWillDisappear(animated)
//    }
    

    

}
