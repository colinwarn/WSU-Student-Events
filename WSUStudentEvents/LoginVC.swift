//
//  LoginVC.swift
//  WSUStudentEvents
//
//  Created by Colin Warn on 8/1/17.
//  Copyright © 2017 Colin Warn. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var loginBtnOutlet: UIButton!
    @IBOutlet weak var loginSCOutlet: UISegmentedControl!
    
    @IBOutlet weak var emailTFOutlet: UITextField!
    @IBOutlet weak var passwordTFOutlet: UITextField!
    
    let defaults = UserDefaults.standard
    let loggedInKey = "isLoggedIn"
    var isSignIn = true
    
    var email = ""
    var password = ""
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTFOutlet.delegate = self
        passwordTFOutlet.delegate = self
        
        
        // Dismiss keyboard on tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginVC.dismissKeyboard))
        
       
        
        view.addGestureRecognizer(tap)
        
        emailTFOutlet.addTarget(self, action: #selector(LoginVC.emailTFTextChanged), for: .editingDidEnd)
        passwordTFOutlet.addTarget(self, action: #selector(LoginVC.passwordTFTextChanged), for: .editingDidEnd)
        emailTFOutlet.addTarget(self, action: #selector(LoginVC.disableLoginButton), for: .editingDidBegin)
        passwordTFOutlet.addTarget(self, action: #selector(LoginVC.disableLoginButton), for: .editingDidBegin)
        

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        let isLoggedIn = defaults.bool(forKey: loggedInKey)
        print(isLoggedIn)
        if isLoggedIn == true{
            presentMainScreen()
        }
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func disableLoginButton() {
        loginBtnOutlet.isEnabled = false
        loginBtnOutlet.isHidden = true
        loginSCOutlet.isEnabled = false
        loginSCOutlet.isHidden = true
    }
    func enableLoginButton() {
        loginBtnOutlet.isEnabled = true
        loginBtnOutlet.isHidden = false
        loginSCOutlet.isEnabled = true
        loginSCOutlet.isHidden = false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func forgotUsernamePasswordPressed(_ sender: Any) {
        //Embed in UIAlertController with Textfield, pass in email
        
        let passwordResetController = UIAlertController(title: "Password Reset", message: "Enter the email address to send the password reset instructions to", preferredStyle: UIAlertControllerStyle.alert)
        
            passwordResetController.addAction(UIAlertAction(title: "Enter", style: .default, handler: {
                alert -> Void in
                let passwordTextField = passwordResetController.textFields![0] as UITextField
                let emailToCheck = passwordTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
                    Auth.auth().sendPasswordReset(withEmail: emailToCheck!) { error in
                        if error != nil {
                            let errorControl = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                            errorControl.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(errorControl, animated: true, completion: nil)
                            
                        }
                        else {
                            let okControl = UIAlertController(title: "Email Sent", message: "Password Reset Email has been sent", preferredStyle: .alert)
                            okControl.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(okControl, animated: true, completion: nil)
                        }

                    }

        
               }))
        
        passwordResetController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = "Email"
        })
        
        passwordResetController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            passwordResetController.dismiss(animated: true, completion: nil)
        }))
        present(passwordResetController, animated: true, completion: nil)
    }
    
    

    @IBAction func loginTypeSegmentControllChanged(_ sender: UISegmentedControl) {
        
        
        loginBtnOutlet.setTitle(loginSCOutlet.titleForSegment(at: loginSCOutlet.selectedSegmentIndex), for: .normal)
        
        if loginSCOutlet.selectedSegmentIndex == 0 {
            isSignIn = true
        } else {
            isSignIn = false
        }
    }
    
    
 
    func emailTFTextChanged() {
        enableLoginButton()
        if let text = emailTFOutlet.text {
            email = text
            
            
        }
    }
    
    
    func passwordTFTextChanged() {
        enableLoginButton()
        if let text = passwordTFOutlet.text {
            password = text
        }
    }
    
    
    
    
    
    
    
  
    @IBAction func logOrRegBtnPressed(_ sender: Any) {
        if isSignIn == true {
            login()
        } else {
            register()
        }
    }
    
    
    //MARK: Login/Register
    func login() {
        
        if email.trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("wsu.edu") {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    self.alertDisplay(title: "Error with Sign In", message: "Your email or password was not correct.")
                } else {
                    
                    
                    
                    
                    
                    
                    
                    if let isVerified = user?.isEmailVerified {
                        // Check if email is verified
                        if !isVerified {
                            let verifyAlert = UIAlertController(title: "Email Not Verified", message: "Your email was not verified.  Resend verification email?", preferredStyle: UIAlertControllerStyle.alert)
                            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                user?.sendEmailVerification(completion: nil)
                            })
                            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
                            verifyAlert.addAction(yesAction)
                            verifyAlert.addAction(noAction)
                            self.defaults.set(true, forKey: self.loggedInKey)
                            
                            

                            print(self.defaults.bool(forKey: self.loggedInKey))
                                
                            self.present(verifyAlert, animated: true, completion: nil)
                            
                        } else {
                            //Username and email for posting to Firebase
                            let emailWithoutPeriods = user?.email?.replacingOccurrences(of: ".", with: "")
                            self.defaults.setValue(emailWithoutPeriods, forKey: "email")
                            
                            self.defaults.set(true, forKey: self.loggedInKey)
                            self.presentMainScreen()
                        }
                    }
                    self.alertDisplay(title: "Success", message: "Logged in successfully.")
                }
            }
        }
            
        else {
            alertDisplay(title: "Invalid Email", message: "The email you entered is not a valid wsu.edu address.")
        }
        
        
    }
    
    func register(){
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                guard let errorMessage = error?.localizedDescription else {
                    return
                }
                self.alertDisplay(title: "Error Creating User", message: "Error creating user. Error: \(errorMessage)")
                print(self.loginSCOutlet.selectedSegmentIndex)
            } else {
                if self.email.trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("wsu.edu") {
                    self.alertDisplay(title: "Verify Your Email", message: "A verification email was sent")
                    print("User created")
                    print(user?.email)
                    
                                        //Send email verification letter
                    user?.sendEmailVerification(completion: nil)
                    
                } else {
                    self.alertDisplay(title: "Invalid Email", message: "The email you entered is not a valid wsu.edu address.")
                }
            }
        }
        
        
    }
    
    func alertDisplay(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentMainScreen() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        self.present(nextViewController, animated:true, completion: nil)
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
