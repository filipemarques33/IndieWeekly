//
//  AboutViewController.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 25/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBAction func backBtnPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var devPicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        devPicture.layer.cornerRadius = devPicture.frame.height/2
        devPicture.layer.borderWidth = 4
        devPicture.layer.borderColor = UIColor.white.cgColor
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

}
