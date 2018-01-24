//
//  CommunityTableViewController.swift
//  IndieWeekly
//
//  Created by Filipe Marques on 19/01/18.
//  Copyright © 2018 Filipe Marques. All rights reserved.
//

import UIKit

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
                let newComment = Comment(creator: mainUser, dateCreated: Date(), content: (commentView?.text)!)
                DatabaseManager.add(comment: newComment, toGame: selectedGame, completionHandler: { (error) in
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
            
            cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.height/2
            
            cell.commentContent.delegate = self
            cell.commentContent.textColor = .lightGray
            cell.commentContent.centerVertically()
            cell.commentContent.text = NSLocalizedString("Write something about this game!", comment: "")
            
            self.postDataSource = cell
            
            return cell
            
        } else {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
            cell.creatorName.text = comments[(indexPath.section)-1].creator.username
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
            cell.dateCreated.text = dateFormatter.string(from: comments[(indexPath.section)-1].dateCreated)
            
            cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.height/2
            
            cell.commentContent.text = comments[(indexPath.section)-1].content
            cell.commentContent.setLineHeight(lineHeight: 1.25)
            
            cell.isUserInteractionEnabled = false
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

