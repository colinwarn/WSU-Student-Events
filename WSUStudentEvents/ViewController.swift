//
//  ViewController.swift
//  WSUStudentEvents
//
//  Created by Colin Warn on 7/15/17.
//  Copyright © 2017 Colin Warn. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating, GADBannerViewDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!
    
   
    
    // Firebase init
    var ref: DatabaseReference!
    
    var events: [EventData] = []
    
    var filteredEvents = [EventData]()
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    var refresher: UIRefreshControl!
    
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Get event data
        loadFirebaseData()
        
        
        //IAP Check
        
        let removeAdsPurchased = defaults.bool(forKey: "nonConsumablePurchaseMade")
            
        
       if removeAdsPurchased == true {
            bannerView.removeFromSuperview()
            tableViewTopConstraint.constant = 0
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       
        
        
        
        
        // Admob
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-9625532846698161/1648465466"
        bannerView.rootViewController = self
        bannerView.load(request)
        
        // Refresh Controller
        
        refresher = UIRefreshControl()
        
        //tableView.contentInset = UIEdgeInsets(top: 20.0, left: 0, bottom: 0, right: 0)
        tableView.addSubview(refresher)
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.tintColor = UIColor.gray
        refresher.addTarget(self, action: #selector(ViewController.loadFirebaseData), for: .valueChanged)
        
        // Search Controller Filters
        searchController.searchBar.scopeButtonTitles = ["All","party", "hangout", "recreation", "event", "other"]
        searchController.searchBar.tintColor = UIColor().crimson()
        
        
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        
        //MARK: Search controller initialization
        searchController.searchResultsUpdater = self
        
        searchController.dimsBackgroundDuringPresentation = false
        
        tableView.tableHeaderView = searchController.searchBar
        
        // Remove keyboard on tap
                
        
        
        // Change Navbar Title to White
        self.navBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        
        
       
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchController.isActive {
            return 44
        }
        else {
            return 0
        }
        
        
    }
    
    
    func loadFirebaseData() {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy HH:mm"
        let currentDate = formatter.string(from: date)
        print(currentDate)
        
        events.removeAll()
        //Unpack blocked events
        var blockedEvents: [String] = []
        
        if let previousArray = self.defaults.stringArray(forKey: "blockedEventsArray") {
            blockedEvents = previousArray
            
        }
        events.removeAll()
        
        let event = Database.database().reference().observeSingleEvent(of: DataEventType.value, with: { snapshot in
            print(snapshot.childrenCount) // I got the expected number of items
            for eventName in snapshot.children.allObjects as! [DataSnapshot] {
                for name in eventName.children.allObjects as! [DataSnapshot] {
                    // Change event key name
                    if name.key == "event" {
                        print(name.value)
                        var newEvent = EventData()
                        for child in name.children.allObjects as! [DataSnapshot] {
                            
                            
                            if child.key == "description" {
                                newEvent.description = child.value as! String
                                
                            }
                            
                            if child.key == "endTime" {
                                
                                let thisEndTime = child.value as! String
                                print(thisEndTime)
                                let formattedEndTime = CustomDateClass().formatDate(dateString: thisEndTime)
                                newEvent.endTime = formattedEndTime
                            }
                            
                            if child.key == "eventName" {
                                newEvent.eventName = child.value as! String
                                
                            }
                            
                            if child.key == "eventType" {
                                newEvent.eventType = child.value as! String
                                
                            }
                            
                            if child.key == "location" {
                                newEvent.location = child.value as! String
                                
                            }
                            
                            if child.key == "password" {
                                
                                newEvent.password = child.value as! String
                                
                            }
                            
                            if child.key == "startTime" {
                                let thisStartTime = child.value as! String
                                let formattedStartTime = CustomDateClass().formatDate(dateString: thisStartTime)
                                newEvent.startTime = formattedStartTime
                            }
                            
                            if child.key == "whosGoingArray" {
                                
                                
                                for each in child.value as! [String]{
                                    print(type(of: each))
                                    
                                    
                                    newEvent.whosGoing.append(each)
                                    
                                }
                                
                                
                                
                            }
                            
                            
                            
                            
                        }
                        
                        
                        self.events.append(newEvent)
                        print("EVENTLIST")
                        print(self.events)
                        
                        print("EVENTS")
                        
                        //Sort event by date
                        self.events = self.events.sorted(by: { $0.startTime < $1.startTime })
                        
                        //MARK: Remove events before current date
                        
                        
                        // Remove blocked events
                        var blockIndex = 0
                        for i in self.events {
                            
                            
                            if blockedEvents.contains(i.eventName) {
                                print("removing blocked event")
                                self.events.remove(at: blockIndex)
                            
                            }
                            
                           
                           
                            
                            
                            blockIndex += 1
                            
                        }

                        
                        var indexCount = 0
                        var tempArrayIndex: [Int] = []
                        for i in self.events {
                            print(i.endTime)
                            //            let endTime = CustomDateClass().formatStringToSmallDate(string: i.endTime)
                            //
                            
                            // If date start time is past current one, move to bottom
                            let startTimeIsLater: Bool = i.startTime < currentDate
                            
                            
                            
                            let endTimeIsLater: Bool = i.endTime < currentDate
                            if endTimeIsLater {
                                print("removing")
                                print(i)
                                self.events.remove(at: indexCount)
                            }
                            
                            if startTimeIsLater {
                                tempArrayIndex.append(indexCount)
                            }
                            
                            indexCount += 1
                        }
                        
                        
                       
                        
                    }
                }
            }
            
            
            // MARK: If date start time is past current one, move to bottom
            
            let indexCount = 0
            var tempArrayIndex: [Int] = []
            for i in self.events {
                print(i.endTime)
                //            let endTime = CustomDateClass().formatStringToSmallDate(string: i.endTime)
                //
                
                
                let startTimeIsLater: Bool = i.startTime < currentDate
                
                
                
                let endTimeIsLater: Bool = i.endTime < currentDate
                if endTimeIsLater {
                    print("removing")
                    print(i)
                    self.events.remove(at: indexCount)
                }
                
                if startTimeIsLater {
                    tempArrayIndex.append(indexCount)
                }
            }

            //  For event start dates, move to bottom
            
            print(tempArrayIndex)
            for i in tempArrayIndex {
                let tempEventData : EventData = self.events[i]
                self.events.remove(at: i)
                self.events.append(tempEventData)
            }

            
            
            self.tableView.numberOfRows(inSection: self.events.count)
            print("EVENT COUNT")
            print(self.events.count)
            self.tableView.reloadData()
            self.refresher.endRefreshing()
            
        })
        
        
        
    }
    
    
    //MARK: Segue To Event Add Controller
    
    @IBAction func addEventPressed(_ sender: Any) {
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "AddEventModelVC") as! ViewController
//        self.present(nextViewController, animated: true, completion: nil)
    }
    
    //MARK: Search View Controller Helper and Delegate Methods
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        
        filteredEvents = events.filter { event in
            if searchController.searchBar.text != "" {
                let categoryMatch = (scope == "All") || (event.eventType == scope)
                print(filteredEvents.count)
                return categoryMatch && event.eventName.lowercased().contains(searchText.lowercased())
                
            } else if searchController.searchBar.text == "" && scope == "All" {
                let categoryMatch = (scope == "All")
                print(filteredEvents.count)
                return categoryMatch
            }
            else {
                
                let categoryMatch = (event.eventType == scope)
                print(filteredEvents.count)
                return categoryMatch
            }
            //MARK: Sort events by date, remove if after previous date
        
        
            
            
        }
        
        
        tableView.reloadData()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
        
        
        
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
//        UIView.animate(withDuration: 0.5, animations: {
//            self.tableViewTopConstraint.constant = 50.0
//            
//        })
//        tableView.beginUpdates()
//        tableView.endUpdates()
        
        
        
        UIView.animate(withDuration: 1, animations: {
            self.navBar.alpha = 0.1
        })
        navBar.isHidden = true
        
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //Move cells up
        //        UIView.animate(withDuration: 0.5, animations: {
//            self.tableViewTopConstraint.constant = 0.0
//        })
//        tableView.beginUpdates()
//        tableView.endUpdates()
        
        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navBar.isHidden = false
        UIView.animate(withDuration: 1, animations: {
            self.navBar.alpha = 1
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        filterContentForSearchText(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
        
        
    }
    
    
    //Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Check if controller is active, and search bar has text or another button besides "All" Selected
        if (searchController.isActive) {
            
            return filteredEvents.count
        }
        
        else {
            
            
            
           
            
            return events.count
        }
        
        
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCell
        let event: EventData
        
        
        
        
        
        
        if searchController.isActive{
            print("Filtered Events")
            print(filteredEvents)
            self.tableView.numberOfRows(inSection: self.filteredEvents.count)
            
            print("EVENT COUNT")
            print(self.filteredEvents.count)
            
            
            event = filteredEvents[indexPath.row]
        }

        else {
            event = events[indexPath.row]
        }
        // Event name
        cell.eventNameLbl.text = event.eventName
        
        // Event type
        switch (event.eventType) {
        case "party":
            cell.eventTypeLbl.text = "🎉"
        case "event":
            cell.eventTypeLbl.text = "🎪"
        case "hangout":
            cell.eventTypeLbl.text = "😎"
        case "recreation":
            cell.eventTypeLbl.text = " 🚴🏽‍♀️"
        case "other":
            cell.eventTypeLbl.text = " 👩🏽‍🏫"
        default:
            break
        }
        
        // Location
        cell.locationLbl.text = event.location
        
        // Start time
        
        var time = event.startTime
        
        if time.isEmpty {
            time = "N/A"
            
        }
        
        cell.timeLbl.text = time
        
        // isLocked
        if event.password != "" {
            cell.isLockedLbl.text = "🔒"
            cell.password = event.password
            
        } else {
            cell.isLockedLbl.text = ""
        }
  
        // Format start and end dates
        
        
       
        return cell
        
    }
   
    
    @IBAction func logoutPressed(_ sender: Any) {
        let logoutController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { (alert) in
            // Navigate to login screen
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.defaults.set(false, forKey: "isLoggedIn")
            self.present(nextViewController, animated:true, completion: nil)
            

        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        logoutController.addAction(ok)
        logoutController.addAction(cancel)
        present(logoutController, animated: true, completion: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        
        
        self.performSegue(withIdentifier: "cellSegue", sender: self)
        

        
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        
        //MARK: Check For Password
        let passwordCheckController = UIAlertController(title: "Enter Password", message: "", preferredStyle: UIAlertControllerStyle.alert)
        var correctPassword = false
        if identifier == "cellSegue"{
            if let cell = sender as? EventCell {
                if cell.password != "" && correctPassword == false{
                    passwordCheckController.addAction(UIAlertAction(title: "Enter", style: .default, handler: {
                        alert -> Void in
                        let passwordTextField = passwordCheckController.textFields![0] as UITextField
                        
                        
                        if passwordTextField.text == cell.password {
                            correctPassword = true
                            self.performSegue(withIdentifier: "cellSegue", sender: self)
                            
                        } else {
                            let tryAgainAC = UIAlertController(title: "Wrong Password", message: "Wrong assword, please try again.", preferredStyle: UIAlertControllerStyle.alert)
                            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                                self.present(passwordCheckController, animated: true, completion: nil)
                                
                            })
                            tryAgainAC.addAction(ok)
                            self.present(tryAgainAC, animated: true, completion: nil)
                            
                            
                            }
                        }))
                    
                    passwordCheckController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
                        textField.placeholder = "Password"
                    })
                    
                    passwordCheckController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
                        passwordCheckController.dismiss(animated: true, completion: nil)
                    }))
                    
                    present(passwordCheckController, animated: true, completion: nil)
                } else {
                    correctPassword = true
                }

            }
        } else {
            correctPassword = true
        }
       
        
        return correctPassword
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let event: EventData
        
        
        
        if segue.identifier == "cellSegue" {
            
            if let nextViewController = segue.destination as? EventInfoVC {
                if let indexPath = tableView.indexPathForSelectedRow {
                    if searchController.isActive {
                        event = filteredEvents[indexPath.row]
                    } else {
                        event = events[indexPath.row]
                    }
                    print(events[indexPath.row].eventName)
                    
                    // Allows the user to hide events
                    defaults.set(event.eventName, forKey: "currentlySelectedEvent")
                    nextViewController.titleEventInfo = event.eventName
                    nextViewController.typEventInfo = event.eventType
                    nextViewController.startDate = event.startTime
                    nextViewController.endDate = event.endTime
                    nextViewController.thisEventDescription = event.description
                    nextViewController.eventLocation = event.location
                }
            }
            
        }
    }
    
    
    
    
    

    


}

