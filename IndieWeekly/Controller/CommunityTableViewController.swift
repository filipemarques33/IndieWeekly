//
//  CommunityTableViewController.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 19/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit
import Nuke

protocol PostCommentDataSource: NSObjectProtocol {
    func getCommentView()->UITextView?
}

class CommunityTableViewController: UITableViewController {

    var selectedGame:Game!
    var comments:[Comment]!
    
    weak var postDataSource:PostCommentDataSource?
    
    @IBAction func postComment(_ sender: UIBarButtonItem){
        
        if let mainUser = MainUser.shared {
            let commentView = postDataSource?.getCommentView()
            if commentView?.textColor != .lightGray && commentView?.text != "" && commentView?.text != nil {
                DatabaseManager.addComment(fromUser: mainUser, content: (commentView?.text)!, toGame: selectedGame, completionHandler: { (error, comment) in
                    
                    guard (error == nil) else {
                        print("Error adding comment to DB")
                        return
                    }
                    
                    if let dataSource = self.postDataSource as? EditCommentTableViewCell {
                        dataSource.commentContent.textColor = .lightGray
                        dataSource.commentContent.text = NSLocalizedString("Write something about this game!", comment: "")
                        dataSource.endEditing(true)
                    }
                    
                    self.getComments(completionBlock: nil)
                })
            }
            
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Login Neccessary", comment: ""), message: NSLocalizedString("Please log in to write a comment about this game.", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = selectedGame.name
        self.tableView.estimatedRowHeight = 87
        
        comments = selectedGame.comments
        comments.sort(by: {$0.dateCreated > $1.dateCreated})
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tap)
        
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (1 + selectedGame.comments.count)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 8
        } else if section == 1 {
            return 40
        } else {
            return 4
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Users' comments"
        }
        return nil
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! EditCommentTableViewCell
            
            cell.profilePicture.image = UIImage(named:"PlaceholderProfilePicture")
            if let user = MainUser.shared, let imageURL = user.profilePictureURL {
                Manager.shared.loadImage(with: imageURL, into: cell.profilePicture)
            }
            
            cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.height/2
            cell.commentContent.delegate = self
            cell.commentContent.textColor = .lightGray
            cell.commentContent.centerVertically()
            cell.commentContent.text = NSLocalizedString("Write something about this game!", comment: "")
            
            self.postDataSource = cell
            
            return cell
            
        } else {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
            
            cell.comment = comments[(indexPath.section)-1]
            
            cell.creatorName.text = comments[(indexPath.section)-1].creator.username
            
            cell.profilePicture.image = UIImage(named:"PlaceholderProfilePicture")
            if let imageURL = comments[(indexPath.section)-1].creator.profilePictureURL {
                Manager.shared.loadImage(with: imageURL, into: cell.profilePicture)
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
            cell.dateCreated.text = dateFormatter.string(from: comments[(indexPath.section)-1].dateCreated)
            
            cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.height/2
            
            cell.commentContent.text = comments[(indexPath.section)-1].content
            cell.commentContent.setLineHeight(lineHeight: 1.25)
            
            cell.delegate = self
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func getComments(completionBlock: (()->Void)? = nil) {
        DatabaseManager.fetchGameComments(game: selectedGame) { (success) in
            self.comments = self.selectedGame.comments
            self.comments.sort(by: {$0.dateCreated > $1.dateCreated})
            self.tableView.reloadData()
            if let completion = completionBlock {
                completion()
            }
        }
    }
    
    @objc func handleRefresh (_ refreshControl: UIRefreshControl) {
        self.getComments() {
            refreshControl.endRefreshing()
        }
    }
    
    func report(comment:Comment, blacklisted:Bool){
        DatabaseManager.report(comment: comment, onGame: selectedGame, blacklisted: blacklisted) { (error) in
            if error != nil {
                print(error?.localizedDescription ?? "Error")
            }
            self.getComments()
        }
    }
}

extension CommunityTableViewController:CommentCellDelegate {
    
    func moreButtonPressed(onCell cell: CommentTableViewCell) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: NSLocalizedString("Report", comment: ""), style: .default) { (action) in
            let alertPrompt = UIAlertController(title: NSLocalizedString("Report Message", comment: ""), message: NSLocalizedString("Do you want stop getting posts this user as well?", comment: ""), preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            alertPrompt.addAction(cancelAction)
            
            let yesAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: {
                (action) in
                
                self.report(comment: cell.comment, blacklisted: true)
            })
            
            alertPrompt.addAction(yesAction)
            
            let noAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: {
                (action) in
                
                self.report(comment: cell.comment, blacklisted: false)
                
            })
            alertPrompt.addAction(noAction)
            
            self.present(alertPrompt, animated: true, completion: nil)
            
        }
        actionSheet.addAction(reportAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }

}

extension CommunityTableViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
        textView.centerVertically()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray && textView.isFirstResponder {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing (_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "" {
            textView.textColor = .lightGray
            textView.text = NSLocalizedString("Write something about this game!", comment: "")
        }
    }

}

extension UITextView {
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
}

