//
//  CustomDateClass.swift
//  WSUStudentEvents
//
//  Created by Colin Warn on 8/4/17.
//  Copyright © 2017 Colin Warn. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    func crimson() -> UIColor {
        return UIColor(colorLiteralRed: 227, green: 38, blue: 54, alpha: 1.0)
    }
}

class CustomDateClass {
    
    func formatDate(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +SSSS"
        print(dateString)
        
        let d1 = dateString.replacingOccurrences(of: "Optional", with: "")
        let d2 = d1.replacingOccurrences(of: "(", with: "")
        let d3 = d2.replacingOccurrences(of: ")", with: "")
        print(d3)
        let date = dateFormatter.date(from: d3)
        
        
        print(date)
        dateFormatter.dateFormat = "MM/dd/yy HH:mm"
        
        
        let returnDate = dateFormatter.string(from: date!)
        print(returnDate)
        return returnDate
    }
    
    func formatStringToDate(string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +SSSS"
        
        
        let d1 = string.replacingOccurrences(of: "Optional", with: "")
        let d2 = d1.replacingOccurrences(of: "(", with: "")
        let d3 = d2.replacingOccurrences(of: ")", with: "")
        print(d3)
        let date = dateFormatter.date(from: d3)
        return date!
    }
    
    func formatStringToSmallDate(string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy HH:mm"
        
        
        let d1 = string.replacingOccurrences(of: "Optional", with: "")
        let d2 = d1.replacingOccurrences(of: "(", with: "")
        let d3 = d2.replacingOccurrences(of: ")", with: "")
        print(d3)
        let date = dateFormatter.date(from: d3)
        return date!
    }
}
