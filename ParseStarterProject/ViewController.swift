/**
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {
    
    //MARK :- IBOutlets
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var `switch`: UISwitch!
    @IBOutlet var riderLabel: UILabel!
    @IBOutlet var driverLabel: UILabel!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var toggleSignUpButton: UIButton!
    
    //MARK :- Global Variables
    
    var signUpState = true
    
    
    //MARK :- User Defined Functions
    
    func alert(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK :- IBActions
    
    @IBAction func signUp(sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
            
            alert("Error!",message: "Enter Username and Password!")
            
        } else {
            
            if signUpState == true {
                
                let user = PFUser()
                user.username = username.text
                user.password = password.text
    
                user["isRider"] = `switch`.on
                
                user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                    
                    if let error = error {
                        print(error)
                        self.alert("Sign Up Failed!", message: error.userInfo["error"] as! String)
                        
                    } else if success != true {
                        
                        print(success)
                        
                    } else {
                        
                        self.performSegueWithIdentifier("loginRider", sender: self)
                    }
                    
                })
            } else {
                
                PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: { (user, error) -> Void in
                    
                    if user != nil {
                        
                        self.performSegueWithIdentifier("loginRider", sender: self)
                        
                    } else {
                        
                        self.alert("Login Failed!", message: error?.userInfo["error"] as! String)
                        
                    }
                    
                    })
                
                
            }
            
        }
        
    }
    
    @IBAction func toggleSignUp(sender: AnyObject) {
        
        if signUpState == true {
            
            signUpButton.setTitle("Sign In", forState: UIControlState.Normal)
            toggleSignUpButton.setTitle("Switch to Sign Up", forState: UIControlState.Normal)
            signUpState = false
            
            riderLabel.hidden = true
            driverLabel.hidden = true
            `switch`.hidden = true
            
        } else {
            
            signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
            toggleSignUpButton.setTitle("Switch to Login", forState: UIControlState.Normal)
            signUpState = true
            
            riderLabel.hidden = false
            driverLabel.hidden = false
            `switch`.hidden = false
        }
        
    }
    
    //MARK :- Overidden Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.username.delegate = self
        self.password.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser()?.username != nil {
            
            performSegueWithIdentifier("loginRider", sender: self)
        
        }
    }
    
}
