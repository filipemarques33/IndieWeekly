//
//  GameInfoExtension.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 19/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

extension GameInfoViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        if section == 0 || section == 1 {
            return UITableViewAutomaticDimension
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Web Views
        if indexPath.section == 3 || indexPath.section == 4 {
            let indexPath = self.infoTableView.indexPathForSelectedRow
            let cell = self.infoTableView.cellForRow(at: indexPath!) as! LinkCell
            
            let webVC = WebViewController(url: cell.website)
            webVC.delegate = self
            webVC.dismissButtonStyle = .close
            
            self.present(webVC, animated: true, completion: nil)
        }
        // Community View
        else if indexPath.section == 2 {
            self.setUpActivityIndicator()
            DatabaseManager.fetchGameComments(game: selectedGame, completionHandler:{ (error) in
                self.stopActivityIndicator()
                self.performSegue(withIdentifier: "segueToCommunity", sender: self)
            })
        }
        
    }
}

extension GameInfoViewController:SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
    }
}

extension GameInfoViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("Synopsis", comment: "")
        case 1:
            return NSLocalizedString("Editor's Critic", comment: "")
        case 2:
            return NSLocalizedString("Community", comment: "")
        case 3:
            return NSLocalizedString("Stores", comment: "")
        case 4:
            return NSLocalizedString("Developer", comment: "")
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 3:
            return selectedGame.stores.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! PlainInfoCell
            cell.infoLabel.text = self.selectedGame.synopsis
            cell.infoLabel.setLineHeight(lineHeight: 1.25)
            return cell
            
        } else if section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! PlainInfoCell
            cell.infoLabel.text = self.selectedGame.editorsCritic
            cell.infoLabel.setLineHeight(lineHeight: 1.25)
            return cell
            
        } else if section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "segueCell", for: indexPath) as! SegueCell
            cell.cellText.text = NSLocalizedString("Read all users' comments", comment: "")
            cell.cellImage.image = UIImage(named: "cell_community")
            return cell
            
        } else if section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "linkCell", for: indexPath) as! LinkCell
            cell.cellText.text = selectedGame.stores[row].name
            cell.cellImage.image = selectedGame.stores[row].image
            cell.website = selectedGame.stores[row].website
            return cell
            
        } else if section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "linkCell", for: indexPath) as! LinkCell
            cell.cellText.text = selectedGame.developer
            cell.cellImage.image = UIImage(named: "cell_website")
            cell.website = selectedGame.devWebsite
            return cell
        }
        
        return UITableViewCell()
        
    }
    
}

extension UILabel {
    func setLineHeight(lineHeight: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.0
        paragraphStyle.lineHeightMultiple = lineHeight
        paragraphStyle.alignment = self.textAlignment
        
        let attrString = NSMutableAttributedString(string: self.text!)
        attrString.addAttribute(NSAttributedStringKey.font, value: self.font, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        self.attributedText = attrString
    }
}

extension UIView {
    func applyGradient() {
        let gradient = CAGradientLayer()
        let clear = UIColor.clear.cgColor
        let black = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75).cgColor
        
        gradient.colors = [clear, black]   // your colors go here
        gradient.locations = [0.0, 1.0]
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
    }
}


