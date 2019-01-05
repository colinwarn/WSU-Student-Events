//
//  AddEventViewModelVC.swift
//  WSUStudentEvents
//
//  Created by Colin Warn on 7/29/17.
//  Copyright © 2017 Colin Warn. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

struct UserEvent {
    var eventName: String = ""
    var description: String = ""
    var endTime: Date?
    var eventType: String = ""
    var eventLocation: String = ""
    var password: String = ""
    var startTime: Date?
    
    
}





enum UserEventEnum: String{
    case eventName = "Event Name"
    case description = "Description"
    case endTime = "End Time"
    case eventType = "Event Type"
    case eventLocation = "Event Location"
    case password = "Password"
    case startTime = "Start Time"
    
    
    
}

class AddEventViewModelVC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    var eventName: String?
    var eventDescription: String?
    var endTime: Date?
    var eventType: String?
    var eventLocation: String?
    var password: String?
    var startTime: Date?
    
    var newUserEventToCreate: UserEvent?
    
    var events = ["party","other","event","hangout","recreation"]

    var eventEnum = UserEventEnum.eventName
    var newEvent: UserEventEnum?
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var eventTypePickerViewOutlet: UIPickerView!
    
    @IBOutlet weak var dateTimerPicker: UIDatePicker!
    @IBOutlet weak var descriptionTextField: UITextView!
    
    @IBOutlet weak var textField: UITextField!
    
    var didNavigateFromMainView = true
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        if didNavigateFromMainView == true{
            if let email = defaults.object(forKey: "email") as? String {
                ref.child(email).observe(DataEventType.value, with: { (snapshot) in
                    if snapshot.hasChild("event") {
                        print("User has event stored")
                        
                        let alertController = UIAlertController(title: "Event Found", message: "An even stored by this user has been retrieved.  Do you want to edit this event, or delete it to create a new one?", preferredStyle: UIAlertControllerStyle.actionSheet)
                        
                        // MARK: Pulling Data from Firebase event on Edit
                        let edit = UIAlertAction(title: "Edit", style: UIAlertActionStyle.default, handler: { (action) in
                            if let email = UserDefaults.standard.object(forKey: "email") as? String {
                                print(email)
                                self.ref.child(email).child("event").observe(DataEventType.value, with: {
                                    (snapshot) in
                                    
                                    for i in snapshot.children.allObjects as! [DataSnapshot] {
                                        print(i)
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = ""
                                        
                                        if i.key == "eventName" {
                                            self.eventName = i.value as? String
                                            print(self.eventName)
                                            self.textField.text = self.eventName
                                        }
                                        
                                        if i.key == "eventType" {
                                            self.eventType = i.value as? String
                                        }
                                        
                                        if i.key == "location" {
                                            self.eventLocation = i.value as? String
                                        }
                                        
                                        if i.key == "description" {
                                            self.eventDescription = i.value as? String
                                            self.descriptionTextField.text = self.eventDescription
                                        }
                                        
                                        if i.key == "startTime" {
                                            
                                          let inStartTime = CustomDateClass().formatStringToDate(string: i.value as! String)
                                            
                                          self.startTime = inStartTime
                                        }
                                        
                                        if i.key == "endTime" {
                                            let inEndTime = CustomDateClass().formatStringToDate(string: i.value as! String)
                                            self.endTime = inEndTime
                                            
                                        }
                                        if i.key == "password" {
                                            self.password = i.value as? String
                                            print(self.password!)
                                        }
                                        
                                        
                                    }
                                    
                                })
                                
                            }

                            
                        })
                        let delete = UIAlertAction(title: "Delete and Create an New One", style:
                            UIAlertActionStyle.default, handler: { (action) in
                            //MARK: Delete event and continue
                                
                                
                                
                                let eventDeletedContr = UIAlertController(title: "Event Delete?", message: "Are You Sure You Want To Delete Your Event", preferredStyle: UIAlertControllerStyle.alert)
                                eventDeletedContr.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action) in
                                    
                                    if let email = self.defaults.string(forKey: "email") {
                                        self.ref.child(email).child("event").removeValue()
                                    }
                                    
                                    let eventHasBeenDeleted = UIAlertController(title: "Event Deleted", message: "Your Event Has Been Deleted", preferredStyle: UIAlertControllerStyle.alert)
                                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                                    eventHasBeenDeleted.addAction(ok)
                                    self.present(eventHasBeenDeleted, animated: true, completion: nil)
                                    
                                }))
                                eventDeletedContr.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: { (action) in
                                    
                                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                                    self.present(nextViewController, animated: true, completion: nil)
                                    
                                }))
                                self.present(eventDeletedContr, animated: true, completion: nil)
                            
                                
                            
                        })
                        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                            self.present(nextViewController, animated: true, completion: nil)
                        })
                        alertController.addAction(edit)
                        alertController.addAction(delete)
                        alertController.addAction(cancel)
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                    }
                })
        }
        }
        
        
        
        //Dismiss keyboard setup
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddEventViewModelVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        textField.delegate = self
        eventTypePickerViewOutlet.delegate = self
        eventTypePickerViewOutlet.dataSource = self
        
        //Check to see if datePicker value changed
        dateTimerPicker.addTarget(self, action: #selector(AddEventViewModelVC.dateChanged), for: .valueChanged)
        

        
        titleLabel.text = eventEnum.rawValue
        descriptionTextField.isHidden = true
        textField.isHidden = false
        dateTimerPicker.isHidden = true
        eventTypePickerViewOutlet.isHidden = true

    }
    override func viewDidAppear(_ animated: Bool) {
        
        
        
        
    }
    
    func dateChanged() {
        if eventEnum == .startTime {
            startTime = dateTimerPicker.date
           
        }
        else if eventEnum == .endTime {
            endTime = dateTimerPicker.date
        }
    }

    
    @IBAction func nextBtnPressed(_ sender: Any) {
        if eventEnum == .eventName {
            if let text = textField.text {
                eventName = text
            }
            
            eventEnum = .description
            updateTitle()
            descriptionTextField.isHidden = false
            textField.isHidden = true
            
        }
        else if eventEnum == .description {
            if let description = descriptionTextField.text {
                eventDescription = description
            }
            eventEnum = .startTime
            descriptionTextField.isHidden = true
            dateTimerPicker.isHidden = false
            if let date = startTime {
                dateTimerPicker.date = date
            }
            updateTitle()
        }
        else if eventEnum == .startTime {
            startTime = dateTimerPicker.date
            eventEnum = .endTime
            updateTitle()
            if let date = endTime {
                dateTimerPicker.date = date
            }
        }
        else if eventEnum == .endTime {
            endTime = dateTimerPicker.date
            eventEnum = .eventType
            updateTitle()
            
            
            getEventTypePickerRowValue()
            dateTimerPicker.isHidden = true
            eventTypePickerViewOutlet.isHidden = false
            
        }
        else if eventEnum == .eventType {
            
            eventEnum = .eventLocation
            updateTitle()
            textField.text = eventLocation
            eventTypePickerViewOutlet.isHidden = true
            textField.isHidden = false
            
        }
        else if eventEnum == .eventLocation {
            if let eventLocationTest = textField.text {
                eventLocation = eventLocationTest
            }
            eventEnum = .password
            updateTitle()
            textField.text = password
            
        }
        else if eventEnum == .password {
            if let passwordTest = textField.text {
                password = passwordTest
            }
           
            
            if let eventNameU = eventName, let eventDescriptionU = eventDescription, let endTimeU = endTime, var eventTypeU = eventType, let eventLocationU = eventLocation, let passwordU = password, let startTimeU = startTime {
                
                
                
            
                
                newUserEventToCreate = UserEvent(eventName: eventNameU, description: eventDescriptionU, endTime: endTimeU, eventType: eventTypeU, eventLocation: eventLocationU, password: passwordU, startTime: startTimeU)
                
            }
            
            
           
            
            //MARK: Push to new view controller
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "NewEventToCreateVC") as! NewEventToCreateVC
            nextViewController.eventToCreate = newUserEventToCreate
            self.present(nextViewController, animated:true, completion: nil)
            
            
            updateTitle()
            print(eventName)
            print(eventDescription)
            print(eventLocation)
            print(eventType)
            print(password)
            print(startTime)
            print(endTime)
            
        } else {
            // Navigate to add event check model
            
        }
        
        
        
        
    }
    
    //MARK: DatePicker Delegate
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func updateTitle() {
        
        self.titleLabel.text = self.eventEnum.rawValue
        textField.text = ""
    }
    
    func navigateToMainScreen() {
        let tmpController :UIViewController! = self.presentingViewController;
        
        self.dismiss(animated: false, completion: {()->Void in
            
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        if eventEnum == .eventName {
            // Can't go back any further
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.present(nextViewController, animated: true, completion: nil)
            
            
        }
        else if eventEnum == .description {
            eventEnum = .eventName
            updateTitle()
            textField.text = eventName
            textField.isHidden = false
            descriptionTextField.isHidden = true
            
            
        }
        else if eventEnum == .startTime {
            eventEnum = .description
            updateTitle()
            descriptionTextField.text = eventDescription
            descriptionTextField.isHidden = false
            dateTimerPicker.isHidden = true
        }
        else if eventEnum == .endTime {
            eventEnum = .startTime
            updateTitle()
            if let date = startTime {
                dateTimerPicker.date = date
            }
            
        }
        else if eventEnum == .eventType {
            eventEnum = .endTime
            updateTitle()
            if let date = endTime {
                dateTimerPicker.date = date
            }
            dateTimerPicker.isHidden = false
            eventTypePickerViewOutlet.isHidden = true
        }
        else if eventEnum == .eventLocation {
            
            eventEnum = .eventType
            updateTitle()
            
            
            getEventTypePickerRowValue()
            eventTypePickerViewOutlet.isHidden = false
            textField.isHidden = true
            
        }
        else if eventEnum == .password {
            eventEnum = .eventLocation
            updateTitle()
            textField.text = eventLocation
        } else {
            eventEnum = .password
            updateTitle()
            textField.text = password
            textField.isHidden = false
            
        }
    }
    
    // MARK: Get Event Type Picker Row Value
    func getEventTypePickerRowValue() {
        if let eventTypeUnwrapped = eventType {
            print(eventTypeUnwrapped)
            guard let currentEventTypeRowNumber = events.index(of: eventTypeUnwrapped) else {
                print("ERROR WITH EVENTTYPEROWNUMBER")
                return
            }
            eventTypePickerViewOutlet.selectRow(currentEventTypeRowNumber, inComponent: 0, animated: true)
        }
        
        if eventType == nil {
            eventType = "party"
        }
        
        
        
        
        
    }
    
    // MARK: TextField editing state save for textField options
    @IBAction func textFieldEditingEnded(_ sender: Any) {
        if eventEnum == .eventName {
            if let text = textField.text {
                eventName = text
            }
            
           
        }
   
        else if eventEnum == .eventType {
            if let eventTypeTest = textField.text {
                eventType = eventTypeTest
            }
           
        }
        else if eventEnum == .eventLocation {
            if let eventLocationTest = textField.text {
                eventLocation = eventLocationTest
            }
           
        }
        else if eventEnum == .password {
            if let passwordTest = textField.text {
                password = passwordTest
            }
            
           
            
            print(eventName)
            print(eventDescription)
            print(eventLocation)
            print(eventType)
            print(password)
            print(startTime)
            print(endTime)
            
        } else {
            // Navigate to add event check model
            
        }
    }
    
    //MARK: Pickerview Logic
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        eventType = events[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return events.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return events[row]
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    //MARK: Limit Character Count
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 25
    }
    
    
    
   
    
    
    
}
