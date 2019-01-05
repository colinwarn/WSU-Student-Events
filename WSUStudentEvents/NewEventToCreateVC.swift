//
//  NewEventToCreateVC.swift
//  WSUStudentEvents
//
//  Created by Colin Warn on 7/31/17.
//  Copyright © 2017 Colin Warn. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class NewEventToCreateVC: UIViewController {
    var eventToCreate: UserEvent?
    
    

    @IBOutlet weak var titleOutlet: UILabel!
    @IBOutlet weak var startTimeOutlet: UILabel!
    
    @IBOutlet weak var eventTypeOutlet: UILabel!
    @IBOutlet weak var locationOutlet: UILabel!
    @IBOutlet weak var descriptionOutlet: UITextView!
    @IBOutlet weak var passwordOutlet: UILabel!
    
    
    let defaults = UserDefaults.standard
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        var startDateString = ""
        var endDateString = ""
        if let startTime = eventToCreate?.startTime, let endTime = eventToCreate?.endTime {
            startDateString = formatter.string(from: startTime)
            endDateString = formatter.string(from: endTime)
        }
        
        
        titleOutlet.text = eventToCreate?.eventName
        startTimeOutlet.text = "\(startDateString) - \(endDateString)"
        eventTypeOutlet.text = eventToCreate?.eventType
        locationOutlet.text = eventToCreate?.eventLocation
        descriptionOutlet.text = eventToCreate?.description
        if let password = eventToCreate?.password {
            if password == "" {
                passwordOutlet.text = "(no password)"
            } else {
                passwordOutlet.text = "Password: \(password)"
            }
            
        }
        

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("EVENT TO CREATE, new VC data transfer check")
        print(eventToCreate)
        print(eventToCreate?.eventName)
    }
    
    
    @IBAction func addEventPressed(_ sender: Any) {
        uploadDataToFirebase()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        present(nextViewController, animated: true, completion: nil)
    }
    
    

    @IBAction func backBtnPressed(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "AddEventViewModelVC") as! AddEventViewModelVC
        if let eventName = eventToCreate?.eventName {
            nextViewController.eventName = eventName
        }
        
        if let eventLocation = eventToCreate?.eventLocation {
            nextViewController.eventLocation = eventLocation
        }
        
        nextViewController.startTime = eventToCreate?.startTime
        nextViewController.endTime = eventToCreate?.endTime
        if let description = eventToCreate?.description {
            nextViewController.eventDescription = description
        }
        
        if let password = eventToCreate?.password {
            nextViewController.password = password
            
        }
        
        if let eventType = eventToCreate?.eventType
        {
            nextViewController.eventType = eventType
        }
        nextViewController.eventEnum = .password
        
        nextViewController.didNavigateFromMainView = false
        
        self.present(nextViewController, animated:true, completion: {
            nextViewController.titleLabel.text = nextViewController.eventEnum.rawValue
            nextViewController.textField.text = self.eventToCreate?.password
        })
    }
    
    func uploadDataToFirebase(){
      
        
        let email = defaults.object(forKey: "email") as! String
        print(email)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +SSSS"
        
        
        
        
        if let eventName = eventToCreate?.eventName, let eventType = eventToCreate?.eventType, let location = eventToCreate?.eventLocation, let password = eventToCreate?.password, let description = eventToCreate?.description, let startTime = eventToCreate?.startTime, let endTime = eventToCreate?.endTime {
            print(startTime)
            print(endTime)
            
            let strEndTime = formatter.string(from: endTime)
            let strStartTime = formatter.string(from: startTime)
            
            print("-----")
            print(strStartTime)
            print(strEndTime)
            
            let post = ["eventName": eventName,
                        "eventType": eventType,
                        "location": location,
                        "password": password,
                        "startTime": strStartTime,
                        "endTime": strEndTime,
                        "description": description] as [String : Any]
            
            print(post)
            
            ref.child(email).child("event").setValue(post)

            
        } else {
            print("error uploading files to firebase")
        }
        
        
    
        
        
        
        
        
        //Email->Events->Data
        
        //Set Email
        
        
        print("Uploading to firebase")
        //Set events
        
        //ref.child(email).child("event").setValuesForKeys(["eventName": eventToCreate?.eventName, "eventType": eventToCreate?.eventType])
        
        
        
    }
    
}
