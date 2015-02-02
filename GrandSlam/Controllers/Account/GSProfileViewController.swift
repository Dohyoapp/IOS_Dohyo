//
//  GSProfileViewController.swift
//  GrandSlam
//
//  Created by Explocial 6 on 29/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

let SHARE_TEXXT = "Spread the word!"


class GSProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var tableView       = UITableView(frame:CGRectZero)
    var tableViewData   = NSMutableArray()
    
    var imageUserView:UIImageView!
    
    var socialShareViewController:GSSocialShareViewController!
    
    let yStart = NAVIGATIONBAR_HEIGHT+20
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableViewData.addObject("My leagues")
        
        let leagues = GSMainViewController.getMainViewControllerInstance().leagues
        var league:PFObject
        for league in leagues{
            tableViewData.addObject(league["title"] as NSString)
        }
        tableViewData.addObject("")
        tableViewData.addObject(SHARE_TEXXT)
        tableViewData.addObject("")
        tableViewData.addObject("Sign Out")
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        tableView.frame         = CGRectMake(0, yStart, self.view.frame.size.width, self.view.frame.size.height-yStart)
        tableView.dataSource    = self
        tableView.delegate      = self
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.separatorStyle  = .None
        self.view.addSubview(tableView)
    }
    
    func closeView(){
        
        SVProgressHUD.dismiss()
        self.view.removeFromSuperview()
        GSMainViewController.getMainViewControllerInstance().createAccountView = false
    }
    
    func createMainCell(cell : UITableViewCell){
        
        imageUserView = UIImageView(frame: CGRectMake(100, 10, 120, 120))
        imageUserView.layer.cornerRadius = 60
        imageUserView.clipsToBounds = true
        var user = PFUser.currentUser()
        let userImageFile:AnyObject! = user.valueForKey("image")
        if(userImageFile != nil){
            (userImageFile as PFFile).getDataInBackgroundWithBlock { (imageData: NSData!, error: NSError!) -> Void in
                if error == nil {
                    self.imageUserView.image = UIImage(data:imageData)
                }
                else{
                    self.imageUserView.image = UIImage(named:"Profile_Icon_Holder")
                }
            }
        }
        else{
            imageUserView.image = UIImage(named:"Profile_Plus")
        }
        
        cell.addSubview(imageUserView)
        
        var imageView = UIView(frame:imageUserView.frame)
        imageView.addGestureRecognizer( UITapGestureRecognizer(target: self, action:Selector("profileImageTap:")) )
        cell.addSubview(imageView)
        
        
        let userNameLabel = UILabel(frame: CGRectMake(50, 145, 220, 33))
        userNameLabel.text = PFUser.currentUser()["username"] as NSString
        userNameLabel.textAlignment = .Center
        userNameLabel.font = UIFont(name:FONT1, size:15)
        userNameLabel.textColor = SPECIALBLUE
        cell.addSubview(userNameLabel)
        
        let emailLabel = UILabel(frame: CGRectMake(50, 170, 220, 33))
        emailLabel.text = PFUser.currentUser()["email"] as NSString
        emailLabel.textAlignment = .Center
        emailLabel.font = UIFont(name:FONT1, size:15)
        emailLabel.textColor = SPECIALBLUE
        cell.addSubview(emailLabel)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 0){
            return 1
        }
        return tableViewData.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        if(indexPath.section == 0){
            return 230
        }else{
            
            if(indexPath.row == 0){
                return 40
            }
            if(indexPath.row == tableViewData.count-2){
                return 70
            }
            return 32
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0){
            
            var cell = UITableViewCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"MainCustomCell")
            createMainCell(cell)
            cell.selectionStyle = .None
            return cell
        }
        else{
            
            var cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell") as GSProfileCell!
            if(cell == nil){
                cell = GSProfileCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"ProfileCell")
            }
            cell.selectionStyle = .None
            
            var objectString = tableViewData.objectAtIndex(indexPath.row) as NSString
            
            cell.labelText.font = UIFont(name:FONT1, size:18)
            if(indexPath.row == 0 || objectString.isEqualToString(SHARE_TEXXT)){
                cell.labelText.font = UIFont(name:FONT4, size:18)
            }
            cell.labelText.text = tableViewData.objectAtIndex(indexPath.row) as NSString
            
            
            cell.viewWithTag(556)?.removeFromSuperview()
            if(indexPath.row == tableViewData.count-2){
                socialShareViewController = GSSocialShareViewController()
                socialShareViewController.view.frame = CGRectMake(0, 0, 320, 40)
                socialShareViewController.view.tag = 556
                cell.addSubview(socialShareViewController.view)
            }
            
            cell.viewWithTag(555)?.removeFromSuperview()
            if(indexPath.row == tableViewData.count-1){
                
                var signInButton = UIButton(frame: CGRectMake(70, 0, 180, 30))
                signInButton.tag = 555
                signInButton.setTitle(objectString, forState: .Normal)
                signInButton.titleLabel!.font = UIFont(name:FONT3, size:15)
                signInButton.setTitleColor(SPECIALBLUE, forState: .Normal)
                signInButton.backgroundColor = UIColor.whiteColor()
                signInButton.layer.borderColor = SPECIALBLUE.CGColor
                signInButton.layer.borderWidth = 1.5
                signInButton.addTarget(self, action:"signOutTap", forControlEvents:.TouchUpInside)
                cell.addSubview(signInButton)
            }
        
            return cell
        }
    }
    
    
    
    func signOutTap(){
        
        var user = PFUser.currentUser()
        PFFacebookUtils.unlinkUserInBackground(user) { (success, error) -> Void in
            
            if(PFFacebookUtils.session() != nil){
                PFFacebookUtils.session().closeAndClearTokenInformation()
               // PFFacebookUtils.session().close()
            }
            PFUser.logOut()
            self.closeView()
        }
    }
    
    
    
    func profileImageTap(recognizer: UITapGestureRecognizer!){
        
        var user = PFUser.currentUser()
        let userImageFile:AnyObject! = user.valueForKey("image")
        if(userImageFile != nil){
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Take Photo","Choose Existing","Remove Photo")
            actionSheet.showInView(self.view)
        }else{
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Take Photo","Choose Existing")
            actionSheet.showInView(self.view)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int)
    {
        switch buttonIndex{
            
        case 0:
            NSLog("Cancel")
            break;
        case 1:
            NSLog("Take Photo")
            pressedTakePhoto()
            break;
        case 2:
            NSLog("Choose Existin")
            pressedChooseExisting()
            break;
        case 3:
            NSLog("Remove Photo")
            clearImage()
            break;
        default:
            NSLog("Default")
            break;
            //Some code here..
            
        }
    }

    func pressedTakePhoto(){

        if(UIImagePickerController.isSourceTypeAvailable(.Camera)){
            
            var imagePicker = UIImagePickerController()
            imagePicker.sourceType = .Camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self;
            GSMainViewController.getMainViewControllerInstance().presentViewController(imagePicker, animated: true, completion: nil)
        }
        else{
            var alertView = UIAlertView(title: "Camera not available.", message: "You don't have a camera or it is currently not available.", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
    }
    
    func pressedChooseExisting(){
        
        if(UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)){
            
            var imagePicker = UIImagePickerController()
            imagePicker.sourceType = .PhotoLibrary
            imagePicker.allowsEditing = true
            imagePicker.delegate = self;
            GSMainViewController.getMainViewControllerInstance().presentViewController(imagePicker, animated: true, completion: nil)
        }
    }

    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        GSMainViewController.getMainViewControllerInstance().dismissViewControllerAnimated(true, nil)
        
        var userId:AnyObject! = PFUser.currentUser().objectId
        if(userId != nil){
            SVProgressHUD.show()
            let imageFile = PFFile(name:NSString(format:"image%@.png", userId as NSString), data:UIImagePNGRepresentation(image))
            PFUser.currentUser().setObject(imageFile, forKey: "image")
            PFUser.currentUser().saveInBackgroundWithBlock({ (success, error) -> Void in
                self.imageUserView.image = image
                SVProgressHUD.dismiss()
            })
        }
    }

    func clearImage(){
        
        self.imageUserView.image = UIImage(named:"Profile_Plus")
        PFUser.currentUser().removeObjectForKey("image")
        PFUser.currentUser().save()
    }
}
