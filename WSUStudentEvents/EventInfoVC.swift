//
//  EventInfoVC.swift
//  WSUStudentEvents
//
//  Created by Colin Warn on 8/3/17.
//  Copyright © 2017 Colin Warn. All rights reserved.
//

import UIKit

class EventInfoVC: UIViewController {

    var titleEventInfo: String?
    var typEventInfo: String?
    var startDate: String?
    var endDate: String?
    var thisEventDescription: String?
    var eventLocation: String?
    
    @IBOutlet weak var titleOutlet: UILabel!
    @IBOutlet weak var typeOutlet: UILabel!
    @IBOutlet weak var locationOutlet: UILabel!
    @IBOutlet weak var timeDateOulet: UILabel!
    @IBOutlet weak var descriptionTextViewOutlet: UITextView!
    let defaults = UserDefaults.standard
    var tempArray: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("DATES")
        
        //Unwrap dates
        if let unEndDate = endDate, let unStartDate = startDate{
            
            timeDateOulet.text = "\(unStartDate) - \(unEndDate)"
        }

        
        
        titleOutlet.text = titleEventInfo
        typeOutlet.text = typEventInfo
        
        locationOutlet.text = eventLocation
        descriptionTextViewOutlet.text = thisEventDescription
        
        // Do any additional setup after loading the view.
    }

    @IBAction func backPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func actionHelper(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default) { (action) in
            // Get previous blocked array, add new event to block
            
            guard let blockedEvent = self.defaults.object(forKey: "currentlySelectedEvent") as? String else {
                return
            }
            
            guard var previousArray = self.defaults.stringArray(forKey: "blockedEventsArray") else {
                
                self.tempArray.append(blockedEvent)
                self.defaults.set(self.tempArray, forKey: "blockedEventsArray")
                return
            }
            
            previousArray.append(blockedEvent)
            self.defaults.set(previousArray, forKey: "blockedEventsArray")
            
            
            self.dismiss(animated: true, completion: nil)
            
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        controller.addAction(actionOk)
        controller.addAction(cancel)
        self.present(controller, animated: true, completion: nil)
    }
  
    @IBAction func reportEventPressed(_ sender: Any) {
        actionHelper(title: "Report Event", message: "Do you really want to report this event?")
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
