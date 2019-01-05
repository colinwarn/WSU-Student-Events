//
//  FAQViewController.swift
//  WSUStudentEvents
//
//  Created by Colin Warn on 9/2/17.
//  Copyright © 2017 Colin Warn. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    

}
